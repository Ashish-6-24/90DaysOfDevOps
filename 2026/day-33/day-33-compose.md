# Day 33: Docker Compose: Multi-Container Basics

Docker Compose simplifies containerized application management by defining and running multiple services through YAML configuration. This hands-on lab covers Nginx deployment, WordPress and MySQL integration, container networking, service-name DNS discovery, named volumes, port mapping, environment variables, and container lifecycle management.

## Objective

Learn how to define, configure, start, inspect, and remove multi-container applications using Docker Compose instead of managing each container individually.

## Learning Outcomes

- Verify Docker Compose installation and version.
- Deploy Nginx using a YAML Compose file.
- Run WordPress and MySQL as interconnected services.
- Understand Compose networking and service-name DNS discovery.
- Configure named volumes for database persistence.
- Manage container lifecycle operations and service logs.
- Use environment variables and `.env` files for configuration.
- Validate Compose configuration and protect sensitive credentials.

## Prerequisites

- Docker Engine installed and running.
- Docker Compose available through the Docker CLI.
- Basic understanding of Docker images, containers, networks, and volumes.
- A web browser for testing the applications.

Related learning: [Day 32 – Docker Volumes & Networking](../day-32/day32-volume-networking.md).

---

## Task 1 - Install and Verify Docker Compose

Check whether Docker Compose is available and identify the installed version.

```bash
docker compose version
```

Record the actual version displayed by your machine.

## Task 2 - Deploy Nginx Using Docker Compose

Create a `compose-basics` directory and add a `docker-compose.yml` file.

```yaml
services:
  nginx-web:
    image: nginx:alpine
    container_name: nginx-server
    restart: unless-stopped
    ports:
      - "8080:80"
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 256M
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    networks:
      - web-tier-net

networks:
  web-tier-net:
    driver: bridge
```
Note: --spider: it does not download or save the file to disk  making the health check lightweight, fast and completely stateless.

### Start the service

```bash
docker compose up -d
```

### Verify the container status

```bash
docker compose ps
```

### Access Nginx

Open the following address in your browser:

```text
http://localhost:8080
```

The host port `8080` forwards traffic to port `80` inside the Nginx container.

### Stop and remove the Compose project

```bash
docker compose down
```

**Key concepts:** YAML configuration, containerization, port mapping, detached mode and service lifecycle management.

## Task 3 - WordPress and MySQL Multi-Container Application

Create a separate Compose configuration for a WordPress application backed by MySQL.

The application contains:

- **WordPress:** serves the website.
- **MySQL:** stores application data.
- **Compose default network:** enables communication between the services.
- **Named volume:** stores MySQL database files independently of the container lifecycle.

### Service discovery

WordPress should connect to the MySQL service using its Compose service name instead of a fixed container IP address.

Configure the WordPress database name, username, and password to match the corresponding MySQL initialization settings.

### Database persistence

Mount a named volume at MySQL's data directory:

```yaml
volumes:
  - db_data:/var/lib/mysql
```

Declare the named volume at the top level of the Compose file:

```yaml
volumes:
  db_data:
```

These snippets illustrate the volume configuration; integrate them into the appropriate `services` and top-level sections of your Compose file.

### Verify persistence

1. Start the WordPress and MySQL services.
2. Open WordPress in your browser and complete the initial setup.
3. Create a test post or page.
4. Run `docker compose down`.
5. Start the application again using `docker compose up -d`.
6. Reopen WordPress and verify whether the test content remains.
7. Document the actual result in `day-33-compose.md`.

A named MySQL volume preserves database files beyond container removal. WordPress media files stored separately from the database may require an additional WordPress volume.

**Important:** Do not use `docker compose down -v` during the persistence test because the `-v` option removes Compose-managed named volumes.

## Task 4 - Essential Docker Compose Commands

| Command | Purpose |
|---|---|
| `docker compose up -d` | Start services in detached mode. |
| `docker compose ps` | Display the project's container status. |
| `docker compose logs -f` | Follow logs from all services. |
| `docker compose logs -f db` | Follow logs from the service named `db`. |
| `docker compose stop` | Stop services without removing containers. |
| `docker compose start` | Start previously stopped containers. |
| `docker compose down` | Remove containers and the default project network. |
| `docker compose config` | Validate and display the resolved Compose configuration. |
| `docker compose up -d --build` | Build configured images and start services. |

The `--build` option is useful for services that define a `build:` section. Services using only prebuilt images generally do not require a custom image build.

## Task 5 - Environment Variable Management

Environment variables make application configuration easier to maintain without embedding every value directly in the Compose file.

### Example `.env` file

```dotenv
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=replace-with-a-local-password
MYSQL_ROOT_PASSWORD=replace-with-a-local-root-password
```

Use your own local credentials rather than publishing real passwords.

### Reference variables in Docker Compose

```yaml
environment:
  MYSQL_DATABASE: ${MYSQL_DATABASE}
  MYSQL_USER: ${MYSQL_USER}
  MYSQL_PASSWORD: ${MYSQL_PASSWORD}
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
```

Ensure the WordPress database settings match the MySQL configuration.

### Validate the resolved configuration

```bash
docker compose config
```

Compose uses `.env` values for variable interpolation. A value reaches a container when the service configuration passes it into the container's environment.

### Credential security

- Add `.env` to `.gitignore`.
- Provide a `.env.example` file containing placeholder values.
- Never commit real database passwords or other secrets to GitHub.
- Handle `docker compose config` output carefully because resolved configuration may reveal sensitive values.

## Key Learnings

1. **Declarative configuration:** Docker Compose defines application services in YAML.
2. **Container networking:** Services communicate over the Compose network using service names.
3. **Persistent storage:** Named volumes preserve database files independently of containers.
4. **Lifecycle management:** Compose provides commands to start, inspect, stop, and remove services.
5. **Configuration management:** Environment variables make application settings easier to maintain.
6. **Operational verification:** Service status, logs, and persistence tests help validate application behavior.


