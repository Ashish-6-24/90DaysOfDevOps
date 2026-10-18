# Day 35 - Multi-Stage Builds & Docker Hub

## Objective

- Compare a single-stage Go Docker image with a multi-stage Go Docker image.
- Measure the images using the output from `docker images`.
- Explain why multi-stage builds reduce the final image size.
- Prepare the optimized image for Docker Hub and verify image tags.
- Review image best practices, including a minimal runtime image and non-root execution.

## Application

- Language: Go (Golang).
- Container port declared by the Dockerfile: `8080`.
- Single-stage image: `app-single-stage:v1`.
- Multi-stage image: `app-multi-stage:v1`.

## Single-Stage Build

- The single-stage image builds and runs the Go application in one stage.
- The image retains the Go build environment even though the compiler and build tools are not needed when the compiled application runs.
- The following values were recorded from the provided `docker images` screenshot.

Check image information:

```bash
docker images
```

Measured result:

```text
Image:        app-single-stage:v1
Disk usage:   1.35GB
Content size: 326MB
```

## Multi-Stage Build

- The first stage, named `builder`, uses `golang:1.22-alpine` to download Go modules and compile the application.
- `CGO_ENABLED=0` and `GOOS=linux` are set when compiling the binary.
- `-ldflags="-s -w"` removes symbol and debug information from the compiled binary, helping reduce its size.
- The second stage starts from Alpine and copies only the compiled `main` binary from the builder stage.
- CA certificates are installed in the runtime image.
- The image creates a dedicated user and group with ID `10001` and runs the application as `app-user`, rather than root.
- The Dockerfile declares port `8080` with `EXPOSE 8080`.

Multi-stage Dockerfile used:

```dockerfile
FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

# Build a Linux binary without CGO dependencies and strip debug information.
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o main .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

RUN addgroup -g 10001 app-group && \
    adduser -u 10001 -G app-group -S -D app-user

WORKDIR /home/app-user

COPY --from=builder /app/main .

RUN chown app-user:app-group /home/app-user/main

# Run the application as a non-root user.
USER app-user

EXPOSE 8080

CMD ["./main"]
```

Build and inspect the multi-stage image (change the Dockerfile filename if yours is different):

```bash
docker build -f Dockerfile.multistage -t app-multi-stage:v1 .
docker images
```

Measured result from the provided screenshot:

```text
Image:        app-multi-stage:v1
Disk usage:   18.1MB
Content size: 5.25MB
```

## Comparison

| Build | Image tag | Disk usage | Content size |
|---|---|---:|---:|
| Single-stage | `app-single-stage:v1` | `1.35GB` | `326MB` |
| Multi-stage | `app-multi-stage:v1` | `18.1MB` | `5.25MB` |

- Based on **content size**, the image decreased from `326MB` to `5.25MB`.
- This is approximately a **98.4% reduction** in content size.
- The screenshot also reports disk usage separately; disk usage and content size are different measurements and should not be treated as interchangeable.

### Why Is the Multi-Stage Image Smaller?

- **Build tools stay in the builder stage:** The Go compiler, linker, Git, module-download tooling, and source files are not copied into the final runtime image.
- **Only the compiled binary is copied:** `COPY --from=builder /app/main .` brings the application executable into the final stage instead of copying the entire build environment.
- **The runtime base is smaller:** The final stage uses Alpine rather than the full Go builder image.
- **The binary is built without CGO:** `CGO_ENABLED=0` creates a self-contained Go binary for applications whose dependencies support this mode, reducing the need for C runtime libraries.
- **The executable is stripped:** `-ldflags="-s -w"` removes symbol and DWARF debug information from the binary.
- **A smaller image can reduce maintenance and exposure:** Fewer included packages generally means fewer components to patch. A smaller image alone does not guarantee that the application is secure.

## Docker Hub

- Sign in to Docker Hub from the terminal:

```bash
docker login
```

