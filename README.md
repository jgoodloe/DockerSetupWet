# Docker Setup with Open-AppSec WAF

Complete setup guide for deploying a comprehensive Docker stack with Open-AppSec WAF, NGINX Proxy Manager, and various services on Ubuntu.

## 📋 Prerequisites

- A clean Ubuntu machine (physical or VM)
- Root or sudo access
- An account on the [Open-AppSec Portal](https://portal.openappsec.io) (free tier available)

## 🚀 Quick Start

1. Clone this repository
2. Follow the setup phases below
3. Start the stack with `docker compose up -d --build`

## 📖 Setup Guide

### Phase 1: System Preparation & Docker Installation

#### Update the System

```bash
sudo apt update && sudo apt upgrade -y
```

#### Install Docker & Docker Compose

```bash
sudo apt install docker.io docker-compose-plugin -y
```

#### Configure User Permissions

Add your current user to the Docker group so you don't have to run Docker commands as root:

```bash
sudo usermod -aG docker $USER
```

⚠️ **Action Required**: You must log out and log back in (or reboot) for this change to take effect.

#### Create External Network

Create the network that NGINX Proxy Manager will use:

```bash
docker network create nginx_proxy_manager_network || true
```

### Phase 2: Directory & File Structure

The setup script will create a structured directory for all your services and configurations.

#### Create Main Directories

```bash
mkdir -p open-appsec-deployment
cd open-appsec-deployment

# Create subdirectories for all services
mkdir -p {npm,portainer,uptime-kuma,filebrowser,homer,n8n,wg-easy,ocsp,fail2ban,crowdsec,falco,grafana,prometheus,loki,code-server}

# Create subdirectories for Open-AppSec specific data
mkdir -p {appsec-config,appsec-data,appsec-logs,appsec-localconfig}

# Create subdirectories for Monitoring Data
mkdir -p grafana/data prometheus/data loki/data
```

### Phase 3: Configuration Files

#### 1. Environment File (.env)

This file connects your machine to the Open-AppSec SaaS cloud.

**Steps:**
1. Go to the [Open-AppSec Portal](https://portal.openappsec.io)
2. Navigate to **Agents > Profiles > New Profile**. Select "Docker"
3. Copy the Token provided
4. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
5. Edit `.env` and replace `YOUR_TOKEN_HERE` with your actual token

#### 2. Monitoring Configuration Files

All monitoring configuration files are included in this repository:
- `prometheus/prometheus.yml` - Prometheus scraping configuration
- `loki/loki-config.yml` - Loki log aggregation configuration
- `loki/promtail-config.yml` - Promtail log collection configuration
- `prometheus/blackbox-config.yml` - Blackbox exporter configuration

#### 3. OCSP Service

The OCSP service requires a custom Dockerfile, which is included in `ocsp/Dockerfile`.

### Phase 4: Launch the Stack

Start all services:

```bash
docker compose up -d --build
```

The `--build` flag ensures the custom OCSP container is built.

The command will automatically pull variables from your `.env` file.

#### Verify Status

```bash
docker ps
```

Ensure `appsec-agent` and `appsec-nginx-proxy-manager` are "Up".

### Phase 5: Post-Installation

#### Access NGINX Proxy Manager

- **URL**: `http://<your-server-ip>:81`
- **Default Email**: `admin@example.com`
- **Default Password**: `changeme`

⚠️ **Important**: Change the default password immediately after first login.

#### Link to Open-AppSec Cloud

Because we used the SaaS `.env` setup, your agent should automatically appear as "Connected" in the Open-AppSec Portal under **Agents**.

#### Configure Proxy Hosts

1. Add your domains in NPM
2. Go to the Open-AppSec Portal to apply security policies to these specific assets

## 🏗️ Architecture

This stack includes:

### Core Services
- **Open-AppSec Agent** - WAF agent connecting to SaaS
- **NGINX Proxy Manager** - Reverse proxy with Open-AppSec integration

### Management & Utilities
- **Portainer** - Docker container management UI
- **Watchtower** - Automatic container updates
- **Filebrowser** - Web-based file manager
- **Code-Server** - VS Code in the browser

### Applications & Dashboards
- **Uptime Kuma** - Uptime monitoring
- **Homer** - Dashboard homepage
- **n8n** - Workflow automation
- **WG-Easy** - WireGuard VPN management

### Monitoring Stack
- **Grafana** - Visualization and dashboards
- **Prometheus** - Metrics collection
- **Loki** - Log aggregation
- **Promtail** - Log shipping
- **Node Exporter** - System metrics
- **cAdvisor** - Container metrics
- **Blackbox Exporter** - Endpoint monitoring
- **Nginx Exporter** - NPM metrics

### Security & Utilities
- **Fail2Ban** - Intrusion prevention
- **CrowdSec** - Collaborative security
- **OCSP** - Certificate status checking
- **Falco** - Runtime security monitoring

## 📁 Directory Structure

```
open-appsec-deployment/
├── .env                          # Environment variables (create from .env.example)
├── docker-compose.yml            # Main orchestration file
├── appsec-config/                # Open-AppSec configuration
├── appsec-data/                  # Open-AppSec data
├── appsec-logs/                  # Open-AppSec logs
├── appsec-localconfig/           # Open-AppSec local config
├── npm/                          # NGINX Proxy Manager data
│   ├── data/
│   └── letsencrypt/
├── prometheus/
│   ├── prometheus.yml
│   ├── blackbox-config.yml
│   └── data/
├── loki/
│   ├── loki-config.yml
│   ├── promtail-config.yml
│   └── data/
├── grafana/
│   └── data/
├── ocsp/
│   └── Dockerfile
└── [other service directories]/
```

## 🔧 Configuration

### Ports

| Service | Port | Description |
|---------|------|-------------|
| NGINX Proxy Manager | 80, 443, 81 | HTTP, HTTPS, Admin UI |
| Portainer | 9443 | Container management |
| Grafana | 3000 | Dashboards |
| Prometheus | 9091 | Metrics |
| Loki | 3100 | Log aggregation |
| Uptime Kuma | 3001 | Uptime monitoring |
| Homer | 8080 | Dashboard homepage |
| n8n | 5678 | Workflow automation |
| WG-Easy | 51820/udp, 51821/tcp | WireGuard VPN |
| Code-Server | 8080 | VS Code in browser |
| OCSP | 8678 | Certificate status |
| cAdvisor | 8081 | Container metrics |
| Node Exporter | 9100 | System metrics |

### Networks

- `webproxy` - Main bridge network for all services
- `nginx_proxy_manager_network` - External network for NPM
- `crowdsec_net` - Isolated network for CrowdSec

## 🔒 Security Notes

1. **Change Default Passwords**: Update all default credentials immediately
2. **Firewall**: Configure your firewall to only expose necessary ports
3. **SSL/TLS**: Use Let's Encrypt certificates through NPM for all services
4. **Token Security**: Never commit your `.env` file with tokens to version control
5. **Regular Updates**: Watchtower will auto-update containers, but review changes

## 🐛 Troubleshooting

### Agent Not Connecting

1. Verify your token in `.env` is correct
2. Check agent logs: `docker logs appsec-agent`
3. Ensure `APPSEC_AUTO_POLICY_LOAD=false` in `.env`

### Services Not Starting

1. Check logs: `docker compose logs [service-name]`
2. Verify all directories exist
3. Check disk space: `df -h`
4. Verify network exists: `docker network ls`

### Port Conflicts

If ports are already in use, modify the port mappings in `docker-compose.yml`.

## 📝 License

This project is provided as-is for educational and deployment purposes.

## 🤝 Contributing

Feel free to submit issues or pull requests for improvements.

## 📚 Additional Resources

- [Open-AppSec Documentation](https://docs.openappsec.io)
- [NGINX Proxy Manager Documentation](https://nginxproxymanager.com)
- [Docker Documentation](https://docs.docker.com)

---

**Note**: This setup is designed for production use with proper security configurations. Always review and customize settings according to your specific requirements.

