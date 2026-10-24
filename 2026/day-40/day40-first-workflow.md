# Day 40 - Building My First GitHub Actions Workflow

## Project Overview

For Day 40 of my #90DaysOfDevOps challenge, I created my first GitHub Actions workflow to understand how automated tasks run after a code push.

I used a public repository named `github-actions-practice` and configured a workflow to run on GitHub-hosted Ubuntu runners. I started with a simple greeting and extended the workflow to inspect the execution environment.

## Objectives

- Understand the basic structure of a GitHub Actions workflow.
- Trigger an automated job whenever code is pushed.
- Execute shell commands on an Ubuntu runner.
- Access GitHub-provided environment variables.
- Observe a failed workflow and identify the cause.
- Document the results and capture a successful pipeline run.

## Repository Structure

```text
github-actions-practice/
├── .github/
│   └── workflows/
│       └── hello.yml
└── README.md
```

The workflow is stored in `.github/workflows/hello.yml`, which allows GitHub Actions to discover and execute it.

## Workflow Configuration

The following is the final workflow configuration, without the temporary failure step:

**File:** `.github/workflows/hello.yml`

```yaml
name: Hello GitHub Actions

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

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

## Understanding the Workflow

### 1. `on:`

Defines the event that starts the workflow. In this project, a push to the repository triggers a new run.

### 2. `jobs:`

Contains the jobs that GitHub Actions executes. I defined one job named `greet`.

### 3. `runs-on:`

Specifies the runner environment. `ubuntu-latest` selects a GitHub-hosted Ubuntu runner.

### 4. `steps:`

Lists the operations performed by the job in sequence. Each step either invokes an action or executes a command.

### 5. `uses:`

Runs an existing GitHub Action. I used `actions/checkout@v4` to make the repository's files available to the runner.

### 6. `run:`

Executes a shell command on the runner. Examples in my workflow include `date`, `ls -ltha`, and `echo`.

### 7. `name:`

Provides a readable label for the workflow or an individual step, making the execution logs easier to understand.

## Additional Workflow Checks

| Check | Purpose |
|---|---|
| Current date | Displays the runner's current date and time. |
| Branch name | Uses `${{ github.ref_name }}` to identify the branch that triggered the run. |
| File listing | Uses `ls -ltha` to display repository contents. |
| Runner operating system | Uses `$RUNNER_OS` to display the runner's operating system. |

These checks helped me understand what information is available during workflow execution and how shell commands can be automated through CI/CD.

## Failure Testing and Troubleshooting

As part of the exercise, I tested the workflow's failure behavior by adding a temporary command:

```bash
exit 1
```

This command returns a nonzero exit status, which causes the step and job to fail.

When investigating a failed run, I can open the **Actions** tab, select the run with a red failure indicator, open the affected job, and inspect the step logs to identify the command that caused the problem.

After removing the intentional failure, I push the corrected workflow and verify that the latest run succeed . 

**Screenshot location:** `2026/day-40/screenshots/green-workflow-run.png`

## Key Learnings

- A Git push can automatically trigger a CI workflow.
- GitHub-hosted runners provide an environment for executing automated commands.
- Workflow events, jobs, runners, and steps each have distinct responsibilities.
- GitHub context variables and runner environment variables provide useful execution information.
- A failed step can stop a job, and the Actions logs help locate the cause.
- Fixing an issue and pushing the correction triggers another workflow run.

## Conclusion

This exercise gave me practical experience with GitHub Actions and the fundamentals of CI automation. I learned how to define a workflow, inspect its execution, troubleshoot a failure, and verify a successful run.

This is my first step toward building more advanced CI/CD pipelines for testing, building, and deploying applications as part of my DevOps learning journey.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham

