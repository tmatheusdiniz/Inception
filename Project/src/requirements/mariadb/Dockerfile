FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Runtime socket directory owned by mysql
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

# Custom MariaDB configuration
COPY ./conf/my.cnf /etc/my.cnf.d/inception.cnf

# Initialization + entrypoint scripts
COPY ./tools/init_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
