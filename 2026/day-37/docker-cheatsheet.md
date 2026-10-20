# Docker Cheat Sheet

A practical command reference for Docker learning, day-to-day DevOps work, deployment checks, and troubleshooting. Replace placeholders such as `CONTAINER`, `IMAGE:TAG`, `USER/REPO:TAG`, `SERVICE`, and `NETWORK` with your actual names.

> **Quick incident workflow:** `docker ps -a` → `docker logs --tail 100 CONTAINER` → `docker inspect CONTAINER` → `docker port CONTAINER` → `docker stats` → `docker events`.

## 1. Docker Status and Context

| Command | Purpose |
|---|---|
| `docker --version` | Show the installed Docker CLI version |
| `docker version` | Show client and server/Engine versions |
| `docker info` | Check daemon details, storage driver, runtime, and resource information |
| `docker context ls` | List Docker contexts/endpoints |
| `docker context show` | Show the currently selected context |
| `docker COMMAND --help` | See valid options for a command |

## 2. Containers

| Command | Purpose |
|---|---|
| `docker run IMAGE` | Create and start a container from an image |
| `docker run -it --rm IMAGE sh` | Run interactively and remove the temporary container when it exits |
| `docker run -d IMAGE` / `docker run -d --name web IMAGE` | Run in detached mode; the second form also assigns a name |
| `docker run -d --name web -p 8080:80 nginx:alpine` | Publish host port `8080` to container port `80` |
| `docker run --restart unless-stopped IMAGE` | Configure a container to restart unless explicitly stopped |
| `docker run --env-file .env IMAGE` | Pass environment variables from a file to the container |
| `docker ps` | List running containers |
| `docker ps -a` | List running and stopped containers |
| `docker start CONTAINER` | Start an existing stopped container |
| `docker stop CONTAINER` | Gracefully stop a running container |
| `docker restart CONTAINER` | Restart a container |
| `docker rm CONTAINER` | Remove a stopped container |
| `docker rm -f CONTAINER` | Force-remove a container; use carefully |
| `docker exec -it CONTAINER sh` | Open a shell in a running container (`bash` may be available instead) |
| `docker logs CONTAINER` | View the container's available logs |
| `docker logs -f --tail 100 CONTAINER` | Follow the latest 100 log lines |
| `docker logs --since 30m CONTAINER` | Show logs from the last 30 minutes |
| `docker inspect CONTAINER` | Inspect configuration, state, mounts, networking, and health details |
| `docker port CONTAINER` | Show published port mappings |
| `docker top CONTAINER` | List processes running inside the container |
| `docker stats` | View live CPU, memory, network, and block I/O usage |
| `docker cp CONTAINER:/path/file ./file` | Copy a file from a container to the host |
| `docker cp ./file CONTAINER:/path/file` | Copy a file from the host into a container |
| `docker diff CONTAINER` | Show filesystem changes in the container's writable layer |

## 3. Images and Registries

| Command | Purpose |
|---|---|
| `docker images` | List local images (alias of `docker image ls`) |
| `docker image ls` | List local images |
| `docker pull IMAGE` | Download an image from a registry (an omitted tag defaults to `latest`) |
| `docker search IMAGE` | Search Docker Hub for images |
| `docker build -t NAME:TAG .` | Build an image and assign a name/tag |
| `docker build --no-cache -t APP:debug .` | Build without reusing cached build layers for troubleshooting |
| `docker image history APP:1.0` | Inspect the image's build-layer history and sizes |
| `docker image inspect APP:1.0` | Inspect image metadata, architecture, and configuration |
| `docker tag IMAGE USER/REPO:TAG` | Add a registry-ready tag to an image |
| `docker login` | Authenticate with a container registry interactively |
| `echo "$DOCKERHUB_TOKEN" \| docker login -u USER --password-stdin` | Log in using a token from an environment variable rather than typing it into the command |
| `docker push USER/REPO:TAG` | Push a tagged image to a registry |
| `docker rmi IMAGE` / `docker image rm IMAGE` | Remove a local image when it is not in use |
| `docker save -o app-image.tar APP:1.0` | Save an image to a tar archive |
| `docker load -i app-image.tar` | Load an image from a tar archive |

**Build-cache reminder:** Docker can reuse unchanged build steps. A changed instruction or input file can invalidate that layer and later layers, so copy stable dependency files before frequently changing source files where the project allows it. Use `--no-cache` for diagnosis, not as the default for every build.

