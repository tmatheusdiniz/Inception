#!/bin/sh
set -e

if [ -z "$DOMAIN_NAME" ]; then
    DOMAIN_NAME="localhost"
    echo "DOMAIN_NAME not set, defaulting to ${DOMAIN_NAME}"
    export DOMAIN_NAME
fi

mkdir -p /etc/ssl/private /etc/ssl/certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out    /etc/ssl/certs/nginx.crt \
    -subj "/C=PT/ST=Porto/L=Porto/O=42School/OU=Inception/CN=${DOMAIN_NAME}"

chmod 600 /etc/ssl/private/nginx.key
chmod 644 /etc/ssl/certs/nginx.crt

echo "SSL certificate generated for ${DOMAIN_NAME}"
