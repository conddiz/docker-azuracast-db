FROM mariadb:10.4-bionic

# Fix locales
RUN apt-get update \
    && apt-get install -y --no-install-recommends language-pack-en \
    && locale-gen en_US \
    && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8"

# Add Dockerize
ENV DOCKERIZE_VERSION v0.6.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates openssl \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && apt-get purge -y --auto-remove wget ca-certificates openssl \
    && rm -rf /var/lib/apt/lists/*

# Sensible default environment values for AzuraCast instances
ENV MYSQL_HOST="mariadb" \
    MYSQL_PORT=3307 \
    MYSQL_USER="azuracast" \
    MYSQL_PASSWORD="azur4c457" \
    MYSQL_DATABASE="azuracast" \
    MYSQL_RANDOM_ROOT_PASSWORD="yes" \
    MYSQL_SLOW_QUERY_LOG=0

COPY ./db.cnf.tmpl /tmp/db.cnf.tmpl
COPY ./db.sql /docker-entrypoint-initdb.d/00-azuracast.sql

COPY scripts/ /usr/local/bin
RUN chmod -R a+x /usr/local/bin

# Note: Docker erases BOTH entrypoint and cmd if you set one or the other in an inherited Dockerfile.
ENTRYPOINT ["dockerize", "-template", "/tmp/db.cnf.tmpl:/etc/mysql/conf.d/db.cnf", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["mysqld"]
