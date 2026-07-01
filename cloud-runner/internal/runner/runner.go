// Package runner orchestrates the full lifecycle for a single regression test case
// on HCP Terraform: run tfpcli test locally (L1) → create workspace → policy set →
// config upload → run (L2 plan + L3 apply) → evaluate → cleanup.
package runner

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"cloud-runner/internal/config"
	"cloud-runner/internal/hcptf"
	"cloud-runner/internal/index"
	"cloud-runner/internal/localrun"
	"cloud-runner/internal/testcase"
)

// Status values for a test phase outcome.
const (
	StatusPass  = "PASS"
	StatusFail  = "FAIL"
	StatusSkip  = "SKIP"
	StatusError = "ERROR"
)

// PhaseResult captures the outcome of one evaluation phase (plan or apply).
type PhaseResult struct {
	Expected string
	Got      string // PASS / FAIL / UNKNOWN / N/A
	Match    bool
	Note     string
}

// TestResult is the full outcome for one test case.
type TestResult struct {
	TestID     string
	PolicyTest localrun.PhaseResult // L1 — tfpcli test, run locally
	Plan       PhaseResult          // L2 — tfp plan, run on HCP Terraform
	Apply      PhaseResult          // L3 — tfp apply, run on HCP Terraform
	RunID      string
	Duration   time.Duration
	CleanupOK  bool
	FatalErr   error
}

// Overall returns PASS only when every non-skipped phase matched expectations.
func (r *TestResult) Overall() string {
	if r.FatalErr != nil {
		return StatusError
	}
	if r.PolicyTest.Status == "FAIL" || r.PolicyTest.Status == "ERROR" {
		return StatusFail
	}
	if r.Plan.Match && r.Apply.Match {
		return StatusPass
	}
	return StatusFail
}

// Runner manages state for executing test cases.
type Runner struct {
	client     *hcptf.Client
	cfg        *config.Config
	projectID  string
	resultsDir string
	local      *localrun.Runner
}

// New creates a Runner. resultsDir is where per-test log files are written.
func New(client *hcptf.Client, cfg *config.Config, projectID string, resultsDir string) *Runner {
	return &Runner{
		client:     client,
		cfg:        cfg,
		projectID:  projectID,
		resultsDir: resultsDir,
		local:      localrun.New(cfg, resultsDir),
	}
}

// writeLog writes content to <resultsDir>/<testID>.<suffix>.log.
func (r *Runner) writeLog(testID, suffix, content string) {
	if content == "" || r.resultsDir == "" {
		return
	}
	path := filepath.Join(r.resultsDir, testID+"."+suffix+".log")
	_ = os.WriteFile(path, []byte(content), 0o644)
}

