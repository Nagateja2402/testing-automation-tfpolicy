package localrun

import (
	"bytes"
	"context"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func (r *Runner) run(ctx context.Context, bin string, args []string, dir string) (string, int) {
	cmd := exec.CommandContext(ctx, bin, args...)
	if dir != "" {
		cmd.Dir = dir
	}
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

func setenv(env []string, key, value string) []string {
	prefix := key + "="
	for i, item := range env {
		if strings.HasPrefix(item, prefix) {
			env[i] = prefix + value
			return env
		}
	}
	return append(env, prefix+value)
}
