# USER_DOC.md — Inception User Documentation

## What is this stack?

Inception is a small web infrastructure composed of three containers, all talking over a private Docker network:

| Container | Role |
|-----------|------|
| **nginx** | HTTPS reverse proxy — the **only** public entry point (port 443) |
| **wordpress** | WordPress + PHP-FPM (no web server inside) |
| **mariadb** | MySQL-compatible database (not exposed outside the network) |

All traffic reaches the stack exclusively through NGINX on port **443** using **TLSv1.2 or TLSv1.3**.

---

## Starting and stopping the project

All commands are run from the **project root** (where the `Makefile` lives).

### Start everything

```bash
make
```

This will:
1. Create the host data directories (`/home/mreinald/data/{wordpress,mariadb}`).
2. Add `mreinald.42.fr` to `/etc/hosts` (requires `sudo`).
3. Build the Docker images and launch the three containers in the background.

### Stop containers (preserve data)

```bash
make stop     # pause containers
make down     # remove containers but keep volumes
```

### Restart

```bash
make restart  # restart running containers
make start    # start previously stopped containers
```

### Check status

```bash
make status   # docker ps -a
make logs     # tail all container logs
```

---

## Accessing the services

| URL | What you get |
|-----|--------------|
| `https://mreinald.42.fr` | WordPress front-end |
| `https://mreinald.42.fr/wp-admin/` | WordPress administration panel |

Your browser will show a certificate warning because the SSL certificate is self-signed — this is expected. Click **"Advanced → Proceed"** (Chrome/Firefox).

---

## Credentials

All credentials are stored as plain-text files in the `secrets/` directory at the project root (one value per file). They are **never** stored in environment variables or the `.env` file.

```
secrets/
├── db_user.txt          ← MariaDB application username
├── db_password.txt      ← MariaDB application password
├── db_root_password.txt ← MariaDB root password
├── wp_admin_user.txt    ← WordPress admin login
├── wp_admin_password.txt
├── wp_admin_email.txt
├── wp_user.txt          ← Secondary WordPress user (author role)
├── wp_user_password.txt
└── wp_user_email.txt
```

> **Security note:** The `secrets/` directory is git-ignored. Never commit these files.

---

## Checking that services are running correctly

```bash
# All three containers should be "Up"
make status

# Test HTTPS connectivity (ignores self-signed cert)
curl -k https://mreinald.42.fr

# Check nginx logs
docker logs nginx

# Check WordPress/PHP-FPM logs
docker logs wordpress

# Check MariaDB logs
docker logs mariadb

# Connect to MariaDB directly (inside the container)
docker exec -it mariadb mariadb -u wpuser -p wordpress
```
