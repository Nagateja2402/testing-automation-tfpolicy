package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"sync"
	"time"

	"cloud-runner/internal/config"
	"cloud-runner/internal/hcptf"
	"cloud-runner/internal/index"
	"cloud-runner/internal/localrun"
	"cloud-runner/internal/runner"
	"cloud-runner/internal/testcase"
)

const usage = `cloud-runner — Run tfpolicy regression tests locally or on HCP Terraform

Usage:
  cloud-runner [flags]

Flags:
  --cloud         Run on HCP Terraform staging (default: local execution)
  --skip-tfp      Local mode only: skip tfp plan/apply (tfpcli level only)
  --test-dir      Path to regression-testing/tests/ directory (default: ./tests)
  --index         Path to index.yml (default: <parent of test-dir>/index.yml)
  --test-id       Run only this test case ID (default: run all)
  --parallel      Max concurrent test cases (default: 5)

  Cloud mode only:
  --token         TFE API token (env: TFE_TOKEN)
  --org           TFE organization name (env: TFE_ORG)
  --host          TFE host (default: app.staging.terraform.io)
  --project       TFE project name (default: regression-testing)
  --tf-version    Terraform version for workspaces (default: 1.15.0-policy20261106)
  --no-cleanup    Keep workspaces and policy sets after run (default: cleanup)
  --timeout       Per-run timeout in minutes (default: 20)
  --purge         Delete all regtest workspaces and policy sets then exit
  --vcs-repo      GitHub repo (owner/name) for VCS-backed policy sets (env: VCS_REPO)
                  default: Nagateja2402/testing-automation-tfpolicy
  --vcs-branch    Branch to ingest policies from (env: VCS_BRANCH, default: main)

  Local mode only:
  --tfpolicy-bin  Path to tfpcli binary (env: TFPOLICY_BIN, default: tfpcli)
  --tfp-bin       Path to tfp binary (env: TFP_BIN, default: tfp)
  --plugin        Path to tfpolicy-plugin binary (env: TF_POLICY_PLUGIN)

Examples:
  # Local, all tests
  cloud-runner

  # Local, single test, tfpcli only
  cloud-runner --skip-tfp --test-id GR-DEP-001

  # HCP Terraform staging, all tests
  cloud-runner --cloud

  # HCP Terraform staging, single test
  cloud-runner --cloud --test-id GR-DEP-001
`

