package localrun

import (
	"context"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	"cloud-runner/internal/config"
	"cloud-runner/internal/index"
	"cloud-runner/internal/testcase"
)

func TestSinglePolicyVarsFile_returns_only_policyvars_file_when_one_exists(t *testing.T) {
	// Given
	dir := t.TempDir()
	varsPath := filepath.Join(dir, "feature.policyvars.hcl")
	if err := os.WriteFile(varsPath, []byte("input = true\n"), 0o644); err != nil {
		t.Fatalf("write policyvars: %v", err)
	}

	// When
	got, err := singlePolicyVarsFile(dir)

	// Then
	if err != nil {
		t.Fatalf("singlePolicyVarsFile returned error: %v", err)
	}
	if got != varsPath {
		t.Fatalf("singlePolicyVarsFile = %q, want %q", got, varsPath)
	}
}

func TestSinglePolicyVarsFile_errors_when_multiple_policyvars_files_exist(t *testing.T) {
	// Given
	dir := t.TempDir()
	for _, name := range []string{"a.policyvars.hcl", "b.policyvars.hcl"} {
		if err := os.WriteFile(filepath.Join(dir, name), []byte("input = true\n"), 0o644); err != nil {
			t.Fatalf("write %s: %v", name, err)
		}
	}

	// When
	_, err := singlePolicyVarsFile(dir)

	// Then
	if err == nil {
		t.Fatal("singlePolicyVarsFile returned nil error, want multiple-file error")
	}
	if !strings.Contains(err.Error(), "expected at most one") {
		t.Fatalf("singlePolicyVarsFile error = %q, want multiple-file message", err.Error())
	}
}

func TestRunnerRunPolicyTest_builds_and_cleans_case_plugin_when_plugin_source_exists(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("shell script stub uses POSIX syntax")
	}

	// Given
	caseDir := t.TempDir()
	pluginDir := filepath.Join(caseDir, "plugin")
	if err := os.Mkdir(pluginDir, 0o755); err != nil {
		t.Fatalf("mkdir plugin: %v", err)
	}
	if err := os.WriteFile(filepath.Join(pluginDir, "go.mod"), []byte("module example.com/plugin\n"), 0o644); err != nil {
		t.Fatalf("write go.mod: %v", err)
	}
	binDir := t.TempDir()
	goStub := filepath.Join(binDir, "go")
	goStubContent := "#!/bin/sh\nwhile [ $# -gt 0 ]; do\n  if [ \"$1\" = \"-o\" ]; then\n    shift\n    printf 'plugin' > \"$1\"\n    exit 0\n  fi\n  shift\ndone\nexit 1\n"
	if err := os.WriteFile(goStub, []byte(goStubContent), 0o755); err != nil {
		t.Fatalf("write go stub: %v", err)
	}
	tfpcliStub := filepath.Join(binDir, "tfpcli")
	if err := os.WriteFile(tfpcliStub, []byte("#!/bin/sh\nexit 0\n"), 0o755); err != nil {
		t.Fatalf("write tfpcli stub: %v", err)
	}
	t.Setenv("PATH", binDir+string(os.PathListSeparator)+os.Getenv("PATH"))
	runner := New(&config.Config{TFPolicyBin: tfpcliStub}, t.TempDir())
	tc := testcase.TestCase{ID: "plugin-case", Dir: caseDir, ExpectPolicyTest: index.ExpectPass}

	// When
	result := runner.RunPolicyTest(context.Background(), tc)

	// Then
	if result.Status != "PASS" {
		t.Fatalf("RunPolicyTest status = %q note = %q, want PASS", result.Status, result.Note)
	}
	if _, err := os.Stat(filepath.Join(pluginDir, "plugin_binary")); !os.IsNotExist(err) {
		t.Fatalf("plugin_binary still exists after cleanup; stat err = %v", err)
	}
}
