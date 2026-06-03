#!/bin/sh
set -e

WP_PATH="/var/www/html"

DB_HOST="${WORDPRESS_DB_HOST:-${MYSQL_HOST:-mariadb}}"
DB_NAME="${WORDPRESS_DB_NAME:-${MYSQL_DATABASE:-}}"
DB_USER="${WORDPRESS_DB_USER:-${MYSQL_USER:-}}"
DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-${MYSQL_PASSWORD:-}}"

WP_URL="${WORDPRESS_URL:-${DOMAIN_NAME:-}}"
WP_TITLE="${WORDPRESS_TITLE:-Inception}"

WP_ADMIN_USER="${WORDPRESS_ADMIN_USER:-${WP_ADMIN_USER:-}}"
WP_ADMIN_PASSWORD="${WORDPRESS_ADMIN_PASSWORD:-${WP_ADMIN_PASSWORD:-}}"
WP_ADMIN_EMAIL="${WORDPRESS_ADMIN_EMAIL:-${WP_ADMIN_EMAIL:-}}"

WP_USER="${WORDPRESS_USER:-${WP_USER:-}}"
WP_USER_PASSWORD="${WORDPRESS_USER_PASSWORD:-${WP_USER_PASSWORD:-}}"
WP_USER_EMAIL="${WORDPRESS_USER_EMAIL:-${WP_USER_EMAIL:-}}"

fail() {
  echo "Error: $1" >&2
  exit 1
}

[ -n "$DB_NAME" ] || fail "Database name is not set (MYSQL_DATABASE or WORDPRESS_DB_NAME)."
[ -n "$DB_USER" ] || fail "Database user is not set (MYSQL_USER or WORDPRESS_DB_USER)."
[ -n "$DB_PASSWORD" ] || fail "Database password is not set (MYSQL_PASSWORD or WORDPRESS_DB_PASSWORD)."
[ -n "$WP_URL" ] || fail "WordPress URL is not set (DOMAIN_NAME or WORDPRESS_URL)."
[ -n "$WP_ADMIN_USER" ] || fail "Admin username is not set (WP_ADMIN_USER or WORDPRESS_ADMIN_USER)."
[ -n "$WP_ADMIN_PASSWORD" ] || fail "Admin password is not set (WP_ADMIN_PASSWORD or WORDPRESS_ADMIN_PASSWORD)."
[ -n "$WP_ADMIN_EMAIL" ] || fail "Admin email is not set (WP_ADMIN_EMAIL or WORDPRESS_ADMIN_EMAIL)."
[ -n "$WP_USER" ] || fail "User name is not set (WP_USER or WORDPRESS_USER)."
[ -n "$WP_USER_PASSWORD" ] || fail "User password is not set (WP_USER_PASSWORD or WORDPRESS_USER_PASSWORD)."
[ -n "$WP_USER_EMAIL" ] || fail "User email is not set (WP_USER_EMAIL or WORDPRESS_USER_EMAIL)."

ADMIN_LOWER=$(printf '%s' "$WP_ADMIN_USER" | tr '[:upper:]' '[:lower:]')
case "$ADMIN_LOWER" in
  *admin*) fail "Admin username must not contain 'admin'." ;;
esac

if ! command -v wp >/dev/null 2>&1; then
  curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x /usr/local/bin/wp
fi

mkdir -p "$WP_PATH"

echo "Waiting for MariaDB at $DB_HOST..."
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

exec php-fpm7.4 -F