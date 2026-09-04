package runner

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"cloud-runner/internal/config"
	"cloud-runner/internal/index"
	"cloud-runner/internal/testcase"
)

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

	result.PolicyTest = r.local.RunPolicyTest(ctx, tc)

	wsName := config.WorkspacePrefix + tc.ID
	psName := config.PolicySetPrefix + tc.ID

	var wsID, psID string

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
		// Keep the policy set until workspace cleanup so policy-check details remain visible in HCP Terraform.
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

	psID, err = r.client.CreatePolicySet(ctx, psName, tc.ID, wsID)
	if err != nil {
		result.FatalErr = fmt.Errorf("create policy set: %w", err)
		return result
	}

	if err := r.client.WaitPolicySetReady(ctx, psID); err != nil {
		result.FatalErr = fmt.Errorf("waiting for policy set ready: %w", err)
		return result
	}

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

	needsApply := tc.ExpectApply != index.ExpectNA
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

	if tc.ExpectPlan != index.ExpectNA {
		got := classifyPlanOutcome(runResult)
		result.Plan.Got = got
		result.Plan.Match = expectationMet(tc.ExpectPlan, got, runResult.PlanLog)
		if !result.Plan.Match {
			result.Plan.Note = truncate(runResult.PlanLog, 5)
		}
	}

	if needsApply {
		got := classifyApplyOutcome(runResult)
		result.Apply.Got = got
		result.Apply.Match = expectationMet(tc.ExpectApply, got, runResult.ApplyLog+runResult.PlanLog)
		if !result.Apply.Match {
			result.Apply.Note = truncate(runResult.ApplyLog, 5)
		}
	}

	if needsApply && (runResult.FinalStatus == "applied" || runResult.FinalStatus == "errored") {
		if runResult.FinalStatus == "errored" {
			result.Apply.Note += " [WARNING: apply errored — resources created before the failure may not be in Terraform state and will NOT be destroyed by the destroy run; delete them manually (e.g. CloudWatch log groups, S3 buckets)]"
		}
		destroyCtx := context.Background()
		// Detach the test's own policy set BEFORE triggering the cleanup destroy run.
		// Many test fixtures intentionally install policies that deny/error on delete
		// or update operations (OP-DEL/OP-ERR/OP-INF suites); if the policy set is
		// still attached, the destroy run itself gets blocked by the very policy it
		// was created to exercise, leaving the AWS resources (e.g. S3 buckets) orphaned.
		if psID != "" {
			if e := r.client.DeletePolicySet(destroyCtx, psID); e != nil {
				result.Apply.Note += fmt.Sprintf(" [pre-destroy policy set cleanup warning: %v]", e)
			} else {
				// Prevent the deferred cleanup from attempting to delete it again.
				psID = ""
			}
		}
		if e := r.client.TriggerDestroyRun(destroyCtx, wsID); e != nil {
			result.Apply.Note += fmt.Sprintf(" [destroy warning: %v]", e)
		}
	}

	return result
}
