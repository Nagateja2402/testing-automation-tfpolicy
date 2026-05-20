# Plan: Unified `cloud-runner` as the single test entrypoint

## Goal

Replace `run_tests.sh` with `cloud-runner` as the **single** entrypoint for the regression suite. The same binary runs tests either locally (tfpcli + tfp on the dev machine) or on HCP Terraform staging, selected by a `--cloud` flag.

Expected outcomes for every test case move out of inline `EXPECT_*` comments in `*.policytest.hcl` and into a single source of truth: `tests/index.yml`.

## Why

Today there are two runners with overlapping responsibilities:

| | `run_tests.sh` | `cloud-runner` |
|---|---|---|
| Where | local | HCP Terraform |
| What it runs | tfpcli test, tfp plan, tfp apply | plan + apply via TFE API |
| Source of EXPECT | `*.policytest.hcl` comments | `*.policytest.hcl` comments |
| Discovery | scans `tests/*` directly | scans `tests/*` via Go |

Two implementations of the same loop drift apart. Comment-based directives are easy to typo and invisible to tooling. A single binary + a structured index file fixes both problems.

## Scope

- **In scope:**
  - Add `local` execution mode to `cloud-runner` (shells out to `tfpcli` / `tfp`).
  - Add `--cloud` flag to switch to the existing HCP Terraform path and also tests the policy using the `tfpcli`.
  - Introduce `index.yml` as the authoritative list of test cases + expected outcomes for all three levels (`tfpolicy_test`, `tfp_plan`, `tfp_apply`).
  - Migrate existing `EXPECT_*` comments from every `*.policytest.hcl` into `index.yml`.
  - Update `AGENTS.md`, `README.md`, and `.opencode/agents/internals.md`.
- **Out of scope:**
  - Removing `run_tests.sh` in this change. Mark it deprecated; delete in a follow-up once `cloud-runner local` reaches parity in CI.
  - Changing the policy/test file formats.
  - Changing the HCP Terraform run logic (workspace, policy set, purge) — only the orchestration around it.

## CLI surface

```
cloud-runner [flags]

Flags:
  --cloud                 Run on HCP Terraform staging (default: local execution)
  --test-id <ID>          Run only this test case (default: run all)
  --test-dir <path>       Path to regression-testing/tests/ (default: ./tests)
  --index <path>          Path to index.yml (default: index.yml)
  --skip-tfp              Local mode only: skip tfp plan/apply (level-1 only)
  --parallel <N>          Max concurrent test cases (default: 5)
  --no-cleanup            Cloud mode only: keep workspaces and policy sets
  --purge                 Cloud mode only: delete all regtest workspaces
  # HCP Terraform connection (cloud mode only)
  --token, --org, --host, --project, --tf-version, --timeout
```

Examples:

```sh
# Local, all tests
cloud-runner

# Local, single test, level-1 only
cloud-runner --skip-tfp --test-id GR-DEP-001

# HCP Terraform staging, all tests
cloud-runner --cloud

# HCP Terraform staging, single test
cloud-runner --cloud --test-id GR-DEP-001
```

## `index.yml` schema

```yaml
# regression-testing/index.yml
# Source of truth for every test case and its per-level expected outcome.

version: 1

test_cases:
  - id: GR-DEP-001
    description: getresources() resolves vpc_id from aws_flow_log to aws_vpc
    suite: GR-DEP
    expect:
      tfpolicy_test: PASS
      tfp_plan:      UNKNOWN
      tfp_apply:     PASS

  - id: GR-DEP-011
    description: cycle detection in getresources()
    suite: GR-DEP
    expect:
      tfpolicy_test: VALIDATION_ERROR
      tfp_plan:      N/A
      tfp_apply:     N/A

  - id: REG-BIN-003
    description: output format regression
    suite: REG-BIN
    expect:
      tfpolicy_test: "ERROR_CONTAINS: invalid argument"
      tfp_plan:      N/A
      tfp_apply:     N/A
```

### Expectation values

Identical semantics to the current `EXPECT_*` directives, so the migration is mechanical:

| Value | Meaning |
|---|---|
| `PASS` | Tool exits 0 |
| `FAIL` | Tool exits non-zero |
| `UNKNOWN` | Exit 0 AND output contains "policy with unknowns" |
| `VALIDATION_ERROR` | `tfpcli validate` exits non-zero |
| `ERROR_CONTAINS: <text>` | Non-zero exit AND output contains `<text>` |
| `N/A` | Skip this level silently |

### Validation rules

`cloud-runner` validates the index at startup and aborts on any of:

- An `id` listed in `index.yml` with no matching `tests/<id>/` directory.
- A `tests/<id>/` directory with no entry in `index.yml`.- An unknown expectation value (anything not in the table above).
- An entry with `tfp_plan != N/A` or `tfp_apply != N/A` but no `tests/<id>/main.tf`.
- A `--test-id` that does not exist in the index.

