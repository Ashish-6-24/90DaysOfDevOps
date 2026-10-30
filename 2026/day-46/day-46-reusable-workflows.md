# Day 46 - Reusable Workflows & Composite Actions

## Overview

- **Reusable workflows** let one workflow call another workflow, so complete jobs and pipelines can be shared.
- **Composite actions** package several steps into one action that can be used inside a job.
- Both approaches reduce duplicated YAML and make GitHub Actions easier to maintain.


## 1. Reusable Workflow Basics

- A reusable workflow is a workflow that another workflow can call instead of repeating the same jobs and steps.
- It is enabled with the `workflow_call` event.
- It must be stored directly in `.github/workflows/` (nested folders are not supported there).
- A caller invokes it at the **job level** using `uses:`.
- A regular action, including a composite action, is invoked inside a job's **steps**.

## 2. Reusable Build Workflow

File: `.github/workflows/reusable-build.yml`

- Accepts `app_name` and `environment` as inputs.
- Requires the caller to pass the `docker_token` secret.
- Checks out the caller's repository code.
- Prints the build target and checks that the Docker token is present without displaying its value.
- Generates a version using the first seven characters of the commit SHA.
- Exposes that version as a reusable-workflow output.

```yaml
name: Reusable Build

on:
  workflow_call:
    inputs:
      app_name:
        description: Application name
        required: true
        type: string
      environment:
        description: Target environment
        required: true
        default: staging
        type: string
    secrets:
      docker_token:
        required: true
    outputs:
      build_version:
        description: Generated build version
        value: ${{ jobs.build.outputs.build_version }}

permissions:
  contents: read

jobs:
  build:
    name: Build application
    runs-on: ubuntu-latest
    outputs:
      build_version: ${{ steps.version.outputs.build_version }}

    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Print build details
        env:
          APP_NAME: ${{ inputs.app_name }}
          TARGET_ENVIRONMENT: ${{ inputs.environment }}
        run: echo "Building ${APP_NAME} for ${TARGET_ENVIRONMENT}"

      - name: Check Docker token
        env:
          DOCKER_TOKEN: ${{ secrets.docker_token }}
        run: |
          if [ -n "$DOCKER_TOKEN" ]; then
            echo "Docker token is set: true"
          else
            echo "Docker token is set: false"
            exit 1
          fi

      - name: Generate build version
        id: version
        env:
          COMMIT_SHA: ${{ github.sha }}
        run: |
          short_sha="${COMMIT_SHA:0:7}"
          echo "build_version=v1.0-${short_sha}" >> "$GITHUB_OUTPUT"
```

## 3. Caller Workflow

File: `.github/workflows/call-build.yml`

- Runs when code is pushed to the `main` branch.
- Calls `reusable-build.yml` and passes its inputs and secret.
- Waits for the reusable build to finish, then prints the returned version.

```yaml
name: Call Reusable Build

on:
  push:
    branches:
      - main

permissions:
  contents: read

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
    with:
      app_name: my-web-app
      environment: production
    secrets:
      docker_token: ${{ secrets.DOCKER_TOKEN }}

  show-version:
    name: Display build version
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Print version from reusable workflow
        run: 'echo "Build version: ${{ needs.build.outputs.build_version }}"'
```

### Configure the Secret

- Open the repository on GitHub.
- Go to **Settings → Secrets and variables → Actions**.
- Create a repository secret named `DOCKER_TOKEN`.
- The caller passes it to the reusable workflow as `docker_token`.
- The example only checks that the token is present; it does not log in to Docker Hub or push an image.

## 4. How the Build Version Output Works

The output is passed through three levels:

1. **Step output:** The version-generation step writes `build_version` to `$GITHUB_OUTPUT`.
2. **Job output:** The `build` job maps `steps.version.outputs.build_version` to its output.
3. **Workflow output:** `workflow_call.outputs` exposes `jobs.build.outputs.build_version` to the caller.

The caller's dependent job reads it with:

```yaml
${{ needs.build.outputs.build_version }}
```

## 5. Custom Composite Action

File: `.github/actions/setup-and-greet/action.yml`

- Takes a name and an optional language code.
- Prints a greeting in English, Nepali, Hindi, or Spanish; unsupported codes use the English greeting.
- Prints the current UTC date and runner operating system.
- Sets the `greeted` output to `true` after the greeting runs.
- Uses environment variables for input values rather than inserting user-provided text directly into shell commands.

```yaml
name: Setup and Greet
description: Print a greeting, date, and runner information

inputs:
  name:
    description: Name to greet
    required: true
  language:
    description: Greeting language (en, ne, hi, or es)
    required: false
    default: en

outputs:
  greeted:
    description: Indicates that the greeting step completed
    value: ${{ steps.set-output.outputs.greeted }}

runs:
  using: composite
  steps:
    - name: Print greeting
      id: greet
      shell: bash
      env:
        PERSON_NAME: ${{ inputs.name }}
        GREETING_LANGUAGE: ${{ inputs.language }}
      run: |
        case "$GREETING_LANGUAGE" in
          ne) greeting="नमस्ते" ;;
          hi) greeting="नमस्ते" ;;
          es) greeting="Hola" ;;
          *)  greeting="Hello" ;;
        esac

        printf '%s, %s!\n' "$greeting" "$PERSON_NAME"

    - name: Show date and runner OS
      shell: bash
      run: |
        echo "Date (UTC): $(date -u '+%Y-%m-%d %H:%M:%S')"
        echo "Runner OS: $RUNNER_OS"

    - name: Set action output
      id: set-output
      shell: bash
      run: echo "greeted=true" >> "$GITHUB_OUTPUT"
```

## 6. Test the Composite Action

File: `.github/workflows/composite-action-demo.yml`

- Uses `workflow_dispatch` so the action can be tested manually from the Actions tab.
- Checks out the repository before calling the local action.
- Reads the composite action's output in a later step.

```yaml
name: Composite Action Demo

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Run setup-and-greet action
        id: greeting
        uses: ./.github/actions/setup-and-greet
        with:
          name: DevOps Learner
          language: ne

      - name: Check action output
        if: steps.greeting.outputs.greeted == 'true'
        run: echo "The greeting action completed successfully."
```

## 7. Reusable Workflow vs Composite Action

| Feature | Reusable Workflow | Composite Action |
|---|---|---|
| Called by | `workflow_call`, using `jobs.<job_id>.uses` | `uses:` inside a job step |
| Can contain jobs? | Yes, one or more jobs | No; it contains steps |
| Can contain multiple steps? | Yes, inside its jobs | Yes, inside the composite action |
| Where does it live? | Directly in `.github/workflows/` | In an action directory containing `action.yml`; commonly `.github/actions/` |
| Can it access secrets directly? | Yes, through declared `workflow_call.secrets` or inherited secrets | No native `secrets` context; pass a secret explicitly as an input when needed |
| Best used for | Sharing complete jobs or CI/CD workflows | Sharing a repeatable group of steps within a job |

