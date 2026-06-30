// Package localrun executes regression test cases locally by shelling out to
// tfpcli and tfp. It is the Go equivalent of the legacy run_tests.sh script.
package localrun

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
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

// ── Level 1 ──────────────────────────────────────────────────────────────────

// RunPolicyTest runs the tfpcli test / validate step (Level 1) for a test case.
// It is exported so that cloud mode (runner package) can reuse it to run L1
// locally while L2/L3 execute on HCP Terraform.
func (r *Runner) RunPolicyTest(ctx context.Context, tc testcase.TestCase) PhaseResult {
	expected := tc.ExpectPolicyTest
	if expected == index.ExpectNA {
		return PhaseResult{Expected: expected, Status: "SKIP", Note: "N/A"}
	}

	if expected == index.ExpectValidationError {
		return r.runValidate(ctx, tc)
	}

	args := []string{"test",
		"--policies=" + tc.Dir,
		"--tests=" + tc.Dir,
	}
	out, ec := r.run(ctx, r.cfg.TFPolicyBin, args, "")
	r.writeLog(tc.ID, "tfpolicy_test", out)
	return checkResult(expected, ec, out, "tfpolicy test")
}

func (r *Runner) runValidate(ctx context.Context, tc testcase.TestCase) PhaseResult {
	args := []string{"validate", "--policies=" + tc.Dir}
	out, ec := r.run(ctx, r.cfg.TFPolicyBin, args, "")
	r.writeLog(tc.ID, "tfpolicy_validate", out)

	if ec != 0 {
		return PhaseResult{
			Expected: index.ExpectValidationError,
			Status:   "PASS",
			Note:     fmt.Sprintf("exit %d (expected validation error)", ec),
		}
	}
	return PhaseResult{
		Expected: index.ExpectValidationError,
		Status:   "FAIL",
		Note:     "expected validation error but tfpcli validate exited 0",
	}
}

// ── Level 2 ──────────────────────────────────────────────────────────────────

func (r *Runner) runTFPPlan(ctx context.Context, tc testcase.TestCase) PhaseResult {
	// Ensure init has run.
	if initOut, ec := r.runInit(ctx, tc); ec != 0 {
		r.writeLog(tc.ID, "tfp_init", initOut)
		return PhaseResult{
			Expected: tc.ExpectPlan,
			Status:   "ERROR",
			Note:     fmt.Sprintf("tfp init failed (exit %d)", ec),
		}
	}

	args := []string{"plan", "--policies=.", "-input=false", "-no-color"}
	if r.cfg.TFPolicyPlugin != "" {
		// Inject plugin path via env — set in the exec environment, not as a flag.
	}
	out, ec := r.run(ctx, r.cfg.TFPBin, args, tc.Dir)
	r.writeLog(tc.ID, "tfp_plan", out)
	return checkResult(tc.ExpectPlan, ec, out, "tfp plan")
}

// ── Level 3 ──────────────────────────────────────────────────────────────────

func (r *Runner) runTFPApply(ctx context.Context, tc testcase.TestCase) PhaseResult {
	// Init if .terraform directory is missing.
	if _, err := os.Stat(filepath.Join(tc.Dir, ".terraform")); os.IsNotExist(err) {
		if initOut, ec := r.runInit(ctx, tc); ec != 0 {
			r.writeLog(tc.ID, "tfp_init", initOut)
			return PhaseResult{
				Expected: tc.ExpectApply,
				Status:   "ERROR",
				Note:     fmt.Sprintf("tfp init failed (exit %d)", ec),
			}
		}
	}

	applyArgs := []string{"apply", "--policies=.", "-auto-approve", "-input=false", "-no-color"}
	out, ec := r.run(ctx, r.cfg.TFPBin, applyArgs, tc.Dir)
	r.writeLog(tc.ID, "tfp_apply", out)
	result := checkResult(tc.ExpectApply, ec, out, "tfp apply")

	// Always destroy to clean up real resources, regardless of apply result.
	destroyArgs := []string{"destroy", "-auto-approve", "-input=false", "-no-color"}
	destroyOut, dec := r.run(ctx, r.cfg.TFPBin, destroyArgs, tc.Dir)
	r.writeLog(tc.ID, "tfp_destroy", destroyOut)
	if dec != 0 {
		result.Note += fmt.Sprintf(" [destroy failed: exit %d — check tfp_destroy.log]", dec)
	}

	// Always clean up local Terraform working files after apply+destroy so the
	// test directory is left in a pristine state (no state, no lock, no cached
	// provider binaries). This mirrors the manual cleanup the team performs and
	// prevents stale state from affecting subsequent runs.
	r.cleanTFWorkdir(tc.Dir, tc.ID)

	return result
}

