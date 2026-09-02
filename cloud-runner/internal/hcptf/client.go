// Package hcptf provides a thin client over the go-tfe SDK for the
// specific operations cloud-runner needs.
package hcptf

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	tfe "github.com/hashicorp/go-tfe"

	"cloud-runner/internal/config"
)
// Client wraps the go-tfe client with helpers scoped to cloud-runner.
type Client struct {
	tfe *tfe.Client
	cfg *config.Config
}

// New creates a configured TFE client.
func New(cfg *config.Config) (*Client, error) {
	tfeConfig := &tfe.Config{
		Address: fmt.Sprintf("https://%s", cfg.Host),
		Token:   cfg.Token,
	}
	c, err := tfe.NewClient(tfeConfig)
	if err != nil {
		return nil, fmt.Errorf("creating TFE client: %w", err)
	}
	return &Client{tfe: c, cfg: cfg}, nil
}

// LookupProjectID returns the ID of the named project inside the org.
func (c *Client) LookupProjectID(ctx context.Context) (string, error) {
	list, err := c.tfe.Projects.List(ctx, c.cfg.Org, &tfe.ProjectListOptions{
		Name: c.cfg.Project,
	})
	if err != nil {
		return "", fmt.Errorf("listing projects: %w", err)
	}
	for _, p := range list.Items {
		if p.Name == c.cfg.Project {
			return p.ID, nil
		}
	}
	return "", fmt.Errorf("project %q not found in org %q", c.cfg.Project, c.cfg.Org)
}

// ---------------------------------------------------------------------------
// Workspace
// ---------------------------------------------------------------------------

func (c *Client) CreateWorkspace(ctx context.Context, name, projectID string) (string, error) {
	tfVer := c.cfg.TFVersion
	ws, err := c.tfe.Workspaces.Create(ctx, c.cfg.Org, tfe.WorkspaceCreateOptions{
		Name:             tfe.String(name),
		ExecutionMode:    tfe.String("remote"),
		TerraformVersion: tfe.String(tfVer),
		AutoApply:        tfe.Bool(true),
		Project: &tfe.Project{
			ID: projectID,
		},
	})
	if err != nil {
		if !isTFVersionError(err) {
			return "", fmt.Errorf("creating workspace %s: %w", name, err)
		}
		alphaVer, resolveErr := c.resolveAlphaTFVersion(ctx)
		if resolveErr != nil {
			return "", fmt.Errorf("creating workspace %s: version %s unavailable and alpha lookup failed: %w", name, tfVer, resolveErr)
		}
		fmt.Printf("  [WARN] TF version %s not available, falling back to latest alpha: %s\n", tfVer, alphaVer)
		ws, err = c.tfe.Workspaces.Create(ctx, c.cfg.Org, tfe.WorkspaceCreateOptions{
			Name:             tfe.String(name),
			ExecutionMode:    tfe.String("remote"),
			TerraformVersion: tfe.String(alphaVer),
			AutoApply:        tfe.Bool(true),
			Project: &tfe.Project{
				ID: projectID,
			},
		})
		if err != nil {
			return "", fmt.Errorf("creating workspace %s: %w", name, err)
		}
	}
	return ws.ID, nil
}

func isTFVersionError(err error) bool {
	return err != nil && strings.Contains(err.Error(), "does not resolve to a version")
}

