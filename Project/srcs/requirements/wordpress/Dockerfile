FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    curl \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

WORKDIR /var/www/html

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/setup_wordpress.sh /usr/local/bin/setup_wordpress.sh

RUN chmod +x /usr/local/bin/setup_wordpress.sh
ENTRYPOINT ["/usr/local/bin/setup_wordpress.sh"]
