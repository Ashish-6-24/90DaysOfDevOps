# Day 34 - Docker Compose: Real-World Multi-Container Apps

## Objective

Build and test a three-service application using Docker Compose. This exercise covers custom image builds, service dependencies, healthchecks, restart policies, networking, persistent storage, labels, and scaling.

```text
             Flask Web App
              /        \
             v          v
        PostgreSQL     Redis
        (Database)     (Cache)
             |
             v
      postgres_data volume
```

## Stack

- **Web Application:** Python Flask
- **Database:** PostgreSQL 16 Alpine
- **Cache:** Redis 7 Alpine
- **Docker Image:** Python 3.11 Slim
- **Orchestration:** Docker Compose
- **Networking:** Custom bridge network (`app-net`)
- **Persistence:** Named Docker volume (`postgres_data`)

## Application Dockerfile

The Flask application is built from a custom Dockerfile instead of using a pre-built application image.

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirement.txt .

RUN pip install --no-cache-dir -r requirement.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

- `FROM` selects the Python base image.
- `WORKDIR` sets the application directory inside the container.
- `COPY` transfers the dependency file and application source code.
- `RUN` installs the Python packages.
- `EXPOSE` documents the application's container port.
- `CMD` starts the Flask application.

The Compose configuration uses `build: .` to build the image from the current project directory.

**Note:** The Dockerfile expects the file to be named `requirement.txt`. If your actual file is named `requirements.txt`, update both references to match.

## Task 1 - Three-Service Application

The application consists of three services:

- `web`: Runs the Python Flask application.
- `db`: Runs PostgreSQL and stores database files in a named volume.
- `redis`: Provides the Redis cache service.

Flask connects to PostgreSQL through `DB_HOST=db` and connects to Redis through `REDIS_HOST=redis`.

These are Compose service names. The services communicate over the shared `app-net` network without requiring hard-coded container IP addresses.

Start and verify the application:

```bash
docker compose config
docker compose up --build -d
docker compose ps
docker compose logs --tail=50 web db redis
curl http://localhost:5000/
```

## Task 2 - Dependencies and Healthchecks

The web service uses the following dependency configuration:

```yaml
depends_on:
  db:
    condition: service_healthy
  redis:
    condition: service_started
```

- **PostgreSQL:** The web application waits for the database healthcheck to pass.
- **Redis:** The web application waits for the Redis container to start, but not necessarily for Redis to become healthy.

The PostgreSQL healthcheck is configured as follows:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
  interval: 5s
  timeout: 5s
  retries: 5
```

Make sure `DB_USER` and `DB_NAME` match the PostgreSQL initialization values `POSTGRES_USER` and `POSTGRES_DB` in your `.env` file.

Test startup behavior:

```bash
docker compose down
docker compose up --build -d
docker compose ps
docker compose logs db web
```

**Key Learning:** A running container does not always mean its service is ready. The `service_healthy` condition waits for a successful healthcheck, while `service_started` only waits for the container to start.

## Task 3 – Restart Policies

The current configuration uses two restart policies:

```yaml
# PostgreSQL
restart: always

# Redis
restart: on-failure
```

- **`always`:** Restarts the container after it exits, subject to Docker's manual-stop behavior.
- **`on-failure`:** Restarts the container when its process exits with a non-zero status.
- **`unless-stopped`:** Restarts the container unless it has been intentionally stopped.
- **`no`:** Disables automatic restarting.

Test the PostgreSQL restart policy:

```bash
docker compose ps -q db
docker compose ps
docker compose logs --tail=50 db
```

To compare `on-failure`, change the database setting temporarily and recreate the service:

```yaml
restart: on-failure
```

```bash
docker compose up -d --force-recreate db
docker compose ps
docker inspect 
```

Record the actual results. A forced termination generally produces a non-zero exit status, so both `always` and `on-failure` may restart the container.

**Key Learning:** Restart policies help recover exited containers, but they do not fix application errors or replace monitoring and backups.

## Task 4 - Custom Dockerfile and Rebuild

The web service uses the following Compose setting:

```yaml
build: .
```

This instructs Compose to build the application image from the Dockerfile in the current project directory.

After changing the application code, rebuild and restart the service:

```bash
docker compose up -d --build
curl http://localhost:5000/
docker compose logs --tail=50 web
```

Verify that the updated application is running and that the changes behave as expected.

## Task 5 - Named Network, Volume and Labels

### Custom Network

The Compose file defines an explicit bridge network:

```yaml
networks:
  app-net:
    driver: bridge
