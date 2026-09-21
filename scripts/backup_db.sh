#!/bin/bash

source /home/ubuntu/app/.env

BACKUP_DIR="/home/ubuntu/app/backups"
S3_BUCKET="s3://meridian-retail-postgres-backups"
DATE=$(date +"%Y-%m-%d")
BACKUP_FILE="$BACKUP_DIR/postgres-backup-$DATE.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "Starting PostgreSQL backup..."

docker exec postgres-db pg_dump \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  | gzip > "$BACKUP_FILE"

echo "Backup created: $BACKUP_FILE"

aws s3 cp "$BACKUP_FILE" \
  "$S3_BUCKET/postgres/$DATE/postgres-backup-$DATE.sql.gz"

echo "Backup uploaded to S3."

rm "$BACKUP_FILE"

echo "Local backup removed."
echo "PostgreSQL backup completed successfully."