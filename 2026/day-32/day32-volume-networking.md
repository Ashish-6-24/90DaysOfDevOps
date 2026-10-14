# Day 32  Docker Volumes & Networking

## Overview

Today's practice focused on two Docker concepts:

- **Docker volumes and bind mounts** for storing data.
- **Docker networking** for communication between containers.

The goal was to see how database data behaves after container removal and how containers use Docker networks to communicate.

---

# Task 1 PostgreSQL Data Persistence

## Run a PostgreSQL Container

```bash
docker run -d --name postgres-db -e POSTGRES_PASSWORD=root postgres
```

## Check the Container

```bash
docker ps -a
```

## Access the PostgreSQL Container

```bash
docker exec -it postgres-db bash
```

## Connect to PostgreSQL

Run this inside the container:

```bash
psql -U postgres
```

## Create a Database

Because the database name contains a hyphen, use double quotes:

```sql
CREATE DATABASE "devops-ai";
```

## Connect to the Database

```sql
\c "devops-ai"
```

## Create a Table

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);
```

## Insert Test Data

```sql
INSERT INTO users (name, email)
VALUES ('Docker User', 'docker@example.com');
```

## Verify the Data

```sql
SELECT * FROM users;
```

Exit PostgreSQL:

```sql
\q
```

Exit the container shell:

```bash
exit
```

## Remove the Container

```bash
docker stop postgres-db
```

```bash
docker rm -v postgres-db
```

## Start a New Container

```bash
docker run -d --name postgres-db -e POSTGRES_PASSWORD=root postgres
```

Check the databases:

```bash
docker exec -it postgres-db psql -U postgres -l
```

Check whether the previous table is available:

```bash
docker exec postgres-db psql -U postgres -d 'devops-ai' -c 'SELECT * FROM users;'
```

### Observation

Record the result shown in your terminal. The new container does not automatically reuse the previous container's database storage, so the `devops-ai` database and its test row should not be available.

Remove this test container before starting Task 2 with the same container name:

```bash
docker stop postgres-db
```

```bash
docker rm -v postgres-db
```

---

# Task 2  Named Volumes

## Create a Named Volume

```bash
docker volume create postgres-data
```

## List Docker Volumes

```bash
docker volume ls
```

## Inspect the Volume

```bash
docker volume inspect postgres-data
```

## Run PostgreSQL with the Volume

```bash
docker run -d --name postgres-db -e POSTGRES_PASSWORD=root -v postgres-data:/var/lib/postgresql postgres
```

The named volume `postgres-data` is mounted at `/var/lib/postgresql`.

## Connect to PostgreSQL

```bash
docker exec -it postgres-db psql -U postgres
```

## Create a Database

```sql
CREATE DATABASE volume_db;
```

## Connect to the Database

```sql
\c volume_db
```

## Create a Table

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);
```

## Insert Data

```sql
INSERT INTO users (name) VALUES ('Persistent Data');
```

## Verify the Data

```sql
SELECT * FROM users;
```

Exit PostgreSQL:

```sql
\q
```

## Remove the Container

```bash
docker stop postgres-db
```

```bash
docker rm postgres-db
```

## Start a New Container Using the Same Volume

```bash
docker run -d --name postgres-db -e POSTGRES_PASSWORD=root -v postgres-data:/var/lib/postgresql postgres
```

Check whether the data remains:

```bash
docker exec postgres-db psql -U postgres -d volume_db -c 'SELECT * FROM users;'
```

### Observation

Record the actual result. When the same named volume is attached to the new container, the database and its row should still be available.

### Key Learning

A **named volume** is managed by Docker and remains separate from a container's lifecycle.

```text
PostgreSQL container
        |
        v
postgres-data volume
        |
        v
Database files
```

Remove the container after verifying Task 2 so the name can be reused later:

```bash
docker stop postgres-db
```

```bash
docker rm postgres-db
```

---

# Task 3  Bind Mounts

## Create a Host Directory

For my Ubuntu environment, I use a directory under `/home/ubuntu/docker-practice/volume`.

```bash
mkdir -p /home/ubuntu/docker-practice/volume
```

## Create an HTML File

```bash
echo '<h1>Day 32 - Bind Mount Test</h1>' > /home/ubuntu/docker-practice/volume/index.html
```

Check the file:

```bash
ls /home/ubuntu/docker-practice/volume
```

## Run Nginx with a Bind Mount

```bash
docker run -d --name nginx-bind -v /home/ubuntu/docker-practice/volume:/usr/share/nginx/html -p 80:80 nginx
```

## Access the Page

Test from the Docker host:

```bash
curl http://localhost
```

If Docker is running on a remote Ubuntu/EC2 host, open `http://<EC2-public-IP>` in the browser and allow inbound TCP port `80` in the instance's security group.

## Update the HTML File

```bash
echo '<h1>Updated Day 32 Page</h1>' > /home/ubuntu/docker-practice/volume/index.html
```

Check the updated content:

```bash
curl http://localhost
```

Refresh the browser to see the updated page.

Stop and remove Nginx before reusing host port 80 in Task 4:

