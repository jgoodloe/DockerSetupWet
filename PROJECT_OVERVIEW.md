# PROJECT_OVERVIEW

## Summary

This repository contains a custom, all-in-one Docker stack for a homelab / small infra deployment that combines: reverse proxy + WAF (NGINX Proxy Manager + Open‑AppSec), management tools, monitoring stack, security/network tooling (WireGuard, CrowdSec, Fail2Ban, Falco), developer tooling (code-server, n8n), and a custom OCSP/CRL checker service. This document provides an overview, dependency map, port mapping table, a basic threat model, an improved `install.sh`, and recommended healthchecks to add to the `docker-compose.yml`.

---

## Table of Contents

* Project overview
* Services (short descriptions)
* Dependency map (graph + list)
* Port mapping diagram (table)
* Threat model (high level)
* Improved `install.sh` (robust; idempotent; validation; user prompts)
* Healthchecks: recommended `healthcheck` blocks to add to each service
* Next steps & checklist

---

## Services (23)

List of services included in `docker-compose.yml` (canonical names from your compose):

1. appsec-agent (Open-AppSec WAF Agent)
2. appsec-nginx-proxy-manager (NGINX Proxy Manager with Open-AppSec)
3. portainer
4. uptime-kuma
5. filebrowser
6. homer
7. n8n
8. wg-easy
9. ocsp (custom CRL/OCSP checker)
10. watchtower
11. code-server
12. grafana
13. prometheus
14. cadvisor
15. loki
16. promtail
17. node-exporter
18. blackbox-exporter
19. nginx-exporter
20. fail2ban
21. crowdsec
22. falco-driver-loader
23. falco

Each service directory contains configuration and supporting files according to repository verification.

---

## High-level architecture

* `webproxy` bridge network exposes reverse proxy (appsec-nginx-proxy-manager) to the world. NPM mediates inbound HTTP(s) and admin UI.
* `npm_network` (external) carries WAF control traffic between `appsec-nginx-proxy-manager` and `appsec-agent`.
* `npm_network` is used for services that integrate with NPM directly (e.g., n8n uses NPM for hostname/proxying).
* Monitoring stack scrapes exporters via `webproxy` and/or direct container network interfaces.
* Security stack (CrowdSec, Fail2Ban, Falco) monitors logs and runtime state to block or alert on malicious behavior.
* `wg-easy` provides VPN access; must be constrained by firewall rules on host and not publicly expose management UI when unnecessary.
* `ocsp` is a custom built service that checks CRLs/OCSP and pushes notifications to Uptime-Kuma or other channels.

---

## Dependency map

### ASCII dependency graph (logical)

```
                    Internet
                       |
                 [appsec-nginx-proxy-manager] <--- WAF agent (appsec-agent)
                       |    \
                       |     \---> [appsec-agent] (WAF manager)
                       |
  -----------------------------------------------------------
  |            |            |           |           |        |
 portainer  uptime-kuma  homer     filebrowser   n8n   code-server
  (docker)    (monitor)   (static)  (files)      (workflow) (ide)

 Monitoring Stack (prometheus, grafana, loki, promtail, exporters)
    ^
    |  (scrapes metrics / receives logs)
    |
  exporters: cadvisor, node-exporter, blackbox-exporter, nginx-exporter

 Security stack: crowdsec, fail2ban (log input) -> modifies host iptables/Docker-USER
 Falco + falco-driver-loader -> host-level runtime detection (eBPF/kmod)

 Custom ocsp service -> reads CRLs (http URLs) -> posts to uptime-kuma or webhook

 VPN: wg-easy (clients) -> internal services (optionally) via routed interface
```

### Dependency list (per service)

* **appsec-nginx-proxy-manager**: needs appsec-agent (hostname), volumes for certs, appsec data volumes, `webproxy` and `npm_network` networks.
* **appsec-agent**: requires `npm_network`; stores conf in `./appsec-config`, data in `./appsec-data`.
* **portainer**: needs `/var/run/docker.sock` and `portainer/data` volume; connected to `webproxy`.
* **uptime-kuma**: stores data in `./uptime-kuma/data`; can receive push notifications from `ocsp`.
* **filebrowser**: mounts host path `/home/jgoodloe/services`, needs `webproxy` network.
* **homer**: static dashboard uses `./homer/assets` and lists services.
* **n8n**: uses `npm_network` + `webproxy`, requires NPM hostname proxying and stable storage for `./n8n/data`.
* **wg-easy**: needs host network capabilities (NET_ADMIN), `./wg-easy/data`.
* **ocsp**: built from `./ocsp` directory, expects CRL URLs and push webhook endpoints (Uptime-Kuma).
* **watchtower**: needs docker socket.
* **code-server**: `./code-server/config` and workspace mounts; connects to `webproxy`.
* **monitoring**: Prometheus config files present; prom scrapes exporters and blackbox; Grafana is provisioned to show dashboards.
* **security**: crowdsec/fail2ban require log volumes (/npm logs/host logs), Falco requires privileged rights and driver loader.

---

## Port mapping diagram