// resolveAlphaTFVersion queries the admin terraform-versions endpoint and
// returns the version string of the newest enabled alpha build available on
// the instance.  Alpha builds are identified by "alpha" in the version string.
func (c *Client) resolveAlphaTFVersion(ctx context.Context) (string, error) {
	type tfVersion struct {
		Version string `json:"version"`
		Enabled bool   `json:"enabled"`
	}
	type responseDoc struct {
		Data []struct {
			Attributes tfVersion `json:"attributes"`
		} `json:"data"`
		Links struct {
			Next interface{} `json:"next"`
		} `json:"links"`
	}

	apiBase := fmt.Sprintf("https://%s/api/v2/admin/terraform-versions", c.cfg.Host)
	var best string

	pageURL := apiBase + "?page[size]=100"
	for pageURL != "" {
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, pageURL, nil)
		if err != nil {
			return "", fmt.Errorf("building admin terraform-versions request: %w", err)
		}
		req.Header.Set("Authorization", "Bearer "+c.cfg.Token)
		req.Header.Set("Content-Type", "application/vnd.api+json")

		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			return "", fmt.Errorf("listing terraform versions: %w", err)
		}
		body, _ := io.ReadAll(resp.Body)
		resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			return "", fmt.Errorf("listing terraform versions: HTTP %d: %s", resp.StatusCode, string(body))
		}

		var doc responseDoc
		if err := json.Unmarshal(body, &doc); err != nil {
			return "", fmt.Errorf("parsing terraform versions response: %w", err)
		}

		for _, item := range doc.Data {
			v := item.Attributes
			if !v.Enabled || !strings.Contains(v.Version, "alpha") {
				continue
			}
			if best == "" || v.Version > best {
				best = v.Version
			}
		}

		pageURL = ""
		if doc.Links.Next != nil {
			if next, ok := doc.Links.Next.(string); ok && next != "" {
				pageURL = next
			}
		}
	}

	if best == "" {
		return "", fmt.Errorf("no enabled alpha Terraform version found on %s", c.cfg.Host)
	}
	return best, nil
}

// DeleteWorkspace removes the workspace by ID.
func (c *Client) DeleteWorkspace(ctx context.Context, wsID string) error {
	return c.tfe.Workspaces.DeleteByID(ctx, wsID)
}

// FindWorkspaceByName returns the ID of the first workspace matching the given
// name in the configured org. Returns ("", nil) when no match is found.
func (c *Client) FindWorkspaceByName(ctx context.Context, name string) (string, error) {
	ws, err := c.tfe.Workspaces.Read(ctx, c.cfg.Org, name)
	if err != nil {
		return "", err
	}
	return ws.ID, nil
}

// ---------------------------------------------------------------------------
// Policy Set (VCS-backed)
// ---------------------------------------------------------------------------

// CreatePolicySet creates a VCS-backed tfpolicy policy set scoped to a single
// workspace. Each test case has its policy files under tests/<testID>/ inside
// the repo, matching the layout of this repository (testing-automation-tfpolicy).
//
// The go-tfe SDK does not support the tfpolicy kind or evaluation-stages, so
// this method uses raw JSON:API HTTP calls throughout.
//
// Note: the staging API returns HTTP 500 from TfPolicySetArchiveCreator even
// when the policy set is successfully created. We recover by searching for the
// set by name after a 5xx.
func (c *Client) CreatePolicySet(ctx context.Context, name, testID, wsID string) (string, error) {
	return c.createPolicySet(ctx, name, testID, wsID, false)
}

