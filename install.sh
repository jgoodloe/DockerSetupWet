#!/bin/bash

# Define colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Setup for DockerSetupWet...${NC}"

# 1. Update System & Install Docker (if not present)
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..."
    sudo apt update
    sudo apt install -y docker.io docker-compose-plugin git
    sudo usermod -aG docker $USER
    echo -e "${GREEN}Docker installed. NOTE: You may need to re-login for group permissions to apply.${NC}"
else
    echo "Docker is already installed."
fi

# 2. Create External Network
echo "Creating Docker Network..."
docker network create nginx_proxy_manager_network || true

# 3. Create Data Directory Structure (These are not in Git)
echo "Creating data directories..."
mkdir -p npm/{data,letsencrypt,custom-conf}
mkdir -p portainer/data
mkdir -p uptime-kuma/data
mkdir -p filebrowser/config
mkdir -p homer/assets
mkdir -p n8n/data
mkdir -p wg-easy/data
mkdir -p fail2ban/data
mkdir -p crowdsec/{config,data}
mkdir -p grafana/data
mkdir -p prometheus/data
mkdir -p loki/data
mkdir -p appsec-config appsec-data appsec-logs appsec-localconfig
mkdir -p code-server/config

# 4. Environment Configuration
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo -e "${GREEN}!!! ACTION REQUIRED !!!${NC}"
    echo "Please edit the .env file and add your Open-AppSec Agent Token."
    read -p "Press Enter to open .env in nano, or Ctrl+C to exit and edit manually..."
    nano .env
fi

# 5. Launch Services
echo "Building and Starting Containers..."
# Ensure the script is running with user permissions that can access docker
docker compose up -d --build

echo -e "${GREEN}Deployment Complete!${NC}"
echo "Access NGINX Proxy Manager at: http://$(hostname -I | awk '{print $1}'):81"

