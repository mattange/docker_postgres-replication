# -*- mode: conf -*-
# based on images from:
# nebirhos/postgres-replication
# danieldent/postgres-replication

FROM postgres:11.3-alpine

MAINTAINER Matteo Angeloni (mattange@gmail.com)

# common settings
ENV MAX_CONNECTIONS 500
ENV WAL_KEEP_SEGMENTS 256
ENV MAX_WAL_SENDERS 100

# master/slave settings
ENV REPLICATION_ROLE master
ENV REPLICATION_USER replication
ENV REPLICATION_PASSWORD "replication_pwd"
ENV PGPASSFILE $PGDATA/.pgpass

# slave settings
ENV POSTGRES_MASTER_SERVICE_HOST localhost
ENV POSTGRES_MASTER_SERVICE_PORT 5432

COPY 10-config.sh /docker-entrypoint-initdb.d/
COPY 20-replication.sh /docker-entrypoint-initdb.d/