func (c *Client) createPolicySet(ctx context.Context, name, testID, wsID string, retried bool) (string, error) {
	payload := map[string]interface{}{
		"data": map[string]interface{}{
			"type": "policy-sets",
			"attributes": map[string]interface{}{
				"name":   name,
				"kind":   "tfpolicy",
				"global": false,
				"vcs-repo": map[string]interface{}{
					"identifier":     c.cfg.VCSRepo,
					"branch":         c.cfg.VCSBranch,
					"oauth-token-id": c.cfg.OAuthTokenID,
				},
				// Policy files live under tests/<testID>/ in this repo.
				"policies-path":       "tests/" + testID,
				"evaluation-stages":   []string{"at_plan", "at_apply"},
				"policy-tool-version": "latest",
			},
			"relationships": map[string]interface{}{
				"workspaces": map[string]interface{}{
					"data": []map[string]string{
						{"type": "workspaces", "id": wsID},
					},
				},
			},
		},
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("marshaling policy set request: %w", err)
	}

	apiURL := fmt.Sprintf("https://%s/api/v2/organizations/%s/policy-sets", c.cfg.Host, c.cfg.Org)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, apiURL, bytes.NewReader(body))
	if err != nil {
		return "", fmt.Errorf("building policy set request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+c.cfg.Token)
	req.Header.Set("Content-Type", "application/vnd.api+json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("creating policy set %s: %w", name, err)
	}
	defer resp.Body.Close()
	respBody, _ := io.ReadAll(resp.Body)

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		var result struct {
			Data struct{ ID string `json:"id"` } `json:"data"`
		}
		if err := json.Unmarshal(respBody, &result); err != nil {
			return "", fmt.Errorf("parsing policy set response: %w", err)
		}
		return result.Data.ID, nil
	}

	if resp.StatusCode >= 500 {
		// Staging crashes in TfPolicySetArchiveCreator even when the set IS
		// created. Recover by looking it up by name.
		psID, err := c.findPolicySetByName(ctx, name)
		if err != nil || psID == "" {
			return "", fmt.Errorf("creating policy set %s: HTTP %d: %s", name, resp.StatusCode, string(respBody))
		}
		fmt.Printf("  [WARN] policy set HTTP %d but found as %s — continuing\n", resp.StatusCode, psID)
		return psID, nil
	}

	// A leftover policy set from a prior interrupted run collides by name (422).
	if resp.StatusCode == http.StatusUnprocessableEntity && isNameConflictMsg(string(respBody)) && !retried {
		if staleID, lookupErr := c.findPolicySetByName(ctx, name); lookupErr == nil && staleID != "" {
			fmt.Printf("  [WARN] policy set %s already exists — deleting and retrying\n", name)
			_ = c.DeletePolicySet(ctx, staleID)
			return c.createPolicySet(ctx, name, testID, wsID, true)
		}
	}

	return "", fmt.Errorf("creating policy set %s: HTTP %d: %s", name, resp.StatusCode, string(respBody))
}

