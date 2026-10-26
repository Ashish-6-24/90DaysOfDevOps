# Day 43 – Jobs, Steps, Environment Variables & Conditionals

## Objective

Learn how GitHub Actions controls workflow execution using multiple jobs, job dependencies, environment variables, outputs, GitHub contexts, and conditional execution.

## Task 1: Multi-Job Workflow

The `multi-job.yml` workflow contains three jobs: `build`, `test`, and `deploy`. The `needs` keyword defines the execution order, so tests wait for the build and deployment waits for tests.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building the app"

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running tests"

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying"
```

The dependency chain is:

```text
build → test → deploy
```

**Verification:** In the repository's **Actions** tab, open a run of `Multi-Job CI/CD Pipeline` and check that the workflow graph shows `build` first, then `test`, then `deploy`. The later jobs should be skipped if a required earlier job fails.

## Task 2: Environment Variables and GitHub Context

Environment variables can be defined at workflow, job, or step scope. The variable is available within the scope where it is defined and its child scopes, unless it is overridden.

```yaml
# Workflow level
env:
  APP_NAME: myapp
```

```yaml
# Job level, inside a job definition
env:
  ENVIRONMENT: staging
```

```yaml
# Step level, inside a step definition
env:
  VERSION: 1.0.0
```

Example step that prints the values and GitHub context:

```yaml
- name: Print variables and GitHub context
  env:
    VERSION: 1.0.0
    COMMIT_SHA: ${{ github.sha }}
    ACTOR_NAME: ${{ github.actor }}
  run: |
    echo "Application: $APP_NAME"
    echo "Environment: $ENVIRONMENT"
    echo "Version: $VERSION"
    echo "Commit SHA: $COMMIT_SHA"
    echo "Triggered by: $ACTOR_NAME"
```

- `APP_NAME` identifies the application.
- `ENVIRONMENT` identifies the target environment, such as staging.
- `VERSION` is scoped to the print step.
- `github.sha` provides the commit SHA for the workflow run.
- `github.actor` identifies the user or account that triggered the run.

**Verification:** Check the step logs for all five values. The SHA and actor should match the actual run.

## Task 3: Job Outputs

A job output exposes a value produced by one of its steps so that a dependent job can use it. In this example, the first job generates today's date and the second job prints the date it receives.

```yaml
jobs:
  set-date:
    runs-on: ubuntu-latest
    outputs:
      today: ${{ steps.date-step.outputs.today }}
    steps:
      - name: Generate date
        id: date-step
        run: echo "today=$(date -u +'%Y-%m-%d')" >> "$GITHUB_OUTPUT"

  read-date:
    needs: set-date
    runs-on: ubuntu-latest
    steps:
      - name: Print received date
        run: echo "Date received from first job: ${{ needs.set-date.outputs.today }}"
```

### What do `needs:` and `outputs:` do?

- `needs: set-date` makes `read-date` wait for the `set-date` job to complete successfully and allows it to reference that job's outputs.
- `outputs:` maps a step output to a job-level output that other dependent jobs can access.
- `$GITHUB_OUTPUT` is used by a step to publish an output value.
- `${{ needs.set-date.outputs.today }}` reads the value exposed by the `set-date` job.

**Why pass outputs between jobs?** Jobs can run on separate runners, so ordinary shell variables do not automatically carry over to another job. Outputs let a job pass generated values—such as a version, artifact name, image tag, date, or deployment URL—to a later job without hard-coding the value.

**Verification:** In the Actions run, confirm that `read-date` starts after `set-date` and prints the generated date.

## Task 4: Conditionals and Error Handling

GitHub Actions supports conditions at both step and job level. These examples demonstrate the required cases.

```yaml
steps:
  - name: Run only on main
    if: github.ref == 'refs/heads/main'
    run: echo "This step runs only on main."

  - name: Simulate an optional failure
    id: optional-check
    continue-on-error: true
    run: |
      echo "Running optional check..."
      exit 1

  - name: Handle the failed step
    if: steps.optional-check.outcome == 'failure'
    run: echo "The optional check failed; handling the result."
```

A job can be restricted to push events with a job-level condition:

```yaml
push-only:
  if: github.event_name == 'push'
  runs-on: ubuntu-latest
  steps:
    - run: echo "This job runs for push events only."
```

The workflow must listen for both `push` and `pull_request` events to demonstrate the difference; the condition causes `push-only` to be skipped for pull requests.

- `if: github.ref == 'refs/heads/main'` checks whether the run's Git reference is the `main` branch.
- `steps.optional-check.outcome == 'failure'` checks whether the optional step's original outcome was a failure.
- `continue-on-error: true` allows the workflow to continue after that step fails, rather than letting the failure fail the job by itself.

**Verification:** Confirm that the optional step is marked as failed, the handling step executes, and the job continues. Test with a push and a pull request to see the push-only job run or skip as expected.

> **Branch note:** This repository's default branch is currently `master`. The assignment's examples use `main`. To test the main-only condition on the current primary branch, either change the condition to `refs/heads/master` or test it on a branch named `main`. Apply the same branch-name choice to the summary in Task 5.

## Task 5: Smart Pipeline

The `smart-pipeline.yml` workflow triggers on pushes to any branch. The `lint` and `test` jobs have no dependency on each other, so they can run in parallel. The `summary` job waits for both.

```yaml
name: Smart Pipeline

on:
  push:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Linting code"

  test:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running tests"

  summary:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - name: Print branch and commit summary
        env:
          COMMIT_MESSAGE: ${{ github.event.head_commit.message }}
        run: |
          if [ "$GITHUB_REF_NAME" = "main" ]; then
            echo "This is a main branch push."
          else
            echo "This is a feature branch push."
          fi
          echo "Commit message: $COMMIT_MESSAGE"
```

Workflow graph:

```text
          ┌── lint ──┐
push ────┤          ├── summary
          └── test ──┘
```

**Verification:** Open a push run in the Actions tab. Confirm that `lint` and `test` can start independently, while `summary` waits for both. Check the summary logs for the branch classification and commit message.

## Key Learning

- **Jobs** are separate units of work, typically run on separate runner instances.
- **Steps** run in sequence within a job.
- **`needs:`** defines job dependencies and controls which jobs must complete successfully before a dependent job can run.
- **Environment variables** provide configuration at workflow, job, or step scope.
- **GitHub contexts** provide workflow metadata such as the commit SHA, actor, branch, and event information.
- **`outputs:`** passes generated step values from one job to another dependent job.
- **`if:`** controls whether a step or job should run.
- **`continue-on-error: true`** allows a step to fail without automatically failing the entire job.
- Independent jobs can run in parallel; dependent jobs wait for their prerequisites.

## Submission Checklist

- [ ] Confirm all workflow files are present in `.github/workflows/`.
- [ ] Run the workflows from the **Actions** tab and review their logs and dependency graphs.
- [ ] Add this file to `2026/day-43/day-43-jobs-steps.md` in the repository.
- [ ] Commit and push the documentation and workflow changes.

> The `echo` commands in these learning workflows demonstrate GitHub Actions control flow. They do not perform real application linting, testing, building, or deployment.
