#!/usr/bin/env bash


set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script with sudo: sudo ./scripts/server_setup.sh"
  exit 1
fi

echo "==> Updating package index"
apt-get update -y

echo "==> Installing prerequisites"
apt-get install -y ca-certificates curl gnupg lsb-release

# ---------------------------------------------------------------------------
# Docker
# ---------------------------------------------------------------------------
echo "==> Setting up Docker's official apt repository"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

echo "==> Installing Docker Engine + Compose plugin"
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

TARGET_USER="${SUDO_USER:-ubuntu}"
if id "$TARGET_USER" &>/dev/null; then
  usermod -aG docker "$TARGET_USER"
  echo "==> Added $TARGET_USER to the docker group (log out/in for it to take effect)"
fi

# ---------------------------------------------------------------------------
# AWS CLI — used to auth to ECR. Credentials come from the instance
# profile attached to this EC2 instance; nothing to configure here.
# ---------------------------------------------------------------------------
if ! command -v aws &> /dev/null; then
  echo "==> Installing AWS CLI v2"
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  apt-get install -y unzip
  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
  rm -rf /tmp/awscliv2.zip /tmp/aws
fi

# ---------------------------------------------------------------------------
# nginx
# ---------------------------------------------------------------------------
echo "==> Installing nginx"
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# ---------------------------------------------------------------------------
# certbot
# ---------------------------------------------------------------------------
echo "==> Installing certbot"
apt-get install -y certbot python3-certbot-nginx