## 4. Volumes and Bind Mounts

| Command | Purpose |
|---|---|
| `docker volume create NAME` | Create a named volume |
| `docker volume ls` | List volumes |
| `docker volume inspect NAME` | Inspect a volume and its mount details |
| `docker volume rm NAME` | Remove an unused named volume |
| `docker run -v app-data:/var/lib/app IMAGE` | Mount a named volume into a container |
| `docker run --mount type=volume,src=app-data,dst=/data IMAGE` | Mount a named volume using explicit mount syntax |
| `docker run --mount type=bind,src="$PWD",dst=/app IMAGE` | Bind-mount the current host directory at `/app` |

**Remember:** named volumes are Docker-managed and commonly used for persistent application/database data. Bind mounts connect a specific host path to a container and are convenient for source code and local development. Removing a container does not normally remove a named volume; deleting a volume can permanently remove its data.

## 5. Networks

| Command | Purpose |
|---|---|
| `docker network create NAME` | Create a user-defined network |
| `docker network ls` | List networks |
| `docker network inspect NAME` | Inspect connected containers and network settings |
| `docker network connect NET CONTAINER` | Connect an existing container to a network |
| `docker network disconnect NET CONTAINER` | Disconnect a container from a network |
| `docker network rm NAME` | Remove a network that is no longer in use |
| `docker run --network app-net --name api IMAGE` | Start a container on a specific network |

Containers attached to the same user-defined network can typically communicate using container names or network aliases and the port on which the destination application listens. Use `-p HOST_PORT:CONTAINER_PORT` when access through the host is required; publishing a port is not normally necessary for traffic between containers on the same network.

## 6. Docker Compose

Run these commands from the directory containing `compose.yaml` or `docker-compose.yml`. Add `-f FILE` if your Compose file has another name or location.

| Command | Purpose |
|---|---|
| `docker compose version` | Show the Compose version |
| `docker compose config` | Resolve and display the effective Compose configuration; useful for validation |
| `docker compose pull` | Pull service images declared in the Compose file |
| `docker compose build` | Build or rebuild service images |
| `docker compose up -d` | Create and start services in the background |
| `docker compose up -d --build` | Build images and start/update services |
| `docker compose ps` | Show service/container status |
| `docker compose logs -f` | Follow logs for all services |
| `docker compose logs -f --tail 100 SERVICE` | Follow the latest logs for one service |
| `docker compose exec SERVICE sh` | Open a shell in a running service container |
| `docker compose run --rm SERVICE COMMAND` | Run a one-off command in a new service container and remove it afterward |
| `docker compose top` | Show processes for service containers |
| `docker compose stats` | View resource use for Compose containers |
| `docker compose port SERVICE 8080` | Show the published host port for a service's container port |
| `docker compose restart SERVICE` | Restart a service's container |
| `docker compose stop` | Stop services without removing their containers |
| `docker compose start` | Start existing stopped service containers |
| `docker compose down` | Stop and remove project containers and Compose-created networks |
| `docker compose down -v` | Also remove project-managed named and anonymous volumes; data may be lost |

**Compose environment reminder:** a project `.env` file is commonly used for variable interpolation in the Compose file. A variable is not automatically passed into a container merely because it is in `.env`; configure `environment:` or `env_file:` under the service. Do not commit real credentials to Git. For sensitive values, consider Compose secrets or an appropriate secrets manager.

**Healthcheck reminder:** short-form `depends_on` controls startup order but does not itself wait for a dependency to become healthy. Add a suitable `healthcheck` and use `condition: service_healthy` where supported and appropriate.

## 7. Dockerfile Instructions

| Instruction | Purpose |
|---|---|
| `FROM image:tag` | Select a base image or begin a new build stage |
| `WORKDIR /app` | Set the working directory for later instructions |
| `COPY src/ /app/` | Copy files from the build context into the image |
| `RUN command` | Execute a command during image build |
| `ADD source destination` | Copy files with additional behavior; prefer `COPY` for ordinary file copying |
| `ARG NAME=value` | Define a build-time argument; do not use it to pass secrets |
| `ENV KEY=value` | Set an environment variable in the image configuration |
| `EXPOSE 8080` | Document the intended container port; does not publish it to the host |
| `USER appuser` | Set the user for later build steps and the runtime process |
| `ENTRYPOINT ["executable"]` | Define the main executable for the container |
| `CMD ["arg1"]` | Define the default command or default arguments, depending on `ENTRYPOINT` |
| `HEALTHCHECK CMD command` | Define a health test for the container |
| `VOLUME ["/data"]` | Declare a mount point intended for persistent/external storage |
| `LABEL key="value"` | Add image metadata |