// cleanTFWorkdir removes Terraform-generated files from a test directory:
// .terraform/, .terraform.lock.hcl, terraform.tfstate, terraform.tfstate.backup
func (r *Runner) cleanTFWorkdir(dir, testID string) {
	targets := []string{
		filepath.Join(dir, ".terraform"),
		filepath.Join(dir, ".terraform.lock.hcl"),
		filepath.Join(dir, "terraform.tfstate"),
		filepath.Join(dir, "terraform.tfstate.backup"),
	}
	var removed, failed []string
	for _, t := range targets {
		if _, statErr := os.Stat(t); os.IsNotExist(statErr) {
			continue // nothing to remove
		}
		if err := os.RemoveAll(t); err != nil {
			failed = append(failed, filepath.Base(t))
		} else {
			removed = append(removed, filepath.Base(t))
		}
	}
	msg := fmt.Sprintf("cleanup: removed %v", removed)
	if len(failed) > 0 {
		msg += fmt.Sprintf("; FAILED to remove %v", failed)
	}
	r.writeLog(testID, "tfp_cleanup", msg)
}

// ── Helpers ───────────────────────────────────────────────────────────────────

func (r *Runner) runInit(ctx context.Context, tc testcase.TestCase) (string, int) {
	args := []string{"init", "-input=false", "-no-color"}
	out, ec := r.run(ctx, r.cfg.TFPBin, args, tc.Dir)
	r.writeLog(tc.ID, "tfp_init", out)
	return out, ec
}

// run executes a command in dir (or the current directory if dir is empty)
// and returns combined stdout+stderr and the exit code.
func (r *Runner) run(ctx context.Context, bin string, args []string, dir string) (string, int) {
	cmd := exec.CommandContext(ctx, bin, args...)
	if dir != "" {
		cmd.Dir = dir
	}
	// Pass through the current environment so AWS credentials, PATH, etc. are
	// inherited. Inject TF_POLICY_PLUGIN if configured.
	cmd.Env = os.Environ()
	if r.cfg.TFPolicyPlugin != "" {
		cmd.Env = setenv(cmd.Env, "TF_POLICY_PLUGIN", r.cfg.TFPolicyPlugin)
	}

	var buf bytes.Buffer
	cmd.Stdout = &buf
	cmd.Stderr = &buf

	err := cmd.Run()
	output := buf.String()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return output, exitErr.ExitCode()
		}
		return output + "\n" + err.Error(), 1
	}
	return output, 0
}

func (r *Runner) writeLog(testID, suffix, content string) {
	if content == "" {
		return
	}
	path := filepath.Join(r.resultsDir, testID+"."+suffix+".log")
	_ = os.WriteFile(path, []byte(content), 0o644)
}

