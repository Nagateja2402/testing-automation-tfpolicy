# HCP Terraform Cloud Regression Test Runner — Plan

## Goal

Run the 28 regression test cases that have `main.tf` on **HCP Terraform (app.staging.terraform.io)** using the existing project `regression-testing`. For each test case:

1. Create an **API-driven workspace** (one per test case)
2. Upload the Terraform config (`main.tf`) as a configuration version
3. Create a **policy set** with the test case's `.policy.hcl` file(s) and associate it with the workspace
4. Trigger a run (plan + apply where applicable)
5. Check plan/apply policy evaluation results against the `EXPECT_TFP_PLAN` / `EXPECT_TFP_APPLY` directives
6. Clean up: trigger a destroy run, then optionally delete workspace and policy set

## Architecture: Go CLI Tool

A single Go binary (`cloud-runner`) that automates the full flow using the **TFE Go SDK** (`github.com/hashicorp/go-tfe`).

### Why API-driven (not CLI-driven)

- No need for `terraform` binary on the machine running the test
- Full programmatic control over run lifecycle (queue plan, wait, inspect policy checks, confirm apply, etc.)
- Can upload config + policies as tarballs via API
- Easier to parallelize

## Test Cases (28 with `main.tf`)

| Test ID | EXPECT_PLAN | EXPECT_APPLY |
|---------|-------------|--------------|
| getresources-vpc-has-compliant-flow-log-passes | UNKNOWN | PASS |
| getresources-cloudtrail-resolves-s3-bucket | PASS | PASS |
| GR-DEP-006 | UNKNOWN | FAIL |
| GR-DEP-007 | PASS | PASS |
| GR-DEP-008 | PASS | PASS |
| GR-DEP-009 | FAIL | FAIL |
| GR-DEP-010 | PASS | PASS |
| GR-DEP-012 | FAIL | FAIL |
| GR-DEP-014 | PASS | PASS |
| GR-DEP-015 | PASS | PASS |
| GR-PLAN-001 | UNKNOWN | PASS |
| GR-PLAN-002 | N/A | PASS |
| GR-PLAN-003 | PASS | PASS |
| GR-PLAN-004 | UNKNOWN | PASS |
| GR-PLAN-005 | FAIL | FAIL |
| GR-PLAN-006 | FAIL | FAIL |
| TF-E2E-001 | PASS | PASS |
| TF-E2E-002 | FAIL | FAIL |
| TF-E2E-003 | UNKNOWN | PASS |
| TF-E2E-004 | UNKNOWN | FAIL |
| TF-E2E-005 | N/A | N/A |
| TF-UNK-001 | UNKNOWN | PASS |
| TF-UNK-003 | PASS | PASS |
| TF-UNK-004 | UNKNOWN | PASS |
| TF-UNK-005 | UNKNOWN | PASS |
| TF-UNK-006 | UNKNOWN | PASS |
| TF-UNK-007 | UNKNOWN | FAIL |
| TF-UNK-008 | UNKNOWN | PASS |

## HCP Terraform Entities

### Organization & Project
- **Host**: `app.staging.terraform.io`
- **Organization**: (read from `TFE_ORG` env var)
- **Project**: `regression-testing` (already exists)
- **Token**: `TFE_TOKEN` env var

### Per Test Case
1. **Workspace**: `regtest-<TEST_ID>` (e.g. `regtest-getresources-vpc-has-compliant-flow-log-passes`)
   - Execution mode: `remote`
   - Auto-apply: `false` (we control apply confirmation programmatically)
   - Working directory: (root)
   - Terraform version: latest stable
   - Environment variables: AWS creds are already configured on the workspace/project

2. **Policy Set**: `regtest-policy-<TEST_ID>`
   - Kind: `terraform-policy` (tfpolicy, not Sentinel/OPA)
   - Scope: workspace-level (attached to the single workspace)
   - Policies uploaded as a tarball containing the `.policy.hcl` file(s) from the test case directory

3. **Configuration Version**: Upload a tarball of the `main.tf` file

4. **Run**: Triggered after config upload; wait for plan → check policy eval → confirm apply (if expected) → check apply policy eval

## Flow Per Test Case

```
1. Create workspace "regtest-<ID>" in project "regression-testing"
2. Create policy set "regtest-policy-<ID>" with kind=terraform-policy
   - Upload tarball of *.policy.hcl files from the test case dir
   - Attach to workspace
3. Upload configuration version (tarball of main.tf)
4. Wait for run to be created automatically
5. Wait for plan to finish
6. Read plan-phase policy evaluation results
   - Compare against EXPECT_TFP_PLAN
7. If apply is expected (EXPECT_TFP_APPLY != N/A):
   a. If plan policy passed (or soft-fail/advisory):
      - Confirm apply
      - Wait for apply to finish
      - Read apply-phase policy evaluation results
      - Compare against EXPECT_TFP_APPLY
   b. If plan policy hard-failed:
      - Apply is blocked; check if EXPECT_TFP_APPLY == FAIL
8. Trigger destroy run to clean up AWS resources
9. Wait for destroy to complete
10. Delete policy set
11. Delete workspace
```

## Policy Evaluation Result Mapping

HCP Terraform surfaces policy evaluations as **task stages** or **policy checks** on a run. The Go SDK provides access via the `PolicyChecks` or `TaskStages` API. For terraform-policy (tfpolicy) type:

