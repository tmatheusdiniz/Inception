# USER_DOC.md — Inception User Documentation

This guide is for an end user or administrator operating an **already-built** stack.
For building the project from scratch and managing it as a developer, see `DEV_DOC.md`.

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

All commands are run from the directory containing the `Makefile`.

| Command | Effect |
|---------|--------|
| `make` | Build the images and start the three containers (creates host data dirs and adds the domain to `/etc/hosts`) |
| `make stop` | Pause the containers |
| `make start` | Start previously stopped containers |
| `make restart` | Restart running containers |
| `make down` | Remove the containers (host data is preserved) |
| `make status` | Show container status (`docker ps -a`) |
| `make logs` | Follow the logs of all containers |

---

## Accessing the services

| URL | What you get |
|-----|--------------|
| `https://mreinald.42.fr` | WordPress front-end |
| `https://mreinald.42.fr/wp-admin/` | WordPress administration panel |

Your browser will show a certificate warning because the SSL certificate is self-signed — this is expected. Click **"Advanced → Proceed"**.

Two WordPress accounts are provisioned at install time: an administrator and a regular author. Log in to the admin panel with the administrator credentials (see below).

---

## Credentials

All credentials are stored as plain-text secret files (one value per file) in the `srcs/secrets/` directory. They are **not** kept in environment variables or in the `.env` file, and these files **must** be excluded from version control via `.gitignore`.

```
srcs/secrets/
├── db_user.txt            ← MariaDB application username
├── db_password.txt        ← MariaDB application password
├── db_root_password.txt   ← MariaDB root password
├── wp_admin_user.txt      ← WordPress administrator login
├── wp_admin_password.txt
├── wp_admin_email.txt
├── wp_user.txt            ← Secondary WordPress user (author role)
├── wp_user_password.txt
└── wp_user_email.txt
```

To change a credential, edit the corresponding file and rebuild the stack (`make re`). The administrator username must **not** contain "admin".

---

## Checking that services are running correctly

```bash
make status                       # all three containers should be "Up"
curl -k https://mreinald.42.fr    # HTTPS responds (ignores self-signed cert)
```

If a service misbehaves, follow its logs with `make logs`. Deeper inspection
(per-container logs, volumes, network) is covered in `DEV_DOC.md`.
