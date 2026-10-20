# Day 36 - Docker Project: Dockerize a Full Application

## 1. Application Chosen and Why

For Day 36, I chose **Chattingo**, my full-stack real-time chat application: [github.com/Ashish-6-24/chattingo](https://github.com/Ashish-6-24/chattingo).

I selected this application because it is more representative of a real deployment than a single standalone container. It includes a React frontend, a Spring Boot backend, a MySQL database, Nginx routing, and real-time WebSocket/SockJS traffic. Dockerizing it requires me to consider build stages, service discovery, network boundaries, secrets, database persistence, and deployment verification.

### Tech Stack

- React 18 / JavaScript
- Java 17 / Spring Boot 3
- Spring Data JPA / Hibernate
- Spring Security and JWT
- MySQL 8.0
- Nginx
- Docker and Docker Compose
- npm and Maven
- WebSocket / SockJS / STOMP

## 2. Architecture

```text
Browser
  |
  | HTTP: host port 80
  v
Nginx + React frontend (container port 8080)
  |             \
  | /auth, /api  \ /ws (WebSocket / SockJS)
  |               \
  v                v
Spring Boot backend (container port 8080)
  |
  | JDBC to mysql:3306 over the Compose network
  v
MySQL 8.0
  |
  v
chat-vol named volume
```

The Compose services share the custom `chattingo` bridge network. The frontend publishes host port `80` and proxies the API and WebSocket paths to `backend:8080`. The backend connects to `mysql:3306`. MySQL data is stored in the named volume `chat-vol`, so it can persist when containers are recreated.

## 3. Frontend Dockerfile - Explained Line by Line

The frontend uses a multi-stage build: Node builds the production bundle, then Nginx serves only the static output.

```dockerfile
# Use a small Node.js base image for the React build stage.
FROM node:20-alpine AS build

# Set the working directory inside the build container.
WORKDIR /app

# Copy package metadata first so dependency installation can be cached.
COPY package*.json ./

# Install dependencies required to build the frontend.
RUN npm install

# Copy the application source and Nginx configuration into the build context.
COPY . .

# Generate the production-ready React static files in /app/build.
RUN npm run build

# Start a separate, smaller runtime stage for serving static content.
FROM nginx:alpine

# Install the project's Nginx reverse-proxy and server configuration.
COPY nginx.conf /etc/nginx/nginx.conf

# Copy only the compiled frontend output from the build stage.
COPY --from=build /app/build /usr/share/nginx/html

# Document the port on which the configured Nginx server listens.
EXPOSE 8080

# Keep Nginx in the foreground so Docker can manage its process.
CMD ["nginx", "-g", "daemon off;"]
```

### Frontend Build Notes

- The `build` stage contains Node.js and the npm dependencies used during compilation.
- The runtime stage serves the generated `/app/build` output with Nginx.
- The custom `nginx.conf` serves the single-page React application and proxies `/auth/`, `/api/`, and `/ws` to the backend.
- The Nginx configuration listens on container port `8080`, matching the Compose mapping `80:8080`.

## 4. Backend Dockerfile - Explained Line by Line

The backend uses Maven to produce an executable JAR, then runs that JAR on a Java runtime image. The `COPY --chown` line below uses the same user and group names created in the Dockerfile; keep these names consistent in the actual file.

```dockerfile
# Use Maven with Java 17 to compile and package the Spring Boot application.
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

# Set the backend build directory.
WORKDIR /app

# Copy the Maven descriptor first to improve dependency-layer caching.
COPY pom.xml .

# Download dependencies before copying frequently changed source code.
RUN mvn dependency:go-offline

# Copy the Java application source into the builder stage.
COPY src ./src

# Package the executable JAR. This command skips tests; run tests separately when required.
RUN mvn -B -ntp -DskipTests package

# Use a Java 17 JRE runtime instead of carrying Maven into the final image.
FROM eclipse-temurin:17-jre-alpine AS runtime

# Create a dedicated group and non-root user for running the application.
RUN addgroup -S app-group && adduser -S app-user -G app-group

# Copy the packaged JAR from the builder and set ownership to the runtime user/group.
COPY --from=builder --chown=app-user:app-group /app/target/chattingo-0.0.1-SNAPSHOT.jar /app/app.jar

# Run the Java process as the non-root application user.
USER app-user

# Document the port exposed by Spring Boot.
EXPOSE 8080

# Start Spring Boot and allow the JVM to size its heap based on container memory.
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.jar"]
```

### Backend Build Notes

- The builder stage includes Maven; the runtime stage includes only a Java runtime and the packaged JAR.
- The Spring Boot container runs as `app-user`, not root.
- `-DskipTests` means the container build does not prove tests pass; execute the test suite separately if test verification is part of submission.
- **Important source fix:** the current repository Dockerfile creates `app-user` and `app-group`, so its `COPY --chown` must use `app-user:app-group`. Names such as `appuser:appgroup` will not match the created accounts and may cause the image build to fail.

## 5. `.dockerignore`

The project has separate ignore files for the frontend and backend. They keep unnecessary local files out of the build context.

Frontend examples:

```text
node_modules/
build/
coverage/
.git/
.env
*.log
```

Backend examples:

```text
target/
.git/
.env
*.log
```

Keep build inputs such as `package.json`, `package-lock.json`, `pom.xml`, source code, and the Nginx configuration available to Docker.

## 6. Docker Compose

The repository's root `docker-compose.yml` defines three services:

- `frontend`: builds from `./frontend`, publishes `80:8080`, and joins the `chattingo` network.
- `backend`: builds from `./backend`, receives its database and JWT settings through environment-variable substitution, and binds host port `127.0.0.1:8080` to its container port `8080`.
- `mysql`: uses `mysql:8.0`, stores its data in `chat-vol`, and has a health check. The backend uses `depends_on` with `condition: service_healthy` for MySQL.

The Compose file uses a custom bridge network named `chattingo` and the persistent named volume `chat-vol`.

## 7. Environment Variables

Create a root-level `.env` file beside `docker-compose.yml`. This is an example template; replace every placeholder with your own values and do not commit the real `.env` file.

```dotenv
MYSQL_DATABASE=chattingo_db
MYSQL_USER=chattingo_app
MYSQL_PASSWORD=replace_with_a_strong_app_password
MYSQL_ROOT_PASSWORD=replace_with_a_different_root_password

SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/chattingo_db?serverTimezone=UTC
JWT_SECRET=replace_with_a_long_random_secret
```

- `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, and `MYSQL_ROOT_PASSWORD` initialize the MySQL container on its first run.
- `SPRING_DATASOURCE_URL` configures Spring Boot. The hostname is `mysql` because that is the Compose service name.
- `JWT_SECRET` must be a strong, private value.
- The variable names in `.env` must match those referenced in `docker-compose.yml`.

Validate the Compose configuration without publishing its expanded values:

```bash
docker compose config
```

## 8. Build, Run, and Verify

Run commands from the Chattingo project root.

```bash
# Build the application images and start the services in the background.
docker compose up --build -d

# Check service state.
docker compose ps

# Review service logs if any container is not running as expected.
docker compose logs --tail=100 frontend
docker compose logs --tail=100 backend
docker compose logs --tail=100 mysql

# Check that Nginx responds on the public host port.
curl -I http://localhost/
```

Open `http://localhost/` in a browser. Then verify the application itself: sign in with a test account, use a second browser session for another account, send a message, and confirm real-time delivery and persistence. A successful `curl` response by itself does not prove the database and WebSocket flows work.

The current Compose configuration includes a MySQL health check but does not define `/health` or a separate health check for the application containers. Do not report a health endpoint check unless the application has been configured to provide one.

## 9. Docker Hub Publishing

After building locally, replace `DOCKERHUB_USERNAME` with your actual Docker Hub username and ensure that the image repositories exist.

```bash
# Confirm the local image names.
docker image ls | grep chattingo

# Tag frontend and backend images.
docker tag chattingo-frontend:latest DOCKERHUB_USERNAME/chattingo-frontend:v1.0.0
docker tag chattingo-backend:latest DOCKERHUB_USERNAME/chattingo-backend:v1.0.0

# Sign in and publish both images.
docker login -u DOCKERHUB_USERNAME
docker push DOCKERHUB_USERNAME/chattingo-frontend:v1.0.0
docker push DOCKERHUB_USERNAME/chattingo-backend:v1.0.0
```

Docker Hub links after the push:

- Frontend: `https://hub.docker.com/r/DOCKERHUB_USERNAME/chattingo-frontend`
- Backend: `https://hub.docker.com/r/DOCKERHUB_USERNAME/chattingo-backend`

**Submission status:** Fill in the actual Docker Hub username and links after the push completes. A set of commands is not evidence that an image has already been published.

## 10. Fresh Deployment Test

For a pull-only test, update the Compose `image:` values to point to the pushed Docker Hub repositories and tags first. Then run:

```bash
# Stop and remove containers, while keeping the persistent database volume.
docker compose down

# Remove the published application tags from the local machine (after replacing the username).
docker image rm DOCKERHUB_USERNAME/chattingo-frontend:v1.0.0 DOCKERHUB_USERNAME/chattingo-backend:v1.0.0

# Retrieve the published images and start without rebuilding from local source.
docker compose pull
docker compose up -d --no-build

docker compose ps
curl -I http://localhost/
```

Then repeat the browser sign-in and real-time messaging checks. Keep `chat-vol` during this verification unless you deliberately want to delete the database contents. `docker compose down -v` deletes Compose-managed volumes and should not be used casually.

## 11. Challenges and Solutions

### Database service name inside Docker

**Problem:** `localhost` inside the backend container refers to the backend container itself, not MySQL.

**Solution:** Configure the JDBC URL with `mysql:3306`, the MySQL service name and internal port on the Compose network.

### Waiting for database readiness

**Problem:** MySQL initialization can take longer than the backend container startup.

**Solution:** The Compose file defines a MySQL health check and makes the backend wait with `depends_on: condition: service_healthy`.

### Frontend API and WebSocket routing

**Problem:** Static files, HTTP API requests, and WebSocket connections need different handling.

**Solution:** Nginx serves the React files and forwards `/auth/`, `/api/`, and `/ws` requests to `backend:8080`; the WebSocket location includes upgrade headers and disables proxy buffering.

### Runtime image size and build dependencies

**Problem:** Build tools are not needed to run the packaged frontend or backend.

**Solution:** Use multi-stage builds: Node builds React static assets, Maven packages the Spring Boot JAR, and the runtime stages contain Nginx or a Java JRE rather than the entire build toolchain.

### Runtime user/group consistency

**Problem:** A `COPY --chown` username or group name that differs from the accounts actually created can cause a backend image build failure.

**Solution:** Match the Dockerfile's `COPY --chown` to `app-user:app-group`, or use another consistent user/group pair in both the `RUN` and `COPY` instructions.

### Persisting database data

**Problem:** Data stored only in a container's writable layer can be lost when the container is removed.

**Solution:** Mount the named volume `chat-vol` at `/var/lib/mysql` and avoid deleting it during normal stop/recreate cycles.

## 12. Final Image Size

Record the real image sizes after building on your machine. Do not guess these values because image size depends on the image layers and the build environment.

```bash
docker image ls chattingo-frontend
docker image ls chattingo-backend
```

| Image | Actual size after build |
|---|---|
| `chattingo-frontend:latest` | **Fill in from Docker output** |
| `chattingo-backend:latest` | **Fill in from Docker output** |

## 13. Docker Hub Links

Replace `DOCKERHUB_USERNAME` with your username after the push has succeeded.

- Frontend image: `https://hub.docker.com/r/DOCKERHUB_USERNAME/chattingo-frontend`
- Backend image: `https://hub.docker.com/r/DOCKERHUB_USERNAME/chattingo-backend`

**Final submission checklist**

- [ ] Frontend and backend Dockerfiles are present and build successfully.
- [ ] `.dockerignore` files are present.
- [ ] Root `.env` is configured locally and not committed.
- [ ] `docker compose up --build -d` starts the services.
- [ ] Browser sign-in, API requests, database persistence, and real-time messaging have been checked.
- [ ] Frontend and backend images have been pushed to Docker Hub.
- [ ] Local application image tags have been removed, pulled again, and tested with `--no-build`.
- [ ] Actual image sizes and Docker Hub URLs are recorded above.

## Conclusion

This Day 36 project applies Docker to a realistic multi-service application. It demonstrates how to build frontend and backend images, route API and WebSocket traffic through Nginx, configure service discovery with Compose, manage secrets through environment variables, wait for database readiness, persist data with a named volume, and prepare a pull-based deployment test.
