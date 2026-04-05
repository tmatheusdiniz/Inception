*This project has been created as part of the 42 curriculum by mreinald*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small but complete web infrastructure using Docker and Docker Compose, running entirely inside a virtual machine. Each service runs in its own dedicated container, built from scratch using custom Dockerfiles based on either Alpine or Debian.

The infrastructure is composed of three core services communicating through a private Docker network:

- **NGINX** — the sole entry point to the infrastructure, serving HTTPS traffic exclusively on port 443 using TLSv1.2 or TLSv1.3
- **WordPress + php-fpm** — the web application, configured and running without NGINX
- **MariaDB** — the relational database used by WordPress

Data is persisted through two named Docker volumes: one for the WordPress database and one for the WordPress website files. Both are stored on the host machine under `/home/login/data`.

The project covers the following concepts:
- **Docker** — images, containers, Dockerfiles, Docker Compose
- **Networking** — custom Docker bridge networks, port exposure, service communication
- **Volumes** — named volumes for data persistence
- **Security** — TLS configuration, environment variables, secrets management, no credentials in source code
- **Services** — NGINX, WordPress, MariaDB, php-fpm
- **System administration** — process management (PID 1), daemon behavior, service restart policies

### Virtual Machines vs Docker

A virtual machine emulates an entire operating system on top of a hypervisor, providing strong isolation but at the cost of significant resource overhead. Each VM requires its own OS kernel, memory allocation, and storage. Docker containers, by contrast, share the host kernel and isolate processes using Linux namespaces and cgroups. They are lightweight, start in seconds, and are designed to run a single service or process. Containers are not VMs — they should not be treated as such.

### Secrets vs Environment Variables

Environment variables are the standard way to pass configuration to containers. They are defined in a `.env` file and injected at runtime via Docker Compose. However, for sensitive data such as passwords and API keys, Docker secrets provide a more secure alternative: secrets are stored as files inside the container at `/run/secrets/`, are never exposed in environment listings, and are more difficult to leak accidentally. In this project, credentials must never appear in Dockerfiles or be committed to the repository.

### Docker Network vs Host Network

Using `network: host` removes network isolation entirely — the container shares the host's network stack directly. This is forbidden in this project. Instead, a custom Docker bridge network is defined in `docker-compose.yml`, allowing containers to communicate with each other by service name while remaining isolated from the outside world. The only exposed port is 443 on the NGINX container.

### Docker Volumes vs Bind Mounts

Bind mounts link a specific path on the host to a path inside the container, which makes them tightly coupled to the host's directory structure. Named volumes, used in this project, are managed entirely by Docker and stored at a defined location (`/home/login/data`). They are portable, easier to back up, and the correct tool for persistent data storage in a containerized environment. Bind mounts are explicitly forbidden for the two required volumes.

## Instructions

### Prerequisites

- A virtual machine running Linux (Debian or similar)
- Docker and Docker Compose installed
- `make` available on the system
- The domain `login.42.fr` pointing to the VM's local IP address (configured via `/etc/hosts`)

### Setup

Clone the repository, then configure the required environment variables. Create a `srcs/.env` file following this structure:
```env
DOMAIN_NAME=login.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=your_user
MYSQL_PASSWORD=your_password
MYSQL_ROOT_PASSWORD=your_root_password
```

Sensitive values (passwords, credentials) must also be stored as secret files in the `secrets/` directory at the root of the repository, and must be listed in `.gitignore`.

### Build and run
```bash
make
```

This will build all Docker images and start the full stack using Docker Compose. The WordPress site will be accessible at `https://login.42.fr`.

### Stop
```bash
make down
```

### Clean everything
```bash
make fclean
```

This stops containers, removes volumes, and cleans all built images.

## Project Structure

```zshell

.
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
├── docker-compose.yml
├── .env
└── requirements/
├── nginx/
│   ├── Dockerfile
│   ├── conf/
│   └── tools/
├── wordpress/
│   ├── Dockerfile
│   ├── conf/
│   └── tools/
└── mariadb/
├── Dockerfile
├── conf/
└── tools/

```

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress CLI documentation](https://wp-cli.org/)
- [php-fpm configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [TLS/SSL with NGINX](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [PID 1 and signal handling in containers](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)

### AI Usage

AI was used during this project for the following tasks:
- Generating the initial structure of this README
- Clarifying concepts such as the differences between named volumes and bind mounts, and between Docker networks and host networking
- Reviewing Dockerfile syntax and suggesting improvements to entrypoint scripts

All AI-generated content was reviewed, tested, and validated before being used. No code was copied without being fully understood.
