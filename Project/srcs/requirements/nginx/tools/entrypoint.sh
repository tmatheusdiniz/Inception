#!/bin/sh
set -e

# Default domain if not provided
if [ -z "$DOMAIN_NAME" ]; then
	DOMAIN_NAME="localhost"
	echo "DOMAIN_NAME not set, defaulting to ${DOMAIN_NAME}"
	export DOMAIN_NAME
fi

# Generate self-signed SSL certificate
/usr/local/bin/setup_nginx.sh

# Substitute $DOMAIN_NAME in the config template → final config
envsubst '${DOMAIN_NAME}' \
    < /etc/nginx/http.d/default.conf.template \
    > /etc/nginx/http.d/default.conf

echo "Waiting for wordpress..."
until getent hosts wordpress > /dev/null 2>&1; do
    sleep 1
done

# Validate config before starting
nginx -t

# Run nginx in the foreground (PID 1) — no daemon, no tail -f hacks
exec nginx -g "daemon off;"
