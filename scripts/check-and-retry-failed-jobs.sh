#!/usr/bin/env bash
set -euo pipefail

# Script to check for failed jobs in a PR and trigger retry workflow
# Usage: ./check-and-retry-failed-jobs.sh <pr_number> <repository> [dry_run]
#
# Arguments:
#   pr_number: The PR number to check
#   repository: The repository in format "owner/repo"
#   dry_run: Optional. If set to "true", will not trigger retry (default: false)
#
# Requirements:
#   - gh CLI must be installed and authenticated
#   - GH_TOKEN environment variable must be set

PR_NUMBER="${1:-}"
REPOSITORY="${2:-}"
DRY_RUN="${3:-false}"

# Validate inputs
if [ -z "$PR_NUMBER" ]; then
  echo "❌ Error: PR number is required"
  echo "Usage: $0 <pr_number> <repository> [dry_run]"
  exit 1
fi

if [ -z "$REPOSITORY" ]; then
  echo "❌ Error: Repository is required"
  echo "Usage: $0 <pr_number> <repository> [dry_run]"
  exit 1
fi

if [ -z "${GH_TOKEN:-}" ]; then
  echo "❌ Error: GH_TOKEN environment variable must be set"
  exit 1
fi

echo "🔍 Checking PR #$PR_NUMBER for failed jobs..."
echo "📦 Repository: $REPOSITORY"

# Get PR branch name
pr_branch=$(gh pr view "$PR_NUMBER" --repo "$REPOSITORY" --json headRefName --jq '.headRefName')

if [ -z "$pr_branch" ]; then
  echo "❌ Error: Could not find PR #$PR_NUMBER"
  exit 1
fi

echo "📝 PR branch: $pr_branch"

# Get workflow run ID from PR checks
# This is more reliable than querying all workflow runs, especially for older PRs
echo "🔍 Getting workflow runs from PR checks..."

# Get the check runs for this PR and extract unique run IDs
# gh pr checks outputs URLs like: https://github.com/owner/repo/actions/runs/12345/job/67890
# Note: gh pr checks exits with code 1 if any checks failed, so we need to allow that
check_output=$(gh pr checks "$PR_NUMBER" --repo "$REPOSITORY" 2>&1 || true)
run_ids=$(echo "$check_output" | \
  grep -o 'actions/runs/[0-9]*' | \
  sed 's|actions/runs/||' | \
  sort -u)

if [ -z "$run_ids" ]; then
  echo "ℹ️ No workflow runs found for this PR"
  echo "💡 Tests may not have started yet"
  exit 0
fi

# Get the most recent run ID (they come sorted, so take the last one)
latest_run_id=$(echo "$run_ids" | tail -1)

if [ -z "$latest_run_id" ]; then
  echo "ℹ️ Could not determine workflow run ID"
  echo "💡 Tests may not have started yet"
  exit 0
fi

echo "📋 Latest workflow run ID: $latest_run_id"
echo "🔗 Run URL: https://github.com/$REPOSITORY/actions/runs/$latest_run_id"

# Get detailed status of the workflow run
run_status=$(gh api "repos/$REPOSITORY/actions/runs/$latest_run_id" --jq '.status')
run_conclusion=$(gh api "repos/$REPOSITORY/actions/runs/$latest_run_id" --jq '.conclusion')
workflow_name=$(gh api "repos/$REPOSITORY/actions/runs/$latest_run_id" --jq '.name')

echo "📊 Workflow: $workflow_name"
echo "📊 Run status: $run_status"
echo "📊 Run conclusion: $run_conclusion"

# Only check for failed jobs if the run has completed or is in progress
if [ "$run_status" != "completed" ] && [ "$run_status" != "in_progress" ]; then
  echo "ℹ️ Run is in status: $run_status - waiting for completion"
  echo "💡 Will check again later"
  exit 0
fi

# Check if there are any failed jobs in the latest run
echo "🔍 Checking for failed jobs..."
failed_jobs_list=$(gh api "repos/$REPOSITORY/actions/runs/$latest_run_id/jobs" \
  --jq '.jobs[] | select(.conclusion == "failure") | .name')

# Count non-empty lines (handle empty string case)
if [ -z "$failed_jobs_list" ]; then
  failed_jobs_count=0
else
  failed_jobs_count=$(echo "$failed_jobs_list" | wc -l | tr -d ' ')
fi

if [ "$failed_jobs_count" -eq 0 ]; then
  echo "✅ No failed jobs found"

  if [ "$run_status" = "in_progress" ]; then
    echo "💡 Tests are still running - will check again later"
  else
    echo "💡 All jobs passed or are still running"
  fi

  exit 0
fi

echo "🔄 Found $failed_jobs_count failed job(s):"
echo "$failed_jobs_list" | sed 's/^/  - /'

# Trigger retry if not in dry run mode
if [ "$DRY_RUN" = "true" ]; then
  echo ""
  echo "🧪 DRY RUN MODE - Would have triggered retry for run $latest_run_id"
  echo "💡 To actually trigger retry, run without dry_run flag or set it to 'false'"
else
  echo ""
  echo "🚀 Triggering retry workflow..."

  # Try to trigger retry, but don't fail if it doesn't work (e.g., token permissions)
  set +e
  retry_output=$(gh workflow run retry.yml \
    --repo "$REPOSITORY" \
    --field run_id="$latest_run_id" 2>&1)
  retry_exit_code=$?
  set -e

  if [ $retry_exit_code -eq 0 ]; then
    echo "✅ Retry workflow triggered successfully"
    echo "💡 A new workflow run will be created to retry the failed jobs"
    echo "🔗 Monitor at: https://github.com/$REPOSITORY/actions/workflows/retry.yml"
  else
    echo "⚠️ Failed to trigger retry workflow (exit code: $retry_exit_code)"
    echo "Error output:"
    echo "$retry_output" | sed 's/^/  /'
    echo ""
    echo "Common causes:"
    echo "  - Token lacks 'workflow' permission (HTTP 403)"
    echo "  - Token lacks 'actions: write' scope"
    echo ""
    echo "💡 Continuing anyway - tests may have already passed"
    echo "💡 Check if PR is mergeable in the next cycle"
  fi
fi

exit 0
