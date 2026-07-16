package runner

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"cloud-runner/internal/config"
	"cloud-runner/internal/hcptf"
	"cloud-runner/internal/index"
	"cloud-runner/internal/localrun"
	"cloud-runner/internal/testcase"
)

type recordingCloudClient struct {
	calls []string
}

func (c *recordingCloudClient) record(call string) {
	c.calls = append(c.calls, call)
}

func (c *recordingCloudClient) CreateWorkspace(_ context.Context, _, _ string) (string, error) {
	c.record("create-workspace")
	return "ws-1", nil
}

func (c *recordingCloudClient) FindWorkspaceByName(_ context.Context, _ string) (string, error) {
	c.record("find-workspace")
	return "", nil
}

func (c *recordingCloudClient) TriggerDestroyRun(_ context.Context, _ string) error {
	c.record("trigger-destroy-run")
	return nil
}

func (c *recordingCloudClient) DeleteWorkspace(_ context.Context, _ string) error {
	c.record("delete-workspace")
	return nil
}

func (c *recordingCloudClient) CreatePolicySet(_ context.Context, _, _, _ string) (string, error) {
	c.record("create-policy-set")
	return "ps-1", nil
}

func (c *recordingCloudClient) WaitPolicySetReady(_ context.Context, _ string) error {
	c.record("wait-policy-set-ready")
	return nil
}

func (c *recordingCloudClient) UploadConfig(_ context.Context, _ string, _ []byte) (string, error) {
	c.record("upload-config")
	return "cv-1", nil
}

func (c *recordingCloudClient) TriggerRun(_ context.Context, _, _ string, _ bool) (*hcptf.RunResult, error) {
	c.record("trigger-run")
	return &hcptf.RunResult{
		RunID:       "run-1",
		PlanStatus:  "applied",
		FinalStatus: "applied",
		PlanLog:     `{"@message":"Plan: 1 to add","changes":{"add":1,"change":0,"import":0,"remove":0,"operation":"plan"}}`,
		ApplyLog:    "Apply complete",
		PolicyLog:   "── Plan stage (passed): passed=1 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n── Apply stage (passed): passed=1 advisory_failed=0 mandatory_failed=0 errored=0 unknown=0\n",
	}, nil
}

func (c *recordingCloudClient) DeletePolicySet(_ context.Context, _ string) error {
	c.record("delete-policy-set")
	return nil
}

func TestRunCleanupDeletesPolicySetWithWorkspaceCleanup(t *testing.T) {
	client := &recordingCloudClient{}
	cfg := &config.Config{Cleanup: true, TFPolicyBin: "tfpcli"}
	r := newRunner(client, cfg, "project-1", "")
	r.local = &localrun.Runner{}

	result := r.Run(context.Background(), testCaseForCleanupTest(t))
	if result.FatalErr != nil {
		t.Fatalf("Run() FatalErr = %v", result.FatalErr)
	}

	destroyAt := callIndex(client.calls, "trigger-destroy-run")
	deletePolicyAt := callIndex(client.calls, "delete-policy-set")
	deleteWorkspaceAt := callIndex(client.calls, "delete-workspace")
	if destroyAt == -1 || deletePolicyAt == -1 || deleteWorkspaceAt == -1 {
		t.Fatalf("calls = %v; want destroy, delete policy set, delete workspace", client.calls)
	}
	if deletePolicyAt < destroyAt {
		t.Fatalf("delete-policy-set occurred before destroy run: %v", client.calls)
	}
	if deletePolicyAt > deleteWorkspaceAt {
		t.Fatalf("delete-policy-set should be part of workspace cleanup before delete-workspace: %v", client.calls)
	}
}

func TestRunNoCleanupKeepsPolicySetAndWorkspace(t *testing.T) {
	client := &recordingCloudClient{}
	cfg := &config.Config{Cleanup: false, TFPolicyBin: "tfpcli"}
	r := newRunner(client, cfg, "project-1", "")
	r.local = &localrun.Runner{}

	result := r.Run(context.Background(), testCaseForCleanupTest(t))
	if result.FatalErr != nil {
		t.Fatalf("Run() FatalErr = %v", result.FatalErr)
	}
	if callIndex(client.calls, "trigger-destroy-run") == -1 {
		t.Fatalf("calls = %v; want destroy run preserved for applied resources", client.calls)
	}
	if callIndex(client.calls, "delete-policy-set") != -1 {
		t.Fatalf("delete-policy-set called with Cleanup=false: %v", client.calls)
	}
	if callIndex(client.calls, "delete-workspace") != -1 {
		t.Fatalf("delete-workspace called with Cleanup=false: %v", client.calls)
	}
}

func testCaseForCleanupTest(t *testing.T) testcase.TestCase {
	t.Helper()
	dir := t.TempDir()
	mainTF := `terraform { required_providers { aws = { source = "hashicorp/aws" } } }
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "main" { bucket = "example-cleanup-test" }
`
	if err := os.WriteFile(filepath.Join(dir, "main.tf"), []byte(mainTF), 0o644); err != nil {
		t.Fatalf("WriteFile(main.tf): %v", err)
	}
	return testcase.TestCase{
		ID:               "cleanup-order",
		Dir:              dir,
		HasMainTF:        true,
		ExpectPolicyTest: index.ExpectNA,
		ExpectPlan:       index.ExpectPass,
		ExpectApply:      index.ExpectPass,
	}
}

func callIndex(calls []string, target string) int {
	for i, call := range calls {
		if call == target {
			return i
		}
	}
	return -1
}
