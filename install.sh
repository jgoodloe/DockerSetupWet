#!/usr/bin/env bash
set -euo pipefail

# PROJECT: DockerSetupWet - Robust installer
# Usage: ./install.sh [--dry-run] [--skip-pull]

DRY_RUN=0
SKIP_PULL=0
COMPOSE_FILE=docker-compose.yml
REQUIRED_CMDS=(docker)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function echoerr { printf "%s\n" "$*" >&2; }

while [[ ${#} -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --skip-pull) SKIP_PULL=1; shift ;;
    --help|-h) echo "Usage: $0 [--dry-run] [--skip-pull]"; exit 0 ;;
    *) echoerr "Unknown option: $1"; exit 2;;
  esac
done

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
  echo "[*] Docker not found. Installing Docker..."
  if [[ $DRY_RUN -eq 0 ]]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    sudo usermod -aG docker "$USER"
    echo "[!] Docker installed. You may need to log out and back in for group permissions."
  else
    echo "DRY RUN: would install Docker"
  fi
fi

# Check if docker compose is available
if ! docker compose version >/dev/null 2>&1; then
  if ! docker-compose version >/dev/null 2>&1; then
    echo "[*] Docker Compose not found. Installing..."
    if [[ $DRY_RUN -eq 0 ]]; then
      sudo apt-get update && sudo apt-get install -y docker-compose-plugin
    else
      echo "DRY RUN: would install docker-compose-plugin"
    fi
  fi
fi

# Determine compose command
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif docker-compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echoerr "Docker Compose not available. Please install it."
  exit 3
fi

# Validate compose file
if [[ ! -f "$BASE_DIR/$COMPOSE_FILE" ]]; then
  echoerr "Compose file not found at $BASE_DIR/$COMPOSE_FILE"
  exit 4
fi

# Create Docker network
echo "[*] Creating Docker network..."
if [[ $DRY_RUN -eq 0 ]]; then
  docker network create nginx_proxy_manager_network || true
else
  echo "DRY RUN: would create network nginx_proxy_manager_network"
fi

# Create required directories and set safe permissions
echo "[*] Ensuring expected directories exist..."
REQUIRED_DIRS=(
  npm/data npm/letsencrypt npm/custom-conf
  appsec-config appsec-data appsec-logs appsec-localconfig
  portainer/data
  uptime-kuma/data
  filebrowser/config
  homer/assets/icons
  n8n/data
  wg-easy/data
  ocsp
  grafana/data
  prometheus/data
  loki/data
  fail2ban/data
  crowdsec/config crowdsec/data
  code-server/config
  falco/config
)

for d in "${REQUIRED_DIRS[@]}"; do
  dst="$BASE_DIR/$d"
  if [[ ! -d "$dst" ]]; then
    echo "  - Creating $dst"
    if [[ $DRY_RUN -eq 0 ]]; then
      mkdir -p "$dst"
    fi
  fi
done

# Fix Prometheus data directory permissions (runs as nobody:65534)
if [[ $DRY_RUN -eq 0 ]] && [[ -d "$BASE_DIR/prometheus/data" ]]; then
  echo "[*] Setting Prometheus data directory permissions..."
  sudo chown -R 65534:65534 "$BASE_DIR/prometheus/data" 2>/dev/null || echo "  Note: Could not set Prometheus permissions (may need manual fix)"
fi

for d in "${REQUIRED_DIRS[@]}"; do
  dst="$BASE_DIR/$d"
  if [[ ! -d "$dst" ]]; then
    echo "  - Creating $dst"
    if [[ $DRY_RUN -eq 0 ]]; then
      mkdir -p "$dst"
    fi
  fi
done

# Create .env from template if missing
if [[ ! -f "$BASE_DIR/.env" ]]; then
  if [[ -f "$BASE_DIR/.env.template" ]]; then
    echo "[*] Creating .env from .env.template"
    if [[ $DRY_RUN -eq 0 ]]; then
      cp "$BASE_DIR/.env.template" "$BASE_DIR/.env"
      echo "[!] IMPORTANT: Edit .env and add your Open-AppSec token and other secrets"
      echo "[!] Press Enter to open .env in nano, or Ctrl+C to exit and edit manually..."
      read -r
      nano "$BASE_DIR/.env"
    else
      echo "DRY RUN: would copy .env.template to .env"
    fi
  else
    echoerr ".env.template not found. Cannot proceed."
    exit 5
  fi
fi

# Optional docker pull (unless skip)
if [[ $SKIP_PULL -eq 0 ]]; then
  echo "[*] Pulling images (this may take a while)..."
  if [[ $DRY_RUN -eq 0 ]]; then
    $COMPOSE_CMD -f "$COMPOSE_FILE" pull || echo "[!] Some images failed to pull (continue)"
  else
    echo "DRY RUN: would pull images"
  fi
fi

# Start stack
echo "[*] Starting stack with docker compose up -d"
if [[ $DRY_RUN -eq 0 ]]; then
  $COMPOSE_CMD -f "$COMPOSE_FILE" up -d --build --remove-orphans
  echo "[*] Waiting for key services to become healthy..."
  sleep 6
  # quick health check summary
  docker ps --format 'table {{.Names}}\t{{.Status}}'
  echo ""
  echo "[*] Install complete!"
  echo "[*] Access NGINX Proxy Manager at: http://$(hostname -I | awk '{print $1}'):81"
  echo "[*] Access Grafana at: http://$(hostname -I | awk '{print $1}'):3000"
  echo "[*] Access Homer Dashboard at: http://$(hostname -I | awk '{print $1}'):8080"
  echo ""
  echo "[*] If needed, review .env, then run: $COMPOSE_CMD logs -f to inspect issues."
else
  echo "DRY RUN: would run $COMPOSE_CMD up -d --build"
fi
