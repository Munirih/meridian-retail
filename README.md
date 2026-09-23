# Meridian Retail Group — Reverse Proxy, Domains, TLS & Multi-Service Foundations

Meridian Retail Group's e-commerce storefront: a multi-service application running on Docker Compose on a single EC2 instance, provisioned with Terraform and deployed via GitHub Actions.


## Architecture

- Compute — a single EC2 instance running the full application stack via Docker Compose.
- Services — auth-service, catalog-service, orders-service, and frontend, each built as its own Docker image and a PostgreSQL Database, running as a container, backed up daily to Amazon S3 bucket.
- Reverse proxy — nginx, configured to route root traffic (/) to the frontend and /api/* paths to the correct backend service. It also terminates TLS, so HTTPS is handled at the proxy rather than in application code.
- TLS — certificates issued and auto-renewed via Certbot, serving the storefront over a secure DuckDNS domain with automatic HTTP → HTTPS redirects. DuckDNS is used for testing purposes.
- Networking & access — a custom VPC, subnets, and security groups, provisioned via Terraform (terraform/modules/network, terraform/modules/securitygroup), with SSH restricted to a strict IP whitelist. CI/CD workflows open that whitelist only for the duration of a run.
- Image registry — Amazon ECR (terraform/modules/ecr), with immutable tags: once an image is pushed under a tag, that tag can never be overwritten, so what's running in production is always traceable to an exact build.
- Compute provisioning — the EC2 instance and its IAM instance profile are defined in terraform/modules/ec2-instance and terraform/modules/iam.
- Backups storage — an S3 bucket (terraform/modules/s3_bucket) holds daily database backups.
- Remote Terraform State Management with state locking (S3 Bucket)


## project Structure

```text
meridian-retail/
├── .github/workflows/
│   ├── configure.yml         # One-time / rebuild-only server 
│   └── deploy.yml            # CI/CD: build, push, deploy on every
├── auth-service/
├── catalog-service/
├── orders-service/
├── frontend/
├── docs/
│   ├── backup-strategy.md
│   └── routing-explained.md
├── images/
├── nginx/
│   └── meridian-http.conf    # Reverse proxy routing rules
├── scripts/
│   ├── server_setup.sh       # Installs Docker and core tooling on the server
│   ├── backup_db.sh          # Nightly Postgres backup to S3 (run via cron)
│   └── restore.sh            # Restores a given day's backup from S3
├── terraform/
│   ├── modules/
│   │   ├── ec2-instance/
│   │   ├── ecr/
│   │   ├── iam/
│   │   ├── network/
│   │   ├── s3_bucket/
│   │   └── securitygroup/
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── terraform.tfvars       # gitignored — actual values
│   └── terraform.tfvars.example
├── docker-compose.prod.yml   # Production service definitions
├── docker-compose.yml        # Local development
├── .env.example 
├── .gitignore                    # gitignored — actual values
└── README.md
```
## CI/CD Pipeline

 (.github/workflows/configure.yml) is manual-trigger only (workflow_dispatch) It:

1. Locates the EC2 instance by tag and opens temporary SSH access for the GitHub runner's IP only.
2. Copies scripts/ and nginx/ to the server and runs server_setup.sh.
3. Installs the nginx config and reloads nginx.
4. Requests/renews the TLS certificate via Certbot.
5. Schedules the nightly backup cron job (backup_db.sh, daily at midnight UTC).
6. Revokes the GitHub runner's SSH access again.


(.github/workflows/deploy.yml) runs on every relevant push and:

1. Builds and pushes each service's Docker image to its ECR repository, tagged with the commit SHA (github.sha), so every deployed image is traceable to an exact commit. ECR tag immutability prevents that tag from ever being silently overwritten.
2. Opens temporary SSH access to the EC2 instance for the GitHub runner's IP, same pattern as provisioning.
3. Writes a fresh .env on the server from GitHub Secrets (DB credentials, JWT secret, domain, etc.) — no secrets are stored in the repo.
4. Pulls and redeploys via docker compose -f docker-compose.prod.yml pull && up -d --remove-orphans.
5. Revokes SSH access again once the deploy completes.



## Local development

Access the documentation to run the app localy [here](documentation.md)

Local docker compose builds images from source and exposes service ports directly for convenience. This differs from production, which pulls pre-built images from ECR, exposes only nginx, and injects secrets fresh at deploy time rather than from a hand-edited .env.

## Database backups

Backup (scripts/backup_db.sh) — runs daily via cron. Dumps the postgres-db container's database with pg_dump, compresses it, uploads it to an S3 bucket.
Restore (scripts/restore.sh) — run manually, on demand:

```bash
  ./scripts/restore.sh 2026-09-20
```
Downloads that date's backup from S3 and replays it into the database via psql. 

## Security notes

- SSH access has no standing allowlist entry for CI — it's opened and revoked within a single workflow run.
- Application ports are not exposed publicly; nginx is the only entry point.
- IAM roles are scoped to least privilege for the actions each workflow actually performs.
- ECR repositories use immutable tags to prevent silent image overwrites.