# tfpolicy Regression Test Suite

A three-level regression test suite for the `tfpolicy` `getresources()` dependency resolution fix and related policy engine behaviors.

## Directory Structure

```
regression-testing/
├── cloud-runner/         # Unified test runner (Go) — local and HCP Terraform modes
├── index.yml             # Source of truth: test cases + expected outcomes
├── run_tests.sh          # DEPRECATED shim → delegates to cloud-runner
├── results/              # Per-test logs (git-ignored)
└── tests/                # All test case directories
    └── <TEST-ID>/        # e.g. getresources-vpc-has-compliant-flow-log-passes/
        ├── *.policy.hcl      # Policy under test
        ├── *.policytest.hcl  # Mock test data (no EXPECT directives — see index.yml)
        └── main.tf           # Terraform config (only for tfp plan/apply cases)
```

## Test Levels

Each test case is evaluated at up to three levels:

| Level | Tool | What it tests |
|---|---|---|
| 1 | `tfpcli test` / `tfpcli validate` | Policy logic against mock data — no cloud required |
| 2 | `tfp plan` | Policy evaluation during a real Terraform plan against AWS |
| 3 | `tfp apply` | Policy evaluation during a real Terraform apply against AWS |

Whether each level runs for a given test case is controlled by the `expect` values in `tests/index.yml`.

## `index.yml`

`index.yml` at the repo root is the **single source of truth** for every test case and its expected outcomes. Expected outcomes are no longer stored as comments in `*.policytest.hcl` files.

```yaml
version: 1

test_cases:
  - id: getresources-vpc-has-compliant-flow-log-passes
    description: getresources() resolves vpc_id from aws_flow_log to aws_vpc
    suite: GR-DEP
    expect:
      tfpolicy_test: PASS
      tfp_plan:      UNKNOWN
      tfp_apply:     PASS
```

### Expectation values

| Value | Meaning |
|---|---|
| `PASS` | Tool exits 0 |
| `FAIL` | Tool exits non-zero |
| `UNKNOWN` | Exit 0 AND output contains "policy with unknowns" |
| `VALIDATION_ERROR` | `tfpcli validate` exits non-zero |
| `ERROR_CONTAINS: <text>` | Non-zero exit AND output contains `<text>` |
| `N/A` | Skip this level silently |

## Running Tests

### Local mode (default)

Shells out to `tfpcli` and `tfp` on your machine. No cloud credentials required for level 1.

```sh
# Build the runner first
cd cloud-runner && go build -o cloud-runner . && cd ..

# All tests, all levels
./cloud-runner/cloud-runner

# All tests, tfpcli level only (no AWS needed)
./cloud-runner/cloud-runner --skip-tfp

# Single test
./cloud-runner/cloud-runner --test-id getresources-vpc-has-compliant-flow-log-passes

# Single test, level 1 only
./cloud-runner/cloud-runner --skip-tfp --test-id getresources-vpc-has-compliant-flow-log-passes
```

### Cloud mode (HCP Terraform staging)

```sh
# All tests on staging
./cloud-runner/cloud-runner --cloud

# Single test on staging
./cloud-runner/cloud-runner --cloud --test-id getresources-vpc-has-compliant-flow-log-passes

# Keep workspaces for inspection after run
./cloud-runner/cloud-runner --cloud --no-cleanup

# Delete all regtest workspaces and policy sets
./cloud-runner/cloud-runner --purge
```

### Environment variables

| Variable | Used by | Description |
|---|---|---|
| `TFPOLICY_BIN` | local | Path to tfpcli binary (default: `tfpcli`) |
| `TFP_BIN` | local | Path to tfp binary (default: `tfp`) |
| `TF_POLICY_PLUGIN` | local | Path to tfpolicy-plugin binary |
| `TFE_TOKEN` | cloud | HCP Terraform API token |
| `TFE_ORG` | cloud | HCP Terraform organization name |
| `TFE_HOST` | cloud | HCP Terraform host (default: `app.staging.terraform.io`) |

### Override binary paths (local mode)

```sh
./cloud-runner/cloud-runner \
  --tfpolicy-bin /path/to/tfpcli \
  --tfp-bin /path/to/tfp \
  --plugin /path/to/tfpolicy-plugin
```

## Prerequisites

| Binary | Default | Override |
|---|---|---|
| `tfpcli` | must be on `$PATH` | `--tfpolicy-bin` or `TFPOLICY_BIN` |
| `tfp` | must be on `$PATH` | `--tfp-bin` or `TFP_BIN` |
| `tfpolicy-plugin` | none | `--plugin` or `TF_POLICY_PLUGIN` |

## AWS Credentials

Levels 2 and 3 (`tfp plan` / `tfp apply`) create real AWS resources. Set credentials in the environment before running:

```sh
export AWS_ACCESS_KEY_ID="ASIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

## Test Suites

| Suite prefix | Coverage |
|---|---|
| `GR-DEP-*` | `getresources()` dependency resolution across resource types |
| `GR-PLAN-*` | `getresources()` unknown-at-plan vs resolved-at-apply behavior |
| `PP-PROV-*` | Provider pre-plan policies (`provider_policy`) |
| `PP-MOD-*` | Module pre-plan policies (`module_policy`) |
| `OP-CRE/UPD/DEL/ALL/INF/ERR-*` | Operation-scoped policies and inference |
| `FB-FLT-*` | `filter` expression behavior |
| `EL-*` | Enforcement levels (`mandatory`, `advisory`, `mandatory_overridable`) |
| `REG-BIN-*` | Binary regression — existing behavior must be unchanged |
| `TF-E2E-*` | Full create → plan → apply → destroy lifecycle |
| `EC-GR/OP/ENF-*` | Edge cases for getresources, operations, and enforcement |

## Adding a New Test Case

1. Create `tests/<NEW-ID>/` with `.policy.hcl`, `.policytest.hcl`, and optionally `main.tf`.
2. Add an entry to `tests/index.yml` with `id`, `description`, `suite`, and the three `expect.*` values.
3. Run locally: `./cloud-runner/cloud-runner --test-id <NEW-ID>`.
4. Optionally on staging: `./cloud-runner/cloud-runner --cloud --test-id <NEW-ID>`.

`cloud-runner` validates the index at startup and **aborts** if `tests/index.yml` and `tests/` are out of sync.

## Logs and Results

All output is saved under `results/` (git-ignored):

| File | Content |
|---|---|
| `<ID>.tfpolicy_test.log` | Output of `tfpcli test` |
| `<ID>.tfpolicy_validate.log` | Output of `tfpcli validate` (VALIDATION_ERROR cases) |
| `<ID>.tfp_init.log` | Output of `tfp init` |
| `<ID>.tfp_plan.log` | Output of `tfp plan --policies=.` |
| `<ID>.tfp_apply.log` | Output of `tfp apply --policies=.` |
| `<ID>.tfp_destroy.log` | Output of `tfp destroy` (always runs after apply) |

## Resource Cleanup

The runner always attempts `tfp destroy -auto-approve` after each apply, even if the apply failed. If destroy fails, a warning is printed and the log is saved to `<ID>.tfp_destroy.log`. Check that file and clean up manually if needed.
