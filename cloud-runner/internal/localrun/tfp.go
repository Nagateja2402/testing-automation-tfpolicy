package localrun

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"cloud-runner/internal/testcase"
)

func (r *Runner) runTFPPlan(ctx context.Context, tc testcase.TestCase) PhaseResult {
	pluginBinary, buildResult := r.buildCasePlugin(ctx, tc, tc.ExpectPlan)
	if buildResult != nil {
		return *buildResult
	}
	if pluginBinary != "" {
		defer r.cleanCasePlugin(pluginBinary, tc.ID)
	}

	if initOut, ec := r.runInit(ctx, tc); ec != 0 {
		r.writeLog(tc.ID, "tfp_init", initOut)
		return PhaseResult{
			Expected: tc.ExpectPlan,
			Status:   "ERROR",
			Note:     fmt.Sprintf("tfp init failed (exit %d)", ec),
		}
	}

	args := []string{"plan", "--policies=.", "-input=false", "-no-color"}
	out, ec := r.run(ctx, r.cfg.TFPBin, args, tc.Dir)
	r.writeLog(tc.ID, "tfp_plan", out)
	return checkResult(tc.ExpectPlan, ec, out, "tfp plan")
}

func (r *Runner) runTFPApply(ctx context.Context, tc testcase.TestCase) PhaseResult {
	pluginBinary, buildResult := r.buildCasePlugin(ctx, tc, tc.ExpectApply)
	if buildResult != nil {
		return *buildResult
	}
	if pluginBinary != "" {
		defer r.cleanCasePlugin(pluginBinary, tc.ID)
	}

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

	destroyArgs := []string{"destroy", "-auto-approve", "-input=false", "-no-color"}
	destroyOut, dec := r.run(ctx, r.cfg.TFPBin, destroyArgs, tc.Dir)
	r.writeLog(tc.ID, "tfp_destroy", destroyOut)
	if dec != 0 {
		result.Note += fmt.Sprintf(" [destroy failed: exit %d — check tfp_destroy.log]", dec)
	}
	r.cleanTFWorkdir(tc.Dir, tc.ID)
	return result
}

func (r *Runner) runInit(ctx context.Context, tc testcase.TestCase) (string, int) {
	args := []string{"init", "-input=false", "-no-color"}
	out, ec := r.run(ctx, r.cfg.TFPBin, args, tc.Dir)
	r.writeLog(tc.ID, "tfp_init", out)
	return out, ec
}

func (r *Runner) cleanTFWorkdir(dir, testID string) {
	targets := []string{
		filepath.Join(dir, ".terraform"),
		filepath.Join(dir, ".terraform.lock.hcl"),
		filepath.Join(dir, "terraform.tfstate"),
		filepath.Join(dir, "terraform.tfstate.backup"),
	}
	var removed, failed []string
	for _, target := range targets {
		if _, statErr := os.Stat(target); os.IsNotExist(statErr) {
			continue
		}
		if err := os.RemoveAll(target); err != nil {
			failed = append(failed, filepath.Base(target))
		} else {
			removed = append(removed, filepath.Base(target))
		}
	}
	msg := fmt.Sprintf("cleanup: removed %v", removed)
	if len(failed) > 0 {
		msg += fmt.Sprintf("; FAILED to remove %v", failed)
	}
	r.writeLog(testID, "tfp_cleanup", msg)
}