// checkResult evaluates a tool exit code and output against an EXPECT value
// and returns the corresponding PhaseResult.
//
// tfp always exits 0 regardless of policy outcome. Policy results are
// communicated entirely through output text:
//
//   mandatory / mandatory_overridable fail → "Error: Condition not met"
//   advisory fail                          → "Warning: Condition not met"
//   unknown condition                      → "Warning: Unknown condition"
//   pass                                   → no policy output lines
func checkResult(expected string, ec int, output, level string) PhaseResult {
	policyFailed := containsAny(output, "Error: Condition not met", "Warning: Condition not met")
	policyUnknown := containsAny(output, "Warning: Unknown condition", "Unknown condition")

	switch expected {
	case index.ExpectPass:
		if ec != 0 {
			return PhaseResult{
				Expected: expected,
				Status:   "FAIL",
				Note:     fmt.Sprintf("%s: exit %d but expected PASS\n%s", level, ec, firstLines(output, 5)),
			}
		}
		if policyFailed {
			return PhaseResult{
				Expected: expected,
				Status:   "FAIL",
				Note:     fmt.Sprintf("%s: policy condition not met (expected PASS)\n%s", level, firstLines(output, 5)),
			}
		}
		if policyUnknown {
			return PhaseResult{
				Expected: expected,
				Status:   "FAIL",
				Note:     fmt.Sprintf("%s: policy condition unknown (expected definitive PASS)\n%s", level, firstLines(output, 5)),
			}
		}
		return PhaseResult{Expected: expected, Status: "PASS"}

	case index.ExpectFail:
		if ec != 0 {
			return PhaseResult{Expected: expected, Status: "PASS", Note: fmt.Sprintf("exit %d (expected failure)", ec)}
		}
		if policyFailed {
			return PhaseResult{Expected: expected, Status: "PASS", Note: "policy condition not met (expected failure)"}
		}
		return PhaseResult{
			Expected: expected,
			Status:   "FAIL",
			Note:     fmt.Sprintf("%s: exit 0, no policy failure detected (expected FAIL)\n%s", level, firstLines(output, 5)),
		}

	case index.ExpectUnknown:
		if ec != 0 {
			return PhaseResult{
				Expected: expected,
				Status:   "FAIL",
				Note:     fmt.Sprintf("%s: exit %d but expected UNKNOWN (exit 0 + warning)\n%s", level, ec, firstLines(output, 5)),
			}
		}
		if policyUnknown {
			return PhaseResult{Expected: expected, Status: "PASS", Note: "policy condition unknown (expected)"}
		}
		if policyFailed {
			return PhaseResult{
				Expected: expected,
				Status:   "FAIL",
				Note:     fmt.Sprintf("%s: policy failed (expected UNKNOWN, not definitive FAIL)\n%s", level, firstLines(output, 5)),
			}
		}
		// Condition resolved to pass — acceptable, unknown resolved at plan time.
		return PhaseResult{
			Expected: expected,
			Status:   "PASS",
			Note:     "exit 0 with no unknown warning (condition may have resolved at plan time)",
		}

	case index.ExpectNA:
		return PhaseResult{Expected: expected, Status: "SKIP", Note: "N/A"}
	}

	// ERROR_CONTAINS: <text>
	if strings.HasPrefix(expected, index.ExpectErrorContains) {
		substr := strings.TrimSpace(strings.TrimPrefix(expected, index.ExpectErrorContains))
		// Accept non-zero exit with substring (tfpcli behaviour) OR exit 0 with
		// substring in output (tfp behaviour — tfp always exits 0).
		if strings.Contains(output, substr) && (ec != 0 || policyFailed || policyUnknown) {
			return PhaseResult{
				Expected: expected,
				Status:   "PASS",
				Note:     fmt.Sprintf("exit %d, output contains %q", ec, substr),
			}
		}
		// Also accept exit 0 with the substring present even without a policy
		// signal, since some error messages (e.g. cycle detection) may not
		// produce standard Condition-not-met lines.
		if ec == 0 && strings.Contains(output, substr) {
			return PhaseResult{
				Expected: expected,
				Status:   "PASS",
				Note:     fmt.Sprintf("output contains %q", substr),
			}
		}
		return PhaseResult{
			Expected: expected,
			Status:   "FAIL",
			Note: fmt.Sprintf("%s: exit=%d expected error containing %q\n%s",
				level, ec, substr, firstLines(output, 5)),
		}
	}

	return PhaseResult{
		Expected: expected,
		Status:   "ERROR",
		Note:     fmt.Sprintf("unknown expectation value %q", expected),
	}
}

func firstLines(s string, n int) string {
	lines := strings.SplitN(s, "\n", n+1)
	if len(lines) > n {
		lines = lines[:n]
	}
	return strings.Join(lines, "\n")
}

func containsAny(s string, subs ...string) bool {
	sl := strings.ToLower(s)
	for _, sub := range subs {
		if strings.Contains(sl, strings.ToLower(sub)) {
			return true
		}
	}
	return false
}

// setenv sets or replaces a key=value pair in an environment slice.
func setenv(env []string, key, value string) []string {
	prefix := key + "="
	for i, e := range env {
		if strings.HasPrefix(e, prefix) {
			env[i] = prefix + value
			return env
		}
	}
	return append(env, prefix+value)
}
