#!/usr/bin/env bash
# DEPRECATED: run_tests.sh is superseded by cloud-runner.
#
# Use cloud-runner instead:
#   cloud-runner                          # local mode, all tests
#   cloud-runner --skip-tfp               # local mode, tfpcli level only
#   cloud-runner --test-id getresources-vpc-has-compliant-flow-log-passes     # local mode, single test
#   cloud-runner --cloud                  # HCP Terraform staging, all tests
#   cloud-runner --cloud --test-id getresources-vpc-has-compliant-flow-log-passes
#
# This shim is kept for one release to avoid breaking existing scripts.
# It will be removed in the next release.

echo "DEPRECATED: run_tests.sh is superseded by cloud-runner." >&2
echo "  Use: cloud-runner [--cloud] [--skip-tfp] [--test-id <ID>]" >&2
echo "" >&2

# Best-effort translation of legacy env var / positional arg to cloud-runner flags.
args=()
if [[ "${SKIP_TFP:-}" == "true" ]]; then
  args+=(--skip-tfp)
fi
if [[ -n "${1:-}" ]]; then
  args+=(--test-id "$1")
fi

exec cloud-runner "${args[@]}"
