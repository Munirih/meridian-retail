# PostgreSQL Backup Strategy

## 1. Purpose

The Meridian Retail application uses PostgreSQL to store application data.

A database backup strategy was implemented to protect this data against accidental deletion, corruption, server failure, or other operational problems.

The backup solution uses:

- PostgreSQL `pg_dump`
- Gzip compression
- Amazon S3
- IAM permissions
- A scheduled cron job
- A manual restore test

The most important part of the strategy is that the backup process was not only created but also tested through an actual database restoration.

## 2. Backup Architecture

The backup flow is:

```text
PostgreSQL Container
        │
        │ pg_dump
        ▼
PostgreSQL SQL Dump
        │
        │ gzip
        ▼
Compressed .sql.gz file
        │
        │ AWS CLI
        ▼
Private Amazon S3 Bucket
```

The PostgreSQL database runs inside the Docker container:

```text
postgres-db
```

The backup script executes `pg_dump` inside this container.

## 3. Backup Script

The backup is performed by:

```text
scripts/backup_db.sh
```

The script first loads the database configuration:

```bash
source /home/ubuntu/app/.env
```

This makes variables such as the following available to the script:

```text
DB_USER
DB_NAME
```

The script then creates a temporary local backup directory:

```text
/home/ubuntu/app/backups
```

A PostgreSQL dump is created using:

```bash
docker exec postgres-db pg_dump \
  -U "$DB_USER" \
  -d "$DB_NAME"
```

The output is compressed using gzip:

```bash
| gzip
```

The resulting file has the format:

```text
postgres-backup-YYYY-MM-DD.sql.gz
```

## 4. S3 Storage

The compressed backup is uploaded to a private S3 bucket.

The bucket is:

```text
meridian-retail-postgres-backups
```

Backups are organized by date.

Example:

```text
s3://meridian-retail-postgres-backups/
└── postgres/
    └── 2026-09-21/
        └── postgres-backup-2026-09-21.sql.gz
```

Organizing backups by date makes it easier to identify and restore a specific backup.

## 5. Why the S3 Bucket Is Private

The S3 bucket is configured with S3 Block Public Access enabled.

The backup data should not be publicly accessible because it contains database information.

Access is provided through the EC2 instance's IAM role instead of storing AWS access keys inside the backup script.

The EC2 role is allowed to perform the required S3 operations.

## 6. IAM Permissions

The EC2 IAM role has scoped permissions for the PostgreSQL backup bucket.

The permissions include:

```text
s3:PutObject
s3:GetObject
s3:ListBucket
```

### Uploading backups

```text
s3:PutObject
```

Allows the backup script to upload backup files.

### Downloading backups

```text
s3:GetObject
```

Allows the restore process to download a backup.

### Listing the bucket

```text
s3:ListBucket
```

Allows the server to list objects in the backup bucket.

The permissions are restricted to the PostgreSQL backup bucket rather than providing unrestricted S3 access.

## 7. Local Backup File

The backup is temporarily stored on the EC2 server:

```text
/home/ubuntu/app/backups/
```

After the backup is successfully uploaded to S3, the local backup file is removed.

This means the server does not unnecessarily retain multiple local copies of the database backups.

The S3 bucket acts as the persistent backup location.

## 8. Backup Schedule

The backup is automated using cron.

The configured cron job is:

```cron
0 0 * * * /home/ubuntu/app/scripts/backup_db.sh >> /home/ubuntu/app/backup.log 2>&1
```

The EC2 server uses UTC.

Therefore:

```text
00:00 UTC
     =
02:00 SAST
```

The backup runs once every day at 02:00 South African time.

## 9. Backup Logging

The cron job redirects the script output to:

```text
/home/ubuntu/app/backup.log
```

The command:

```bash
>> /home/ubuntu/app/backup.log 2>&1
```

means:

- normal output is appended to `backup.log`
- error output is also redirected to the same file

The log provides a simple way to investigate whether a scheduled backup succeeded or failed.

The log file is not the database backup itself.

The actual backup is stored in S3.

## 10. Restore Process

The restore process is handled by:

```text
scripts/restore_db.sh
```

The restore flow is:

```text
Private S3 Bucket
        │
        │ aws s3 cp
        ▼
Temporary /tmp file
        │
        │ gunzip
        ▼
SQL dump
        │
        │ psql
        ▼
PostgreSQL database
```

The restore script accepts a backup date.

For example:

```bash
./restore_db.sh 2026-09-21
```

It downloads:

```text
postgres-backup-2026-09-21.sql.gz
```

from:

```text
s3://meridian-retail-postgres-backups/postgres/2026-09-21/
```

The backup is temporarily stored in:

```text
/tmp/
```

## 11. Restore Testing

A backup is only useful if it can actually be restored.

A manual restore test was therefore performed.

The test followed these steps:

### Step 1 — Download the backup from S3

```text
aws s3 cp \
  s3://meridian-retail-postgres-backups/postgres/$(date +%Y-%m-%d)/postgres-backup-$(date +%Y-%m-%d).sql.gz \
  /tmp/postgres-backup-test.sql.gz
```

### Step 2 — Inspect the backup

The compressed file inspected using:

```bash
gunzip -c /tmp/postgres-backup-test.sql.gz | head -30
```

### Step 3 — Create a temporary database

A temporary database called restore_test:

```text
docker exec -i postgres-db psql -U "$DB_USER" -d postgres \
  -c "CREATE DATABASE restore_test;"
```


### Step 4 — Restore the backup

The backup restored into the temporary database.

```text
gunzip -c /tmp/postgres-backup-test.sql.gz | docker exec -i postgres-db \
  psql -U "$DB_USER" -d restore_test
```

### Step 5 — Verify the tables

The restored database checked using:

```bash
docker exec -i postgres-db psql -U "$DB_USER" -d restore_test -c "\dt"
```

### Step 6 — Verify the data

The restored data queried to confirm that records were successfully recovered.

```text
docker exec -i postgres-db psql -U "$DB_USER" -d restore_test \
  -c "SELECT * FROM orders LIMIT 5;"
```

### Step 7 — Remove the test database

After the successful test, the temporary database is removed:

```text
docker exec -i postgres-db psql -U "$DB_USER" -d postgres \
  -c "DROP DATABASE restore_test;"
```