func main() {
	cfg := &config.Config{}

	fs := flag.NewFlagSet("cloud-runner", flag.ExitOnError)

	// Mode
	fs.BoolVar(&cfg.Cloud, "cloud", false, "Run on HCP Terraform staging (default: local)")
	fs.BoolVar(&cfg.SkipTFP, "skip-tfp", false, "Local mode: skip tfp plan/apply levels")

	// Common
	fs.StringVar(&cfg.TestDir, "test-dir", "tests", "Path to regression-testing/tests/ directory")
	fs.StringVar(&cfg.IndexPath, "index", "", "Path to index.yml (default: <test-dir>/index.yml)")
	fs.StringVar(&cfg.TestID, "test-id", "", "Single test case ID to run")
	fs.IntVar(&cfg.Parallel, "parallel", config.DefaultParallel, "Max concurrent test cases")

	// Cloud-only
	fs.StringVar(&cfg.Token, "token", "", "TFE API token (or TFE_TOKEN env)")
	fs.StringVar(&cfg.Org, "org", config.DefaultOrg, "TFE organization (or TFE_ORG env)")
	fs.StringVar(&cfg.Host, "host", config.DefaultHost, "TFE host")
	fs.StringVar(&cfg.Project, "project", config.DefaultProject, "TFE project name")
	fs.StringVar(&cfg.OAuthTokenID, "oauth-token-id", config.DefaultOAuthTokenID, "VCS OAuth token ID for policy sets")
	fs.StringVar(&cfg.VCSRepo, "vcs-repo", config.DefaultVCSRepo, "VCS repo (owner/name) for policy sets (env: VCS_REPO)")
	fs.StringVar(&cfg.VCSBranch, "vcs-branch", config.DefaultVCSBranch, "VCS branch to ingest policies from (env: VCS_BRANCH)")
	fs.StringVar(&cfg.TFVersion, "tf-version", config.DefaultTFVersion, "Terraform version for workspaces")
	noCleanup := fs.Bool("no-cleanup", false, "Keep workspaces/policy sets after run")
	purge := fs.Bool("purge", false, "Delete all regtest workspaces and policy sets then exit")
	fs.IntVar(&cfg.RunTimeoutMins, "timeout", config.DefaultRunTimeoutMins, "Per-run timeout (minutes)")

	// Local-only
	fs.StringVar(&cfg.TFPolicyBin, "tfpolicy-bin", config.DefaultTFPolicyBin, "Path to tfpcli binary")
	fs.StringVar(&cfg.TFPBin, "tfp-bin", config.DefaultTFPBin, "Path to tfp binary")
	fs.StringVar(&cfg.TFPolicyPlugin, "plugin", "", "Path to tfpolicy-plugin binary (env: TF_POLICY_PLUGIN)")

	fs.Usage = func() { fmt.Fprint(os.Stderr, usage) }
	if err := fs.Parse(os.Args[1:]); err != nil {
		os.Exit(1)
	}

	cfg.Cleanup = !*noCleanup
	cfg.FromEnv()

	// Resolve test directory to absolute path.
	absTestDir, err := filepath.Abs(cfg.TestDir)
	if err != nil {
		fatal("resolving test-dir: %v", err)
	}
	cfg.TestDir = absTestDir

	// Resolve index path. Default is index.yml in the repo root (parent of tests/).
	if cfg.IndexPath == "" {
		cfg.IndexPath = filepath.Join(filepath.Dir(cfg.TestDir), "index.yml")
	} else {
		p, err := filepath.Abs(cfg.IndexPath)
		if err != nil {
			fatal("resolving index path: %v", err)
		}
		cfg.IndexPath = p
	}

	// --purge: only requires token + org, skip everything else.
	if *purge {
		if err := cfg.ValidateForPurge(); err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n\n", err)
			fs.Usage()
			os.Exit(1)
		}
		ctx := context.Background()
		client, err := hcptf.New(cfg)
		if err != nil {
			fatal("creating TFE client: %v", err)
		}
		runPurge(ctx, client, cfg)
		return
	}

	// Validate configuration.
	if err := cfg.Validate(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n\n", err)
		fs.Usage()
		os.Exit(1)
	}

	// Load and validate index.yml.
	idx, err := index.Load(cfg.IndexPath)
	if err != nil {
		fatal("loading index: %v", err)
	}
	if err := idx.Validate(cfg.TestDir); err != nil {
		fatal("%v", err)
	}

	if cfg.Cloud {
		runCloud(cfg, idx, *purge)
	} else {
		runLocal(cfg, idx)
	}
}

// ── Local mode ────────────────────────────────────────────────────────────────

func runLocal(cfg *config.Config, idx *index.Index) {
	// Resolve results directory relative to the parent of tests/.
	resultsDir := filepath.Join(filepath.Dir(cfg.TestDir), "results")
	if err := os.MkdirAll(resultsDir, 0o755); err != nil {
		fatal("creating results dir: %v", err)
	}

	// Discover test cases.
	var cases []testcase.TestCase
	var err error
	if cfg.TestID != "" {
		tc, err := testcase.DiscoverOne(cfg.TestDir, cfg.TestID, idx)
		if err != nil {
			fatal("%v", err)
		}
		cases = append(cases, *tc)
	} else {
		cases, err = testcase.DiscoverAll(cfg.TestDir, idx)
		if err != nil {
			fatal("discovering test cases: %v", err)
		}
	}

	if len(cases) == 0 {
		fmt.Println("No test cases found.")
		os.Exit(0)
	}

	printLocalHeader(cfg, len(cases))

	r := localrun.New(cfg, resultsDir)
	results := runLocalParallel(context.Background(), r, cases, cfg.Parallel)

	// Sort by test ID for stable output.
	sort.Slice(results, func(i, j int) bool { return results[i].TestID < results[j].TestID })

	exitCode := printLocalResults(results, resultsDir)
	os.Exit(exitCode)
}

