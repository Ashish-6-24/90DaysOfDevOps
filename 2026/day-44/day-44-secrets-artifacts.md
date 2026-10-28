# Day 44 - Secrets, Artifacts & CI Testing

## GitHub Secrets

- Created the `MY_SECRET_MESSAGE` repository secret.
- Passed the secret through an environment variable.
- Verified its presence without exposing its value.

```yaml
- name: Verify secret
  env:
    MY_SECRET: ${{ secrets.MY_SECRET_MESSAGE }}
  run: |
    if [ -n "$MY_SECRET" ]; then
      echo "The secret is set: true"
    else
      echo "The secret is set: false"
      exit 1
    fi
```

- **Security:** Never expose credentials in CI logs. GitHub masks recognized secret values, but masking is not a substitute for safe handling.

## Docker Credentials

Configured repository secrets for future Docker Hub workflows:

- `DOCKER_USERNAME`
- `DOCKER_TOKEN`

Credentials are stored in GitHub Secrets instead of being hardcoded in workflow files.

## Artifact Management

- Generated a test report during a workflow run.
- Uploaded the report using `actions/upload-artifact@v4`.
- Downloaded and inspected the report from GitHub Actions.

```yaml
- name: Upload report
  uses: actions/upload-artifact@v7.0.2
  with:
    name: test-report
    path: output/test-report.txt
```

### Sharing Artifacts Between Jobs

```yaml
- name: Download report
  uses: actions/download-artifact@v8.0.2
  with:
    name: test-report
    path: downloaded-report
```

- Artifacts preserve outputs after a job finishes.
- Common uses include test reports, build packages, logs, and files passed between jobs.

## Running Real Tests in CI

- Added a system information Bash script to the practice repository.
- Validated its syntax using `bash -n`.
- Executed the script on an Ubuntu GitHub-hosted runner.
- Used the script's exit status to determine whether the step succeeds or fails.

```yaml
- name: Validate Bash syntax
  run: bash -n scripts/systems_info.sh

- name: Execute script
  run: bash scripts/systems_info.sh
```

- A non-zero exit code fails the step by default.
- Tested failure handling by intentionally introducing an error, then correcting the script.
- Verified that the workflow returned to a passing state.

## Dependency Caching

- Used `actions/cache@v6.1.0` to reuse downloaded dependencies.
- Configured a cache key based on the runner operating system and dependency files.

```yaml
- name: Cache dependencies
  uses: actions/cache@v6.1.0
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

- **Cached data:** Files stored in `~/.cache/pip`.
- **Storage:** GitHub-managed Actions cache, available to eligible later workflow runs.
- Matching keys can reduce repeated downloads; cache misses require dependencies to be fetched again.

## Key Learnings

- Protect credentials with repository secrets and environment variables.
- Use artifacts to retain and transfer workflow outputs.
- Run actual scripts and tests as part of CI.
- Confirm both failure handling and successful recovery.
- Cache dependencies to improve repeated workflow execution.

- [ ] Include screenshots showing the artifact and passing CI run.
- [ ] Commit and push the documentation to your `90DaysOfDevOps` repository.
