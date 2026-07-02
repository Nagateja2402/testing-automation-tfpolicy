# tfpolicy Regression Test Suite — Agent Instructions

## Repository Purpose

A three-level regression test suite for the `tfpolicy` `getresources()` dependency resolution fix and related policy engine behaviors. `cloud-runner` is the single entrypoint — it runs tests either locally (tfpcli + tfp) or on HCP Terraform staging (`--cloud`).

## Repository Layout

```
regression-testing/
├── cloud-runner/         # Unified test runner (Go)
│   ├── main.go           # CLI entrypoint — routes local vs cloud
│   └── internal/
│       ├── config/       # Runtime config (Cloud, SkipTFP, IndexPath, binaries)
│       ├── index/        # Parse + validate index.yml
│       ├── localrun/     # Local execution mode (shells out to tfpcli/tfp)
│       ├── testcase/     # Discovery from index.yml + on-disk inspection
│       ├── runner/       # Cloud orchestration (HCP Terraform lifecycle)
│       └── hcptf/        # HCP Terraform API client
├── index.yml             # Source of truth: test cases + expected outcomes
├── run_tests.sh          # DEPRECATED — thin shim that calls cloud-runner
├── results/              # Per-test logs (git-ignored)
└── tests/
    └── <TEST-ID>/        # e.g. getresources-vpc-has-compliant-flow-log-passes/
        ├── *.policy.hcl
        ├── *.policytest.hcl  # Mock data only — no EXPECT directives
        └── main.tf           # Only for level 2/3 cases
```

## Test Levels

| Level | Tool | Requirement |
|-------|------|-------------|
| 1 | `tfpcli test` / `tfpcli validate` | No cloud needed |
| 2 | `tfp plan` | AWS credentials required |
| 3 | `tfp apply` | AWS credentials required |

## `tests/index.yml`

`index.yml` at the repo root is the **single source of truth** for test cases and expected outcomes. `*.policytest.hcl` files contain only mock data — `EXPECT_*` comment directives have been removed.

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
|-------|---------|
| `PASS` | Tool exits 0 |
| `FAIL` | Tool exits non-zero |
| `UNKNOWN` | Exit 0 AND output contains "policy with unknowns" |
| `VALIDATION_ERROR` | `tfpcli validate` exits non-zero |
| `ERROR_CONTAINS: <text>` | Non-zero exit AND output contains `<text>` |
| `N/A` | Skip this level silently |

`cloud-runner` validates index.yml at startup and aborts on drift.

## Running Tests

```sh
# Local, all tests
cloud-runner

# Local, tfpcli only (no AWS)
cloud-runner --skip-tfp

# Local, single test
cloud-runner --test-id getresources-vpc-has-compliant-flow-log-passes

# HCP Terraform staging, all tests
cloud-runner --cloud

# HCP Terraform staging, single test
cloud-runner --cloud --test-id getresources-vpc-has-compliant-flow-log-passes
```

## Prerequisites

| Binary | Default | Override |
|--------|---------|----------|
| `tfpcli` | `$PATH` | `--tfpolicy-bin` / `TFPOLICY_BIN` |
| `tfp` | `$PATH` | `--tfp-bin` / `TFP_BIN` |
| `tfpolicy-plugin` | none | `--plugin` / `TF_POLICY_PLUGIN` |

## Adding a New Test Case

1. Create `tests/<NEW-ID>/` with `.policy.hcl`, `.policytest.hcl`, and optionally `main.tf`.
2. Add an entry to `tests/index.yml` with `id`, `description`, `suite`, and all three `expect.*` values.
3. Run locally: `cloud-runner --test-id <NEW-ID>`.
4. Optionally on staging: `cloud-runner --cloud --test-id <NEW-ID>`.

If step 1 and step 2 are out of sync, `cloud-runner` will abort at startup with a clear error.

## Key Implementation Notes

- `internal/index` owns all YAML parsing and structural validation of `tests/index.yml`.
- `internal/localrun` ports `run_tests.sh` logic to Go: shells out to `tfpcli`/`tfp`, evaluates output against `checkResult`, writes per-test logs to `results/`.
- `internal/testcase` no longer parses `EXPECT_*` comments — it reads expectations from the `index.Index` passed in at construction.
- `internal/runner` handles the HCP Terraform cloud lifecycle (workspace → policy set → config upload → run → evaluate → cleanup). Its interior is unchanged.
- `--skip-tfp` flag only — the legacy `SKIP_TFP` env var is not supported.
- `TF_POLICY_PLUGIN` is only relevant in local mode; cloud mode selects the plugin via the Terraform version.