Use a `.dockerignore` file to exclude unnecessary files from the build context (for example, `.git`, local dependencies, build outputs, and secret files). Never copy credentials into an image. Prefer non-root runtime users and small, maintained runtime images when feasible.

## 8. Monitoring and Troubleshooting

| Command | Purpose |
|---|---|
| `docker events` | Stream Docker Engine events |
| `docker events --since 10m` | Review recent Engine events |
| `docker system df` | Summarize Docker disk usage |
| `docker system df -v` | Show more detail about Docker disk usage |
| `docker inspect CONTAINER` | Check exit state, error, mounts, port bindings, and configured healthcheck |
| `docker logs --tail 100 CONTAINER` | Start by checking recent application output |
| `docker port CONTAINER` | Verify the host-to-container port mapping |
| `docker stats CONTAINER` | Check container CPU and memory usage |
| `docker network inspect NETWORK` | Verify which containers are connected to a network |
| `docker image history IMAGE:TAG` | Investigate image layers and their sizes |
| `docker builder du` | Show local builder cache usage where supported |
| `docker builder prune` | Remove unused build cache after reviewing the impact |

**A simple diagnosis order:**

1. `docker ps -a` — is the container running, exited, or restarting?
2. `docker logs --tail 100 CONTAINER` — what did the application report?
3. `docker inspect CONTAINER` — check exit code, health, mounts, environment/configuration, and networks.
4. `docker port CONTAINER` and `docker network inspect NETWORK` — confirm the network path and published ports.
5. `docker stats` and `docker top CONTAINER` — look for resource pressure or unexpected processes.
6. `docker events --since 10m` — check for recent start, stop, health, or other Engine events.

## 9. Cleanup Commands

| Command | Purpose |
|---|---|
| `docker image prune` | Remove dangling images |
| `docker image prune -a` | Remove images not used by existing containers |
| `docker container prune` | Remove all stopped containers |
| `docker volume prune` | Remove unused volumes (review carefully because data may be lost) |
| `docker network prune` | Remove unused networks |
| `docker system prune` | Remove multiple types of unused Docker resources |
| `docker system prune -a` | Also remove unused images not just dangling images |

```bash
# Review current disk use before cleanup
docker system df

docker system df -v

# Cleanup commands: run only when you understand what is unused
docker image prune
docker container prune
docker volume prune
docker network prune
docker system prune
```

**Important:** prune commands remove resources and can affect future builds, stopped containers, or data stored in unused volumes. Do not run broad cleanup commands blindly on production hosts. Review prompts and confirm backups before any operation that can remove persistent data.

## 10. Commands Worth Memorizing First

```bash
# Inspect state, output, configuration, ports, and resource use
docker ps -a
docker logs --tail 100 -f CONTAINER
docker inspect CONTAINER
docker port CONTAINER
docker stats

# Build, tag, and publish an image
docker build -t APP:1.0 .
docker tag APP:1.0 USER/REPO:1.0
docker login
docker push USER/REPO:1.0

# Start and troubleshoot a Compose application
docker compose config
docker compose up -d --build
docker compose ps
docker compose logs -f --tail 100
docker compose exec SERVICE sh

docker system df
```

## Important Concepts

- **Image vs container:** an image is a packaged template; a container is an instance created from it.
- **Data persistence:** the container writable layer is removed with its container; volumes and bind mounts exist outside that layer.
- **Networking:** containers on the same user-defined network can generally use container/service names to reach each other.
- **Ports:** `-p 8080:80` maps host port `8080` to container port `80`; `EXPOSE 80` by itself does not publish a port.
- **`CMD` vs `ENTRYPOINT`:** `ENTRYPOINT` defines the main executable; `CMD` provides a default command or arguments.
- **Multi-stage builds:** build tools can stay in a builder stage while only runtime artifacts are copied into the final stage.
- **Cache:** Docker can reuse unchanged build steps, but changing an earlier instruction or its inputs can invalidate later cached steps.
- **Secrets:** avoid baking passwords, API keys, or tokens into images, Dockerfiles, source control, or command history.

