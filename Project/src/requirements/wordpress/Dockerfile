FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	php7.4-fpm \
	php7.4-mysql \
	mariadb-client \
	curl \
	redis-tools \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

# Work directory for WordPress
WORKDIR /var/www/html

COPY ./config/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./script/setup_wordpress.sh /usr/local/bin/setup_wordpress.sh
RUN chmod +x /usr/local/bin/setup_wordpress.sh

CMD ["/usr/local/bin/setup_wordpress.sh"]
