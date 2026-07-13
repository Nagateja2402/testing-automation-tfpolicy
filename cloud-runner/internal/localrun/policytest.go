package localrun

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"cloud-runner/internal/index"
	"cloud-runner/internal/testcase"
)

func (r *Runner) RunPolicyTest(ctx context.Context, tc testcase.TestCase) PhaseResult {
	expected := tc.ExpectPolicyTest
	if expected == index.ExpectNA {
		return PhaseResult{Expected: expected, Status: "SKIP", Note: "N/A"}
	}

	pluginBinary, buildResult := r.buildCasePlugin(ctx, tc, expected)
	if buildResult != nil {
		return *buildResult
	}
	if pluginBinary != "" {
		defer r.cleanCasePlugin(pluginBinary, tc.ID)
	}

	if expected == index.ExpectValidationError {
		return r.runValidate(ctx, tc)
	}

	args := []string{"test", "--policies=" + tc.Dir, "--tests=" + tc.Dir}
	inputFile, inputErr := singlePolicyVarsFile(tc.Dir)
	if inputErr != nil {
		r.writeLog(tc.ID, "tfpolicy_input_file", inputErr.Error())
		return PhaseResult{Expected: expected, Status: "ERROR", Note: inputErr.Error()}
	}
	if inputFile != "" {
		args = append(args, "--input-file="+inputFile)
	}
	out, ec := r.run(ctx, r.cfg.TFPolicyBin, args, tc.Dir)
	r.writeLog(tc.ID, "tfpolicy_test", out)
	return checkResult(expected, ec, out, "tfpolicy test")
}

func (r *Runner) buildCasePlugin(ctx context.Context, tc testcase.TestCase, expected string) (string, *PhaseResult) {
	pluginDir := filepath.Join(tc.Dir, "plugin")
	goMod := filepath.Join(pluginDir, "go.mod")
	if _, err := os.Stat(goMod); os.IsNotExist(err) {
		return "", nil
	}

	pluginBinary := filepath.Join(pluginDir, "plugin_binary")
	out, ec := r.run(ctx, "go", []string{"build", "-o", pluginBinary, "."}, pluginDir)
	r.writeLog(tc.ID, "tfpolicy_plugin_build", out)
	if ec != 0 {
		return "", &PhaseResult{
			Expected: expected,
			Status:   "FAIL",
			Note:     fmt.Sprintf("plugin build failed (exit %d) — check tfpolicy_plugin_build.log", ec),
		}
	}
	return pluginBinary, nil
}

func (r *Runner) cleanCasePlugin(pluginBinary, testID string) {
	if err := os.Remove(pluginBinary); err != nil && !os.IsNotExist(err) {
		r.writeLog(testID, "tfpolicy_plugin_cleanup", fmt.Sprintf("failed to remove %s: %v", pluginBinary, err))
	}
}

func singlePolicyVarsFile(dir string) (string, error) {
	matches, err := filepath.Glob(filepath.Join(dir, "*.policyvars.hcl"))
	if err != nil {
		return "", fmt.Errorf("find policy vars file: %w", err)
	}
	switch len(matches) {
	case 0:
		return "", nil
	case 1:
		return matches[0], nil
	default:
		return "", fmt.Errorf("expected at most one *.policyvars.hcl file, found %d", len(matches))
	}
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
