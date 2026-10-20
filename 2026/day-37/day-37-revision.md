# Day 37 – Docker Revision

## Goal

Review and reinforce the Docker skills covered in Days 29–36. Use this file to record what I can demonstrate, what needs more practice, and the concepts I should revisit before moving on.

## Quick-Fire Questions and Answers

### 1. What is the difference between an image and a container?

A **Docker image** is a versioned, read-only package containing the filesystem and configuration needed to create a container. A **container** is an instance of an image with its own runtime state and writable layer.

### 2. What happens to data inside a container when you remove it?

Data stored only in the container's writable layer is removed with the container. Data stored in a named volume or a bind mount is separate and usually remains, unless that storage is explicitly deleted or the host files are changed.

### 3. How do two containers on the same custom network communicate?

They can communicate over the network using the other container's name (or a configured network alias) and the port on which its application listens. Host port publishing is not required for container-to-container traffic on that network.

### 4. What does `docker compose down -v` do differently from `docker compose down`?

`docker compose down` stops and removes the project's containers and Compose-created networks. Adding `-v` also removes the project's declared named volumes and anonymous volumes attached to its containers. External volumes are not removed. Use this option carefully because volume data may be lost.

### 5. Why are multi-stage builds useful?

They let a build stage contain compilers and development dependencies while a later runtime stage receives only the files it needs. This can reduce the final image size and avoid shipping unnecessary build tools.

### 6. What is the difference between `COPY` and `ADD`?

`COPY` copies files from the build context into the image. `ADD` provides additional behavior, including automatic extraction of local tar archives and support for certain remote sources. For ordinary copies, `COPY` is usually clearer and preferred.

### 7. What does `-p 8080:80` mean?

It publishes **host port `8080`** and forwards traffic to **container port `80`**. The application inside the container must actually listen on the target port.

### 8. How do you check how much disk space Docker is using?

Run:

```bash
docker system df
```

For more detail, use `docker system df -v`.

## Two Practice Areas

These are the two selected revision exercises for this session. Replace them with other topics if the self-assessment above reveals more urgent weak spots.

### Practice 1: Compose Environment Variables and Service Health

1. Create a small `compose.yaml` with an application service and a database service.
2. Put non-secret configuration values in a `.env` file and reference them in the Compose configuration.
3. Add a database healthcheck and configure the application dependency to wait for the database to be healthy, where supported by the Compose implementation.
4. Run `docker compose config`, start the services, and inspect `docker compose ps` and `docker compose logs`.
5. Confirm that the healthcheck checks actual readiness, not merely whether the database process exists.

### Practice 2: Multi-Stage Image Build

1. Choose a small application that has a build or dependency-install stage.
2. Write a Dockerfile with a build stage and a separate runtime stage.
3. Copy only the required runtime artifacts into the final stage.
4. Build the image and inspect it with `docker image ls` and `docker image history IMAGE`.
5. Run the container and verify that the application still works without build-only tools in the final stage.

## Revision Notes

- Image layers and cache: compare a build before and after changing a frequently edited source file.
- Persistence: test that a file in a named volume remains available after replacing a container, then remove the test volume only when its data is no longer needed.
- Networking: use a user-defined network and test service-name resolution from one container to another.
- Compose cleanup: understand the impact of `docker compose down` before using `docker compose down -v`.

## Completion Checklist

- [ ] I completed the self-assessment based on hands-on evidence.
- [ ] I answered the quick-fire questions before checking the answers.
- [ ] I completed both practice exercises or documented what remains unfinished.
- [ ] I reviewed the cheat sheet and corrected any commands I could not explain.
- [ ] I saved both Markdown files in `2026/day-37/`.
- [ ] I committed and pushed the changes to my fork.

## Git Submission

From the repository root, check the files and commit them:

```bash
git status
git add 2026/day-37/docker-cheatsheet.md 2026/day-37/day-37-revision.md
git commit -m "Add Day 37 Docker revision notes"
git push
```

## Learn in Public

Share one useful Docker lesson from today's revision on LinkedIn. For example, explain how named volumes differ from a container's writable layer, or why a healthcheck is different from simply starting a database container.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