- Tag the local multi-stage image. Replace `<DOCKERHUB_USERNAME>` with your Docker Hub username:

```bash
docker tag app-multi-stage:v1 \
  <DOCKERHUB_USERNAME>/app-multi-stage:v1
```

- Push the versioned image:

```bash
docker push <DOCKERHUB_USERNAME>/app-multi-stage:v1
```

- Pull the exact version to verify that Docker Hub can serve it:

```bash
docker pull <DOCKERHUB_USERNAME>/app-multi-stage:v1
```

- Run the published image:

```bash
docker run --rm <DOCKERHUB_USERNAME>/app-multi-stage:v1
```

- If the Go application serves HTTP on port `8080`, publish the port when running it:

```bash
docker run --rm -p 8080:8080 \
  <DOCKERHUB_USERNAME>/app-multi-stage:v1
```

Docker Hub repository URL:

```text
<ADD YOUR DOCKER HUB REPOSITORY URL>
```

- Replace the username and URL placeholders after publishing.
- The local screenshots confirm the reported image sizes; they do not by themselves prove that the image has been pushed to Docker Hub.

### Image Tags: Specific Version vs. `latest`

- A tag such as `v1` names a particular version of the image.
- `latest` is just a tag name; Docker does not automatically update it every time another version is pushed.
- Publish `latest` explicitly if you want that tag to refer to this image:

```bash
docker tag app-multi-stage:v1 \
  <DOCKERHUB_USERNAME>/app-multi-stage:latest

docker push <DOCKERHUB_USERNAME>/app-multi-stage:latest
```

- Pull the two tags for comparison:

```bash
docker pull <DOCKERHUB_USERNAME>/app-multi-stage:v1
docker pull <DOCKERHUB_USERNAME>/app-multi-stage:latest
```

- The pulls succeed only if both tags exist in that Docker Hub repository. If both tags point to the same image, they run the same image content; after a later release, the tags can point to different image versions.

## Image Best Practices

- **Use a minimal runtime base:** The multi-stage image uses Alpine for the runtime stage. The supplied screenshots do not include an Ubuntu runtime measurement, so record an Ubuntu comparison only after building and measuring one.
- **Avoid `latest` for reproducible builds:** The current runtime line is `FROM alpine:latest`. To meet the assignment's specific-tag requirement, replace it with a tested, explicit Alpine release tag and rebuild. Consider pinning the builder image to a specific Go and Alpine tag as well.
- **Run as non-root:** The Dockerfile creates UID/GID `10001` and switches to `USER app-user`.
- **Reduce unnecessary layers:** The Dockerfile currently uses separate `RUN` instructions for package installation, user creation, and ownership. These can be combined where practical; `COPY --chown=app-user:app-group` can also set ownership when copying the binary and may remove the separate `chown` layer.
- **Improve dependency caching:** The Dockerfile copies `go.mod` before downloading modules, so module dependencies can be cached separately from later source-code changes. If the project has a `go.sum`, copy it alongside `go.mod` before `go mod download`.
- **Exclude unnecessary files:** Add a `.dockerignore` file to prevent items such as `.git`, local binaries, logs, and unrelated files from being sent to the build context.

Verify the configured runtime user:

```bash
docker image inspect app-multi-stage:v1 \
  --format='Configured user: {{.Config.User}}'
```

Expected output:

```text
app-user
```

## What I Learned

- A single-stage Go image can include a full build toolchain that is not needed at runtime.
- Multi-stage builds separate compilation from execution and copy only the required application artifact into the final image.
- In this comparison, the content size changed from `326MB` to `5.25MB`, a reduction of approximately `98.4%`.
- The multi-stage Dockerfile runs as a non-root user and uses a compiled Go binary in an Alpine runtime image.
- Specific tags, layer caching, and a `.dockerignore` file help make builds more predictable and efficient.
- Docker Hub distribution must be verified by pushing and pulling the actual image tags.