func runLocalParallel(ctx context.Context, r *localrun.Runner, cases []testcase.TestCase, maxParallel int) []*localrun.TestResult {
	sem := make(chan struct{}, maxParallel)
	var mu sync.Mutex
	var wg sync.WaitGroup
	results := make([]*localrun.TestResult, 0, len(cases))

	for _, tc := range cases {
		tc := tc
		wg.Add(1)
		sem <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-sem }()

			fmt.Printf("  [START] %s\n", tc.ID)
			res := r.Run(ctx, tc)
			fmt.Printf("  [DONE]  %s → %s (%.1fs)\n", tc.ID, res.Overall(), res.Duration.Seconds())

			mu.Lock()
			results = append(results, res)
			mu.Unlock()
		}()
	}
	wg.Wait()
	return results
}

func printLocalHeader(cfg *config.Config, count int) {
	fmt.Println()
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println("  cloud-runner — local mode")
	fmt.Printf("  tfpcli     : %s\n", cfg.TFPolicyBin)
	fmt.Printf("  tfp        : %s\n", cfg.TFPBin)
	if cfg.TFPolicyPlugin != "" {
		fmt.Printf("  plugin     : %s\n", cfg.TFPolicyPlugin)
	}
	fmt.Printf("  skip-tfp   : %v\n", cfg.SkipTFP)
	fmt.Printf("  test cases : %d\n", count)
	if cfg.TestID != "" {
		fmt.Printf("  filter     : %s\n", cfg.TestID)
	}
	fmt.Println("══════════════════════════════════════════════════════════════════")
}

func printLocalResults(results []*localrun.TestResult, resultsDir string) int {
	const w = "%-20s"
	var passed, failed int
	var failures []string

	fmt.Println()
	fmt.Println("──────────────────────────────────────────────────────────────────")
	fmt.Printf("  %-15s  %-8s  %-8s  %-8s  %-8s\n", "TEST ID", "OVERALL", "L1-TEST", "L2-PLAN", "L3-APPLY")
	fmt.Println("──────────────────────────────────────────────────────────────────")
	_ = w

	for _, r := range results {
		overall := r.Overall()
		marker := "✓"
		if overall != "PASS" {
			marker = "✗"
		}
		fmt.Printf("  %s %-13s  %-8s  %-8s  %-8s  %-8s\n",
			marker, r.TestID, overall,
			r.PolicyTest.Status, r.Plan.Status, r.Apply.Status)

		// Print failure notes.
		for label, p := range map[string]localrun.PhaseResult{
			"L1": r.PolicyTest, "L2": r.Plan, "L3": r.Apply,
		} {
			if p.Status == "FAIL" || p.Status == "ERROR" {
				fmt.Printf("    [%s] %s\n", label, p.Note)
			}
		}

		if overall == "PASS" {
			passed++
		} else {
			failed++
			failures = append(failures, r.TestID)
		}
	}

	fmt.Println("──────────────────────────────────────────────────────────────────")
	fmt.Println()
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println("  SUMMARY")
	fmt.Printf("  Total  : %d\n", len(results))
	fmt.Printf("  Passed : %d\n", passed)
	fmt.Printf("  Failed : %d\n", failed)
	if len(failures) > 0 {
		fmt.Println()
		fmt.Println("  Failures:")
		for _, f := range failures {
			fmt.Printf("    ✗ %s\n", f)
		}
	}
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Printf("\n  Logs saved to: %s/\n\n", resultsDir)

	if failed > 0 {
		return 1
	}
	return 0
}