```

All three services join this network so they can communicate using their Compose service names.

### Named Volume

PostgreSQL uses a named volume to preserve database files:

```yaml
volumes:
  postgres_data:
    driver: local
```

The database service mounts this volume at `/var/lib/postgresql/data`.

- `docker compose down` removes the containers and project network but normally preserves named volumes.
- `docker compose down -v` also removes Compose-managed named volumes.

Test persistence:

1. Send several requests to the application.
2. Stop and remove the project using `docker compose down`.
3. Start it again using `docker compose up -d`.
4. Check whether the PostgreSQL data remains.

The PostgreSQL counter should retain its value when the same named volume is reused. Redis data may reset if it is stored only in memory and the container is recreated.

### Service Labels

The services include labels for resource identification:

```yaml
labels:
  - "environment=test"
  - "tier=function"
```

The database uses `tier=database`, while Redis uses `tier=cache`.

Labels provide metadata that helps identify resources; they do not control networking or application behavior.

Inspect the resources:

```bash
docker network ls
docker volume ls
docker compose ps
docker inspect postgres_db 
```

## Task 6 – Scaling Experiment

The current web service contains these settings:

```yaml
container_name: web_application

ports:
  - "5000:5000"
```

Attempt to scale the application:

```bash
docker compose up -d --scale web=3
```

### What Happens?

The current configuration has two limitations:

1. **Fixed container name:** `container_name: web_application` prevents Compose from scaling the `web` service beyond one container.
2. **Fixed host port:** The mapping `5000:5000` assigns host port `5000` to the container. Multiple replicas cannot bind the same host IP and port combination simultaneously.

### How to Test Three Replicas

First, remove this setting from the `web` service:

```yaml
container_name: web_application
```

Then change the port mapping to:

```yaml
ports:
  - "5000"
```

This lets Docker assign a different host port to each replica.

Recreate the project and start three replicas:

```bash
docker compose down
docker compose up -d --build --scale web=3
docker compose ps
```

Inspect the assigned host ports:

```bash
docker compose port --index=1 web 5000
docker compose port --index=2 web 5000
docker compose port --index=3 web 5000
```

## Verification Checklist

- [ ] Validated the Compose configuration.
- [ ] Started Flask, PostgreSQL, and Redis.
- [ ] Verified application connectivity to the database and cache.
- [ ] Inspected the PostgreSQL healthcheck.
- [ ] Understood `service_healthy` versus `service_started`.
- [ ] Tested the database restart behavior.
- [ ] Compared `always` and `on-failure`.
- [ ] Rebuilt the application image after changing code.
- [ ] Verified the custom network and named volume.
- [ ] Inspected service labels.
- [ ] Tested database persistence after `down` and `up`.
- [ ] Tested the scaling limitations caused by `container_name` and fixed port mapping.
- [ ] Kept `.env` and real credentials out of Git.

## Key Learnings

- Healthchecks help determine whether a service is ready.
- `depends_on` controls startup ordering and can wait for a successful healthcheck.
- Restart policies determine how Docker responds when a container exits.
- Custom Dockerfiles allow images to be built from application source code.
- Named networks support service discovery between containers.
- Named volumes keep database files independent of container lifecycle.
- Labels help identify and organize Docker resources.
- Scaling requires removing fixed container names and addressing host-port conflicts.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#DockerCompose` `#Python` `#PostgreSQL` `#Redis`
