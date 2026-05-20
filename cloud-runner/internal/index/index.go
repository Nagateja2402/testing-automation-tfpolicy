// Package index parses and validates the tests/index.yml file, which is the
// authoritative source of truth for all test cases and their expected outcomes.
package index

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
)

// Valid expectation values.
const (
	ExpectPass            = "PASS"
	ExpectFail            = "FAIL"
	ExpectUnknown         = "UNKNOWN"
	ExpectNA              = "N/A"
	ExpectValidationError = "VALIDATION_ERROR"
	ExpectErrorContains   = "ERROR_CONTAINS:" // prefix; remainder is substring to match
)

// Expect holds the three per-level expected outcomes for a test case.
type Expect struct {
	TFPolicyTest string `yaml:"tfpolicy_test"`
	TFPPlan      string `yaml:"tfp_plan"`
	TFPApply     string `yaml:"tfp_apply"`
}

// TestCase is a single entry from index.yml.
type TestCase struct {
	ID          string `yaml:"id"`
	Description string `yaml:"description"`
	Suite       string `yaml:"suite"`
	Expect      Expect `yaml:"expect"`
}

// Index is the parsed contents of index.yml.
type Index struct {
	Version   int        `yaml:"version"`
	TestCases []TestCase `yaml:"test_cases"`
}

// Load reads and parses the index.yml at the given path.
func Load(path string) (*Index, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading index file %s: %w", path, err)
	}
	var idx Index
	if err := yaml.Unmarshal(data, &idx); err != nil {
		return nil, fmt.Errorf("parsing index file %s: %w", path, err)
	}
	return &idx, nil
}

// Validate checks that the index is consistent with the tests/ directory on
// disk and that all expectation values are valid. testsDir is the path to
// the tests/ directory (parent of each test case folder).
func (idx *Index) Validate(testsDir string) error {
	var errs []string

	// Build a set of IDs declared in the index.
	indexed := make(map[string]struct{}, len(idx.TestCases))
	for _, tc := range idx.TestCases {
		if tc.ID == "" {
			errs = append(errs, "index entry missing required field 'id'")
			continue
		}
		if _, dup := indexed[tc.ID]; dup {
			errs = append(errs, fmt.Sprintf("duplicate id %q in index.yml", tc.ID))
		}
		indexed[tc.ID] = struct{}{}

		// Validate expectation values.
		for field, val := range map[string]string{
			"tfpolicy_test": tc.Expect.TFPolicyTest,
			"tfp_plan":      tc.Expect.TFPPlan,
			"tfp_apply":     tc.Expect.TFPApply,
		} {
			if err := validateExpect(val); err != nil {
				errs = append(errs, fmt.Sprintf("%s expect.%s: %v", tc.ID, field, err))
			}
		}

		// If plan or apply is not N/A, main.tf must exist.
		if tc.Expect.TFPPlan != ExpectNA || tc.Expect.TFPApply != ExpectNA {
			mainTF := filepath.Join(testsDir, tc.ID, "main.tf")
			if _, err := os.Stat(mainTF); os.IsNotExist(err) {
				errs = append(errs, fmt.Sprintf(
					"%s has tfp_plan=%q or tfp_apply=%q but tests/%s/main.tf does not exist",
					tc.ID, tc.Expect.TFPPlan, tc.Expect.TFPApply, tc.ID,
				))
			}
		}

		// The test directory itself must exist.
		dir := filepath.Join(testsDir, tc.ID)
		if _, err := os.Stat(dir); os.IsNotExist(err) {
			errs = append(errs, fmt.Sprintf(
				"index.yml references %q but tests/%s/ directory does not exist", tc.ID, tc.ID,
			))
		}
	}

	if len(errs) > 0 {
		return fmt.Errorf("index validation failed:\n  - %s", strings.Join(errs, "\n  - "))
	}
	return nil
}

// ByID returns the TestCase with the given id, or an error if not found.
func (idx *Index) ByID(id string) (*TestCase, error) {
	for i := range idx.TestCases {
		if idx.TestCases[i].ID == id {
			return &idx.TestCases[i], nil
		}
	}
	return nil, fmt.Errorf("test case %q not found in index.yml", id)
}

// validateExpect returns an error if val is not a recognised expectation value.
func validateExpect(val string) error {
	switch val {
	case ExpectPass, ExpectFail, ExpectUnknown, ExpectNA, ExpectValidationError:
		return nil
	}
	if strings.HasPrefix(val, ExpectErrorContains) {
		rest := strings.TrimSpace(strings.TrimPrefix(val, ExpectErrorContains))
		if rest == "" {
			return fmt.Errorf("ERROR_CONTAINS: requires a non-empty substring")
		}
		return nil
	}
	return fmt.Errorf("unknown expectation value %q", val)
}
