# Day 49 - DevSecOps: Secure CI/CD Pipeline

## Overview

- Integrated automated security checks into the Chattingo GitHub Actions pipeline.
- Implemented Trivy, BetterLeaks, Semgrep, SpotBugs, Hadolint, and OWASP ZAP.
- Applied workflow-level permissions to follow the principle of least privilege.

## Pipeline Architecture

```text
Pull Request
    |
    +--> Code Quality / SAST
    +--> Code Testing
    +--> Trivy Dependency Scan
    +--> Dockerfile Lint
    +--> Secret Detection
    |
    +--> PR Validation

Push to Main
    |
    +--> Build & Test
    +--> Docker Image Build & Push
    +--> Trivy Image Scan
    +--> OWASP ZAP DAST

Repository Security
    |
    +--> Secret Scanning
    +--> Push Protection
```

## 1. Trivy – Vulnerability Scanning

- Scanned project dependencies and Docker images for known CVEs.
- Targeted HIGH and CRITICAL severity vulnerabilities.
- Generated SARIF reports for GitHub Security integration.

**Image scanning configuration:**

```yaml
- name: Scan Docker Image
  uses: aquasecurity/trivy-action@v0.36.0
  with:
    image-ref: ashish0624/chattingo-backend:${{ inputs.image_tag }}
    format: sarif
    output: trivy-results.sarif
    severity: CRITICAL,HIGH
    exit-code: "1"
```

- `image-ref`: Specifies the container image to inspect.
- `severity`: Filters vulnerability severity.
- `exit-code: "1"`: Fails the step when matching vulnerabilities are found.
- `output`: Generates a SARIF security report.

**Note:** The current repository configuration uses `exit-code: "0"` and `continue-on-error: true`. Blocking enforcement is still pending.

## 2. Dependency Vulnerability Scanning

- Used Trivy filesystem scanning to inspect project dependencies.
- Dependency Review is intended to inspect dependency changes introduced through pull requests.

```yaml
dependency-review:
  runs-on: ubuntu-latest
  if: github.event_name == 'pull_request'
  permissions:
    contents: read
    pull-requests: read
  steps:
    - uses: actions/checkout@v4

    - name: Review Dependencies
      uses: actions/dependency-review-action@v4
      with:
        fail-on-severity: critical
```

- Detects vulnerable dependency changes before PR merging.
- **Status:** This action is a proposed addition; it is not yet present in the inspected workflow.

## 3. Secret Detection

- Integrated BetterLeaks for automated secret detection.
- Scans repository content and Git history for potentially exposed credentials.
- GitHub Secret Scanning identifies exposed supported secrets.
- Push Protection blocks supported secrets before they enter the repository.

If an AWS key is exposed, revoke or rotate it immediately and investigate unauthorized usage.

## 4. Static and Dynamic Security Testing

| Tool | Purpose |
|---|---|
| Semgrep | Static Application Security Testing (SAST) |
| SpotBugs | Java code analysis |
| Hadolint | Dockerfile linting |
| OWASP ZAP | Dynamic Application Security Testing (DAST) |
| Trivy | Dependency and container vulnerability scanning |
| BetterLeaks | Secret detection |

## 5. Least-Privilege Workflow Permissions

Applied explicit GitHub Actions permissions to restrict unnecessary access.

```yaml
permissions:
  contents: read
  security-events: write
```

- `contents: read`: Allows repository checkout and read operations.
- `security-events: write`: Allows publishing security scan results.
- Limits the potential impact of compromised actions or workflow steps.

## 6. Workflow Execution

**GitHub Actions:** [DevSecOps Pipeline – Run #41022724798](https://github.com/Ashish-6-24/chattingo/actions/runs/41022724798)

- Trigger: Push to `main`.
- Result: 11 jobs completed successfully.
- Trivy dependency audit: Completed.
- Backend and frontend image scans: Completed.
- BetterLeaks: Completed.
- Semgrep SAST: Completed.
- Hadolint: Completed.
- OWASP ZAP: Completed.

[![DevSecOps Pipeline](https://github.com/Ashish-6-24/chattingo/actions/workflows/devsecops_pipeline.yml/badge.svg)](https://github.com/Ashish-6-24/chattingo/actions/workflows/devsecops_pipeline.yml)

**Trivy scan screenshot:**

Add the actual vulnerability scan output screenshot here.

## 7. Security Improvements

- Enforce Trivy failure on HIGH and CRITICAL vulnerabilities.
- Add Dependency Review to the PR workflow.
- Verify GitHub Secret Scanning and Push Protection settings.
- Make secret detection blocking.
- Scan Docker images before pushing them to Docker Hub.
- Review non-blocking test and DAST configurations.
- Pin third-party actions to commit SHAs.
- Explore OIDC for short-lived cloud credentials.

## Key Takeaways

- Integrated security checks into CI/CD.
- Learned the difference between filesystem and container image scanning.
- Understood dependency review, secret detection, SAST, and DAST.
- Applied least-privilege workflow permissions.
- Identified the difference between a successful scan execution and an enforced security gate.
