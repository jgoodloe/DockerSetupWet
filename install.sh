#!/bin/bash

#
# Script Name: install.sh
# Description: Fully automates the installation of Docker, Docker Compose,
#              creates required directories and configuration files, and
#              launches the entire multi-service stack (NPM, Open-AppSec, Monitoring).
#
# Usage: ./install.sh
#

# --- Configuration Variables ---
PROJECT_DIR="$(basename "$PWD")"

# --- Utility Functions ---

# Function to check if a command exists
command_exists () {
  command -v "$1" >/dev/null 2>&1
}

# Function to install Docker and Docker Compose Plugin
install_docker() {
    echo "--- Phase 1: Installing Docker and Docker Compose ---"
    if command_exists docker; then
        echo "Docker is already installed. Skipping installation."
    else
        echo "Installing Docker..."
        # Use the official convenience script for robust, non-interactive installation
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
        
        # Add the current user to the docker group to run commands without sudo
        sudo usermod -aG docker "$USER"
        echo "Docker installed successfully. Please log out and log back in (or run 'newgrp docker') for changes to take effect."
        # Note: We continue, but the user may need to restart their session for full permissions.
        # We use sudo for subsequent docker commands to ensure they run.
    fi

    # Ensure Docker Compose plugin is available
    if command_exists docker compose; then
        echo "Docker Compose Plugin is ready."
    else
        # This is usually installed by the get-docker.sh script now, but we check.
        echo "Docker Compose V2 plugin not found. Attempting install via apt (Ubuntu/Debian)..."
        sudo apt-get update && sudo apt-get install -y docker-compose-plugin
        if ! command_exists docker compose; then
            echo "Error: Docker Compose V2 plugin could not be installed. Please install it manually."
            exit 1
        fi
    fi
    echo "----------------------------------------------------"
}

# Function to create Docker network
create_network() {
    echo "--- Phase 2: Creating Docker Networks ---"
    docker network create nginx_proxy_manager_network || true
    echo "Docker networks ready"
    echo "----------------------------------------------------"
}

# Function to setup directory structure and config files
setup_directories_and_configs() {
    echo "--- Phase 3: Setting up Directories and Configuration Files ---"

    # Create persistent data directories
    mkdir -p npm/{data,letsencrypt,custom-conf}
    mkdir -p portainer/data
    mkdir -p uptime-kuma/data
    mkdir -p filebrowser/config
    mkdir -p homer/assets/icons
    mkdir -p n8n/data
    mkdir -p wg-easy/data
    mkdir -p fail2ban/data
    mkdir -p crowdsec/{config,data}
    mkdir -p grafana/data
    mkdir -p prometheus/data
    mkdir -p loki/data
    mkdir -p appsec-config appsec-data appsec-logs appsec-localconfig
    mkdir -p code-server/config
    mkdir -p falco/config
    mkdir -p ocsp
    echo "Created persistent data directories"

    # Note: Configuration files are already in place in prometheus/, loki/, and homer/assets/
    # The docker-compose.yml references these directly
    echo "Configuration files are ready in their respective directories"
    echo "----------------------------------------------------"
}

# Function to handle .env file creation and editing
configure_environment() {
    echo "--- Phase 4: Configuring Environment Variables ---"
    
    # Create the .env file from the template
    if [ -f ".env.template" ]; then
        cp ".env.template" ".env"
        echo "Created .env file from .env.template."
    else
        echo "Error: .env.template not found. Cannot proceed."
        exit 1
    fi

    echo ""
    echo "#####################################################################"
    echo "### CRITICAL STEP: OPEN-APPSEC TOKEN CONFIGURATION                  ###"
    echo "#####################################################################"
    echo "Please edit the generated '.env' file now. You MUST replace:"
    echo "1. 'REPLACE_WITH_YOUR_TOKEN' with your Open-AppSec SaaS Profile Token."
    echo "2. 'user@example.com' with your actual email address (optional, but recommended)."
    echo ""
    echo "Opening .env for editing..."
    
    # Use nano for editing the file
    nano .env

    echo "Finished editing .env. Continuing with deployment..."
    echo "----------------------------------------------------"
}

# Function to launch the Docker stack
launch_stack() {
    echo "--- Phase 5: Launching Docker Stack ---"

    # Use 'sudo' for running the compose command, especially if the user hasn't logged in/out yet
    # 'up -d' runs in detached mode
    sudo docker compose up -d

    if [ $? -eq 0 ]; then
        echo "----------------------------------------------------"
        echo "✅ Deployment Complete!"
        echo "All services are running in the background."
        echo "----------------------------------------------------"
        echo "Next steps:"
        echo "1. Verify container status: sudo docker ps"
        echo "2. Access NGINX Proxy Manager: http://<Your Server IP>:81"
        echo "3. Access Grafana: http://<Your Server IP>:3000 (Default user: admin, Pass: admin)"
    else
        echo "----------------------------------------------------"
        echo "❌ ERROR: Docker Compose failed to start the services."
        echo "Please check the logs: sudo docker compose logs"
        echo "----------------------------------------------------"
        exit 1
    fi
}

# --- Main Execution ---

# Ensure the script is run from the root of the cloned repository
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: 'docker-compose.yml' not found. Please run this script from the root directory of the DockerSetupWet repository."
    exit 1
fi

install_docker
create_network
setup_directories_and_configs
configure_environment
launch_stack

# Suggest logging out for non-sudo docker commands to work
echo ""
echo "NOTE: If you want to run 'docker' or 'docker compose' commands without 'sudo', you must log out and log back in to activate the docker group membership."