## Implementation outline

### New / changed Go packages

```
cloud-runner/
├── main.go                              # add --cloud flag, route to runner
└── internal/
    ├── config/config.go                 # add Cloud bool, SkipTFP bool
    ├── index/index.go                   # NEW: parse + validate index.yml (root)
    ├── testcase/testcase.go             # drop EXPECT_* parsing; consume index entries
    ├── localrun/localrun.go             # NEW: ports run_tests.sh logic to Go
    │                                    #   - shells out to tfpcli/tfp
    │                                    #   - same check_result semantics
    │                                    #   - writes per-test logs to results/
    ├── runner/runner.go                 # cloud orchestration (unchanged interior)
    └── hcptf/client.go                  # unchanged
```

### Execution flow

```
main
 ├─ parse flags + env
 ├─ load index.yml
 ├─ validate(index, tests/)              # fail-fast on drift
 ├─ filter cases by --test-id / --skip-tfp
 ├─ if --cloud:
 │     runner.New(client, cfg).Run(case) for each, bounded by --parallel
 │  else:
 │     localrun.New(cfg).Run(case)       for each, bounded by --parallel
 └─ print summary; exit nonzero if any failed
```

### Local mode details (`internal/localrun`)

Direct port of `run_tests.sh`:

- Level 1: `tfpcli test --policies=tests/<id> --tests=tests/<id>` (or `tfpcli validate` for `VALIDATION_ERROR`).
- Level 2: `cd tests/<id> && tfp init && tfp plan --policies=.` (skip if no `main.tf` or expect is `N/A` or `--skip-tfp`).
- Level 3: `cd tests/<id> && tfp apply --policies=. -auto-approve` then **always** `tfp destroy -auto-approve`.
- Per-test logs to `results/<id>.{tfpolicy_test,tfp_init,tfp_plan,tfp_apply,tfp_destroy}.log`.
- Same env vars: `TFPOLICY_BIN`, `TFP_BIN`, `TF_POLICY_PLUGIN`.

### Migration of EXPECT directives

A one-shot script (`scripts/migrate_expects.go`, deleted after the cutover) walks every `tests/<id>/*.policytest.hcl`, extracts the three `EXPECT_*` lines, and writes `tests/index.yml`. Then the `EXPECT_*` comment lines are stripped from every `*.policytest.hcl`.

After migration:
- `*.policytest.hcl` files contain only test data — no metadata.
- `index.yml` is the single source of truth.
- Reviewers can see the full expected-outcome matrix on one page.

## Deprecation of `run_tests.sh`

`run_tests.sh` stays in the repo for one release, with the body replaced by:

```sh
#!/usr/bin/env bash
echo "run_tests.sh is deprecated. Use: cloud-runner [--cloud] [--test-id <ID>]" >&2
exec cloud-runner "$@"
```

Once the team has switched, delete the script.

## Documentation updates

- `README.md`: replace the "Running the Tests" section with `cloud-runner` examples; add the `index.yml` schema reference; document `--cloud` vs local.
- `AGENTS.md`: replace the EXPECT-directive table with a pointer to `tests/index.yml`. Update "Adding a new test case" to require a new index entry.
- `.opencode/agents/internals.md`: same updates.
- `cloud-runner/README.md` (if present): document local mode.

## Adding a new test case (post-change)

1. Create `tests/<NEW-ID>/` with `.policy.hcl`, `.policytest.hcl`, and optionally `main.tf`.
2. Add an entry to `tests/index.yml` with `id`, `description`, `suite`, and the three `expect.*` values.
3. Run locally: `cloud-runner --test-id <NEW-ID>`.
4. Optionally on staging: `cloud-runner --cloud --test-id <NEW-ID>`.

If steps 1 and 2 disagree, the runner aborts at startup with a clear error.

## Open questions

1. Should the index allow per-case overrides for `tf_version`, `parallel`, or workspace name? Suggested: not in v1 — keep the index minimal.
2. Should `cloud-runner local` honor `SKIP_TFP=true` as an env var for backward compatibility, or only the `--skip-tfp` flag? Suggested: both, with the flag taking precedence.
only the --skip-tfp be use and not use the SKIP_TFP=true env val
3. Where does the `tfpolicy-plugin` path live in cloud mode? Today it's hard-coded in `run_tests.sh` for local use; cloud mode does not need it. Keep it env-driven (`TF_POLICY_PLUGIN`) and only required in local mode.
tfplugin-plugin path is configured on cloud automatically by selecting the terraform version hence no need to worry about the plugin path

## Rollout

1. Land `index.yml` (root) + migration script. CI continues to use `run_tests.sh`.
2. Land `internal/index`, `internal/localrun`, and the new `--cloud` flag. Both runners produce the same results on the same suite.
3. Switch CI to `cloud-runner` (local mode). Mark `run_tests.sh` deprecated.
4. After one release with no regressions, delete `run_tests.sh` and the migration script.
