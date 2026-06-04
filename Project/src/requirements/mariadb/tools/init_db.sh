#!/bin/sh
set -e

# ─── Load credentials from Docker secrets ─────────────────────────────────────
read_secret() {
    local path="/run/secrets/$1"
    if [ -f "$path" ]; then
        # Strip potential trailing newline
        tr -d '\n' < "$path"
    else
        echo "ERROR: secret '$1' not found at $path" >&2
        exit 1
    fi
}

DB_USER=$(read_secret db_user)
DB_PASSWORD=$(read_secret db_password)
DB_ROOT_PASSWORD=$(read_secret db_root_password)
DB_NAME="${MYSQL_DATABASE:-wordpress}"

echo "==> MariaDB init: user='$DB_USER' database='$DB_NAME'"

# ─── First-boot initialization ────────────────────────────────────────────────
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "==> First boot — initializing data directory..."

    # mysql_install_db sets up the system tables
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null

    # Bootstrap SQL — runs once with --bootstrap (no server needed)
    mysqld --user=mysql --bootstrap --skip-networking --skip-grant-tables <<-SQL
        USE mysql;
        FLUSH PRIVILEGES;

        -- Secure the root account
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

        -- Remove anonymous users and test database
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

        -- Application database and user
        CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

        FLUSH PRIVILEGES;
SQL

    echo "==> Database '${DB_NAME}' and user '${DB_USER}' created."
else
    echo "==> Data directory already initialized — skipping bootstrap."
fi

# ─── Unset secrets from environment ──────────────────────────────────────────
unset DB_USER DB_PASSWORD DB_ROOT_PASSWORD

# ─── Start MariaDB in foreground (PID 1) ─────────────────────────────────────
echo "==> Starting MariaDB..."
exec mysqld --user=mysql