// findPolicySetByName searches the org for a policy set with the given name.
func (c *Client) findPolicySetByName(ctx context.Context, name string) (string, error) {
	apiURL := fmt.Sprintf("https://%s/api/v2/organizations/%s/policy-sets?page%%5Bsize%%5D=100", c.cfg.Host, c.cfg.Org)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, apiURL, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer "+c.cfg.Token)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	var result struct {
		Data []struct {
			ID         string `json:"id"`
			Attributes struct{ Name string `json:"name"` } `json:"attributes"`
		} `json:"data"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return "", err
	}
	for _, ps := range result.Data {
		if ps.Attributes.Name == name {
			return ps.ID, nil
		}
	}
	return "", nil
}

// WaitPolicySetReady polls the policy set's current version until it reaches
// status "ready" (VCS ingestion complete) or errors.
func (c *Client) WaitPolicySetReady(ctx context.Context, psID string) error {
	deadline := time.Now().Add(3 * time.Minute)
	for {
		if time.Now().After(deadline) {
			return fmt.Errorf("timed out waiting for policy set %s to be ready", psID)
		}

		apiURL := fmt.Sprintf("https://%s/api/v2/policy-sets/%s?include=current_version", c.cfg.Host, psID)
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, apiURL, nil)
		if err != nil {
			return err
		}
		req.Header.Set("Authorization", "Bearer "+c.cfg.Token)

		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			return err
		}
		body, _ := io.ReadAll(resp.Body)
		resp.Body.Close()

		var result struct {
			Included []struct {
				Type       string `json:"type"`
				Attributes struct {
					Status string `json:"status"`
					Error  string `json:"error"`
				} `json:"attributes"`
			} `json:"included"`
		}
		if err := json.Unmarshal(body, &result); err != nil {
			return fmt.Errorf("parsing policy set status: %w", err)
		}

		for _, inc := range result.Included {
			if inc.Type == "policy-set-versions" {
				switch inc.Attributes.Status {
				case "ready":
					return nil
				case "errored":
					return fmt.Errorf("policy set %s ingestion errored: %s", psID, inc.Attributes.Error)
				}
			}
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(5 * time.Second):
		}
	}
}

// DeletePolicySet removes a policy set by ID.
func (c *Client) DeletePolicySet(ctx context.Context, psID string) error {
	return c.tfe.PolicySets.Delete(ctx, psID)
}

// ---------------------------------------------------------------------------
// Purge — bulk delete all regtest workspaces and policy sets
// ---------------------------------------------------------------------------

// RegtestResource is a workspace or policy set created by cloud-runner.
type RegtestResource struct {
	ID   string
	Name string
}

// ListRegtestWorkspaces returns all workspaces in the org whose name starts
// with config.WorkspacePrefix ("regtest-").
func (c *Client) ListRegtestWorkspaces(ctx context.Context) ([]RegtestResource, error) {
	var found []RegtestResource
	opts := &tfe.WorkspaceListOptions{
		ListOptions: tfe.ListOptions{PageSize: 100},
	}
	for {
		page, err := c.tfe.Workspaces.List(ctx, c.cfg.Org, opts)
		if err != nil {
			return nil, fmt.Errorf("listing workspaces: %w", err)
		}
		for _, ws := range page.Items {
			if strings.HasPrefix(ws.Name, config.WorkspacePrefix) {
				found = append(found, RegtestResource{ID: ws.ID, Name: ws.Name})
			}
		}
		if page.NextPage == 0 {
			break
		}
		opts.PageNumber = page.NextPage
	}
	return found, nil
}

// ListRegtestPolicySets returns all policy sets in the org whose name starts
// with config.PolicySetPrefix ("regtest-polset-").
func (c *Client) ListRegtestPolicySets(ctx context.Context) ([]RegtestResource, error) {
	var found []RegtestResource
	opts := &tfe.PolicySetListOptions{
		ListOptions: tfe.ListOptions{PageSize: 100},
	}
	for {
		page, err := c.tfe.PolicySets.List(ctx, c.cfg.Org, opts)
		if err != nil {
			return nil, fmt.Errorf("listing policy sets: %w", err)
		}
		for _, ps := range page.Items {
			if strings.HasPrefix(ps.Name, config.PolicySetPrefix) {
				found = append(found, RegtestResource{ID: ps.ID, Name: ps.Name})
			}
		}
		if page.NextPage == 0 {
			break
		}
		opts.PageNumber = page.NextPage
	}
	return found, nil
}

// PurgeResult summarises the outcome of a purge operation.
type PurgeResult struct {
	PolicySetsDeleted  int
	WorkspacesDeleted  int
	PolicySetErrors    []string
	WorkspaceErrors    []string
}

// PurgeAll deletes every regtest workspace and policy set found in the org.
// Policy sets are deleted first so that workspaces are no longer associated
// with them before workspace deletion is attempted.
func (c *Client) PurgeAll(ctx context.Context) (*PurgeResult, error) {
	result := &PurgeResult{}

	policySets, err := c.ListRegtestPolicySets(ctx)
	if err != nil {
		return result, err
	}
	workspaces, err := c.ListRegtestWorkspaces(ctx)
	if err != nil {
		return result, err
	}

	// Delete policy sets first.
	for _, ps := range policySets {
		if err := c.DeletePolicySet(ctx, ps.ID); err != nil {
			result.PolicySetErrors = append(result.PolicySetErrors,
				fmt.Sprintf("%s (%s): %v", ps.Name, ps.ID, err))
		} else {
			result.PolicySetsDeleted++
		}
	}

	// Destroy then delete each workspace.
	for _, ws := range workspaces {
		fmt.Printf("  [DESTROY] %s\n", ws.Name)
		if err := c.TriggerDestroyRun(ctx, ws.ID); err != nil {
			// Non-fatal: workspace may have no state (never applied).
			// Log the warning and proceed to delete.
			fmt.Printf("  [WARN]    %s: destroy run failed (may have no state): %v\n", ws.Name, err)
		}
		if err := c.DeleteWorkspace(ctx, ws.ID); err != nil {
			result.WorkspaceErrors = append(result.WorkspaceErrors,
				fmt.Sprintf("%s (%s): %v", ws.Name, ws.ID, err))
		} else {
			result.WorkspacesDeleted++
		}
	}

	return result, nil
}

// ---------------------------------------------------------------------------
// Configuration Version
// ---------------------------------------------------------------------------

// UploadConfig creates a configuration version, uploads the tarball, and
// returns the CV ID. It waits until the CV status becomes "uploaded".
func (c *Client) UploadConfig(ctx context.Context, wsID string, tarball []byte) (string, error) {
	cv, err := c.tfe.ConfigurationVersions.Create(ctx, wsID, tfe.ConfigurationVersionCreateOptions{
		AutoQueueRuns: tfe.Bool(false),
	})
	if err != nil {
		return "", fmt.Errorf("creating configuration version: %w", err)
	}

	if cv.UploadURL == "" {
		return "", fmt.Errorf("configuration version %s has no upload URL", cv.ID)
	}

	// PUT tarball to the archivist upload URL.
	req, err := http.NewRequestWithContext(ctx, http.MethodPut, cv.UploadURL,
		bytes.NewReader(tarball))
	if err != nil {
		return cv.ID, err
	}
	req.Header.Set("Content-Type", "application/octet-stream")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return cv.ID, fmt.Errorf("uploading config tarball: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return cv.ID, fmt.Errorf("upload returned HTTP %d: %s", resp.StatusCode, string(body))
	}

	// Poll until uploaded.
	deadline := time.Now().Add(2 * time.Minute)
	for time.Now().Before(deadline) {
		cv, err = c.tfe.ConfigurationVersions.Read(ctx, cv.ID)
		if err != nil {
			return cv.ID, fmt.Errorf("reading configuration version %s: %w", cv.ID, err)
		}
		if cv.Status == tfe.ConfigurationUploaded {
			return cv.ID, nil
		}
		if cv.Status == tfe.ConfigurationErrored {
			return cv.ID, fmt.Errorf("configuration version %s errored: %s", cv.ID, cv.ErrorMessage)
		}
		select {
		case <-ctx.Done():
			return cv.ID, ctx.Err()
		case <-time.After(3 * time.Second):
		}
	}
	return cv.ID, fmt.Errorf("timed out waiting for configuration version %s to upload", cv.ID)
}

// ---------------------------------------------------------------------------
// Run lifecycle
// ---------------------------------------------------------------------------

// RunResult holds the outcome of a plan or apply phase.
type RunResult struct {
	// RunID is the TFE run ID.
	RunID string

	// FinalStatus is the terminal run status after apply (e.g. "applied", "errored").
	// When apply was not attempted, this equals PlanStatus.
	FinalStatus string

	// PlanStatus is the plan-terminal status captured before apply confirmation.
	// Use this to evaluate the plan phase; FinalStatus may be overwritten by apply.
	PlanStatus string

	// PolicyPassed is true when no hard-mandatory policy blocked the phase.
	PolicyPassed bool

	// PolicyHasUnknowns is true when the plan log contains unknown-condition warnings.
	PolicyHasUnknowns bool

	// PlanLog is the raw plan log text (truncated to 500 lines).
	PlanLog string

	// ApplyLog is the raw apply log text (truncated to 500 lines).
	ApplyLog string

	// PolicyLog is the concatenated output from all policy checks for the run.
	PolicyLog string

	// Err is set when an unexpected error occurred (not a policy denial).
	Err error
}

// TriggerRun creates a new run for the given workspace + config version,
// waits for it to reach a terminal plan state, then conditionally confirms apply.
// applyIfAllowed controls whether apply is confirmed after plan passes.
func (c *Client) TriggerRun(ctx context.Context, wsID, cvID string, applyIfAllowed bool) (*RunResult, error) {
	run, err := c.tfe.Runs.Create(ctx, tfe.RunCreateOptions{
		Message: tfe.String("cloud-runner regression test"),
		Workspace: &tfe.Workspace{ID: wsID},
		ConfigurationVersion: &tfe.ConfigurationVersion{ID: cvID},
		AutoApply: tfe.Bool(false),
	})
	if err != nil {
		return nil, fmt.Errorf("creating run: %w", err)
	}

	result := &RunResult{RunID: run.ID}
	timeout := time.Duration(c.cfg.RunTimeoutMins) * time.Minute
	deadline := time.Now().Add(timeout)

	// Wait for plan-terminal state.
	planStatus, err := c.waitForRunStatus(ctx, run.ID, deadline, isPlanTerminal)
	if err != nil {
		result.Err = err
		result.FinalStatus = planStatus
		result.PlanStatus = planStatus
		return result, nil
	}
	result.FinalStatus = planStatus
	result.PlanStatus = planStatus

	// Fetch plan log regardless of status.
	if planID, err := c.planIDForRun(ctx, run.ID); err == nil {
		planLog, _ := c.fetchPlanLog(ctx, planID)
		result.PlanLog = planLog
		result.PolicyPassed, result.PolicyHasUnknowns = analyzeLog(planLog)
	}

	// Fetch policy check logs (one per policy set attached to the run).
	result.PolicyLog = c.fetchPolicyCheckLogs(ctx, run.ID)

	// If plan ended with a hard policy failure (errored with DenyResult), stop here.
	if planStatus == string(tfe.RunErrored) && !result.PolicyPassed {
		return result, nil
	}

	// A mandatory_overridable denial parks the run at policy_override awaiting a
	// manual override that never comes here. Confirming apply on it would hang
	// until the run timeout, so treat a blocked plan as terminal and stop.
	if planPolicyBlocked(result.PolicyLog) {
		return result, nil
	}

	// If plan passed and caller wants apply, confirm it.
	if applyIfAllowed && isPlanPassedStatus(planStatus) {
		if err := c.tfe.Runs.Apply(ctx, run.ID, tfe.RunApplyOptions{
			Comment: tfe.String("cloud-runner auto-apply"),
		}); err != nil {
			result.Err = fmt.Errorf("confirming apply: %w", err)
			return result, nil
		}

		// Wait for apply-terminal state.
		applyStatus, err := c.waitForRunStatus(ctx, run.ID, deadline, isApplyTerminal)
		result.FinalStatus = applyStatus
		if err != nil {
			result.Err = err
			return result, nil
		}

		// Re-fetch policy outcomes now that apply is terminal: the at_apply
		// evaluation only reaches a verdict after apply runs, so the copy taken
		// right after plan still shows the Apply stage as pending/all-zero.
		result.PolicyLog = c.fetchPolicyCheckLogs(ctx, run.ID)

		// Fetch apply log.
		if applyID, err := c.applyIDForRun(ctx, run.ID); err == nil {
			applyLog, _ := c.fetchApplyLog(ctx, applyID)
			result.ApplyLog = applyLog
			// Re-assess policy from apply log.
			applyPassed, applyUnknowns := analyzeLog(applyLog)
			result.PolicyPassed = applyPassed
			result.PolicyHasUnknowns = applyUnknowns
		}
	}

	return result, nil
}

// TriggerDestroyRun queues a destroy run and waits for it to complete.
// Errors are non-fatal (cleanup best-effort).
func (c *Client) TriggerDestroyRun(ctx context.Context, wsID string) error {
	run, err := c.tfe.Runs.Create(ctx, tfe.RunCreateOptions{
		Message:      tfe.String("cloud-runner cleanup destroy"),
		Workspace:    &tfe.Workspace{ID: wsID},
		IsDestroy:    tfe.Bool(true),
		AutoApply:    tfe.Bool(true),
	})
	if err != nil {
		return fmt.Errorf("creating destroy run: %w", err)
	}

	deadline := time.Now().Add(15 * time.Minute)
	_, err = c.waitForRunStatus(context.Background(), run.ID, deadline, isApplyTerminal)
	return err
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

func (c *Client) waitForRunStatus(
	ctx context.Context,
	runID string,
	deadline time.Time,
	isTerminal func(string) bool,
) (string, error) {
	for {
		if time.Now().After(deadline) {
			return "", fmt.Errorf("timeout waiting for run %s", runID)
		}
		run, err := c.tfe.Runs.Read(ctx, runID)
		if err != nil {
			return "", fmt.Errorf("reading run %s: %w", runID, err)
		}
		status := string(run.Status)
		if isTerminal(status) {
			return status, nil
		}
		select {
		case <-ctx.Done():
			return status, ctx.Err()
		case <-time.After(8 * time.Second):
		}
	}
}

// isPlanTerminal returns true when we've reached a status after planning.
func isPlanTerminal(status string) bool {
	switch tfe.RunStatus(status) {
	case tfe.RunPlanned,
		tfe.RunPlannedAndFinished,
		tfe.RunErrored,
		tfe.RunCanceled,
		tfe.RunDiscarded,
		tfe.RunPolicySoftFailed,
		tfe.RunPolicyChecked,
		tfe.RunPolicyOverride,
		tfe.RunApplyQueued,
		tfe.RunApplying,
		tfe.RunApplied:
		return true
	}
	return false
}

// isPlanPassedStatus returns true when the plan outcome allows confirm-apply.
func isPlanPassedStatus(status string) bool {
	switch tfe.RunStatus(status) {
	case tfe.RunPlanned,
		tfe.RunPolicySoftFailed,
		tfe.RunPolicyChecked,
		tfe.RunPolicyOverride,
		tfe.RunPlannedAndFinished:
		return true
	}
	return false
}

// isApplyTerminal returns true once apply has reached a stable state.
// RunPlannedAndFinished is included because a destroy run with 0 resources
// never transitions to applied — it ends at planned_and_finished.
func isApplyTerminal(status string) bool {
	switch tfe.RunStatus(status) {
	case tfe.RunApplied,
		tfe.RunErrored,
		tfe.RunCanceled,
		tfe.RunDiscarded,
		tfe.RunPlannedAndFinished:
		return true
	}
	return false
}

func (c *Client) planIDForRun(ctx context.Context, runID string) (string, error) {
	run, err := c.tfe.Runs.ReadWithOptions(ctx, runID, &tfe.RunReadOptions{
		Include: []tfe.RunIncludeOpt{tfe.RunPlan},
	})
	if err != nil {
		return "", err
	}
	if run.Plan == nil {
		return "", fmt.Errorf("run %s has no plan", runID)
	}
	return run.Plan.ID, nil
}

func (c *Client) applyIDForRun(ctx context.Context, runID string) (string, error) {
	run, err := c.tfe.Runs.ReadWithOptions(ctx, runID, &tfe.RunReadOptions{
		Include: []tfe.RunIncludeOpt{tfe.RunApply},
	})
	if err != nil {
		return "", err
	}
	if run.Apply == nil {
		return "", fmt.Errorf("run %s has no apply", runID)
	}
	return run.Apply.ID, nil
}

func (c *Client) fetchPlanLog(ctx context.Context, planID string) (string, error) {
	plan, err := c.tfe.Plans.Read(ctx, planID)
	if err != nil {
		return "", err
	}
	if plan.LogReadURL == "" {
		return "", nil
	}
	return fetchLogURL(ctx, plan.LogReadURL)
}

func (c *Client) fetchApplyLog(ctx context.Context, applyID string) (string, error) {
	apply, err := c.tfe.Applies.Read(ctx, applyID)
	if err != nil {
		return "", err
	}
	if apply.LogReadURL == "" {
		return "", nil
	}
	return fetchLogURL(ctx, apply.LogReadURL)
}

func (c *Client) fetchPolicyCheckLogs(ctx context.Context, runID string) string {
	type tfPolicyEval struct {
		ID         string `json:"id"`
		Attributes struct {
			Status      string `json:"status"`
			StageType   string `json:"stage-type"`
			ResultCount struct {
				Passed          int `json:"passed"`
				AdvisoryFailed  int `json:"advisory-failed"`
				MandatoryFailed int `json:"mandatory-failed"`
				Errored         int `json:"errored"`
				Unknown         int `json:"unknown"`
			} `json:"result-count"`
		} `json:"attributes"`
	}
	type tfPolicyEvalList struct {
		Data []tfPolicyEval `json:"data"`
	}

	doGetRaw := func(url string) ([]byte, error) {
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
		if err != nil {
			return nil, err
		}
		req.Header.Set("Authorization", "Bearer "+c.cfg.Token)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			return nil, err
		}
		defer resp.Body.Close()
		body, err := io.ReadAll(io.LimitReader(resp.Body, 4<<20))
		if err != nil {
			return nil, err
		}
		if resp.StatusCode >= 300 {
			return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(body))
		}
		return body, nil
	}

	evalsRaw, err := doGetRaw(fmt.Sprintf("https://%s/api/v2/runs/%s/tf-policy-evaluations", c.cfg.Host, runID))
	if err != nil {
		return ""
	}
	var evalList tfPolicyEvalList
	if err := json.Unmarshal(evalsRaw, &evalList); err != nil || len(evalList.Data) == 0 {
		return ""
	}

	var sb strings.Builder
	for _, eval := range evalList.Data {
		if sb.Len() > 0 {
			sb.WriteString("\n")
		}
		rc := eval.Attributes.ResultCount
		fmt.Fprintf(&sb, "── %s stage (%s): passed=%d advisory_failed=%d mandatory_failed=%d errored=%d unknown=%d\n",
			eval.Attributes.StageType, eval.Attributes.Status,
			rc.Passed, rc.AdvisoryFailed, rc.MandatoryFailed, rc.Errored, rc.Unknown)

		outcomesRaw, err := doGetRaw(fmt.Sprintf("https://%s/api/v2/tf-policy-evaluations/%s/tf-policy-set-outcomes", c.cfg.Host, eval.ID))
		if err != nil {
			continue
		}
		var prettyBuf bytes.Buffer
		if err := json.Indent(&prettyBuf, outcomesRaw, "  ", "  "); err == nil {
			sb.WriteString("  ")
			sb.Write(prettyBuf.Bytes())
			sb.WriteByte('\n')
		}
	}
	return sb.String()
}

func fetchLogURL(ctx context.Context, url string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return "", err
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20)) // 1 MiB cap
	return string(body), err
}

// analyzeLog inspects a plan or apply log for policy results.
// It returns:
//   - passed: true if no hard-mandatory DenyResult was observed
//   - hasUnknowns: true if the log mentions unknown policy conditions
func analyzeLog(log string) (passed, hasUnknowns bool) {
	if log == "" {
		return true, false
	}

	hasDeny := false
	scanner := bufio.NewScanner(strings.NewReader(log))
	for scanner.Scan() {
		line := scanner.Text()
		// Hard policy denial produces an error-level JSON log line.
		if strings.Contains(line, `"result":"DenyResult"`) &&
			strings.Contains(line, `"enforcement_level":"mandatory"`) {
			hasDeny = true
		}
		// Unknown conditions produce a warning in the log.
		if strings.Contains(line, "policy with unknowns") ||
			strings.Contains(line, "unknown condition") ||
			strings.Contains(line, "Unknown condition") {
			hasUnknowns = true
		}
	}
	return !hasDeny, hasUnknowns
}

// planPolicyBlocked reports whether the Plan-stage policy summary in the policy
// log shows a mandatory failure. A mandatory_overridable denial produces this
// and parks the run at policy_override, which must not be driven to apply.
func planPolicyBlocked(policyLog string) bool {
	if policyLog == "" {
		return false
	}
	for _, line := range strings.Split(policyLog, "\n") {
		if !strings.Contains(line, "Plan stage") {
			continue
		}
		if idx := strings.Index(line, "mandatory_failed="); idx >= 0 {
			rest := line[idx+len("mandatory_failed="):]
			return len(rest) > 0 && rest[0] != '0'
		}
	}
	return false
}

func isNameConflictMsg(body string) bool {
	return strings.Contains(strings.ToLower(body), "has already been taken")
}
