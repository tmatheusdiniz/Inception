#!/bin/sh
set -e

# Fall back to localhost if DOMAIN_NAME is not set
if [ -z "$DOMAIN_NAME" ]; then
	DOMAIN_NAME="localhost"
	echo "DOMAIN_NAME not set, defaulting to ${DOMAIN_NAME}"
	export DOMAIN_NAME
fi

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out    /etc/nginx/ssl/nginx.crt \
    -subj "/C=PT/ST=Porto/L=Porto/O=42School/OU=Inception/CN=${DOMAIN_NAME}"

chmod 600 /etc/nginx/ssl/nginx.key
chmod 644 /etc/nginx/ssl/nginx.crt

echo "SSL certificate generated for ${DOMAIN_NAME}"