| EXPECT directive | How to verify on HCP Terraform |
|-----------------|-------------------------------|
| `PASS` | Policy evaluation passes. Run continues without policy errors. Plan/Apply succeeds (no hard-mandatory failures). |
| `FAIL` | Policy evaluation produces a hard-mandatory failure. The run is blocked/errored at that phase. |
| `UNKNOWN` | Policy evaluation passes with warnings (unknowns). Run continues. Check for "policy with unknowns" in policy output. |
| `N/A` | Skip checking this phase. |

**Key consideration**: On HCP Terraform, "UNKNOWN" at plan time means the policy evaluation completes with warnings but doesn't block. The run proceeds to apply. At apply time all values are resolved.

## Go Package Structure

```
cloud-runner/
├── go.mod
├── go.sum
├── main.go              # CLI entrypoint (flags, orchestration)
├── internal/
│   ├── config/
│   │   └── config.go    # Config struct: TFE host, token, org, project, test dirs
│   ├── workspace/
│   │   └── workspace.go # Create/delete workspaces
│   ├── policyset/
│   │   └── policyset.go # Create/upload/attach/delete policy sets
│   ├── runner/
│   │   └── runner.go    # Upload config, trigger run, wait, check results
│   ├── evaluator/
│   │   └── evaluator.go # Compare run results against EXPECT directives
│   └── testcase/
│       └── testcase.go  # Parse test case dirs, extract EXPECT directives, build tarballs
```

## CLI Interface

```
cloud-runner [flags]

Flags:
  --org           TFE organization name (or TFE_ORG env)
  --token         TFE API token (or TFE_TOKEN env)
  --host          TFE host (default: app.staging.terraform.io)
  --project       TFE project name (default: regression-testing)
  --test-dir      Path to regression-testing/ directory
  --test-id       Run a single test case (optional; runs all if omitted)
  --cleanup       Delete workspaces and policy sets after run (default: true)
  --parallel      Max concurrent test cases (default: 5)
  --timeout       Per-run timeout (default: 15m)
```

## Dependencies

- `github.com/hashicorp/go-tfe` — TFE/TFC Go SDK
- Standard library `archive/tar`, `compress/gzip` for tarball creation
- `github.com/spf13/cobra` (optional, for CLI)

## Environment Variables

| Var | Required | Description |
|-----|----------|-------------|
| `TFE_TOKEN` | Yes | HCP Terraform API token |
| `TFE_ORG` | Yes | Organization name |
| `TFE_HOST` | No | Defaults to `app.staging.terraform.io` |

AWS credentials are assumed to be already configured as workspace/project-level environment variables on HCP Terraform.

## Result Checking Logic

```go
func checkPlanResult(run *tfe.Run, expected string) Result {
    switch expected {
    case "N/A":
        return Result{Status: "SKIP"}
    case "PASS":
        // Plan succeeded, no policy hard-failures
        if run.Status is planned/planned_and_finished/apply_queued {
            return PASS
        }
        return FAIL
    case "FAIL":
        // Plan policy hard-failed, run is errored/policy_checked
        if run.Status is policy_soft_failed/errored with policy failure {
            return PASS  // we expected failure
        }
        return FAIL
    case "UNKNOWN":
        // Plan succeeded (no hard fail) but has policy warnings about unknowns
        if run.Status is planned/apply_queued AND policy output contains "unknown" warnings {
            return PASS
        }
        // Also accept: plan passed without unknown warnings (values resolved at plan time)
        if run.Status is planned/apply_queued {
            return PASS_WITH_WARNING  // "may have resolved at plan time"
        }
        return FAIL
    }
}
```

## Execution Order

1. Parse all test case directories, filter to those with `main.tf`
2. Look up the `regression-testing` project ID
3. For each test case (up to `--parallel` concurrently):
   a. Create workspace
   b. Create + upload policy set
   c. Upload config version → triggers run
   d. Poll run status until terminal state
   e. Evaluate plan-phase result
   f. If applicable, confirm apply and wait
   g. Evaluate apply-phase result
   h. Trigger destroy run and wait
   i. Cleanup workspace + policy set
4. Print summary table (same format as `run_tests.sh`)
5. Exit 0 if all pass, 1 if any unexpected failure

## Edge Cases

- **TF-E2E-005**: Both PLAN and APPLY are `N/A`. Skip entirely (or only create workspace to verify setup works).
- **GR-PLAN-002**: PLAN is `N/A` but APPLY is `PASS`. Need to auto-approve the plan without checking plan policy, then check apply.
- **FAIL at plan blocking apply**: When EXPECT_PLAN=FAIL and EXPECT_APPLY=FAIL, the run is blocked at plan. Apply never runs. Both expectations are satisfied.
- **Destroy runs**: Always attempt destroy even if the run failed. Destroy runs don't need policy checks.
- **Timeout**: If a run doesn't reach terminal state within `--timeout`, mark as ERROR.

## Open Questions

1. **Policy set kind**: Is `terraform-policy` the correct kind value for tfpolicy policy sets in the TFE API? Need to verify against staging API.
2. **Policy evaluation API**: How are tfpolicy results surfaced differently from Sentinel/OPA? Need to check if `PolicyChecks` or `TaskStages` API is used.
3. **AWS credentials**: Confirm they are configured at the project level in `regression-testing` on staging, or if we need to set them per-workspace.
4. **Terraform version**: Should we pin a specific version, or use the workspace default?
5. **Concurrent workspace limits**: Any org-level limits on staging for concurrent runs?
