# Day 39 - CI/CD Concepts

## Why CI/CD Exists

Manual software delivery can cause:

- **Code conflicts:** Changes can overwrite or break other developers’ work.
- **Untested releases:** Bugs and syntax errors can reach production without automated checks.
- **Environment differences:** Missing dependencies, local settings, or configuration can make the app fail elsewhere.
- **Slow feedback:** Problems may be discovered late, making them harder to diagnose.
- **Deployment bottlenecks:** Releases depend on people following manual steps correctly.
- **Weak traceability and rollbacks:** It can be difficult to identify what was deployed, who deployed it, and how to restore a previous version.

**“It works on my machine”** means the application runs in one developer’s environment but fails in another because software versions, dependencies, environment variables, permissions, or operating systems differ.

There is no universally safe number of manual deployments per day. Manual releases become riskier as frequency and complexity increase; automated, tested deployments make frequent releases more repeatable.

## Continuous Integration (CI)

- Developers integrate code into a shared repository frequently.
- Pushes and pull requests can trigger automated builds and tests.
- CI catches issues such as broken tests, syntax errors, and regressions early.
- **Example:** A developer opens a pull request for a payment feature, and GitHub Actions installs dependencies and runs the test suite before the change is merged.

## Continuous Delivery

- Extends CI by packaging successfully tested code and keeping it ready for release.
- The release can be deployed to production, but a person may still need to approve the production deployment.
- **Example:** A successful pipeline publishes a release artifact and updates staging; the team approves it before production release.

## Continuous Deployment

- Automatically releases every change that passes the required checks to production, without a manual production approval step.
- Requires reliable automated testing, monitoring, and recovery practices.
- **Example:** A bug fix merged into the main branch passes the pipeline and is automatically deployed to live users.

## Pipeline Anatomy

| Component | Purpose |
|---|---|
| **Trigger** | Event that starts a workflow, such as a push, pull request, or scheduled run. |
| **Stage** | A broad phase of delivery, such as build, test, containerize, or deploy. |
| **Job** | A unit of work within a workflow; it runs on a runner and can depend on other jobs. |
| **Step** | One command or action executed within a job. |
| **Runner** | The machine or virtual environment that executes a job. |
| **Artifact** | Output saved from a job, such as a package, test report, or coverage file. |

## Example Pipeline

```text
[ Developer pushes code to GitHub ]
                 |
                 v
+------------------------------------+
| Stage 1: BUILD                     |
| Install dependencies and package   |
| or compile the application         |
+------------------------------------+
                 |
                 v
+------------------------------------+
| Stage 2: TEST                      |
| Run automated tests and checks     |
+------------------------------------+
                 |
          Tests pass
                 |
                 v
+------------------------------------+
| Stage 3: DOCKERIZE                 |
| Build a Docker image and publish   |
| it to a container registry         |
+------------------------------------+
                 |
                 v
+------------------------------------+
| Stage 4: DEPLOY                    |
| Deploy the image to the staging    |
| server and verify the rollout      |
+------------------------------------
```

### Observations

- **Triggers:** Pushes to `master`, pull requests, and a weekly scheduled run on Monday (`0 0 * * 1`).
- **Jobs:** Six top-level jobs: `changes`, `test`, `benchmark`, `regression-test`, `coverage-combine`, and `test-alls-green`.
- **Runners:** Uses GitHub-hosted runners, including `ubuntu-latest`, `windows-latest`, and `macos-latest` for relevant jobs.
- **Testing approach:** The `test` job uses a matrix to test combinations of operating systems, Python versions, and dependency options.
- **Other checks:** The workflow includes benchmarking, regression-test checks, combining coverage results, and a final job to summarize required job outcomes.
- **Change filtering:** The `changes` job checks whether relevant source or workflow files changed. Its output helps decide whether some testing jobs need to run.
- **Purpose:** Helps maintain FastAPI quality by automatically checking changes across environments and running additional testing and benchmark tasks.

### Workflow Flow 

```text
Push to master / Pull request / Weekly schedule
                       |
                       v
                 Check changes
                       |
          +------------+-------------+
          |            |             |
          v            v             v
        Tests      Benchmarks   Regression checks
          |
          v
  Combine coverage results
          |
          v
  Summarize required job results
```

*This is a simplified view: jobs can run in parallel, and some jobs depend on the results of others.*

## Key Learning

- CI/CD is a software delivery practice, not a single tool.
- Tools such as GitHub Actions, Jenkins, and GitLab CI help implement automated workflows.
- A failed pipeline gives the team early feedback and helps prevent an unchecked change from moving forward.
- Clear job dependencies, automated tests, and useful artifacts make delivery more consistent and traceable.