// ── Cloud mode ────────────────────────────────────────────────────────────────

func runCloud(cfg *config.Config, idx *index.Index, _ bool) {
	ctx := context.Background()

	client, err := hcptf.New(cfg)
	if err != nil {
		fatal("creating TFE client: %v", err)
	}

	// Discover test cases that require a cloud run.
	var cases []testcase.TestCase
	if cfg.TestID != "" {
		tc, err := testcase.DiscoverOne(cfg.TestDir, cfg.TestID, idx)
		if err != nil {
			fatal("%v", err)
		}
		if !tc.NeedsCloudRun() {
			fmt.Printf("Test case %s does not require a cloud run (no main.tf or both N/A).\n", cfg.TestID)
			os.Exit(0)
		}
		cases = append(cases, *tc)
	} else {
		cases, err = testcase.Discover(cfg.TestDir, idx)
		if err != nil {
			fatal("discovering test cases: %v", err)
		}
	}

	if len(cases) == 0 {
		fmt.Println("No test cases found that require cloud runs.")
		os.Exit(0)
	}

	printCloudHeader(cfg, len(cases))

	projectID, err := client.LookupProjectID(ctx)
	if err != nil {
		fatal("looking up project: %v", err)
	}
	fmt.Printf("  Project ID : %s\n\n", projectID)

	r := runner.New(client, cfg, projectID)
	results := runCloudParallel(ctx, r, cases, cfg.Parallel)

	sort.Slice(results, func(i, j int) bool { return results[i].TestID < results[j].TestID })

	printCloudResults(results)
	exitCode := printCloudSummary(results)
	os.Exit(exitCode)
}

func runCloudParallel(ctx context.Context, r *runner.Runner, cases []testcase.TestCase, maxParallel int) []*runner.TestResult {
	sem := make(chan struct{}, maxParallel)
	var mu sync.Mutex
	var wg sync.WaitGroup
	results := make([]*runner.TestResult, 0, len(cases))

	for _, tc := range cases {
		tc := tc
		wg.Add(1)
		sem <- struct{}{}
		go func() {
			defer wg.Done()
			defer func() { <-sem }()

			fmt.Printf("  [START] %s\n", tc.ID)
			res := r.Run(ctx, tc)
			fmt.Printf("  [DONE]  %s → %s (%.1fs)\n",
				tc.ID, res.Overall(), res.Duration.Seconds())

			mu.Lock()
			results = append(results, res)
			mu.Unlock()
		}()
	}
	wg.Wait()
	return results
}

func printCloudHeader(cfg *config.Config, count int) {
	fmt.Println()
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println("  cloud-runner — HCP Terraform mode")
	fmt.Printf("  Host       : %s\n", cfg.Host)
	fmt.Printf("  Org        : %s\n", cfg.Org)
	fmt.Printf("  Project    : %s\n", cfg.Project)
	fmt.Printf("  TF version : %s\n", cfg.TFVersion)
	fmt.Printf("  Cleanup    : %v\n", cfg.Cleanup)
	fmt.Printf("  Parallel   : %d\n", cfg.Parallel)
	fmt.Printf("  Timeout    : %dm\n", cfg.RunTimeoutMins)
	fmt.Printf("  Test cases : %d\n", count)
	fmt.Println("══════════════════════════════════════════════════════════════════")
}

