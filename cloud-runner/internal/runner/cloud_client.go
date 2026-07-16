package runner

import (
	"context"

	"cloud-runner/internal/hcptf"
)

type cloudClient interface {
	CreateWorkspace(ctx context.Context, name, projectID string) (string, error)
	FindWorkspaceByName(ctx context.Context, name string) (string, error)
	TriggerDestroyRun(ctx context.Context, wsID string) error
	DeleteWorkspace(ctx context.Context, wsID string) error
	CreatePolicySet(ctx context.Context, name, testID, wsID string) (string, error)
	WaitPolicySetReady(ctx context.Context, psID string) error
	UploadConfig(ctx context.Context, wsID string, tarball []byte) (string, error)
	TriggerRun(ctx context.Context, wsID, cvID string, applyIfAllowed bool) (*hcptf.RunResult, error)
	DeletePolicySet(ctx context.Context, psID string) error
}
