# Developer Documentation

## 1. Environment Setup

### Prerequisites

Before building the project, ensure the following software is installed:

* Linux Virtual Machine (required by the project subject)
* Docker Engine
* Docker Compose Plugin
* GNU Make
* OpenSSL (for TLS certificate generation)
* Git

Verify the installation:

```bash
docker --version
docker compose version
make --version
openssl version
```

---

### Project Structure

```text
.
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
├── srcs/
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       └── wordpress/
└── DEV_DOC.md
```

---

### Configure Environment Variables

Create the file:

```bash
srcs/.env
```

Example:

```env
DOMAIN_NAME=login.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

WP_ADMIN_USER=siteowner
WP_ADMIN_EMAIL=admin@example.com

WP_USER=user42
WP_USER_EMAIL=user42@example.com
```

Replace all values with your own configuration.

---

### Configure Secrets

Create the secrets directory:

```bash
mkdir -p secrets
```

Required secret files:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
└── credentials.txt
```

Example:

```bash
echo "secure_db_password" > secrets/db_password.txt
echo "secure_root_password" > secrets/db_root_password.txt
echo "wordpress_user_password" > secrets/credentials.txt
```

**Important:**

* Never commit secrets to Git.
* Add them to `.gitignore`.
* Dockerfiles must not contain passwords.

---

### Host Configuration

Add your domain to `/etc/hosts`:

```bash
127.0.0.1 login.42.fr
```

Replace `login` with your own 42 login.

Example:

```bash
127.0.0.1 jsmith.42.fr
```

---

### Persistent Storage Directories

Create the host directories used by Docker named volumes:

```bash
mkdir -p /home/<login>/data/mariadb
mkdir -p /home/<login>/data/wordpress
```

Example:

```bash
mkdir -p /home/jsmith/data/mariadb
mkdir -p /home/jsmith/data/wordpress
```

These directories store all persistent project data.

---

## 2. Build and Launch

### Build Images

Build all services:

```bash
make
```

or

```bash
make build
```

Equivalent Docker Compose command:

```bash
docker compose -f srcs/docker-compose.yml build
```

---

### Start Infrastructure

```bash
make up
```

or

```bash
docker compose -f srcs/docker-compose.yml up -d
```

This starts:

* NGINX
* WordPress (PHP-FPM)
* MariaDB

---

### Stop Infrastructure

```bash
make down
```

or

```bash
docker compose -f srcs/docker-compose.yml down
```

---

### Rebuild Everything

```bash
make re
```

Typical implementation:

```Makefile
re: fclean build up
```

---

### Remove Containers, Images and Volumes

```bash
make fclean
```

Equivalent:

```bash
docker compose -f srcs/docker-compose.yml down -v
docker system prune -af
```

---

## 3. Container Management

### List Running Containers

```bash
docker ps
```

### List All Containers

```bash
docker ps -a
```

### View Container Logs

NGINX:

```bash
docker logs nginx
```

WordPress:

```bash
docker logs wordpress
```

MariaDB:

```bash
docker logs mariadb
```

### Open a Shell Inside a Container

NGINX:

```bash
docker exec -it nginx sh
```

WordPress:

```bash
docker exec -it wordpress sh
```

MariaDB:

```bash
docker exec -it mariadb sh
```

### Restart a Container

```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

---

## 4. Volume Management

### List Volumes

```bash
docker volume ls
```

### Inspect a Volume

```bash
docker volume inspect mariadb_volume
```

### Remove a Volume

```bash
docker volume rm mariadb_volume
```

Only remove volumes if data loss is acceptable.

---

## 5. Data Persistence

### MariaDB Data

Database files are stored in:

```text
/home/<login>/data/mariadb
```

This directory is mapped to the MariaDB named volume.

Contents include:

* WordPress database
* User accounts
* Tables
* Configuration data

Data survives:

* Container restarts
* Container recreation
* Host reboots

---

### WordPress Data

Website files are stored in:

```text
/home/<login>/data/wordpress
```

This directory contains:

* Themes
* Plugins
* Uploads
* WordPress core files

Data persists independently from the container lifecycle.

---

### Verify Persistence

Inspect volumes:

```bash
docker volume inspect mariadb_volume
docker volume inspect wordpress_volume
```

Verify mount points:

```bash
docker inspect mariadb
docker inspect wordpress
```

---

## 6. Useful Troubleshooting Commands

Check container status:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Check network configuration:

```bash
docker network ls
docker network inspect inception_network
```

View resource usage:

```bash
docker stats
```

Validate Docker Compose file:

```bash
docker compose -f srcs/docker-compose.yml config
```

Check mounted volumes:

```bash
docker inspect wordpress | grep Mounts -A 20
```

---

## 7. Development Workflow

1. Modify service configuration or Dockerfiles.
2. Rebuild affected images:

```bash
docker compose build
```

3. Restart services:

```bash
docker compose up -d
```

4. Verify logs:

```bash
docker logs <container_name>
```

5. Test access through:

```text
https://login.42.fr
```

This workflow ensures configuration changes are correctly applied while preserving persistent data stored in Docker volumes.

