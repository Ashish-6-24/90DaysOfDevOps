# Day 45 - Publishing a Docker Image with GitHub Actions

## Goal

For Day 45 of my #90DaysOfDevOps challenge, I am setting up GitHub Actions to build the frontend Docker image from my Chattingo project and publish it to Docker Hub. This removes the need to build and upload that image manually after every change.

## Repositories and Files

- **CI/CD practice repository:** [ci-cd-practice](https://github.com/Ashish-6-24/ci-cd-practice)
- **Application repository:** [chattingo](https://github.com/Ashish-6-24/chattingo)
- **Workflow definition:** `.github/workflows/docker-publish.yml`
- **Dockerfile used by the workflow:** `chattingo/frontend/Dockerfile`
- **Source branch for Chattingo:** `main`
- **Publishing branch in the practice repository:** `master`

The workflow checks out the practice repository first, then places the Chattingo repository in a `chattingo/` subdirectory. The image build uses the frontend directory as its context; this Day 45 workflow publishes the frontend image rather than the whole multi-service application.

## Workflow Design

The workflow is intended to build on pushes to branches and on pull requests. Publishing is limited to a push on the `master` branch. Builds for feature branches and pull requests should verify that the image can be built without uploading it to Docker Hub.

The workflow contains these stages:

1. Retrieve the practice repository and the Chattingo source.
2. Calculate a short version of the triggering commit's SHA.
3. Configure Docker Buildx for the image build.
4. Sign in to Docker Hub only when a push to `master` is being handled.
5. Build the frontend image and publish it only for that default-branch push.

Workflow location:

```text
.github/workflows/docker-publish.yml
```

## Docker Hub Authentication

Configure the following items under the practice repository's **Settings → Secrets and variables → Actions**:

| Name | GitHub setting | Used for |
|---|---|---|
| `DOCKERHUB_USERNAME` | Repository variable | Docker Hub account name used in the image tag |
| `DOCKERHUB_TOKEN` | Repository secret | Docker Hub access token used to sign in |

The token belongs in a GitHub Actions secret. It should not be written into the workflow file or printed in logs. The username variable should contain only the Docker Hub username, without spaces or line breaks.

## Branch and Publishing Rules

The CI workflow can run for a feature-branch push or a pull request so that changes can be checked early. Those runs should have image publishing disabled. Only a push to `master` should sign in to Docker Hub and upload the image.

This repository currently uses `master` as its default branch, so the branch condition must use `refs/heads/master`. If the repository's default branch is renamed later, update the workflow conditions to match.

## Image Versions

The build is intended to publish two tags:

```text
latest
sha-<7-character-commit-SHA>
```

`latest` is a convenient label for the most recently published image. The short-SHA tag identifies the source commit that produced a particular image, which is helpful when tracing a release or rolling back to an earlier build.

The intended image name is:

```text
<DOCKERHUB_USERNAME>/chattingo-frontend-github-action
```

Replace the username placeholder with the Docker Hub account configured in the repository variable.

## Docker Hub Repository

Docker Hub location:

```text
https://hub.docker.com/r/<DOCKERHUB_USERNAME>/chattingo-frontend-github-action
```

Replace `<DOCKERHUB_USERNAME>` with the configured account name after the repository has been created or published.

## Pull and Start the Published Image

Once the image has been successfully published, pull the `latest` tag and start a container. The port mapping below assumes the frontend image listens on port `8080` inside the container.

```bash
docker pull <DOCKERHUB_USERNAME>/chattingo-frontend-github-action:latest

docker run -d \
  --name chattingo-frontend \
  -p 8080:8080 \
  <DOCKERHUB_USERNAME>/chattingo-frontend-github-action:latest
```

Open `http://localhost:8080` to test the frontend. Substitute the real Docker Hub username in both commands.

## From a Git Push to a Running Container

```text
git push
   |
   v
GitHub Actions starts
   |
   v
Check out ci-cd-practice and Chattingo
   |
   v
Prepare Docker Buildx and identify the commit
   |
   v
Build the Chattingo frontend image
   |
   +---- Feature branch / pull request: build only
   |
   +---- Push to master: sign in and publish
                          |
                          v
                    Docker Hub tags
                    - latest
                    - sha-<short-SHA>
                          |
                          v
                    docker pull
                          |
                          v
                    docker run
                          |
                          v
                    Frontend container
```
[![Docker Build & Push](https://github.com/Ashish-6-24/ci-cd-practice/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Ashish-6-24/ci-cd-practice/actions/workflows/docker-publish.yml) 
## Verification Checklist

- [ ] The `docker-publish.yml` workflow runs in the Actions tab.
- [ ] A feature-branch or pull-request run builds the image without publishing it.
- [ ] A push to `master` completes the Docker login and image-publishing steps.
- [ ] The `latest` and `sha-<7-character-commit-SHA>` tags appear in Docker Hub.
- [ ] The README badge reports a successful run.
- [ ] The published image can be pulled and started with Docker.
- [ ] A screenshot of the successful Actions run is saved with the Day 45 challenge notes.
