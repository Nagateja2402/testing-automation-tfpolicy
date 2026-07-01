// Package runner orchestrates the full lifecycle for a single regression test case
// on HCP Terraform: run tfpcli test locally (L1) → create workspace → policy set →
// config upload → run (L2 plan + L3 apply) → evaluate → cleanup.
package runner

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
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
		if isNameConflict(err) {
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
		// psID is normally already deleted before the destroy run (see Step 9);
		// this is a fallback for early-return paths where Step 9 was not reached.
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
		// Detach the policy set BEFORE destroying. A destroy is a "delete"
		// operation, so a delete-scoped mandatory policy (e.g. OP-DEL-*) would
		// block the destroy run and orphan the resources. Deleting the policy
		// set first lets the destroy proceed unimpeded.
		if r.cfg.Cleanup && psID != "" {
			if e := r.client.DeletePolicySet(destroyCtx, psID); e != nil {
				fmt.Printf("  [CLEANUP ERR] delete policy set %s: %v\n", psID, e)
			} else {
				psID = ""
			}
		}
		if e := r.client.TriggerDestroyRun(destroyCtx, wsID); e != nil {
			result.Apply.Note += fmt.Sprintf(" [destroy warning: %v]", e)
		}
	}

	return result
}

// policyStageCounts holds the aggregated result-count for one policy
// evaluation stage (Init / Plan / Apply) parsed from RunResult.PolicyLog.
type policyStageCounts struct {
	found           bool
	passed          int
	advisoryFailed  int
	mandatoryFailed int
	errored         int
	unknown         int
}

// Matches a PolicyLog stage summary line, capturing StageType (group 1,
// case-insensitive) and the five counts, e.g.:
//	── Plan stage (failed): passed=0 advisory_failed=0 mandatory_failed=1 errored=0 unknown=0
var stageHeaderRe = regexp.MustCompile(
	`(?i)──\s+(\w+)\s+stage\s+\([^)]*\):\s+passed=(\d+)\s+advisory_failed=(\d+)\s+mandatory_failed=(\d+)\s+errored=(\d+)\s+unknown=(\d+)`,
)

// policyStage reads the named stage's counts from PolicyLog. The authoritative
// policy verdict lives ONLY here — the Terraform plan/apply logs carry
// resource-change events, never policy results. found=false when stage absent.
func policyStage(policyLog, stage string) policyStageCounts {
	var out policyStageCounts
	if policyLog == "" {
		return out
	}
	for _, m := range stageHeaderRe.FindAllStringSubmatch(policyLog, -1) {
		if !strings.EqualFold(m[1], stage) {
			continue
		}
		out.found = true
		out.passed = atoiSafe(m[2])
		out.advisoryFailed = atoiSafe(m[3])
		out.mandatoryFailed = atoiSafe(m[4])
		out.errored = atoiSafe(m[5])
		out.unknown = atoiSafe(m[6])
		return out
	}
	return out
}

func atoiSafe(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}

// classifyPolicyStage maps one stage's counts to PASS/FAIL/UNKNOWN. Only a
// mandatory failure or an errored policy blocks (FAIL); advisory failures are
// non-blocking warnings (HCP marks the stage passed) so they do not fail the
// stage. A pending unknown is UNKNOWN; otherwise PASS.
func classifyPolicyStage(c policyStageCounts) string {
	if c.mandatoryFailed > 0 || c.errored > 0 {
		return index.ExpectFail
	}
	if c.unknown > 0 {
		return index.ExpectUnknown
	}
	return index.ExpectPass
}

// classifyPlanOutcome maps the plan phase to PASS/FAIL/UNKNOWN. An Init-stage
// failure (module_policy / provider_policy evaluate at init) blocks and cancels
// the plan, so it is checked first; otherwise the Plan stage governs, falling
// back to run status only when no policy stage is present.
func classifyPlanOutcome(r *hcptf.RunResult) string {
	if r == nil {
		return StatusError
	}

	if init := policyStage(r.PolicyLog, "init"); init.found {
		if v := classifyPolicyStage(init); v != index.ExpectPass {
			return v
		}
	}

	if stage := policyStage(r.PolicyLog, "plan"); stage.found {
		return classifyPolicyStage(stage)
	}

	switch tfe_RunStatus(r.PlanStatus) {
	case "errored":
		return index.ExpectFail
	case "applied", "planned", "planned_and_finished",
		"policy_checked", "policy_soft_failed", "policy_override":
		return index.ExpectPass
	default:
		return StatusError
	}
}

// classifyApplyOutcome maps the apply phase to PASS/FAIL/UNKNOWN. When the plan
// blocks apply, the Apply stage is unreachable with zero counts, so the run
// status decides whether apply actually completed.
func classifyApplyOutcome(r *hcptf.RunResult) string {
	if r == nil {
		return StatusError
	}

	switch tfe_RunStatus(r.FinalStatus) {
	case "applied":
		if stage := policyStage(r.PolicyLog, "apply"); stage.found {
			return classifyPolicyStage(stage)
		}
		return index.ExpectPass

	case "errored":
		// Apply errored, or plan was hard-blocked so apply was unreachable — both FAIL.
		return index.ExpectFail

	case "planned_and_finished":
		// A plan with zero resource changes ends here without an apply phase. If
		// policy passed at plan, apply is vacuously satisfied → PASS; a plan-stage
		// policy failure/unknown still governs the outcome.
		if stage := policyStage(r.PolicyLog, "plan"); stage.found {
			return classifyPolicyStage(stage)
		}
		if planHadNoChanges(r.PlanLog) {
			return index.ExpectPass
		}
		return index.ExpectFail

	case "planned", "policy_checked",
		"policy_soft_failed", "policy_override":
		// Apply was reachable but never confirmed/ran; flag tests that expected it.
		return index.ExpectFail

	default:
		return StatusError
	}
}

// planHadNoChanges reports whether the plan produced zero resource changes,
// which drives a run to planned_and_finished with no apply phase. Keys on the
// Terraform JSON change_summary line: "changes":{"add":0,...,"operation":"plan"}.
func planHadNoChanges(planLog string) bool {
	return strings.Contains(planLog, `"add":0,"change":0,"import":0,"remove":0`) ||
		strings.Contains(planLog, "Plan: 0 to add, 0 to change, 0 to destroy")
}

type tfe_RunStatus string

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

// isNameConflict reports a duplicate-workspace-name 422. TFE phrases it as
// "...Validation failed: Name has already been taken"; older/self-hosted
// variants use "name is already taken" or "already exists". Case-insensitive.
func isNameConflict(err error) bool {
	if err == nil {
		return false
	}
	msg := strings.ToLower(err.Error())
	return strings.Contains(msg, "has already been taken") ||
		strings.Contains(msg, "name is already taken") ||
		strings.Contains(msg, "already exists")
}

func truncate(s string, lines int) string {
	parts := strings.SplitN(s, "\n", lines+1)
	if len(parts) > lines {
		parts = parts[:lines]
	}
	return strings.Join(parts, "\n")
}
