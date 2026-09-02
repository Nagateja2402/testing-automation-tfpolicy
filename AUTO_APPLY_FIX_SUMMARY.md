# Auto-Apply Fix Summary

## Problem

Cloud-runner tests were getting stuck when running plan+apply tests. Even though workspaces were configured with `AutoApply: true`, runs still required manual confirmation in the UI and never proceeded to the apply phase automatically.

## Root Cause

The issue was **NOT** with the workspace `AutoApply` setting, but with **API token permissions**.

According to HCP Terraform documentation:
> "Plans can be auto-applied if the auto-apply setting is enabled on the workspace **AND** the plan was queued by a new VCS commit **OR** by a user with permission to apply runs for the workspace."

When using the API-driven workflow (which cloud-runner uses), the API token must have **"apply runs" permission** for auto-apply to work. Without this permission, runs pause at "Needs Confirmation" regardless of the workspace's auto-apply setting.

## Token Types and Permissions

| Token Type | Can Create Runs? | Can Apply Runs? | Notes |
|------------|------------------|-----------------|-------|
| **Organization token** | ❌ No | ❌ No | Cannot be used for this workflow |
| **User token** | ✅ Yes | ✅ If user has apply permission | Inherits user's workspace permissions |
| **Team token** | ✅ Yes | ✅ If team has apply permission | Inherits team's workspace permissions |

## Changes Made

### 1. Code Changes (Defense in Depth)

Even though the real issue is permissions, I made defensive code changes to ensure auto-apply works correctly when permissions are proper:

#### a. Workspace Creation (`cloud-runner/internal/hcptf/client.go`)
```go
// Lines 65 & 83: Changed AutoApply from false to true
AutoApply: tfe.Bool(true),
```

#### b. Run Creation (`cloud-runner/internal/hcptf/client.go`)
```go
// Line 586: Changed AutoApply from false to true
run, err := c.tfe.Runs.Create(ctx, tfe.RunCreateOptions{
    // ...
    AutoApply: tfe.Bool(true),
})
```

#### c. Apply Confirmation Logic (`cloud-runner/internal/hcptf/client.go`)
```go
// Lines 629-645: Added logic to detect when apply is already in progress
// and skip manual confirmation in that case

// With AutoApply: true, the run automatically proceeds to apply after plan
// succeeds, so we skip manual confirmation and go straight to waiting.
if applyIfAllowed && (isPlanPassedStatus(planStatus) || isApplyInProgress(planStatus)) {
    // Only manually confirm if NOT already applying
    if isPlanPassedStatus(planStatus) && !isApplyInProgress(planStatus) {
        // Manual Apply call
    }
    // Wait for apply to complete...
}
```

Added helper function:
```go
func isApplyInProgress(status string) bool {
    switch tfe.RunStatus(status) {
    case tfe.RunApplyQueued, tfe.RunApplying, tfe.RunApplied:
        return true
    }
    return false
}
```

### 2. Documentation Updates

Added comprehensive token requirements documentation to `cloud-runner/README.md`:

- **Token Requirements section** explaining the need for apply permissions
- **Troubleshooting entry** for "Runs stuck at Needs Confirmation"
- Instructions for using user tokens vs team tokens
- Note that organization tokens cannot be used

## Solution

### Immediate Fix (Recommended)

**Use a User Token:**
1. Log into HCP Terraform as a user with apply permission on workspaces
2. Go to **User Settings → Tokens**
3. Create a new API token
4. Export it: `export TFE_TOKEN=<your-user-token>`
5. Run cloud-runner

### Alternative: Team Token Setup

If you need to use a team token:

1. **Create/identify a team** in your organization
2. **Grant workspace access** to the team:
   - Go to **Projects → regression-testing → Settings → Team Access**
   - Add your team with **"Apply"** or **"Admin"** permission
3. **Generate team token**:
   - Go to **Settings → Teams → [Team Name] → Team API Token**
   - Generate and copy the token
4. **Use the token**: `export TFE_TOKEN=<team-token>`

## Verification

After applying the fix:

1. Ensure you're using a user token or properly configured team token
2. Run a test: `./cloud-runner --test-id <test-name> --cloud`
3. Check the run in HCP Terraform UI:
   - It should show "Auto Apply: Enabled" on the run
   - After plan completes successfully, it should automatically proceed to apply
   - No "Confirm & Apply" button should appear

## Technical Details

### Why Organization Tokens Don't Work

From HCP Terraform API documentation:
> "Organization API tokens have permissions across the entire organization. They can perform all CRUD operations on most resources, but have some limitations; **most importantly, they cannot start runs or create configuration versions**."

Organization tokens are designed for workspace/team setup, not for running actual Terraform operations.

### Auto-Apply Permission Flow

```
API Request to Create Run
  ↓
Token Permission Check
  ├─ Has "apply runs" permission? → Auto-apply enabled → Apply after plan
  └─ No "apply runs" permission? → Auto-apply disabled → Pause at "Needs Confirmation"
```

Even if the workspace has `AutoApply: true`, the permission check happens at run creation time based on the token's capabilities.

## References

- [HCP Terraform API Tokens Documentation](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens)
- [API-driven Run Workflow](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/run/api)
- [Runs API Reference](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/run)
- [Permission Model](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/permissions)
