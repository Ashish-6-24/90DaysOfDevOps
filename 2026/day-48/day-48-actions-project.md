# Day 48 - GitHub Actions Capstone

## Project Overview

An end-to-end CI/CD project using **GitHub Actions, Python Flask, Docker, and Docker Hub**.

- Built a Flask application with a `/health` endpoint.
- Automated application testing using reusable workflows.
- Built and published Docker images to Docker Hub.
- Configured separate PR and main branch pipelines.
- Added a production deployment approval gate.
- Automated container health checks every 12 hours.

## Application Structure

```text
github-actions-capstone/
├── app/
│   └── main.py
├── tests/
│   └── test_app.py
├── .github/
│   └── workflows/
│       ├── reusable-build-test.yml
│       ├── reusable-docker.yml
│       ├── pr-pipeline.yml
│       ├── main-pipeline.yml
│       └── health-check.yml
├── Dockerfile
├── .dockerignore
├── requirements.txt
├── README.md
└── day-48-actions-project.md
```

## Application Endpoints

| Endpoint | Description |
|---|---|
| `/` | Returns an application welcome message |
| `/health` | Returns application health status |

**Application port:** `5000`

## GitHub Actions Pipeline

### 1. Reusable Build & Test

**File:** `reusable-build-test.yml`

- Triggered using `workflow_call`.
- Accepts Python version and test execution inputs.
- Installs application dependencies.
- Runs pytest when enabled.
- Exposes the test result as a workflow output.

### 2. Reusable Docker Build & Push

**File:** `reusable-docker.yml`

- Triggered using `workflow_call`.
- Accepts Docker image name and tag.
- Authenticates with Docker Hub.
- Builds and pushes Docker images.
- Exposes the published image URL.

### 3. PR Pipeline

**File:** `pr-pipeline.yml`

- Runs when a PR is opened or updated against `main`.
- Calls the reusable build-and-test workflow.
- Prints a PR validation summary.
- Does not build or publish Docker images.

### 4. Main Branch Pipeline

**File:** `main-pipeline.yml`

- Runs on pushes to `main`.
- Executes build and tests.
- Builds and publishes Docker images.
- Uses `latest` and short commit SHA tags.
- Runs the deployment job using the `production` environment.
- Supports manual approval through environment protection rules.

### 5. Scheduled Health Check

**File:** `health-check.yml`

- Runs every 12 hours or manually using `workflow_dispatch`.
- Pulls the latest Docker image.
- Starts the container and checks `/health`.
- Generates a report in GitHub Actions summary.
- Removes the container after execution.

**Schedule configuration:**

```yaml
on:
  schedule:
    - cron: '0 */12 * * *'
  workflow_dispatch:
```

**Pull and run the Docker image:**

```yaml
- name: Run container
  run: |
    docker pull "$IMAGE"
    docker run -d \
      --name capstone-health \
      -p 5000:5000 \
      "$IMAGE"
    sleep 5
```

**Check application health:**

```bash
if curl --fail --silent http://localhost:5000/health; then
  STATUS="PASSED"
else
  STATUS="FAILED"
fi
```

**Generate workflow summary:**

```bash
echo "## Health Check Report" >> "$GITHUB_STEP_SUMMARY"
echo "- Image: $IMAGE" >> "$GITHUB_STEP_SUMMARY"
echo "- Status: $STATUS" >> "$GITHUB_STEP_SUMMARY"
echo "- Time: $(date -u)" >> "$GITHUB_STEP_SUMMARY"

[ "$STATUS" = "PASSED" ]
```

**Container cleanup:**

```yaml
- name: Cleanup
  if: always()
  run: docker rm -f capstone-health || true
```

## Pipeline Architecture

```text
Pull Request
     |
     v
Build & Test
     |
     v
PR Validation Summary


Merge to main
     |
     v
Build & Test
     |
     v
Docker Build & Push
     |
     v
Production Deployment


Every 12 Hours
     |
     v
Pull Latest Docker Image
     |
     v
Run Container
     |
     v
Health Check
     |
     v
Actions Summary
```

## Repository Configuration

Create the following GitHub Actions secrets:

| Secret | Description |
|---|---|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_TOKEN` | Docker Hub access token |

Create the repository variable:

```text
DOCKER_IMAGE
```

Example value:

```text
YOUR_DOCKERHUB_USERNAME/github-actions-capstone
```

Configure a GitHub environment:

```text
production
```

- Enable required reviewers for deployment approval.
- Configure environment protection rules under repository settings.

## Future Improvements

- Add Trivy vulnerability scanning.
- Generate and upload an SBOM.
- Add Slack notifications.
- Introduce staging and production environments.
- Implement automated deployment rollback.
- Deploy the application to a cloud server or Kubernetes.

## Key Learnings

- Building reusable GitHub Actions workflows.
- Managing workflow inputs, secrets, and outputs.
- Automating PR validation and main branch pipelines.
- Building and publishing Docker images.
- Managing production environment approvals.
- Scheduling automated container health checks.
- Connecting CI/CD workflows into an end-to-end pipeline.
