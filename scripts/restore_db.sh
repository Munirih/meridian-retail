#!/bin/bash

source /home/ubuntu/app/.env

S3_BUCKET="s3://meridian-retail-postgres-backups"
BACKUP_DATE="$1"

BACKUP_FILE="postgres-backup-$BACKUP_DATE.sql.gz"
LOCAL_FILE="/tmp/$BACKUP_FILE"

echo "Downloading backup from S3..."

aws s3 cp \
  "$S3_BUCKET/postgres/$BACKUP_DATE/$BACKUP_FILE" \
  "$LOCAL_FILE"

echo "Backup downloaded."

echo "Restoring PostgreSQL database..."

gunzip -c "$LOCAL_FILE" | docker exec -i postgres-db \
  psql -U "$DB_USER" -d "$DB_NAME"

rm "$LOCAL_FILE"

echo "Database restore completed."