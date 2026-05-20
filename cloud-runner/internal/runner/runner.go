// Package runner orchestrates the full lifecycle for a single regression test case
// on HCP Terraform: create workspace → policy set → config upload → run → evaluate → cleanup.
package runner

import (
	"context"
	"fmt"
	"strings"
	"time"

	"cloud-runner/internal/config"
	"cloud-runner/internal/hcptf"
	"cloud-runner/internal/index"
	"cloud-runner/internal/testcase"
)

// Status values for a test phase outcome.
const (
	StatusPass    = "PASS"
	StatusFail    = "FAIL"
	StatusSkip    = "SKIP"
	StatusError   = "ERROR"
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
	TestID    string
	Plan      PhaseResult
	Apply     PhaseResult
	RunID     string
	Duration  time.Duration
	CleanupOK bool
	FatalErr  error
}

// Overall returns PASS if both phases matched expectations, FAIL otherwise.
func (r *TestResult) Overall() string {
	if r.FatalErr != nil {
		return StatusError
	}
	if r.Plan.Match && r.Apply.Match {
		return StatusPass
	}
	return StatusFail
}

// Runner manages state for executing test cases.
type Runner struct {
	client    *hcptf.Client
	cfg       *config.Config
	projectID string
}

// New creates a Runner.
func New(client *hcptf.Client, cfg *config.Config, projectID string) *Runner {
	return &Runner{client: client, cfg: cfg, projectID: projectID}
}

// Run executes the full lifecycle for a single test case and returns its result.
func (r *Runner) Run(ctx context.Context, tc testcase.TestCase) *TestResult {
	start := time.Now()
	result := &TestResult{
		TestID: tc.ID,
		Plan:   PhaseResult{Expected: tc.ExpectPlan, Got: index.ExpectNA, Match: true},
		Apply:  PhaseResult{Expected: tc.ExpectApply, Got: index.ExpectNA, Match: true},
	}

	wsName := config.WorkspacePrefix + tc.ID
	psName := config.PolicySetPrefix + tc.ID

	var wsID, psID string

	// ── Step 1: Create workspace ────────────────────────────────────────────
	var err error
	wsID, err = r.client.CreateWorkspace(ctx, wsName, r.projectID)
	if err != nil {
		result.FatalErr = fmt.Errorf("create workspace: %w", err)
		result.Duration = time.Since(start)
		return result
	}

	// Ensure cleanup runs even on failure.
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

	// ── Step 2: Create VCS-backed policy set ────────────────────────────────
	psID, err = r.client.CreatePolicySet(ctx, psName, tc.ID, wsID)
	if err != nil {
		result.FatalErr = fmt.Errorf("create policy set: %w", err)
		return result
	}

	// Wait for VCS ingestion to complete before triggering a run.
	if err := r.client.WaitPolicySetReady(ctx, psID); err != nil {
		result.FatalErr = fmt.Errorf("waiting for policy set ready: %w", err)
		return result
	}

	// ── Step 3: Upload Terraform config ─────────────────────────────────────
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

	// ── Step 4: Determine whether we need apply ──────────────────────────────
	needsApply := tc.ExpectApply != index.ExpectNA

	// ── Step 5: Trigger run (plan + optional apply) ──────────────────────────
	runResult, err := r.client.TriggerRun(ctx, wsID, cvID, needsApply)
	if runResult != nil {
		result.RunID = runResult.RunID
	}
	if err != nil {
		result.FatalErr = fmt.Errorf("trigger run: %w", err)
		return result
	}
	if runResult.Err != nil {
		// Non-fatal run error — still evaluate phases.
		result.Plan.Note = fmt.Sprintf("run error: %v", runResult.Err)
	}

	// ── Step 6: Evaluate plan phase ──────────────────────────────────────────
	if tc.ExpectPlan != index.ExpectNA {
		got := classifyRunOutcome(runResult, false)
		result.Plan.Got = got
		result.Plan.Match = expectationMet(tc.ExpectPlan, got, runResult.PlanLog)
		if !result.Plan.Match {
			result.Plan.Note = truncate(runResult.PlanLog, 5)
		}
	}

	// ── Step 7: Evaluate apply phase ─────────────────────────────────────────
	if needsApply {
		got := classifyRunOutcome(runResult, true)
		result.Apply.Got = got
		result.Apply.Match = expectationMet(tc.ExpectApply, got, runResult.ApplyLog+runResult.PlanLog)
		if !result.Apply.Match {
			result.Apply.Note = truncate(runResult.ApplyLog, 5)
		}
	}

	// ── Step 8: Destroy resources if apply ran ───────────────────────────────
	if needsApply && runResult.FinalStatus == "applied" {
		destroyCtx := context.Background()
		if e := r.client.TriggerDestroyRun(destroyCtx, wsID); e != nil {
			result.Apply.Note += fmt.Sprintf(" [destroy warning: %v]", e)
		}
	}

	return result
}

// classifyRunOutcome maps the hcptf.RunResult to PASS / FAIL / UNKNOWN
// for plan (applyPhase=false) or apply (applyPhase=true).
func classifyRunOutcome(r *hcptf.RunResult, applyPhase bool) string {
	if r == nil {
		return StatusError
	}

	log := r.PlanLog
	if applyPhase {
		log = r.ApplyLog
	}

	switch tfe_RunStatus(r.FinalStatus) {
	case "applied":
		// Apply succeeded.
		passed, unknowns := analyzeLogForPhase(log)
		if !passed {
			return index.ExpectFail
		}
		if unknowns && !applyPhase {
			return index.ExpectUnknown
		}
		return index.ExpectPass

	case "errored":
		// Could be a hard policy failure or an infra error (e.g. no AWS creds).
		// We treat it as FAIL from a policy perspective.
		return index.ExpectFail

	case "planned", "planned_and_finished", "policy_checked", "policy_soft_failed":
		// Plan completed; no hard-mandatory block.
		_, unknowns := analyzeLogForPhase(r.PlanLog)
		if unknowns {
			return index.ExpectUnknown
		}
		return index.ExpectPass

	default:
		return StatusError
	}
}

type tfe_RunStatus string

// analyzeLogForPhase is a local alias so this package doesn't import hcptf.
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

func truncate(s string, lines int) string {
	parts := strings.SplitN(s, "\n", lines+1)
	if len(parts) > lines {
		parts = parts[:lines]
	}
	return strings.Join(parts, "\n")
}
