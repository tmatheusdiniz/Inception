FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Runtime socket directory owned by mysql
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld && mkdir -p /var/log/mysql && chown mysql:mysql /var/log/mysql && rm -rf /var/lib/mysql/*

# Custom MariaDB configuration
COPY ./conf/my.cnf /etc/mysql/mariadb.conf.d/50-inception.cnf

# Initialization + entrypoint scripts
COPY ./tools/init_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