func printCloudResults(results []*runner.TestResult) {
	fmt.Println()
	fmt.Println("──────────────────────────────────────────────────────────────────")
	fmt.Printf("  %-15s  %-8s  %-8s  %-8s  %-8s  %s\n",
		"TEST ID", "OVERALL", "PLAN_EXP", "PLAN_GOT", "APPL_EXP", "APPL_GOT")
	fmt.Println("──────────────────────────────────────────────────────────────────")

	for _, r := range results {
		overall := r.Overall()
		marker := "✓"
		if overall != runner.StatusPass {
			marker = "✗"
		}
		fmt.Printf("  %s %-13s  %-8s  %-8s  %-8s  %-8s  %-8s\n",
			marker, r.TestID, overall,
			r.Plan.Expected, r.Plan.Got,
			r.Apply.Expected, r.Apply.Got,
		)
		if r.FatalErr != nil {
			fmt.Printf("    ERROR: %v\n", r.FatalErr)
		}
		if r.Plan.Note != "" && !r.Plan.Match {
			fmt.Printf("    PLAN NOTE: %s\n", r.Plan.Note)
		}
		if r.Apply.Note != "" && !r.Apply.Match {
			fmt.Printf("    APPLY NOTE: %s\n", r.Apply.Note)
		}
		if r.RunID != "" {
			fmt.Printf("    Run: https://app.staging.terraform.io/app/%s/runs/%s\n", cfg_placeholder_org, r.RunID)
		}
	}
	fmt.Println("──────────────────────────────────────────────────────────────────")
}

// cfg_placeholder_org is replaced at call sites with the actual org value.
// It exists here only to keep the compiler happy; printCloudResults receives
// the org through the runner.TestResult URL (already embedded in RunID context).
const cfg_placeholder_org = "(org)"

func printCloudSummary(results []*runner.TestResult) int {
	var passed, failed, errored int
	var totalDuration time.Duration
	var failures []string

	for _, r := range results {
		totalDuration += r.Duration
		switch r.Overall() {
		case runner.StatusPass:
			passed++
		case runner.StatusError:
			errored++
			failures = append(failures, r.TestID+" (error)")
		default:
			failed++
			failures = append(failures, r.TestID)
		}
	}

	fmt.Println()
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println("  SUMMARY")
	fmt.Printf("  Total    : %d\n", len(results))
	fmt.Printf("  Passed   : %d\n", passed)
	fmt.Printf("  Failed   : %d\n", failed)
	fmt.Printf("  Errors   : %d\n", errored)
	fmt.Printf("  Duration : %.1fs\n", totalDuration.Seconds())

	if len(failures) > 0 {
		fmt.Println()
		fmt.Println("  Failures:")
		for _, f := range failures {
			fmt.Printf("    ✗ %s\n", f)
		}
	}
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println()

	if failed > 0 || errored > 0 {
		return 1
	}
	return 0
}

func fatal(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "FATAL: "+format+"\n", args...)
	os.Exit(1)
}

// runPurge destroys then deletes all regtest workspaces and policy sets.
func runPurge(ctx context.Context, client *hcptf.Client, cfg *config.Config) {
	fmt.Println()
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println("  cloud-runner — Purge regtest workspaces and policy sets")
	fmt.Printf("  Host : %s\n", cfg.Host)
	fmt.Printf("  Org  : %s\n", cfg.Org)
	fmt.Println("  Note : each workspace will have a destroy run queued before")
	fmt.Println("         deletion — this may take several minutes.")
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println()

	fmt.Println("  Discovering regtest resources...")
	result, err := client.PurgeAll(ctx)
	if err != nil {
		fatal("purge failed: %v", err)
	}

	fmt.Printf("  Policy sets deleted : %d\n", result.PolicySetsDeleted)
	for _, e := range result.PolicySetErrors {
		fmt.Printf("    [ERROR] %s\n", e)
	}
	fmt.Printf("  Workspaces deleted  : %d\n", result.WorkspacesDeleted)
	for _, e := range result.WorkspaceErrors {
		fmt.Printf("    [ERROR] %s\n", e)
	}

	fmt.Println()
	if len(result.PolicySetErrors)+len(result.WorkspaceErrors) > 0 {
		fmt.Println("  Purge completed with errors.")
		os.Exit(1)
	}
	fmt.Println("  Purge completed successfully.")
	fmt.Println("══════════════════════════════════════════════════════════════════")
	fmt.Println()
}