| Service (container)         |                                                         Host port(s) | Purpose / Notes                                                                |
| --------------------------- | -------------------------------------------------------------------: | ------------------------------------------------------------------------------ |
| appsec-nginx-proxy-manager |                                                          80, 443, 81 | Public HTTP(S) + NPM admin; must be exclusive on host                          |
| appsec-agent                |                                                               (none) | internal network only (npm_network)                                            |
| portainer                   |                                                                 9443 | Docker management UI (TLS)                                                     |
| uptime-kuma                 |                               (no host port listed) or uses webproxy | If proxied through NPM then no direct host port needed; ensure NPM proxy works |
| filebrowser                 |                                                80 (inside container) | Typically proxied via NPM; no host port required                               |
| homer                       |                                                                 8080 | Host-mapped as `8080:8080` in compose (public static dashboard)                |
| n8n                         |                                                                 5678 | Workflow UI & webhooks                                                         |
| wg-easy                     |                                                 51820/udp, 51821/tcp | WireGuard data + admin UI                                                      |
| ocsp                        |                                                                 8678 | CRL/OCSP HTTP API (host mapping `8678:8678`)                                   |
| watchtower                  |                                                               (none) | Runs background; uses docker socket                                            |
| code-server                 |                          (not required to be host-mapped if proxied) | Compose maps to proxy domain; compose had none direct except proxy env         |
| grafana                     |                                                                 3000 | Grafana UI                                                                     |
| prometheus                  | 9091 -> 9090 mapping (note compose maps host 9091 to container 9090) | Prometheus UI                                                                  |
| cadvisor                    |                                                            8081:8080 | Container metrics UI                                                           |
| loki                        |                                                                 3100 | Loki ingestion API                                                             |
| promtail                    |                                                               (none) | Pushes logs to Loki; uses volumes to read logs                                 |
| node-exporter               |                                                                 9100 | Node metrics for Prometheus                                                    |
| blackbox-exporter           |                                                     (none host port) | Typically scraped via Prometheus internal network                              |
| nginx-exporter              |                                                               (none) | Scrapes `appsec-nginx-proxy-manager` stub_status endpoint internally                 |
| fail2ban                    |                                                               (none) | Blocks via iptables/Docker-USER                                                |
| crowdsec                    |                                                               (none) | Internal service for log analysis; may interact with bouncers                  |
| falco-driver-loader / falco |                                                               (none) | Host privileged runtime visibility                                             |

**Notes:**

* Many services are intended to be reverse-proxied by the NPM instance — that minimizes exposed host ports.
* Ensure there are no port conflicts on the host (especially 80, 443, 81, 51820/51821, 3000, 8080).
* Re-check `prometheus` host port mapping: your compose maps container port 9090 to host 9091 which is non-standard; either accept that or change to `9090:9090`.

---

## Threat model (high-level)

This section outlines primary threats, impact, and mitigations relevant to this stack.

| Threat                                                                  | Impact                                 |            Likelihood | Primary Mitigations                                                                                                                        |
| ----------------------------------------------------------------------- | -------------------------------------- | --------------------: | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Public-facing WAF bypass / misconfiguration                             | Compromise of proxied apps             |                Medium | Keep Open-AppSec policies hardened; enable strict TLS; limit management UI exposure; use admin ACLs; monitor logs.                         |
| Exposed admin UIs (Portainer, wg-easy, code-server) accessible publicly | Remote takeover of services / RCE      | High (if unprotected) | Protect with NPM basic auth or auth proxy; bind admin UIs to internal network only; use 2FA where supported; restrict by source IP or VPN. |
| Docker socket exposure (Portainer, Watchtower)                          | Host/container compromise              |                  High | Limit access to docker socket; run Portainer with limited RBAC and role separation; avoid public port unless proxied/secured.              |
| Misconfigured VPN (wg-easy)                                             | Lateral movement into internal network |                Medium | Use strong keys; disable admin UI externally; firewall rules to limit client-to-host access; client routing controls.                      |
| Unpatched containers -> vulnerabilities                                 | Exploits via CVEs                      |                  High | Use Watchtower or controlled update pipeline; test images before upgrade; pin versions where stability matters.                            |
| Log poisoning / log-based evasion (CrowdSec, Fail2Ban)                  | Bypass detection                       |                Medium | Use structured logging, centralize logs, sanitize inputs, use multiple detectors (CrowdSec + Falco).                                       |
| Falco/eBPF driver security                                              | Kernel-level risk                      |            Low-Medium | Prefer kmod driver when eBPF not required; keep driver code updated; limit module load permissions.                                        |
| OCSP/CRL tampering or unreachable CRL servers                           | Failure to detect revoked certs        |                Medium | SSL/TLS to CRL servers; fallback endpoints; alerting via Uptime-Kuma; caching; multiple CRL sources.                                       |
| Misconfigured Prometheus scrape targets exposing sensitive metrics      | Info leakage                           |                Medium | Protect Grafana and Prometheus UIs; use auth proxy; restrict access.                                                                       |

**Recommendations:**

* Never expose admin UIs directly to the public without authentication & source IP restrictions.
* Use NPM to front services with authentication and TLS termination; keep admin ports on internal only when possible.
* Pin critical images and maintain vulnerability scanning. Consider running a CI job to test container upgrades.
* Ensure backups for important volumes (Prometheus data, Grafana provisioning, OCSP DBs, n8n workflows).

---

## Next steps & checklist before publishing

* [ ] Review all secrets in `.env` and remove plaintext secrets; prefer Docker secrets when publishing.
* [ ] Add `.gitignore` entries for sensitive directories (e.g., `npm/letsencrypt`, `code-server/config`, any private keys).
* [ ] Add a `SECURITY.md` with disclosure & contact info.
* [ ] Run `docker-compose config` to validate and `docker-compose up` in a test environment.
* [ ] Validate all `healthcheck` implementations in a dev deployment.
* [ ] Consider a staging deployment for upgrades and Watchtower testing.

---

## Appendix: Useful commands

```bash
# Validate compose
docker-compose -f docker-compose.yml config

# Start clean
docker-compose down --volumes --remove-orphans
docker-compose up -d --remove-orphans

# See service health statuses
docker ps --format "{{.Names}} {{.Status}}"

# Tail logs for a service
docker-compose logs -f appsec-nginx-proxy-manager
```

---

*Document created for DockerSetupWet project*

