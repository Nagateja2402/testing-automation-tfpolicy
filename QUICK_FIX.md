# Quick Fix: Auto-Apply Not Working

## TL;DR

**The issue**: Runs stuck at "Needs Confirmation" even with auto-apply enabled.

**The cause**: Your API token lacks "apply runs" permission.

**The fix**: Use a user token instead of an organization/team token.

## Steps to Fix

### Option 1: User Token (Easiest)

```bash
# 1. Generate user token in HCP Terraform UI:
#    User Settings → Tokens → Create API Token

# 2. Export it
export TFE_TOKEN="your-user-token-here"

# 3. Run tests
./cloud-runner/cloud-runner --cloud
```

### Option 2: Team Token with Proper Permissions

```bash
# 1. In HCP Terraform UI:
#    Projects → regression-testing → Settings → Team Access
#    → Add team with "Apply" or "Admin" permission

# 2. Generate team token:
#    Settings → Teams → [Your Team] → Team API Token

# 3. Export it
export TFE_TOKEN="your-team-token-here"

# 4. Run tests
./cloud-runner/cloud-runner --cloud
```

## How to Verify

After fixing, check a run in the HCP Terraform UI:
- Should show "Auto Apply: Enabled"
- After plan completes → automatically proceeds to apply
- No "Confirm & Apply" button

## What Changed in Code

All code changes are defensive (handle both permission scenarios):

1. ✅ Workspace `AutoApply: true` (both creation paths)
2. ✅ Run `AutoApply: true` (run creation)
3. ✅ Smart apply detection (skips manual confirm if already applying)

## Why Organization Tokens Don't Work

Organization tokens **cannot create runs or configuration versions** per HCP Terraform API design. They're only for org/workspace management, not for running Terraform.

## More Details

See `AUTO_APPLY_FIX_SUMMARY.md` for complete technical explanation.
