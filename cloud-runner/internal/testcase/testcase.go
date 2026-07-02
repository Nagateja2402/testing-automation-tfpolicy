// Package testcase discovers regression test case directories and builds
// TestCase values from the tests/index.yml index (via the index package).
package testcase

import (
	"archive/tar"
	"bytes"
	"compress/gzip"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"cloud-runner/internal/index"
)

// TestCase represents a single regression test case, combining on-disk
// information with expected outcomes from index.yml.
type TestCase struct {
	// ID is the directory name, e.g. "GR-DEP-001".
	ID string

	// Dir is the absolute path to the test case directory.
	Dir string

	// HasMainTF is true when main.tf exists (cloud run / tfp levels required).
	HasMainTF bool

	// PolicyFiles lists the absolute paths to *.policy.hcl files.
	PolicyFiles []string

	// ExpectPolicyTest is the expected outcome for tfpcli test / validate.
	ExpectPolicyTest string

	// ExpectPlan is the expected outcome for tfp plan.
	ExpectPlan string

	// ExpectApply is the expected outcome for tfp apply.
	ExpectApply string
}

// NeedsCloudRun returns true when plan or apply is not N/A and main.tf exists.
func (tc *TestCase) NeedsCloudRun() bool {
	return tc.HasMainTF &&
		(tc.ExpectPlan != index.ExpectNA || tc.ExpectApply != index.ExpectNA)
}

// Discover loads all test cases from index.yml that need a cloud run (have
// main.tf and at least one non-N/A plan/apply expectation).
func Discover(testsDir string, idx *index.Index) ([]TestCase, error) {
	var cases []TestCase
	for _, entry := range idx.TestCases {
		tc, err := fromIndex(testsDir, entry)
		if err != nil {
			return nil, fmt.Errorf("loading test case %s: %w", entry.ID, err)
		}
		if tc.NeedsCloudRun() {
			cases = append(cases, *tc)
		}
	}
	return cases, nil
}

// DiscoverAll loads all test cases from index.yml regardless of cloud run
// eligibility. Used by local mode which runs all three levels.
func DiscoverAll(testsDir string, idx *index.Index) ([]TestCase, error) {
	var cases []TestCase
	for _, entry := range idx.TestCases {
		tc, err := fromIndex(testsDir, entry)
		if err != nil {
			return nil, fmt.Errorf("loading test case %s: %w", entry.ID, err)
		}
		cases = append(cases, *tc)
	}
	return cases, nil
}

// DiscoverOne returns the single test case with the given ID from the index.
func DiscoverOne(testsDir string, id string, idx *index.Index) (*TestCase, error) {
	entry, err := idx.ByID(id)
	if err != nil {
		return nil, err
	}
	return fromIndex(testsDir, *entry)
}

// DiscoverMany returns the test cases for the given IDs, in the order supplied.
// It fails if any ID is not found in the index.
func DiscoverMany(testsDir string, ids []string, idx *index.Index) ([]TestCase, error) {
	var cases []TestCase
	for _, id := range ids {
		tc, err := DiscoverOne(testsDir, id, idx)
		if err != nil {
			return nil, err
		}
		cases = append(cases, *tc)
	}
	return cases, nil
}

// fromIndex builds a TestCase from an index entry by inspecting the on-disk
// test case directory.
func fromIndex(testsDir string, entry index.TestCase) (*TestCase, error) {
	dir := filepath.Join(testsDir, entry.ID)

	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("reading dir %s: %w", dir, err)
	}

	tc := &TestCase{
		ID:               entry.ID,
		Dir:              dir,
		ExpectPolicyTest: entry.Expect.TFPolicyTest,
		ExpectPlan:       entry.Expect.TFPPlan,
		ExpectApply:      entry.Expect.TFPApply,
	}

	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		switch {
		case name == "main.tf":
			tc.HasMainTF = true
		case strings.HasSuffix(name, ".policy.hcl"):
			tc.PolicyFiles = append(tc.PolicyFiles, filepath.Join(dir, name))
		}
	}

	return tc, nil
}

// ConfigTarball builds an in-memory .tar.gz of the Terraform configuration
// files from the test case directory. It includes main.tf and any supporting
// directories (e.g. modules/) needed for the plan, but excludes policy files
// (*.policy.hcl, *.policytest.hcl) which are managed via the VCS policy set.
func (tc *TestCase) ConfigTarball() ([]byte, error) {
	var buf bytes.Buffer
	gz := gzip.NewWriter(&buf)
	tw := tar.NewWriter(gz)

	if err := addDirToTar(tw, tc.Dir, ""); err != nil {
		return nil, fmt.Errorf("building config tarball for %s: %w", tc.ID, err)
	}

	if err := tw.Close(); err != nil {
		return nil, err
	}
	if err := gz.Close(); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// addDirToTar recursively adds files from srcDir into the tar archive.
// Policy files (*.policy.hcl, *.policytest.hcl) are excluded since they are
// delivered to HCP Terraform via the VCS-backed policy set, not the config.
func addDirToTar(tw *tar.Writer, srcDir, archivePath string) error {
	entries, err := os.ReadDir(srcDir)
	if err != nil {
		return err
	}
	for _, e := range entries {
		name := e.Name()
		if strings.HasSuffix(name, ".policy.hcl") || strings.HasSuffix(name, ".policytest.hcl") {
			continue
		}
		if strings.HasPrefix(name, ".") {
			continue
		}
		srcPath := filepath.Join(srcDir, name)
		var tarName string
		if archivePath == "" {
			tarName = name
		} else {
			tarName = archivePath + "/" + name
		}
		if e.IsDir() {
			if err := addDirToTar(tw, srcPath, tarName); err != nil {
				return err
			}
			continue
		}
		content, err := os.ReadFile(srcPath)
		if err != nil {
			return err
		}
		hdr := &tar.Header{
			Name: tarName,
			Mode: 0o644,
			Size: int64(len(content)),
		}
		if err := tw.WriteHeader(hdr); err != nil {
			return err
		}
		if _, err := io.Copy(tw, bytes.NewReader(content)); err != nil {
			return err
		}
	}
	return nil
}

// PolicyContent returns the raw bytes of the first policy file.
// For simplicity, each test case has exactly one .policy.hcl.
func (tc *TestCase) PolicyContent() (string, []byte, error) {
	if len(tc.PolicyFiles) == 0 {
		return "", nil, fmt.Errorf("no policy files in test case %s", tc.ID)
	}
	path := tc.PolicyFiles[0]
	content, err := os.ReadFile(path)
	if err != nil {
		return "", nil, fmt.Errorf("reading policy file %s: %w", path, err)
	}
	return filepath.Base(path), content, nil
}
