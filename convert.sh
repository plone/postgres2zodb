#!/bin/bash
set -e

mkdir -p /data/output/filestorage /data/output/blobstorage
chown -R postgres:postgres /data/output

echo "[INFO] Waiting for PostgreSQL to be ready..."
until pg_isready -U "$POSTGRES_USER"; do
  sleep 1
done

echo "[INFO] Creating database..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    DROP DATABASE IF EXISTS zodbconvert;
    CREATE DATABASE zodbconvert;
EOSQL

echo "[INFO] Create filtered dump section list without aiven_extras..."
pg_restore -l /data/zodb.dump | grep -i -v aiven_extras > /data/dump.list
echo "[INFO] Restoring binary dump..."
pg_restore -L /data/dump.list -U  "$POSTGRES_USER" --no-owner --no-privileges   --exclude-schema=aiven_extras  -d zodbconvert /data/zodb.dump
rm /data/dump.list


echo "[INFO] Running zodbconvert..."
/opt/zodbenv/bin/zodbconvert /opt/zodbenv/relstorage.cfg

echo "[INFO] Conversion complete — shutting down PostgreSQL and exiting."
pg_ctl -D "$PGDATA" -m fast stop
sleep 2
exit 0