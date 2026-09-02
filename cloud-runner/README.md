# cloud-runner

`cloud-runner` runs tfpolicy regression tests against HCP Terraform (staging or production) by:

1. Creating an API-driven workspace per test case
2. Creating a VCS-backed `tfpolicy` policy set pointing at the test's policy file in GitHub
3. Uploading the test's `main.tf` as a configuration version
4. Triggering a run and waiting for completion
5. Comparing plan/apply outcomes against `EXPECT_TFP_PLAN` / `EXPECT_TFP_APPLY` directives
6. Deleting the workspace and policy set (unless `--no-cleanup` is set)

---

## Prerequisites

- Go 1.25+
- An HCP Terraform account with:
  - An organization (default: `nagateja-test-org`)
  - A project named `regression-testing` inside that org
  - A VCS (GitHub) OAuth connection configured in the org
  - AWS credentials configured as a variable set on the `regression-testing` project
  - **CRITICAL**: API token with "apply runs" permission (see Token Requirements below)
- A GitHub repo containing the policy files, organized as `<TEST-ID>/<policy-file>.policy.hcl`
  (default: `Nagateja2402/tfpolicy-regression-tests`, branch `main`)

### Token Requirements

For auto-apply to work, the API token (`TFE_TOKEN`) must have permission to apply runs on workspaces. This requires either:

1. **User token** (recommended for testing): Use your personal API token from **User Settings → Tokens**
2. **Team token**: Create a team with "Apply" permission on the `regression-testing` project:
   - Go to **Projects → regression-testing → Settings → Team Access**
   - Add a team with **"Apply"** or **"Admin"** workspace access
   - Generate a team API token from **Settings → Teams → [Team Name] → Team API Token**

**Note**: Organization tokens CANNOT be used as they lack permission to create runs and apply.

---

## Building

```bash
cd regression-testing/cloud-runner
go build -o cloud-runner .
```

---

## Configuration

| Flag | Env var | Default | Description |
|------|---------|---------|-------------|
| `--token` | `TFE_TOKEN` | — | **Required.** HCP Terraform API token |
| `--org` | `TFE_ORG` | `nagateja-test-org` | Organization name |
| `--host` | `TFE_HOST` | `app.staging.terraform.io` | HCP Terraform host |
| `--project` | — | `regression-testing` | Project name inside the org |
| `--oauth-token-id` | — | `ot-QzmpZ8opf2RUMVAE` | VCS OAuth token ID for policy sets |
| `--test-dir` | — | `.` (current directory) | Path to the `regression-testing/` directory |
| `--test-id` | — | _(run all)_ | Run only a single test case by ID (e.g. `getresources-cloudtrail-resolves-s3-bucket`) |
| `--tf-version` | — | `1.15.0-policy20261106` | Terraform version for workspaces (auto-falls back if unavailable) |
| `--no-cleanup` | — | `false` | Keep workspaces and policy sets after the run |
| `--parallel` | — | `5` | Max number of test cases to run concurrently |
| `--timeout` | — | `20` | Per-run timeout in minutes |

---

## Running tests

### Run all test cases

```bash
export TFE_TOKEN=<your-token>

./cloud-runner --test-dir /path/to/regression-testing
```

### Run a single test case

Use `--test-id` with the test directory name (e.g. `getresources-cloudtrail-resolves-s3-bucket`):

```bash
./cloud-runner \
  --token "$TFE_TOKEN" \
  --test-dir /path/to/regression-testing \
  --test-id getresources-cloudtrail-resolves-s3-bucket
```

### Keep resources for inspection after the run

```bash
./cloud-runner \
  --token "$TFE_TOKEN" \
  --test-dir /path/to/regression-testing \
  --test-id getresources-cloudtrail-resolves-s3-bucket \
  --no-cleanup
```

The run URL is printed in the results table so you can open it directly in the HCP Terraform UI.

### Run against a different org or host

```bash
./cloud-runner \
  --token "$TFE_TOKEN" \
  --host app.terraform.io \
  --org my-org \
  --oauth-token-id ot-XXXXXXXXXXXXXXXX \
  --test-dir /path/to/regression-testing
```

---

## Test case structure

Each subdirectory of `regression-testing/` is one test case. `cloud-runner` looks for:

| File | Purpose |
|------|---------|
| `main.tf` | Terraform configuration uploaded to HCP Terraform |
| `*.policytest.hcl` | Contains `EXPECT_TFP_PLAN` / `EXPECT_TFP_APPLY` directives |
| `*.policy.hcl` | Policy file (must also exist in the GitHub VCS repo under `<TEST-ID>/`) |

**EXPECT directives** (in the `.policytest.hcl` file):

```hcl
# EXPECT_TFP_PLAN: PASS    # policy must pass at plan
# EXPECT_TFP_APPLY: FAIL   # policy must deny at apply
# EXPECT_TFP_PLAN: UNKNOWN # result is unknown (unknowns or PASS are both accepted)
```

A test case with no `main.tf`, or with all directives set to `N/A`, is skipped automatically.

---

## Output

```
  TEST ID          OVERALL   PLAN_EXP  PLAN_GOT  APPL_EXP  APPL_GOT
  ✓ getresources-cloudtrail-resolves-s3-bucket     PASS      PASS      PASS      PASS      PASS
  ✗ getresources-vpc-has-compliant-flow-log-passes     FAIL      UNKNOWN   FAIL      N/A       N/A
    PLAN NOTE: <log excerpt>
    Run: https://app.staging.terraform.io/app/(org)/runs/run-XXXXX

  SUMMARY
  Total    : 2
  Passed   : 1
  Failed   : 1
  Errors   : 0
  Duration : 94.3s
```

Exit code is `0` if all tests pass, `1` if any test fails or errors.

---

## AWS credentials

Test cases that provision AWS resources require valid credentials. These are supplied via a
**variable set** named `aws-creds` scoped to the `regression-testing` project in HCP Terraform.
The variable set must contain:

| Variable | Category |
|----------|----------|
| `AWS_ACCESS_KEY_ID` | env |
| `AWS_SECRET_ACCESS_KEY` | env (sensitive) |
| `AWS_SESSION_TOKEN` | env (sensitive) |

If runs fail with `ExpiredToken` in the plan log, the session tokens need to be refreshed in
the variable set on HCP Terraform.

---

## Troubleshooting

**Runs stuck at "Needs Confirmation" / auto-apply not working**
The API token lacks "apply runs" permission. This happens when:
- Using an organization token (which can't apply runs)
- Using a team token where the team doesn't have "Apply" permission on the workspace/project
- Using a user token from a user without apply permission

**Fix**: Use a user token or ensure the team token's team has "Apply" or "Admin" permission on the `regression-testing` project. See "Token Requirements" in Prerequisites.

**`TF version X not available, falling back to Y`**
The requested `--tf-version` is not yet available on the target HCP Terraform instance.
The runner falls back to the latest alpha automatically.

**Plan errors with `ExpiredToken`**
AWS session credentials in the `aws-creds` variable set have expired. Update them in the
HCP Terraform UI under **Organizations → nagateja-test-org → Variable Sets → aws-creds**.

**Policy set orphaned after a failed run**
If a run is interrupted before cleanup, a stale workspace or policy set may remain.
The org limit is 1 policy set on the free tier, so subsequent runs will fail.
Delete the orphan manually in the HCP Terraform UI or via the API, then re-run.

**`config_params must be provided for tfpolicy policies`**
The policy set payload is missing `evaluation-stages`. This is handled internally; if you
see this error it means the raw HTTP call in `internal/hcptf/client.go` was changed.
