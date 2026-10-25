# Day 42 – Understanding GitHub Actions Runners

## 1. GitHub-Hosted Runners

GitHub-hosted runners are managed compute environments that GitHub provides to execute workflow jobs. This workflow compares three operating systems and prints basic details about each runner.

**File:** `.github/workflows/runner-os.yml`

```yaml
name: Runner OS Comparison

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  ubuntu:
    runs-on: ubuntu-latest
    steps:
      - name: Show runner details
        run: |
          echo "Operating system: Ubuntu"
          hostname
          whoami

  windows:
    runs-on: windows-latest
    steps:
      - name: Show runner details
        run: |
          Write-Output "Operating system: Windows"
          hostname
          whoami

  macos:
    runs-on: macos-latest
    steps:
      - name: Show runner details
        run: |
          echo "Operating system: macOS"
          hostname
          whoami
```

GitHub maintains these machines and their runner images. The three jobs use separate operating-system environments and may execute in parallel, depending on runner availability.

![GitHub-hosted runner jobs](screenshots/runner-os.png)

## 2. Checking Available Tools

Ubuntu runner images contain a range of tools commonly needed for building and testing software. This workflow records the versions available when it runs.

**File:** `.github/workflows/runner-tools.yml`

```yaml
name: Inspect Ubuntu Tools

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  inspect:
    runs-on: ubuntu-latest
    steps:
      - name: Print tool versions
        run: |
          docker --version
          python3 --version
          node --version
          git --version
```

Pre-installed software saves setup time and reduces the number of installation steps in a pipeline. Available versions can change when GitHub updates its runner image, so I should check the output from my run.

References:
- [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
- [Ubuntu runner image software inventory](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md)

![Ubuntu tool versions](screenshots/runner-tools.png)

## 3. Registering a Self-Hosted Runner

A self-hosted runner is a computer or virtual machine that I maintain and connect to my GitHub repository to execute workflow jobs.

Setup summary:

1. Open the repository settings and go to **Actions → Runners**.
2. Choose **New self-hosted runner** and select the Linux platform that matches the machine's architecture.
3. Follow the commands GitHub generates to download and configure the runner.
4. Start the runner, preferably as a service for continued availability.
5. Confirm that the runner appears online and ready to accept work in GitHub.

The registration commands and token must come from the repository's runner setup page. They should not be added to this document or committed to source control.

![Self-hosted runner ready in GitHub](screenshots/self-hosted-idle.png)

## 4. Running a Job on My Own Runner

This workflow prints the runner host and working directory, then writes a proof file under the account running the runner. The workflow is manually triggered so it does not run automatically for every push or pull request.

**File:** `.github/workflows/self-hosted.yml`

```yaml
name: Self-Hosted Runner Test

on:
  workflow_dispatch:

jobs:
  verify-runner:
    runs-on: self-hosted
    steps:
      - name: Show machine information
        run: |
          hostname
          pwd

      - name: Create and verify proof file
        run: |
          proof_file="$HOME/day42-runner-proof.txt"
          echo "Created by a GitHub Actions job" > "$proof_file"
          test -f "$proof_file"
          cat "$proof_file"
```

After the run, I should check the file on the runner machine at `~/day42-runner-proof.txt` (assuming the runner service uses that user's home directory). The job log and the file on the machine confirm that the job ran on my own infrastructure.

![Job running on the self-hosted runner](screenshots/self-hosted-job.png)

## 5. Selecting a Runner by Label

Labels help GitHub choose a suitable runner when several self-hosted machines are registered. For example, a label can distinguish a Linux runner from a runner with a particular tool or hardware capability.

After adding the custom label `my-linux-runner` in the repository's runner settings, update the job selector to:

```yaml
runs-on: [self-hosted, linux, my-linux-runner]
```

GitHub will look for a runner matching all the specified labels. I should trigger the workflow again and confirm it is assigned to the intended machine.

## 6. GitHub-Hosted and Self-Hosted Comparison

| Category | GitHub-hosted | Self-hosted |
|---|---|---|
| Who maintains the machine? | GitHub manages the hosted runner environment. | I or my organization manage the host and runner software. |
| Cost | Depends on repository visibility, plan, runner type, and applicable usage limits. | Requires infrastructure resources plus maintenance time. |
| Tools | A broad set of common tools is supplied with the runner image. | I choose and maintain the installed software. |
| Suitable for | Standard builds, tests, and jobs across supported operating systems. | Custom environments, private infrastructure, special tools, or hardware. |
| Security consideration | Workflow permissions and secrets still require careful handling. | The host needs extra protection because workflow code can access its environment. |

**Security note:** A self-hosted runner should not process untrusted workflow code. For this exercise, a disposable or isolated VM is preferable to a personal machine, particularly when the repository is public.

## Key Takeaways

- The `runs-on` field selects the machine environment for a job.
- GitHub-hosted runners are convenient for standard workflows and operating-system testing.
- Self-hosted runners let me control the machine, tools, and environment, but I must maintain and secure them.
- Labels direct jobs to runners with the required characteristics.
- Checking job logs and verifying the proof file on the machine helps confirm where the job executed.

## Evidence Checklist

- [ ] Screenshot showing the Ubuntu, Windows, and macOS jobs.
- [ ] Screenshot containing the Docker, Python, Node.js, and Git versions.
- [ ] Screenshot of the self-hosted runner shown as online/idle in GitHub.
- [ ] Screenshot of a successful job on the self-hosted runner.
- [ ] Re-ran the self-hosted workflow using the `my-linux-runner` label.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
