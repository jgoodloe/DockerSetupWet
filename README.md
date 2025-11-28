# DockerSetupWet

Automated setup for a secure Ubuntu server featuring NGINX Proxy Manager with Open-AppSec (SaaS Managed), Monitoring Stack, and utilities.

## Services Included

- **Core:** NGINX Proxy Manager + Open-AppSec WAF (SaaS) + MariaDB
- **Management:** Portainer, Watchtower, FileBrowser, Code-Server
- **Monitoring:** Prometheus, Grafana, Loki, cAdvisor, Node Exporter
- **Security:** Fail2Ban, CrowdSec, WireGuard (wg-easy)

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

### Access NGINX Proxy Manager

- **URL**: `http://<server-ip>:81`
- **Default Credentials**: `admin@example.com` / `changeme`
- **⚠️ ACTION**: Immediately change the default admin password

### Verify Open-AppSec Connection

1. Log back into the [Open-AppSec Portal](https://my.openappsec.io)
2. Check the **Agents** tab to confirm your newly deployed agent is connected and reporting status
3. Create your first Asset (e.g., for a proxy host you define in NPM) and Install the Policy to fully secure your NGINX instance

### Access Grafana (Monitoring)

- **URL**: `http://<server-ip>:3000`
- **Default Login**: `admin` / `admin`
- **⚠️ ACTION**: Immediately change the default Grafana admin password
- The Prometheus and Loki data sources should already be provisioned and ready for use

## Repository Structure

```
DockerSetupWet/
├── install.sh                  # Automated setup script
├── docker-compose.yml          # Master service definition
├── .env.template              # Environment variable template
├── .gitignore                 # Git ignore rules
├── README.md                  # This file
└── config/                    # Configuration templates
    ├── prometheus/
    │   └── prometheus.yml
    ├── loki/
    │   └── config.yml
    ├── grafana/
    │   └── provisioning/
    │       ├── datasources.yml
    │       └── dashboards.yml
    └── appsec_agent/
        └── local_policy.yaml
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

You should see `appsec-nginx-proxy-manager`, `appsec-agent`, `mariadb`, `prometheus`, `loki`, `grafana`, `cadvisor`, and `node-exporter` listed as `Up`.

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
