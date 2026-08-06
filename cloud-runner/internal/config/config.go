// Package config holds the runtime configuration for cloud-runner.
package config

import (
	"errors"
	"fmt"
	"os"
	"strings"
)

const (
	DefaultHost    = "app.staging.terraform.io"
	DefaultProject = "regression-testing"
	DefaultOrg     = "nagateja-test-org"
	// DefaultOAuthTokenID is the VCS OAuth token for Nagateja2402 in nagateja-test-org.
	DefaultOAuthTokenID = "ot-QzmpZ8opf2RUMVAE"
	// DefaultVCSRepo is the GitHub repo (owner/name) that holds the regression
	// tests. Using the same repo avoids maintaining a separate policy-only repo.
	DefaultVCSRepo = "Nagateja2402/testing-automation-tfpolicy"
	// DefaultVCSBranch is the branch to ingest policies from.
	DefaultVCSBranch = "main"
	// DefaultTFVersion is the preferred policy-enabled Terraform version.
	// If the HCP Terraform instance does not yet carry this build, the client
	// will fall back to FallbackTFVersion automatically.
	DefaultTFVersion      = "1.16.0-alpha20260626"
	FallbackTFVersion     = "1.15.0-policy20261002"
	DefaultParallel       = 5
	DefaultRunTimeoutMins = 20
	WorkspacePrefix       = "regtest-"
	PolicySetPrefix       = "regtest-polset-"
	PolicyPrefix          = "regtest-pol-"

	// Local mode binary defaults.
	DefaultTFPolicyBin = "tfpolicy"
	DefaultTFPBin      = "tfp"
)

// Config is the top-level runtime configuration.
type Config struct {
	// Cloud selects HCP Terraform mode; false means local execution.
	Cloud bool

	// SkipTFP skips tfp plan/apply levels in local mode (level-1 only).
	SkipTFP bool

	// IndexPath is the path to tests/index.yml.
	IndexPath string

	// HCP Terraform connection (cloud mode only)
	Host  string
	Token string
	Org   string

	// VCS OAuth token ID for VCS-backed policy sets
	OAuthTokenID string

	// VCSRepo is the GitHub repo (owner/name) used for VCS-backed policy sets.
	// Defaults to DefaultVCSRepo (this repo).
	VCSRepo string

	// VCSBranch is the branch to ingest policies from.
	VCSBranch string

	// Project in the org that workspaces are created under
	Project string

	// Terraform version used for policy-enabled workspaces
	TFVersion string

	// Root directory containing regression test case folders (tests/)
	TestDir string

	// Optional: run only these test case IDs (empty = run all).
	// Accepts a single ID or a comma-separated list, e.g. "id-a,id-b".
	TestID string

	// Whether to delete workspaces/policy-sets after each run (cloud mode only)
	Cleanup bool

	// Max concurrent test cases
	Parallel int

	// Per-run timeout in minutes (cloud mode only)
	RunTimeoutMins int

	// Local mode binary paths — resolved from env vars or defaults.
	TFPolicyBin    string // tfpcli binary
	TFPBin         string // tfp binary
	TFPolicyPlugin string // tfpolicy-plugin binary (required for local tfp plan/apply)
}

// Validate ensures all required fields are set and coherent.
func (c *Config) Validate() error {
	var errs []error

	if c.TestDir == "" {
		errs = append(errs, errors.New("test directory is required (--test-dir)"))
	}
	if c.Parallel < 1 {
		errs = append(errs, fmt.Errorf("--parallel must be >= 1, got %d", c.Parallel))
	}

	if c.Cloud {
		// Cloud mode requires HCP Terraform credentials.
		if c.Token == "" {
			errs = append(errs, errors.New("TFE token is required in cloud mode (--token or TFE_TOKEN)"))
		}
		if c.Org == "" {
			errs = append(errs, errors.New("organization is required in cloud mode (--org or TFE_ORG)"))
		}
		if c.RunTimeoutMins < 1 {
			errs = append(errs, fmt.Errorf("--timeout must be >= 1, got %d", c.RunTimeoutMins))
		}
	}

	if len(errs) > 0 {
		return fmt.Errorf("configuration errors: %w", errors.Join(errs...))
	}
	return nil
}

// ValidateForPurge checks only the fields required for a --purge run:
// token and org. test-dir, parallel, and timeout are not needed.
func (c *Config) ValidateForPurge() error {
	var errs []error
	if c.Token == "" {
		errs = append(errs, errors.New("TFE token is required (--token or TFE_TOKEN)"))
	}
	if c.Org == "" {
		errs = append(errs, errors.New("organization is required (--org or TFE_ORG)"))
	}
	if len(errs) > 0 {
		return fmt.Errorf("configuration errors: %w", errors.Join(errs...))
	}
	return nil
}

// FromEnv fills in Token, Org, and local binary paths from environment
// variables if not already set by flags.
func (c *Config) FromEnv() {
	if token := os.Getenv("TFE_TOKEN"); token != "" {
		c.Token = token
	}
	if org := os.Getenv("TFE_ORG"); org != "" {
		c.Org = org
	}
	if h := os.Getenv("TFE_HOST"); h != "" && c.Host == DefaultHost {
		c.Host = h
	}
	if repo := os.Getenv("VCS_REPO"); repo != "" && c.VCSRepo == DefaultVCSRepo {
		c.VCSRepo = repo
	}
	if branch := os.Getenv("VCS_BRANCH"); branch != "" && c.VCSBranch == DefaultVCSBranch {
		c.VCSBranch = branch
	}

	// Local mode binary overrides.
	if bin := os.Getenv("TFPOLICY_BIN"); bin != "" && c.TFPolicyBin == DefaultTFPolicyBin {
		c.TFPolicyBin = bin
	}
	if bin := os.Getenv("TFP_BIN"); bin != "" && c.TFPBin == DefaultTFPBin {
		c.TFPBin = bin
	}
	if plugin := os.Getenv("TF_POLICY_PLUGIN"); plugin != "" {
		c.TFPolicyPlugin = plugin
	}
}

// TestIDs splits the TestID flag into individual IDs. It accepts a single ID
// or a comma-separated list and trims blanks. Returns nil when TestID is empty
// (meaning "run all").
func (c *Config) TestIDs() []string {
	if strings.TrimSpace(c.TestID) == "" {
		return nil
	}
	var ids []string
	for _, part := range strings.Split(c.TestID, ",") {
		if id := strings.TrimSpace(part); id != "" {
			ids = append(ids, id)
		}
	}
	return ids
}