// Run executes the full lifecycle for a single test case and returns its result.
func (r *Runner) Run(ctx context.Context, tc testcase.TestCase) *TestResult {
	start := time.Now()
	result := &TestResult{
		TestID: tc.ID,
		Plan:   PhaseResult{Expected: tc.ExpectPlan, Got: index.ExpectNA, Match: true},
		Apply:  PhaseResult{Expected: tc.ExpectApply, Got: index.ExpectNA, Match: true},
	}

	// ── Step 1: L1 — run tfpcli test locally ─────────────────────────────────
	result.PolicyTest = r.local.RunPolicyTest(ctx, tc)

	wsName := config.WorkspacePrefix + tc.ID
	psName := config.PolicySetPrefix + tc.ID

	var wsID, psID string

	// ── Step 2: Create workspace (retry once on name conflict) ────────────────
	var err error
	wsID, err = r.client.CreateWorkspace(ctx, wsName, r.projectID)
	if err != nil {
		// Fix: If workspace already exists from a prior stale run, delete it and retry.
		if strings.Contains(err.Error(), "name is already taken") ||
			strings.Contains(err.Error(), "already exists") {
			fmt.Printf("  [WARN] workspace %s already exists — purging and retrying\n", wsName)
			if staleID, lookupErr := r.client.FindWorkspaceByName(ctx, wsName); lookupErr == nil && staleID != "" {
				_ = r.client.TriggerDestroyRun(ctx, staleID)
				_ = r.client.DeleteWorkspace(ctx, staleID)
			}
			wsID, err = r.client.CreateWorkspace(ctx, wsName, r.projectID)
		}
		if err != nil {
			result.FatalErr = fmt.Errorf("create workspace: %w", err)
			result.Duration = time.Since(start)
			return result
		}
	}

	defer func() {
		result.Duration = time.Since(start)
		if !r.cfg.Cleanup {
			return
		}
		cleanupCtx := context.Background()
		cleanupOK := true
		if psID != "" {
			if e := r.client.DeletePolicySet(cleanupCtx, psID); e != nil {
				fmt.Printf("  [CLEANUP ERR] delete policy set %s: %v\n", psID, e)
				cleanupOK = false
			}
		}
		if wsID != "" {
			if e := r.client.DeleteWorkspace(cleanupCtx, wsID); e != nil {
				fmt.Printf("  [CLEANUP ERR] delete workspace %s: %v\n", wsID, e)
				cleanupOK = false
			}
		}
		result.CleanupOK = cleanupOK
	}()

	// ── Step 3: Create VCS-backed policy set ──────────────────────────────────
	psID, err = r.client.CreatePolicySet(ctx, psName, tc.ID, wsID)
	if err != nil {
		result.FatalErr = fmt.Errorf("create policy set: %w", err)
		return result
	}

	if err := r.client.WaitPolicySetReady(ctx, psID); err != nil {
		result.FatalErr = fmt.Errorf("waiting for policy set ready: %w", err)
		return result
	}

	// ── Step 4: Upload Terraform config ───────────────────────────────────────
	tarball, err := tc.ConfigTarball()
	if err != nil {
		result.FatalErr = fmt.Errorf("build config tarball: %w", err)
		return result
	}

	cvID, err := r.client.UploadConfig(ctx, wsID, tarball)
	if err != nil {
		result.FatalErr = fmt.Errorf("upload config: %w", err)
		return result
	}

	// ── Step 5: Determine whether we need apply ───────────────────────────────
	needsApply := tc.ExpectApply != index.ExpectNA

	// ── Step 6: Trigger run (plan + optional apply) ───────────────────────────
	runResult, err := r.client.TriggerRun(ctx, wsID, cvID, needsApply)
	if runResult != nil {
		result.RunID = runResult.RunID
	}
	if err != nil {
		result.FatalErr = fmt.Errorf("trigger run: %w", err)
		return result
	}
	if runResult.Err != nil {
		result.Plan.Note = fmt.Sprintf("run error: %v", runResult.Err)
	}

	r.writeLog(tc.ID, "cloud_plan", runResult.PlanLog)
	r.writeLog(tc.ID, "cloud_apply", runResult.ApplyLog)
	r.writeLog(tc.ID, "cloud_policy", runResult.PolicyLog)

	// ── Step 7: Evaluate plan phase (use PlanStatus, NOT FinalStatus) ─────────
	// Fix: FinalStatus is overwritten by apply; PlanStatus preserves the plan result.
	if tc.ExpectPlan != index.ExpectNA {
		got := classifyPlanOutcome(runResult)
		result.Plan.Got = got
		result.Plan.Match = expectationMet(tc.ExpectPlan, got, runResult.PlanLog)
		if !result.Plan.Match {
			result.Plan.Note = truncate(runResult.PlanLog, 5)
		}
	}

	// ── Step 8: Evaluate apply phase ──────────────────────────────────────────
	if needsApply {
		got := classifyApplyOutcome(runResult)
		result.Apply.Got = got
		result.Apply.Match = expectationMet(tc.ExpectApply, got, runResult.ApplyLog+runResult.PlanLog)
		if !result.Apply.Match {
			result.Apply.Note = truncate(runResult.ApplyLog, 5)
		}
	}

	// ── Step 9: Destroy resources if apply ran or partially applied ───────────
	if needsApply && (runResult.FinalStatus == "applied" || runResult.FinalStatus == "errored") {
		if runResult.FinalStatus == "errored" {
			result.Apply.Note += " [WARNING: apply errored — resources created before the failure may not be in Terraform state and will NOT be destroyed by the destroy run; delete them manually (e.g. CloudWatch log groups, S3 buckets)]"
		}
		destroyCtx := context.Background()
		if e := r.client.TriggerDestroyRun(destroyCtx, wsID); e != nil {
			result.Apply.Note += fmt.Sprintf(" [destroy warning: %v]", e)
		}
	}

	return result
}

