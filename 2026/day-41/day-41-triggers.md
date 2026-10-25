# Day 41 – Triggers & Matrix Builds

## Pull Request Trigger

**File:** `.github/workflows/pr-check.yml`

```yaml
name: Pull Request Check

on:
  pull_request:
    branches: [main]
    types: [opened, synchronize]

jobs:
  pr-check:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v7
      - name: Print source branch
        run: 'echo "PR check running for branch: ${{ github.head_ref }}"'
```

This workflow runs when a pull request targeting `main` is opened or updated with new commits. Verify its result in the pull request checks.

## Scheduled Trigger

**File:** `.github/workflows/hello.yml`

```yaml
name: Hello GitHub Actions

on:
  push:
  schedule:
    - cron: '0 0 * * *'

jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v7
      - name: Say hello
        run: echo "Hello from GitHub Actions!"
      - name: Current date
        run: date
      - name: Branch
        run: 'echo "Branch: ${{ github.ref_name }}"'
      - name: List files
        run: ls -ltha
      - name: Runner OS
        run: 'echo "OS: $RUNNER_OS"'
```

- Every day at midnight UTC: `0 0 * * *`
- Every Monday at 9 AM UTC: `0 9 * * 1`

Cron field order: `minute hour day-of-month month day-of-week`. The workflow can run on both a push and its scheduled time.

## Manual Trigger

**File:** `.github/workflows/manual.yml`

```yaml
name: Manual Environment Workflow

on:
  workflow_dispatch:
    inputs:
      environment:
        description: Select the environment
        required: true
        type: choice
        options:
          - staging
          - production
        default: staging

jobs:
  show-environment:
    runs-on: ubuntu-latest
    steps:
      - name: Print selected environment
        run: |
          echo "Selected environment: ${{ inputs.environment }}"
```

Start this workflow from the Actions tab, choose `staging` or `production`, then check the job logs to confirm the selected value is printed.

## Matrix Build

**File:** `.github/workflows/matrix.yml`

```yaml
name: Python Matrix Build

on:
  push:
  workflow_dispatch:

jobs:
  test-python:
    name: Python ${{ matrix.python-version }} on ${{ matrix.os }}
    runs-on: ${{ matrix.os }}

    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest]
        python-version: ["3.10", "3.11", "3.12"]
        exclude:
          - os: windows-latest
            python-version: "3.10"

    steps:
      - name: Checkout code
        uses: actions/checkout@v7
      - name: Set up Python
        uses: actions/setup-python@v7
        with:
          python-version: ${{ matrix.python-version }}
      - name: Print Python version
        run: python --version
```

- Three Python versions on Ubuntu produce **3 jobs**.
- Adding Ubuntu and Windows produces **6 combinations** (3 Python versions × 2 operating systems).
- Excluding Windows with Python 3.10 leaves **5 jobs**.

## Exclude & Fail-Fast

For the failure test, temporarily add this step to the matrix job:

```yaml
      - name: Intentionally fail one matrix job
        if: matrix.os == 'windows-latest' && matrix.python-version == '3.11'
        run: exit 1
```

- `fail-fast: true` (the default): GitHub Actions cancels other in-progress matrix jobs after a failure.
- `fail-fast: false`: Other matrix jobs are allowed to continue when one job fails.

The overall workflow still fails if any job fails. After the test, remove the temporary step and verify that the final matrix run succeeds.

## Key Learnings

- `pull_request` runs checks when a pull request is opened or updated.
- `schedule` uses cron syntax to start workflows automatically.
- `workflow_dispatch` allows a workflow to be started manually with inputs.
- A matrix tests multiple combinations using one job definition.
- `exclude` removes a selected combination, while `fail-fast` controls how other jobs respond to a failure.

## Conclusion

Day 41 introduces pull request, scheduled and manual triggers, as well as matrix builds across different Python versions and operating systems. It also demonstrates how matrix exclusions and fail-fast behavior affect workflow execution.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
