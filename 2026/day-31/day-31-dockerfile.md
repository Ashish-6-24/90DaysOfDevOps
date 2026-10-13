# Day 31  Dockerfile: Build Your Own Images

## Task

Today's goal was to build custom Docker images and understand how Dockerfiles control the image build process.

During this practical, I worked with:

* Building an Ubuntu image
* Dockerfile instructions
* `CMD` and `ENTRYPOINT`
* Creating an Nginx static website image
* Port mapping and container testing
* `.dockerignore`
* Docker build context and layer caching

---

# Task 1 – Build an Ubuntu Image

## Objective

Create and run a custom Ubuntu-based Docker image.

## Build the Image

Command used:

```bash
docker build -t my-ubuntu:v1 .
```

## Run the Container

Command used:

```bash
docker run --name ubuntu-container my-ubuntu:v1
```

The image was built with the tag `my-ubuntu:v1` and run in a container named `ubuntu-container`.

---

# Task 2 – Dockerfile Instructions

The web image practical used these Dockerfile instructions:

```dockerfile
FROM
WORKDIR
COPY
EXPOSE
CMD
```

## `FROM`

Selects the base image.

```dockerfile
FROM nginx:alpine
```

## `WORKDIR`

Sets the working directory inside the image.

```dockerfile
WORKDIR /usr/share/nginx/html
```

## `COPY`

Copies a file from the build context into the image.

```dockerfile
COPY index.html .
```

## `EXPOSE`

Documents the port used by the application inside the container.

```dockerfile
EXPOSE 80
```

`EXPOSE` does not publish the port by itself. Port publishing is configured with `docker run -p`.

## `CMD`

Defines the default command run when the container starts.

```dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

---

# Task 3 – CMD vs ENTRYPOINT

## `CMD`

**Why:** Provides a default command that can be overridden at runtime.

**When:** Use it when the container needs default behavior that users may change.

Example:

```dockerfile
CMD ["python", "app.py"]
```

## `ENTRYPOINT`

**Why:** Defines the main executable; runtime arguments are passed to it.

**When:** Use it when the container should always run a specific application or tool.

Example:

```dockerfile
ENTRYPOINT ["curl"]
```

Running `docker run my-image google.com` executes `curl google.com`.

---

# Task 4 – Build a Static Website Image

## Project Directory

The website project was created under:

```text
~/docker-practice/web-app/
├── Dockerfile
└── index.html
```

## Dockerfile

The Nginx Dockerfile uses `nginx:alpine`, copies `index.html` into the Nginx web root, and starts Nginx in the foreground.

```dockerfile
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY index.html .

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

## Build and Tag the Image

Commands used during the practical:

```bash
docker build -t nginx-server .
docker image tag nginx-server my-website:v1
```

I also rebuilt the image directly with this tag:

```bash
docker build -t my-website:v1 .
```

## Run the Website

The website container was run with host port `8080` mapped to container port `80`:

```bash
docker run -d --name my-website-container -p 8080:80 my-website:v1
```

## Test the Website

Command used on the EC2 instance:

```bash
curl -I http://localhost:8080
```

The host port is `8080`; Nginx listens on port `80` inside the container. Therefore, the mapping is `8080:80`, not `8080:8080`.

---

# Task 5 – `.dockerignore`

## Purpose

A `.dockerignore` file excludes matching files from the Docker build context. This can reduce the context size and keep unnecessary files out of the build process.

## `.dockerignore` Content

For this task, the required patterns are:

```text
node_modules
.git
*.md
.env
```

## Create the File

From the website project directory:

```bash
cd ~/docker-practice/web-app
cat > .dockerignore <<'IGNORE_LIST'
node_modules
.git
*.md
.env
IGNORE_LIST
```

Check the file:

```bash
cat .dockerignore
```

## Rebuild the Image

```bash
docker build --no-cache -t my-website:v2 .
```

`.dockerignore` filters files from the build context; it does not automatically remove files that have already been copied into a previously built image or container.

---

# Task 6 – Docker Build Optimization

## Build and Observe the Cache

I built an optimization image:

```bash
docker build -t my-website:optimization .
```

Then I changed `index.html` by adding a comment:

```bash
echo '<!-- Build optimization test -->' >> index.html
```

I rebuilt the image to compare Docker's cache behavior:

```bash
docker build -t my-website:optimization .
```

## Why Does Layer Order Matter?

Docker can reuse cached build steps when the instruction and its inputs have not changed. If a file copied by a `COPY` instruction changes, that layer must be rebuilt, along with any dependent later steps.

Keep stable instructions early and frequently changing files later. For applications with dependencies, copy dependency manifests and install dependencies before copying the rest of the source code.

For this static website, the stable Nginx base image can be reused when only `index.html` changes.

---

# Important Commands Practiced

## Build and Tag Images

```bash
docker build -t my-ubuntu:v1 .
docker build -t nginx-server .
docker image tag nginx-server my-website:v1
docker build -t my-website:v1 .
docker build -t my-website:optimization .
```

## Run and Inspect Containers

```bash
docker run --name ubuntu-container my-ubuntu:v1
docker run -d --name my-website-container -p 8080:80 my-website:v1
docker ps
docker ps -a
docker exec -it my-website-container sh
```

## Test the Website

```bash
curl -I http://localhost:8080
```

---

# Key Learnings

* A **Dockerfile** contains instructions for building an image.
* `docker build` creates an image; `docker run` starts a container from it.
* `COPY` transfers files from the build context into an image.
* `EXPOSE` documents the container port; `-p` publishes a host-to-container port mapping.
* `.dockerignore` excludes selected files from the build context.
* Docker's layer cache can speed up rebuilds when earlier instructions and their inputs remain unchanged.

---

# Final Project Structure

```text
docker-practice/
└── web-app/
    ├── .dockerignore
    ├── Dockerfile
    └── index.html
```

---

# Conclusion

Day 31 covered building a custom Ubuntu image, creating an Nginx website image, running a container with port mapping, and learning how `.dockerignore` and layer caching help make Docker builds more efficient.
