// Package config holds the runtime configuration for cloud-runner.
package config

import (
	"errors"
	"fmt"
	"os"
)

const (
	DefaultHost    = "app.staging.terraform.io"
	DefaultProject = "regression-testing"
	DefaultOrg     = "nagateja-test-org"
	// DefaultOAuthTokenID is the VCS OAuth token for Nagateja2402 in nagateja-test-org.
	DefaultOAuthTokenID = "ot-QzmpZ8opf2RUMVAE"
	// DefaultTFVersion is the preferred policy-enabled Terraform version.
	// If the HCP Terraform instance does not yet carry this build, the client
	// will fall back to FallbackTFVersion automatically.
	DefaultTFVersion      = "1.15.0-policy20261105"
	FallbackTFVersion     = "1.15.0-policy20261002"
	DefaultParallel       = 5
	DefaultRunTimeoutMins = 20
	WorkspacePrefix       = "regtest-"
	PolicySetPrefix       = "regtest-polset-"
	PolicyPrefix          = "regtest-pol-"

	// Local mode binary defaults.
	DefaultTFPolicyBin = "tfpcli"
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

	// Project in the org that workspaces are created under
	Project string

	// Terraform version used for policy-enabled workspaces
	TFVersion string

	// Root directory containing regression test case folders (tests/)
	TestDir string

	// Optional: run only this single test case ID (empty = run all)
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
