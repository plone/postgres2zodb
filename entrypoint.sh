#!/bin/bash
set -e

: "${DB_NAME:=zodbconvert}"
: "${DB_USER:=postgres}"
: "${DUMP_FILE:=/data/zodb.dump}"
: "${CONVERT_CONF:=/relstorage.cfg}"

echo "Starting PostgreSQL..."
pg_ctlcluster 16 main start

echo "Creating database ${DB_NAME}..."
psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;"

echo "Restoring binary dump: ${DUMP_FILE}..."
pg_restore -U "$DB_USER" -d "$DB_NAME" "$DUMP_FILE"

echo "Creating output dirs..."
mkdir -p /data/output/filestorage
mkdir -p /data/output/blobstorage

echo "Running zodbconvert..."
zodbconvert "$CONVERT_CONF"

echo "Done. Output written to /data/output/"