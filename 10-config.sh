#!/bin/bash
set -e

echo [*] configuring $REPLICATION_ROLE instance

echo "max_connections = $MAX_CONNECTIONS" >> "$PGDATA/postgresql.conf"

# We set master replication-related parameters for both slave and master,
# so that the slave might work as a primary after failover.
# also view the following links:
# https://www.postgresql.org/docs/11/runtime-config-replication.html
# https://www.postgresql.org/docs/11/auth-pg-hba-conf.html
# https://valehagayev.wordpress.com/2018/08/15/postgresql-11-streaming-replication-hot-standby/

echo "wal_level = replica">> "$PGDATA/postgresql.conf"
echo "wal_keep_segments = $WAL_KEEP_SEGMENTS" >> "$PGDATA/postgresql.conf"
echo "max_wal_senders = $MAX_WAL_SENDERS" >> "$PGDATA/postgresql.conf"
echo "listen_addresses = '*'" >> "$PGDATA/postgresql.conf"

# slave settings, ignored on master
echo "hot_standby = on" >> "$PGDATA/postgresql.conf"
echo "hot_standby_feedback = off" >> "$PGDATA/postgresql.conf"

# with "trust" no password is requested so not really secure
#echo "host replication $REPLICATION_USER 0.0.0.0/0 trust" >> "$PGDATA/pg_hba.conf"
# md5 needs encryption of the password in the creation of the user
# in the other file or also scram-sha-256 but needs configuration via "password_encryption" above
echo "host replication $REPLICATION_USER 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"

