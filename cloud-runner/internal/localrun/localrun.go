// Package localrun executes regression test cases locally by shelling out to
// tfpcli and tfp. It is the Go equivalent of the legacy run_tests.sh script.
package localrun

import (
	"context"
	"time"

	"cloud-runner/internal/config"
	"cloud-runner/internal/index"
	"cloud-runner/internal/testcase"
)

// PhaseResult captures the outcome of one evaluation phase.
type PhaseResult struct {
	Expected string
	Status   string // PASS / FAIL / SKIP / ERROR
	Note     string
}

// TestResult is the full outcome for one test case across all three levels.
type TestResult struct {
	TestID     string
	PolicyTest PhaseResult
	Plan       PhaseResult
	Apply      PhaseResult
	Duration   time.Duration
}

// Overall returns PASS only if every non-skipped phase passed.
func (r *TestResult) Overall() string {
	for _, p := range []PhaseResult{r.PolicyTest, r.Plan, r.Apply} {
		if p.Status == "FAIL" || p.Status == "ERROR" {
			return "FAIL"
		}
	}
	return "PASS"
}

// Runner executes test cases locally.
type Runner struct {
	cfg        *config.Config
	resultsDir string
}

// New creates a Runner. resultsDir is where per-test log files are written.
func New(cfg *config.Config, resultsDir string) *Runner {
	return &Runner{cfg: cfg, resultsDir: resultsDir}
}

// Run executes all three levels for a single test case.
func (r *Runner) Run(ctx context.Context, tc testcase.TestCase) *TestResult {
	start := time.Now()
	res := &TestResult{TestID: tc.ID}

	// ── Level 1: tfpcli test / validate ──────────────────────────────────────
	res.PolicyTest = r.RunPolicyTest(ctx, tc)

	// ── Level 2: tfp plan ────────────────────────────────────────────────────
	if r.cfg.SkipTFP || !tc.HasMainTF || tc.ExpectPlan == index.ExpectNA {
		reason := "N/A"
		if r.cfg.SkipTFP {
			reason = "--skip-tfp"
		}
		res.Plan = PhaseResult{Expected: tc.ExpectPlan, Status: "SKIP", Note: reason}
	} else {
		res.Plan = r.runTFPPlan(ctx, tc)
	}

	// ── Level 3: tfp apply ───────────────────────────────────────────────────
	if r.cfg.SkipTFP || !tc.HasMainTF || tc.ExpectApply == index.ExpectNA {
		reason := "N/A"
		if r.cfg.SkipTFP {
			reason = "--skip-tfp"
		}
		res.Apply = PhaseResult{Expected: tc.ExpectApply, Status: "SKIP", Note: reason}
	} else {
		res.Apply = r.runTFPApply(ctx, tc)
	}

	res.Duration = time.Since(start)
	return res
}
