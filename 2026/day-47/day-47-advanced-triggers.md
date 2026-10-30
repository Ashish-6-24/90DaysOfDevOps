# Day 47 Advanced GitHub Actions Triggers

## PR Lifecycle Events

**Workflow:** `.github/workflows/pr-lifecycle.yml`

- Listens for important pull request activities:
  - `opened` – PR created.
  - `synchronize` – New commits pushed.
  - `reopened` – Closed PR reopened.
  - `closed` – PR closed or merged.
- Captures the PR title, author, source branch, and target branch.
- Executes a separate step when a PR is successfully merged.

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened, closed]
```

Merged PR condition:

```yaml
if: github.event.action == 'closed' && github.event.pull_request.merged == true
```

## PR Validation

**Workflow:** `.github/workflows/pr-checks.yml`

Configured three independent validation jobs:

- **File Size:** Rejects changed files exceeding 1 MB.
- **Branch Naming:** Accepts only `feature/*`, `fix/*`, and `docs/*`.
- **PR Description:** Warns when the PR body is empty without blocking the workflow.

Example file-size validation:

```bash
# 1 MB = 1048576 bytes
if [ "$size" -gt 1048576 ]; then
  echo "File '$file' is too large ($size bytes)."
  failed=1
fi
```

Allowed branch prefixes:

```text
feature/*
fix/*
docs/*
```

Branch validation logic:

```bash
case "$BRANCH_NAME" in
  feature/*|fix/*|docs/*) echo "Valid branch" ;;
  *) echo "::error::Invalid branch name"; exit 1 ;;
esac
```

## Cron Schedules

**Workflow:** `.github/workflows/scheduled-tasks.yml`

- Added two recurring schedules.
- Included `workflow_dispatch` for manual testing.
- Printed the cron expression responsible for the scheduled run.
- Added a `curl` health check to verify an endpoint response.

Monday at 2:30 AM UTC:

```text
30 2 * * 1
```

Every 6 hours:

```text
0 */6 * * *
```

Every weekday at 9 AM IST:

```text
30 3 * * 1-5
```

First day of every month at midnight UTC:

```text
0 0 1 * *
```

Schedule identification:

```yaml
run: echo "Schedule: ${{ github.event.schedule }}"
```

Health check:

```bash
curl --fail --silent --show-error "$HEALTHCHECK_URL"
```

- GitHub evaluates cron schedules in UTC by default.
- Scheduled workflows execute from the default branch.
- GitHub may delay scheduled runs during periods of high Actions demand; queued runs can also be dropped.
- In public repositories, schedules are automatically disabled after 60 days without repository activity.

## Path & Branch Filters

**Workflows:** `.github/workflows/smart-triggers.yml` and `.github/workflows/docs-ignore.yml`

- Configured application-specific triggers for `src/` and `app/`.
- Restricted execution to `main` and `release/*`.
- Created a separate workflow to exclude documentation-only changes.

Application file filter:

```yaml
on:
  push:
    branches:
      - main
      - 'release/*'
    paths:
      - 'src/**'
      - 'app/**'
```

Documentation exclusion:

```yaml
on:
  push:
    paths-ignore:
      - '*.md'
      - 'docs/**'
```

**When to use each filter:**

- `paths`: Use an allowlist when only selected file changes should start a workflow.
- `paths-ignore`: Use an exclusion list when most changes should trigger a workflow except specified files or directories.
- When combining branch and path filters, both conditions must match.

## `workflow_run`

**Workflows:** `.github/workflows/tests.yml` and `.github/workflows/deploy-after-tests.yml`

- Created a test workflow that runs whenever code is pushed.
- Configured a second workflow to listen for its completion.
- Checked the result of the preceding workflow before deployment.
- Prevented deployment when tests fail.

Test workflow trigger:

```yaml
name: Run Tests

on:
  push:
```

Chaining trigger:

```yaml
on:
  workflow_run:
    workflows: ["Run Tests"]
    types: [completed]
```

Deployment condition:

```yaml
if: github.event.workflow_run.conclusion == 'success'
```

Failure notification:

```yaml
- name: Report unsuccessful tests
  if: github.event.workflow_run.conclusion != 'success'
  run: echo "::warning::Tests failed. Deployment skipped."
```

`workflow_run` allows one independently defined workflow to react to another workflow's completion.

## `workflow_run` vs `workflow_call`

| Comparison | `workflow_run` | `workflow_call` |
|---|---|---|
| Main purpose | Chain workflows | Reuse workflow definitions |
| Activation | Another workflow completes | Another workflow calls it |
| Relationship | Separate workflow runs | Caller invokes reusable logic |
| Data | Workflow run event context | Inputs, secrets, and outputs |
| Example | Tests → Deployment | Shared build or security checks |

## `repository_dispatch`

**Workflow:** `.github/workflows/external-trigger.yml`

- Accepts custom events sent through the GitHub API.
- Listens specifically for `deploy-request`.
- Reads deployment information from `client_payload`.
- Useful for connecting external services with GitHub Actions.

Event configuration:

```yaml
name: External Event Trigger

on:
  repository_dispatch:
    types: [deploy-request]

jobs:
  process-dispatch:
    runs-on: ubuntu-latest
    steps:
      - name: Print Client Payload Environment
        run: |
          echo "Deployment Environment: ${{ github.event.client_payload.environment }}"
```

Trigger using GitHub CLI:

```bash
gh api repos/<owner>/<repo>/dispatches \
  -f event_type=deploy-request \
  -f client_payload='{"environment":"production"}'
```

- External deployment tools can request a release.
- Monitoring services can trigger incident-response workflows.
- Bots and internal automation systems can initiate repository tasks.
- The API request requires suitable repository access.

## Key Learnings

- PR activity types provide more control over pull request automation.
- Validation jobs help enforce repository contribution standards.
- Cron expressions automate recurring maintenance and health checks.
- Path and branch filters prevent unnecessary workflow executions.
- `workflow_run` connects independent workflow executions.
- `workflow_call` enables reusable workflow configurations.
- `repository_dispatch` connects external services to GitHub Actions.
- Event-driven workflows make CI/CD pipelines more flexible and automated.
