# DockerSetupWet

Automated setup for a secure Ubuntu server featuring NGINX Proxy Manager with Open-AppSec (SaaS Managed), Monitoring Stack, and utilities.

## Services Included

- **Core:** NGINX Proxy Manager + Open-AppSec WAF (SaaS)
- **Management:** Portainer, Watchtower, FileBrowser, Code-Server
- **Monitoring:** Prometheus, Grafana, Loki, Uptime Kuma
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

The script will prompt you to edit the `.env` file. You MUST paste your Open-AppSec Agent Token into the `APPSEC_AGENT_TOKEN` field.

## Post-Install

Access your NGINX Admin UI at: `http://<server-ip>:81`

**Default Credentials:** `admin@example.com` / `changeme`

---

## 🚀 How to Create the GitHub Project (For You)

Execute these commands on your local machine (where you created the files above) to push them to your repository.

```bash
# 1. Initialize Git in your project folder
cd path/to/your/DockerSetupWet/files
git init

# 2. Add the remote repository
git remote add origin https://github.com/jgoodloe/DockerSetupWet.git

# 3. Stage all files
git add .

# 4. Commit
git commit -m "Initial commit of full docker stack"

# 5. Push to GitHub (You may be asked for username/Personal Access Token)
git branch -M main
git push -u origin main
```

## 🖥️ How to Install on the New Machine

Once the code is on GitHub, log into your new Ubuntu machine and run:

```bash
# 1. Download and set up
git clone https://github.com/jgoodloe/DockerSetupWet.git
cd DockerSetupWet
chmod +x install.sh

# 2. Run the magic script
./install.sh
```

The script will handle the heavy lifting (installing Docker, creating folders), pause to let you paste your token, and then launch everything.