```bash
docker stop nginx-bind
```

```bash
docker rm nginx-bind
```

## Named Volume vs. Bind Mount

| Named Volume | Bind Mount |
|---|---|
| **Location:** Docker manages where it is stored, often under Docker's volumes directory. | **Location:** You choose an explicit host path, such as `/home/ubuntu/docker-practice/volume`. |
| **Managed by:** Docker. | **Managed by:** The user and host operating system. Host permissions and directory structure affect it. |
| **Use case:** Persistent application or database data, without needing to manage the underlying host path directly. | **Use case:** Local development, website files, source code, and configuration that you edit on the host. |
| **Example:** `postgres-data:/var/lib/postgresql` | **Example:** `/home/ubuntu/docker-practice/volume:/usr/share/nginx/html` |

### Key Learning

A bind mount links a specific host directory or file to a path inside a container. Changes made to the host file can be seen by the container immediately.

---

# Task 4 Docker Networking Basics

## List Docker Networks

```bash
docker network ls
```

## Inspect the Default Bridge Network

```bash
docker network inspect bridge
```

### Details from My Terminal

- Network: `bridge`
- Driver: `bridge`
- Subnet: `172.17.0.0/16`
- Gateway: `172.17.0.1`
- Linux bridge interface: `docker0`
- Existing container: `postgres-db`
- Existing container IP at the time of inspection: `172.17.0.2`

Container IP addresses may change when containers are recreated.

## Start the First Container on the Default Bridge

```bash
docker run -d -v /home/ubuntu/docker-practice/volume:/usr/share/nginx/html -p 80:80 --name first-container nginx
```

## Start the Second Container on the Default Bridge

PostgreSQL listens on port `5432` by default, so the port mapping uses `5432:5432`:

```bash
docker run -d -p 5432:5432 --name second-container -e POSTGRES_PASSWORD=root postgres:latest
```

### 1. Name-Based Communication

On the default bridge network, automatic container-name DNS resolution is not provided in the same way as it is on a user-defined bridge network. A lookup such as `ping second-container` generally cannot resolve the other container's name on the default bridge.

The default bridge does not have Docker's automatic container-name DNS feature that user-defined bridge networks provide.

### 2. IP-Based Communication

Containers on the default bridge receive IP addresses from the bridge subnet, such as `172.17.0.0/16`. They can generally communicate directly using a reachable container IP address when network rules allow it.

For this section, these are the networking concepts recorded in the notes; the IP-based ping commands are intentionally omitted.

Remove both test containers before reusing their names on the custom network:

```bash
docker rm -f first-container
```

```bash
docker rm -f second-container
```

---

# Task 5  Custom Docker Network

## Create a Custom Network

```bash
docker network create test
```

## Verify the Network

```bash
docker network ls
```

## Inspect the Custom Network

```bash
docker network inspect test
```

## Start the First Container on the Custom Network

```bash
docker run -d -v /home/ubuntu/docker-practice/volume:/usr/share/nginx/html -p 80:80 --name first-container --network test nginx
```

## Start the Second Container on the Custom Network

```bash
docker run -d -p 5432:5432 --name second-container -e POSTGRES_PASSWORD=root --network test postgres:latest
```

### Key Learning

A user-defined bridge network such as `test` provides automatic DNS-based name resolution. Containers on this network can use container names to identify other containers instead of relying on changing IP addresses.

---

# Task 6 Putting Volumes and Networking Together

The `test` network was created in Task 5. The following containers use that network and a host directory for PostgreSQL storage.

## Database Container

```bash
docker run -d --name postgres-db -e POSTGRES_PASSWORD=root -v /home/ubuntu/docker-practice/volume/postgres-data:/var/lib/postgresql --network=test postgres
```

## Application Container

```bash
docker run -d --name app --network=test nginx
```

The database and application containers are attached to the same user-defined network. The database can be referred to by its container name, `postgres-db`, rather than relying on its IP address.

---

# Useful Docker Commands

## Containers

```bash
docker ps
```

```bash
docker ps -a
```

```bash
docker stop <container-name>
```

```bash
docker rm <container-name>
```

```bash
docker exec -it <container-name> bash
```

## Volumes

```bash
docker volume create <volume-name>
```

```bash
docker volume ls
```

```bash
docker volume inspect <volume-name>
```

## Networks

```bash
docker network ls
```

```bash
docker network create <network-name>
```

```bash
docker network inspect <network-name>
```

---

# Key Takeaways

- Removing a container does not make the new container automatically reuse its previous database storage.
- A named volume is managed by Docker and can preserve database files across container recreation.
- A bind mount uses a specific host path and is useful for files edited directly on the host.
- The default bridge supports IP-based communication but does not provide automatic container-name DNS resolution.
- User-defined bridge networks provide container-name resolution.
- Volumes and Docker networks address different needs: storage persistence and container communication.

---


# Submission Checklist

- [ ] Save this file as `day-32-volumes-networking.md` inside `2026/day-32/`.
- [ ] Run the commands and update observations with actual results.
- [ ] Add screenshots from your experiments.
- [ ] Commit and push the completed work to GitHub.