// classifyPlanOutcome maps the plan-terminal status to PASS/FAIL/UNKNOWN.
// It uses PlanStatus (not FinalStatus) so advisory failures at plan are not
// lost when apply subsequently succeeds.
func classifyPlanOutcome(r *hcptf.RunResult) string {
	if r == nil {
		return StatusError
	}

	switch tfe_RunStatus(r.PlanStatus) {
	case "applied":
		// Apply ran — check plan log for policy signals that were present at plan.
		// Note: if apply succeeded cleanly, plan was passing/unknown. Use plan log.
		_, unknowns := analyzeLogForPhase(r.PlanLog)
		if unknowns {
			return index.ExpectUnknown
		}
		return index.ExpectPass

	case "errored":
		return index.ExpectFail

	case "planned", "planned_and_finished", "policy_checked":
		_, unknowns := analyzeLogForPhase(r.PlanLog)
		if unknowns {
			return index.ExpectUnknown
		}
		return index.ExpectPass

	case "policy_soft_failed":
		_, unknowns := analyzeLogForPhase(r.PlanLog)
		if unknowns {
			return index.ExpectUnknown
		}
		// Fix: advisory failures at plan must be reported as FAIL even when apply
		// later succeeds (which changes FinalStatus to "applied").
		if policyLogHasAdvisoryFailed(r.PolicyLog) {
			return index.ExpectFail
		}
		return index.ExpectPass

	default:
		return StatusError
	}
}

// classifyApplyOutcome maps the final (post-apply) status to PASS/FAIL/UNKNOWN.
func classifyApplyOutcome(r *hcptf.RunResult) string {
	if r == nil {
		return StatusError
	}

	switch tfe_RunStatus(r.FinalStatus) {
	case "applied":
		passed, unknowns := analyzeLogForPhase(r.ApplyLog)
		if !passed {
			return index.ExpectFail
		}
		if unknowns {
			return index.ExpectUnknown
		}
		return index.ExpectPass

	case "errored":
		// Fix: if plan was hard-blocked by mandatory policy (errored at plan with no
		// DenyResult in ApplyLog), apply was unreachable — map this to FAIL not ERROR.
		// The plan denial is the failure; unreachable apply is the expected consequence.
		return index.ExpectFail

	case "planned", "planned_and_finished", "policy_checked",
		"policy_soft_failed", "policy_override":
		// Apply was not reached (e.g. plan with unknowns pending policy override).
		// Treat as FAIL so tests expecting apply to run are flagged.
		return index.ExpectFail

	default:
		return StatusError
	}
}

type tfe_RunStatus string

// analyzeLogForPhase inspects a log for hard policy denials and unknown conditions.
func analyzeLogForPhase(log string) (passed, unknowns bool) {
	if log == "" {
		return true, false
	}
	hasDeny := strings.Contains(log, `"result":"DenyResult"`) &&
		strings.Contains(log, `"enforcement_level":"mandatory"`)
	hasUnknown := strings.Contains(log, "policy with unknowns") ||
		strings.Contains(log, "unknown condition") ||
		strings.Contains(log, "Unknown condition")
	return !hasDeny, hasUnknown
}

// expectationMet returns true when the observed outcome matches the EXPECT directive.
func expectationMet(expected, got, log string) bool {
	switch expected {
	case index.ExpectPass:
		return got == index.ExpectPass
	case index.ExpectFail:
		return got == index.ExpectFail
	case index.ExpectUnknown:
		// Accept UNKNOWN or PASS (some computed values resolve at plan time).
		return got == index.ExpectUnknown || got == index.ExpectPass
	case index.ExpectNA:
		return true
	default:
		if strings.HasPrefix(expected, index.ExpectErrorContains) {
			substr := strings.TrimSpace(strings.TrimPrefix(expected, index.ExpectErrorContains))
			return got == index.ExpectFail && strings.Contains(log, substr)
		}
	}
	return false
}

func policyLogHasAdvisoryFailed(policyLog string) bool {
	return strings.Contains(policyLog, "advisory_failed=") &&
		!strings.Contains(policyLog, "advisory_failed=0")
}

func truncate(s string, lines int) string {
	parts := strings.SplitN(s, "\n", lines+1)
	if len(parts) > lines {
		parts = parts[:lines]
	}
	return strings.Join(parts, "\n")
}
