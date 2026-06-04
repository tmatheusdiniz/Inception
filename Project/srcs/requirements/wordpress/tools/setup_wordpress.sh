#!/bin/sh
set -e

WP_PATH="/var/www/html"

# Read from Docker secrets
DB_USER=$(cat /run/secrets/db_user)
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email)
WP_USER=$(cat /run/secrets/wp_user)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
WP_USER_EMAIL=$(cat /run/secrets/wp_user_email)

DB_HOST="${WORDPRESS_DB_HOST:-mariadb}"
DB_NAME="${MYSQL_DATABASE:-wordpress}"
WP_URL="${WORDPRESS_URL:-https://mreinald.42.fr}"
WP_TITLE="${WORDPRESS_TITLE:-Inception}"

if ! command -v wp >/dev/null 2>&1; then
  curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x /usr/local/bin/wp
fi

mkdir -p "$WP_PATH"

echo "Waiting for MariaDB..."
until mysqladmin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --silent; do
  sleep 2
done

if [ ! -f "$WP_PATH/wp-config.php" ]; then
  wp core download --path="$WP_PATH" --allow-root
  wp config create \
    --path="$WP_PATH" \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$DB_HOST" \
    --allow-root
fi

if ! wp core is-installed --path="$WP_PATH" --allow-root; then
  wp core install \
    --path="$WP_PATH" \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  wp user create "$WP_USER" "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASSWORD" \
    --role=author \
    --path="$WP_PATH" \
    --allow-root
fi

chown -R www-data:www-data "$WP_PATH"
exec php-fpm8.2 -F
