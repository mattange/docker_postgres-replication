#!/bin/bash
set -e

if [ $REPLICATION_ROLE = "master" ]; then
# The following line creates the user with no encryption on the password
#    psql -U $POSTGRES_USER -c "CREATE ROLE $REPLICATION_USER WITH REPLICATION PASSWORD '$REPLICATION_PASSWORD' LOGIN"
# the following can allow md5 encryption of the password although it has no ENCRYPT specified as no longer needed
     pgsql -U $POSTGRES_USER -c "CREATE ROLE $REPLICATION_USER WITH REPLICATION PASSWORD '$REPLICATION_PASSWORD' LOGIN"
     pgsql -U $POSTGRES_USER -c "ALTER ROLE $POSTGRES_USER NOREPLICATION"


elif [ $REPLICATION_ROLE = "slave" ]; then
    # stop postgres instance and reset PGDATA,
    # confs will be copied by pg_basebackup
    pg_ctl -D "$PGDATA" -m fast -w stop
    # make sure standby's data directory is empty
    rm -r "$PGDATA"/*

# see following address for information
# https://www.postgresql.org/docs/11/app-pgbasebackup.html
# note that the user that is running the database needs 
# to have access to the password via a .pgpass file 
# that needs to be created before replication started
    
    echo [*] "creating $PGPASSFILE"
    echo ":::$REPLICATION_USER:$REPLICATION_PASSWORD" > "$PGPASSFILE"
    chmod 600 "$PGPASSFILE"    

    pg_basebackup \
         --write-recovery-conf \
         --pgdata="$PGDATA" \
         --wal-method=stream \
         --username=$REPLICATION_USER \
	 --password \
         --host=$POSTGRES_MASTER_SERVICE_HOST \
         --port=$POSTGRES_MASTER_SERVICE_PORT \
         --progress \
         --verbose

    # useless postgres start to fullfil docker-entrypoint.sh stop
    pg_ctl -D "$PGDATA" \
         -o "-c listen_addresses=''" \
         -w start
fi

echo [*] $REPLICATION_ROLE instance configured!

