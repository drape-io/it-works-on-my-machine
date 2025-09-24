# Auto Retry Action

A GitHub Action that automatically retries failed jobs using GitHub's native retry mechanism.

## Features

- ✅ **Native GitHub retry tracking** - Uses `gh run rerun` to retry the same workflow run
- ✅ **Satisfies required status checks** - Retries keep the same run ID
- ✅ **Configurable retry limits** - Set maximum retry attempts
- ✅ **Clean integration** - Just add one step to your job

## Usage

### Option 1: Standard Pattern (Let job fail naturally)
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        run: npm test
        
      - name: Auto retry on failure
        if: failure()
        uses: ./.github/actions/auto-retry
        with:
          max-attempts: 5
```

### Option 2: Continue-on-Error Pattern (More control)
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        id: test_step
        run: npm test
        continue-on-error: true
        
      - name: Auto retry on failure
        uses: ./.github/actions/auto-retry
        with:
          max-attempts: 5
          step-id: test_step
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `max-attempts` | Maximum retry attempts | No | `3` |
| `retry-workflow` | Workflow file to use for retries | No | `retry.yml` |
| `step-id` | ID of step to check (required for continue-on-error) | No | - |

## How It Works

1. **Job fails** → Action detects failure via `job.status`
2. **Check retry limit** → Compares `github.run_attempt` to `max-attempts`
3. **Trigger retry** → Calls `gh workflow run retry.yml` with original `run_id`
4. **Retry workflow** → Uses `gh run rerun --failed` to retry the same workflow run
5. **GitHub tracks retries** → Native `run_attempt` counter increments

## Benefits Over Other Retry Methods

- ✅ **Same workflow run** - Satisfies required status checks
- ✅ **GitHub API tracking** - Native `run_attempt` counter
- ✅ **Clean logs** - Each retry is clearly tracked by GitHub
- ✅ **Reusable** - Works with any job/workflow
- ✅ **Simple** - Just one step to add retry capability

## Requirements

- A `retry.yml` workflow that uses `gh run rerun` (see example in this repo)
- `actions: write` permission in the job using this action
