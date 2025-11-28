# 🔐 Security Policy

This project includes multiple security-related components (WAF, IDS/IPS, log analyzers, VPN, monitoring) and requires careful operational handling.

## Supported Components

| Component | Purpose |
|-----------|---------|
| Open-AppSec WAF | Protects reverse proxy application layer |
| NGINX Proxy Manager | TLS termination + routing |
| CrowdSec | Behavioral IP protection & community threat intelligence |
| Fail2Ban | Log-based banning based on NPM logs |
| Falco | Kernel-level intrusion and runtime anomaly detection |
| wg-easy | VPN entry point |
| OCSP/CRL Checker | Certificate revocation monitoring |

## Reporting a Vulnerability

If you discover a security issue in this project:

📩 **Please open a private issue, or email the maintainer:**
- security@goodloe.xyz (example — adjust for your real address)

**Do not disclose security issues publicly until mitigation instructions have been provided.**

## Hardening Recommendations

### 1. Expose Only Necessary Services

All admin interfaces must be behind NPM auth or the VPN:

- Portainer
- Uptime-Kuma
- wg-easy admin
- Grafana
- code-server
- Prometheus
- Loki
- Blackbox Exporter UI

**Only ports 80/443 should be public.**

### 2. Use TLS Everywhere

- Configure Let's Encrypt or ZeroSSL via NPM
- Enforce HSTS
- Prefer TLS 1.3
- Disable weak cipher suites

### 3. Secure Secrets

- Store API tokens in environment variables or Docker secrets
- Never commit `.env` files with secrets
- Exclude sensitive directories in `.gitignore`

### 4. Database/Storage Safety

**Backup:**
- Prometheus data
- Grafana dashboards
- Homer config
- OCSP logs
- n8n workflow database
- wg-easy keys

### 5. Host OS Hardening

- Enable UFW/iptables whitelisting
- Disable password SSH login (use keys only)
- Regular kernel updates
- Fail2Ban + CrowdSec should both run for layered protection

### 6. Secure Update Path

See [Auto-Upgrade Strategy](#auto-upgrade-strategy) below.

## Incident Response Outline

### Detection

- Falco alerts
- CrowdSec alerts
- Uptime-Kuma Webhook from OCSP
- Prometheus alert rules
- NPM WAF violations

### Immediate Actions

- Lock VPN access
- Rotate credentials
- Disable compromised containers
- Inspect Falco syscall audit logs

### Post-Incident

- Redeploy containers fresh
- Restore configs from backup
- Review NPM logs & CrowdSec decisions
- Patch vulnerabilities

## Responsible Disclosure

We request **90 days** for responsible fixes before public disclosure.

## Auto-Upgrade Strategy

Watchtower is powerful, but unsafe when configured poorly. This is the recommended secure configuration.

### 🎯 Goals

- Safe & controlled auto-updates
- Ability to roll back quickly
- Verification before deployment
- Exclude critical containers when necessary

### 1. Don't Automatically Update Everything

**Critical containers** like:
- `appsec-nginx-proxy-manager`
- `appsec-agent`
- `prometheus`
- `loki`
- `falco`
- `crowdsec`

should not auto-upgrade without testing.

**Recommended:** Add this label to critical services:
```yaml
labels:
  - "com.centurylinklabs.watchtower.enable=false"
```

**Enable auto-updates only for safe stateless containers:**
- Homer
- filebrowser
- uptime-kuma
- exporters
- cadvisor

### 2. Enable Watchtower Notifications

You should be notified when updates occur.

**Examples:**

**Slack:**
```yaml
WATCHTOWER_NOTIFICATION_SLACK_HOOK_URL=https://hooks.slack.com/services/xxx
```

**Discord:**
```yaml
WATCHTOWER_NOTIFICATION_DISCORD_HOOK_URL=https://discord.com/api/webhooks/xxxx
```

**Email:**
```yaml
WATCHTOWER_NOTIFICATION_EMAIL_FROM=updates@yourdomain
WATCHTOWER_NOTIFICATION_EMAIL_TO=you@yourdomain
```

### 3. Staging Pass Before Production

**Recommended workflow:**
1. Staging environment pulls updates (auto)
2. Smoke test via Uptime-Kuma
3. Only after passing → production receives update (manual or supervised)

### 4. Enable Rollback Protection

Use `--rollback` to revert automatically if a new image crashes.

**Recommended Watchtower command:**
```yaml
command: --interval 21600 --cleanup --rollback
```

### 5. Use Digest-Pinned Images for Critical Services

Instead of:
```yaml
image: grafana/grafana:latest
```

Use:
```yaml
image: grafana/grafana@sha256:7d2a...
```

This ensures:
- Reproducible builds
- No unexpected upstream changes
- You update only when you change the digest

### 6. Validation Pipeline Before Update

Watchtower restart logic:
1. Pull new image
2. Stop old container
3. Start new container
4. Wait for healthcheck
5. If healthcheck fails → rollback

Because your stack includes healthchecks, Watchtower becomes safe.

### 7. Backup Before Upgrade

Before any container is allowed to update:

- Snapshot `./grafana/data`
- Snapshot Prometheus TSDB
- Backup wg-easy keys
- Backup n8n database
- Backup Homer config
- Backup OCSP CRL history
- Backup NPM JSON config

**Use:**
```bash
rsync -a ./ /backups/docker/$(date +%Y%m%d)
```

## Best Watchtower Setup

The recommended Watchtower configuration is included in `docker-compose.yml` with:
- `--rollback` for automatic rollback on failure
- `--cleanup` to remove old images
- Appropriate timeout settings
- Healthcheck integration

**Note:** Critical services should have `com.centurylinklabs.watchtower.enable=false` label to prevent automatic updates.

---

**Last Updated**: 2025-11-28
