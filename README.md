# DockerSetupWet

Automated setup for a secure Ubuntu server featuring NGINX Proxy Manager with Open-AppSec (SaaS Managed), Monitoring Stack, and utilities.

## Services Included

### Core Services
- **NGINX Proxy Manager** - Reverse proxy with Open-AppSec WAF (SaaS Managed)
- **Open-AppSec Agent** - WAF agent connecting to SaaS cloud
- **MariaDB** - Database for NGINX Proxy Manager

### Management & Utilities
- **Portainer** - Docker container management UI
- **Watchtower** - Automatic container updates
- **FileBrowser** - Web-based file manager
- **Code-Server** - VS Code in the browser
- **Homer** - Dashboard homepage for all services

### Monitoring Stack
- **Grafana** - Visualization and dashboards
- **Prometheus** - Metrics collection
- **Loki** - Log aggregation
- **Promtail** - Log shipping
- **cAdvisor** - Container metrics
- **Node Exporter** - System metrics
- **Blackbox Exporter** - Endpoint monitoring
- **Nginx Exporter** - NPM metrics
- **Uptime Kuma** - Uptime monitoring

### Security & Network
- **Fail2Ban** - Intrusion prevention
- **CrowdSec** - Collaborative security
- **WireGuard (wg-easy)** - VPN management
- **Falco** - Runtime security monitoring
- **OCSP Service** - Certificate status checking

### Development Tools
- **n8n** - Workflow automation

## Installation

### 1. Prerequisites

- A clean Ubuntu Machine (20.04/22.04+)
- An account on [Open-AppSec Portal](https://my.openappsec.io) (Get your Agent Token)

### 2. Quick Start

Run the following commands on your server:

```bash
# Clone the repository
git clone https://github.com/jgoodloe/DockerSetupWet.git

# Enter the directory
cd DockerSetupWet

# Make the installer executable
chmod +x install.sh

# Run the installer
./install.sh
```

### 3. Configuration

The script will prompt you to edit the `.env` file. You MUST:

1. Replace `REPLACE_WITH_YOUR_TOKEN` with your Open-AppSec SaaS Profile Token
2. Replace `user@example.com` with your actual email address (optional, but recommended)
3. Change the default database passwords (`DB_ROOT_PASSWORD` and `DB_MYSQL_PASSWORD`) to secure, unique passwords

## Post-Install

### Access Services

#### Homer Dashboard (Main Entry Point)
- **URL**: `http://<server-ip>:8080`
- Access all services from the centralized dashboard

#### NGINX Proxy Manager
- **URL**: `http://<server-ip>:81`
- **Default Credentials**: `admin@example.com` / `changeme`
- **⚠️ ACTION**: Immediately change the default admin password

#### Grafana (Monitoring)
- **URL**: `http://<server-ip>:3000`
- **Default Login**: `admin` / `admin`
- **⚠️ ACTION**: Immediately change the default Grafana admin password
- The Prometheus and Loki data sources should already be provisioned and ready for use

#### Other Services
- **Portainer**: `http://<server-ip>:9443`
- **Prometheus**: `http://<server-ip>:9091`
- **Uptime Kuma**: `http://<server-ip>:3001`
- **n8n**: `http://<server-ip>:5678`
- **code-server**: `http://<server-ip>:8080` (or via NPM)
- **WireGuard**: `http://<server-ip>:51821`

### Verify Open-AppSec Connection

1. Log back into the [Open-AppSec Portal](https://my.openappsec.io)
2. Check the **Agents** tab to confirm your newly deployed agent is connected and reporting status
3. Create your first Asset (e.g., for a proxy host you define in NPM) and Install the Policy to fully secure your NGINX instance

### Homer Dashboard Configuration

The Homer dashboard is pre-configured with links to all services. To update it when adding new services:

1. Edit `homer/assets/config.yml`
2. Add your service to the appropriate category
3. Restart Homer: `docker compose restart homer`

See [HOMER_DASHBOARD_NOTES.md](HOMER_DASHBOARD_NOTES.md) for detailed instructions on updating the dashboard.

## Repository Structure

```
DockerSetupWet/
├── install.sh                  # Automated setup script
├── docker-compose.yml          # Master service definition
├── .env.template              # Environment variable template
├── .gitignore                 # Git ignore rules
├── README.md                  # This file
├── HOMER_DASHBOARD_NOTES.md   # Dashboard update instructions
├── prometheus/                # Prometheus configuration
│   ├── prometheus.yml
│   └── blackbox-config.yml
├── loki/                      # Loki configuration
│   ├── loki-config.yml
│   └── promtail-config.yml
├── homer/                     # Homer dashboard
│   └── assets/
│       ├── config.yml
│       └── icons/            # Service icons
├── config/                    # Additional configuration templates
│   ├── prometheus/
│   ├── loki/
│   ├── grafana/
│   └── appsec_agent/
└── [service-data-dirs]/       # Created by install.sh
```

## Installation Process

The `install.sh` script automates the following:

1. **Phase 1**: Installs Docker and Docker Compose (if not present)
2. **Phase 2**: Creates data directories and copies configuration files
3. **Phase 3**: Prompts you to configure the `.env` file with your Open-AppSec token
4. **Phase 4**: Launches all services using Docker Compose

## Verification

After installation, verify all containers are running:

```bash
sudo docker ps
```

You should see all 23 services listed as `Up`:
- **Core**: appsec-nginx-proxy-manager, appsec-agent
- **Management**: portainer, uptime-kuma, filebrowser, homer, watchtower, code-server
- **Development**: n8n
- **Network/Security**: wg-easy, ocsp-service, fail2ban, crowdsec, falco, falco-driver-loader
- **Monitoring**: grafana, prometheus, loki, promtail, cadvisor, node-exporter, blackbox-exporter, nginx-exporter

See [SERVICE_VERIFICATION.md](SERVICE_VERIFICATION.md) for a complete verification checklist.

## Troubleshooting

### Agent Not Connecting

1. Verify your token in `.env` is correct
2. Check agent logs: `sudo docker logs appsec-agent`
3. Ensure the token was copied correctly from the Open-AppSec Portal

### Services Not Starting

1. Check logs: `sudo docker compose logs [service-name]`
2. Verify all directories exist in `./data/`
3. Check disk space: `df -h`
4. Verify Docker is running: `sudo systemctl status docker`

### Port Conflicts

If ports are already in use, modify the port mappings in `docker-compose.yml`.

## Security Notes

1. **Change Default Passwords**: Update all default credentials immediately after first login
2. **Firewall**: Configure your firewall to only expose necessary ports
3. **SSL/TLS**: Use Let's Encrypt certificates through NPM for all services
4. **Token Security**: Never commit your `.env` file with tokens to version control
5. **Regular Updates**: Review and update containers regularly

## Additional Resources

- [Open-AppSec Documentation](https://docs.openappsec.io)
- [NGINX Proxy Manager Documentation](https://nginxproxymanager.com)
- [Docker Documentation](https://docs.docker.com)
- [Grafana Documentation](https://grafana.com/docs/)

---

**Note**: This setup is designed for production use with proper security configurations. Always review and customize settings according to your specific requirements.
