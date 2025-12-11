# Scripts Documentation

## check-and-retry-failed-jobs.sh

Checks a PR for failed workflow jobs and triggers retry workflow if failures are found.

### Usage

```bash
./scripts/check-and-retry-failed-jobs.sh <pr_number> <repository> [dry_run]
```

**Parameters:**
- `pr_number`: The PR number to check (required)
- `repository`: The repository in format "owner/repo" (required)
- `dry_run`: Set to "true" for dry run mode (default: false)

**Examples:**

```bash
# Dry run - won't trigger retry
./scripts/check-and-retry-failed-jobs.sh 958 drape-io/it-works-on-my-machine true

# Actually trigger retry
./scripts/check-and-retry-failed-jobs.sh 958 drape-io/it-works-on-my-machine false
```

### Requirements

#### Environment Variables

- `GH_TOKEN`: GitHub token for authentication (required)

#### Token Permissions

The `PERSONAL_ACCESS_TOKEN` or `GH_TOKEN` used by this script must have the following permissions:

**Required Scopes:**
- ✅ `repo` - Full control of private repositories
  - Needed to read PR information and workflow runs
- ✅ `workflow` - Update GitHub Action workflows
  - Needed to trigger `workflow_dispatch` events
- ✅ `actions: write` - Write access to GitHub Actions
  - Needed to trigger retry workflows

**How to Update Token Permissions:**

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Edit your token or create a new one
3. Ensure these scopes are checked:
   - ✅ repo
   - ✅ workflow
4. Update your repository secrets with the new token

**Common Errors:**

If you see:
```
HTTP 403: Resource not accessible by personal access token
```

This means your token lacks the `workflow` scope. Update the token permissions and refresh the secret.

### How It Works

1. **Get PR info**: Fetches PR details and branch name
2. **Find workflow runs**: Uses `gh pr checks` to find workflow runs for the PR
   - More reliable than querying all workflow runs
   - Works for PRs of any age
3. **Check for failures**: Queries the workflow run jobs to find failures
4. **Trigger retry**: If failures found and not in dry run mode, triggers `retry.yml` workflow
5. **Error handling**: Gracefully handles errors (e.g., token permission issues) and exits 0

### Exit Codes

- `0`: Success (even if no failures found or retry trigger failed)
- `1`: Invalid arguments or authentication failure

The script always exits 0 after attempting retry to ensure the calling workflow continues.

## Token Setup for CI/CD

### GitHub Actions Workflow

In your workflow, set the token:

```yaml
env:
  GH_TOKEN: ${{ secrets.PERSONAL_ACCESS_TOKEN }}

steps:
  - name: Check and retry failed jobs
    run: |
      ./scripts/check-and-retry-failed-jobs.sh "$pr_number" "${{ github.repository }}" false
```

### Local Development

For local testing, set the token in `.envrc` (if using direnv):

```bash
GH_TOKEN=ghp_your_token_here
```

Or export it directly:

```bash
export GH_TOKEN=ghp_your_token_here
./scripts/check-and-retry-failed-jobs.sh 958 drape-io/it-works-on-my-machine true
```

## Troubleshooting

### Issue: "No workflow runs found for this PR"

**Cause**: PR has no workflow runs yet or they haven't been triggered.

**Solution**: Wait for the PR's workflows to run, or trigger them manually.

### Issue: "HTTP 403: Resource not accessible"

**Cause**: Token lacks required permissions (usually `workflow` scope).

**Solution**: Update token permissions as described above.

### Issue: Script hangs or times out

**Cause**: GitHub API rate limiting or network issues.

**Solution**:
- Check GitHub API rate limits: `gh api rate_limit`
- Retry after a few minutes
- Use a token with higher rate limits (authenticated tokens get 5000 req/hour)

### Issue: "Failed jobs found but retry didn't trigger"

**Check**:
1. Token permissions (see above)
2. Workflow file exists: `.github/workflows/retry.yml`
3. Workflow accepts `workflow_dispatch` with `run_id` input
4. Check workflow logs for detailed error messages
