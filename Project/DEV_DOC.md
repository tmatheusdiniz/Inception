# DEV_DOC.md — Developer Documentation

This guide is for a developer setting up, building, and managing the project.
For day-to-day usage of a running stack, see `USER_DOC.md`.

## 1. Environment Setup

### Prerequisites

* A Linux virtual machine (required by the subject)
* Docker Engine
* Docker Compose plugin
* GNU Make
* OpenSSL (used at build time to generate the self-signed TLS certificate)
* Git

Verify:

```bash
docker --version
docker compose version
make --version
openssl version
```

### Project Structure

All required files live next to the `Makefile`:

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── .env
    ├── docker-compose.yml
    ├── secrets/
    │   ├── db_user.txt
    │   ├── db_password.txt
    │   ├── db_root_password.txt
    │   ├── wp_admin_user.txt
    │   ├── wp_admin_password.txt
    │   ├── wp_admin_email.txt
    │   ├── wp_user.txt
    │   ├── wp_user_password.txt
    │   └── wp_user_email.txt
    └── requirements/
        ├── nginx/      # Dockerfile, conf/, tools/
        ├── wordpress/  # Dockerfile, conf/, tools/
        └── mariadb/    # Dockerfile, conf/, tools/
```

### Configure environment variables

Non-sensitive configuration lives in `srcs/.env` (no passwords here — those go in secrets):

```env
DOMAIN_NAME=mreinald.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WORDPRESS_DB_HOST=mariadb
WORDPRESS_TABLE_PREFIX=wp_
WORDPRESS_URL=https://mreinald.42.fr
WORDPRESS_TITLE=Inception
```

### Configure secrets

Every credential is a single-value file under `srcs/secrets/`, mounted into the
containers at `/run/secrets/` by Docker Compose. Create the nine files:

```bash
cd srcs/secrets
echo "wpuser"        > db_user.txt
echo "<db_pass>"     > db_password.txt
echo "<root_pass>"   > db_root_password.txt
echo "siteowner"     > wp_admin_user.txt      # must NOT contain "admin"
echo "<admin_pass>"  > wp_admin_password.txt
echo "admin@mreinald.42.fr" > wp_admin_email.txt
echo "regularuser"   > wp_user.txt
echo "<user_pass>"   > wp_user_password.txt
echo "user@mreinald.42.fr"  > wp_user_email.txt
```

**Important:**

* Never commit secrets. Add `srcs/secrets/` (and `srcs/.env` if it ever holds sensitive data) to `.gitignore`.
* Dockerfiles must contain no passwords.
* The WordPress administrator username must not contain "admin".

### Host configuration

Map the domain to the VM in `/etc/hosts` (the `make setup` target does this automatically):

```bash
127.0.0.1 mreinald.42.fr
```

### Persistent storage directories

The two volumes store their data under `/home/mreinald/data` on the host. The
`make` target creates these for you, but they can be made manually with:

```bash
mkdir -p /home/mreinald/data/mariadb /home/mreinald/data/wordpress
```

---

## 2. Build and Launch (Makefile)

The Makefile wraps Docker Compose. Its compose invocation is:
`docker compose -f ./srcs/docker-compose.yml --env-file ./srcs/.env`.

| Target | Effect |
|--------|--------|
| `make` / `make all` | `setup` + `up` — create data dirs, register the domain, then build and start (detached) |
| `make up` | Build images and start containers in the background (`up -d --build`) |
| `make uplog` | Same as `up` but stays in the foreground with live logs |
| `make down` | Stop and remove containers and the network (host data preserved) |
| `make stop` / `make start` | Stop / start containers without removing them |
| `make restart` | Restart the containers |
| `make status` | `docker ps -a` |
| `make logs` | Follow logs for all services |
| `make clean` | Remove containers, images, and Docker-managed volumes |
| `make fclean` | `clean` + wipe the host data directories under `/home/mreinald/data` |
| `make re` | `fclean` then `all` — full rebuild from scratch |

Equivalent raw Compose commands (run from the project root):

```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build
docker compose -f srcs/docker-compose.yml --env-file srcs/.env down
```

---

## 3. Container Management

```bash
docker ps                 # running containers
docker ps -a              # all containers
docker logs nginx         # per-service logs (also: wordpress, mariadb)
docker exec -it nginx sh  # shell into a container (mariadb/wordpress: sh)
docker restart wordpress  # restart a single container
```

---

## 4. Volume and Network Management

```bash
docker volume ls
docker volume inspect mariadb_volume        # or wordpress_volume
docker network ls
docker network inspect inception_network
```

Only remove a volume if data loss is acceptable.

---

## 5. Data Persistence

The two persistent stores are mapped to the host under `/home/mreinald/data`:

| Volume | Host path | Contents |
|--------|-----------|----------|
| `mariadb_volume` | `/home/mreinald/data/mariadb` | WordPress database, users, tables |
| `wordpress_volume` | `/home/mreinald/data/wordpress` | WordPress core, themes, plugins, uploads |

Because the data lives on the host, it survives container restarts, container
recreation, and host reboots. Verify the mappings with:

```bash
docker inspect mariadb  | grep -A 20 '"Mounts"'
docker volume inspect wordpress_volume
ls -la /home/mreinald/data/{mariadb,wordpress}
```

`make down` keeps this data; `make fclean` deletes it.

---

## 6. Troubleshooting

```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env config   # validate compose file
docker compose -f srcs/docker-compose.yml --env-file srcs/.env ps       # service-level status
docker stats                                                            # live resource usage
```

---

## 7. Development Workflow

1. Edit a Dockerfile, config, or script under `srcs/requirements/`.
2. Rebuild and restart: `make re` (full) or `make up` (incremental).
3. Inspect logs: `docker logs <container>`.
4. Confirm the change behaves as expected through `https://mreinald.42.fr`.

This preserves persistent data in `/home/mreinald/data` while applying configuration changes.
