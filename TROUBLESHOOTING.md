# Troubleshooting Guide

## Common Issues and Solutions

### Watchtower: "unknown flag: --timeout"

**Error:**
```
time="2025-11-28T18:00:54Z" level=fatal msg="unknown flag: --timeout"
```

**Solution:**
1. The configuration file uses `--stop-timeout=30s` (correct flag)
2. If you see this error, the container may be using cached configuration
3. Restart the watchtower container:
   ```bash
   docker compose restart watchtower
   ```
4. If the error persists, stop and recreate:
   ```bash
   docker compose stop watchtower
   docker compose rm watchtower
   docker compose up -d watchtower
   ```

### CrowdSec: "can't find 'nginx' in collections"

**Error:**
```
Error: cscli collections install: can't find 'nginx' in collections
```

**Solution:**
1. The collection name format has changed. Try one of these:

   **Option A:** Update the collection name in docker-compose.yml:
   ```yaml
   environment:
     - COLLECTIONS=crowdsecurity/nginx
   ```

   **Option B:** Install manually after container starts:
   ```bash
   docker exec crowdsec cscli collections install crowdsecurity/nginx
   ```

   **Option C:** Remove COLLECTIONS env var and install via config file:
   - Remove `COLLECTIONS=nginx` from environment
   - Create `crowdsec/config/acquis.yaml` with nginx log configuration
   - Restart container

2. Update CrowdSec to latest version (v1.7.3):
   ```yaml
   image: crowdsecurity/crowdsec:latest
   ```
   Or update to specific version:
   ```yaml
   image: crowdsecurity/crowdsec:v1.7.3
   ```

3. If collection still fails, check available collections:
   ```bash
   docker exec crowdsec cscli collections list
   ```

### Docker Compose: "the attribute `version` is obsolete"

**Warning:**
```
WARN[0000] /home/jgoodloe/DockerSetupWet/docker-compose.yml: the attribute `version` is obsolete
```

**Solution:**
- This is just a warning, not an error
- The `version` field has been removed from docker-compose.yml
- Docker Compose v2 doesn't require it
- You can safely ignore this warning, or it should disappear after the next restart

### Container Health Check Failures

**Symptoms:**
- Containers show as "unhealthy" in `docker ps`
- Services appear to be running but healthchecks fail

**Solutions:**
1. Check if the healthcheck command is available in the container:
   ```bash
   docker exec <container-name> which curl
   docker exec <container-name> which bash
   ```

2. Some containers may not have `curl` or `bash`. Alternative healthchecks:
   - Use `wget` instead of `curl`
   - Use process checks instead of HTTP checks
   - Remove healthcheck if not critical

3. Check container logs:
   ```bash
   docker compose logs <service-name>
   ```

### Port Conflicts

**Error:**
```
Error: bind: address already in use
```

**Solution:**
1. Find what's using the port:
   ```bash
   sudo netstat -tulpn | grep :PORT
   # or
   sudo ss -tulpn | grep :PORT
   ```

2. Either:
   - Stop the conflicting service
   - Change the port in docker-compose.yml

### Network Issues

**Error:**
```
network nginx_proxy_manager_network not found
```

**Solution:**
1. Create the network manually:
   ```bash
   docker network create nginx_proxy_manager_network
   ```

2. Or let install.sh create it (it's included in the script)

### Open-AppSec Agent Not Connecting

**Symptoms:**
- Agent shows as disconnected in Open-AppSec Portal
- Agent logs show connection errors

**Solutions:**
1. Verify token in `.env` file:
   ```bash
   grep APPSEC_AGENT_TOKEN .env
   ```

2. Check agent logs:
   ```bash
   docker logs appsec-agent
   ```

3. Verify network connectivity:
   ```bash
   docker exec appsec-agent ping -c 3 api.openappsec.io
   ```

4. Check if HTTPS proxy is needed (if behind corporate firewall):
   - Set `APPSEC_HTTPS_PROXY` in `.env`

### Service-Specific Issues

#### Prometheus: Config file not found
- Ensure `prometheus/prometheus.yml` exists
- Check file permissions

#### Loki: Config file not found
- Ensure `loki/loki-config.yml` exists
- Check file permissions

#### OCSP: Build fails
- Ensure `ocsp/Dockerfile` exists
- Ensure `ocsp/requirements.txt` exists (can be empty)

#### Falco: Driver loader fails
- May need kernel headers: `sudo apt-get install linux-headers-$(uname -r)`
- Try different driver type in environment variables

## Getting Help

1. Check service logs:
   ```bash
   docker compose logs <service-name>
   ```

2. Check all logs:
   ```bash
   docker compose logs
   ```

3. Verify container status:
   ```bash
   docker compose ps
   ```

4. Validate compose file:
   ```bash
   docker compose config
   ```

5. Check disk space:
   ```bash
   df -h
   ```

6. Check Docker resources:
   ```bash
   docker system df
   ```

## Useful Commands

```bash
# Restart a specific service
docker compose restart <service-name>

# Recreate a service (useful after config changes)
docker compose up -d --force-recreate <service-name>

# View real-time logs
docker compose logs -f <service-name>

# Execute command in container
docker exec -it <container-name> /bin/bash

# Check container resource usage
docker stats

# Clean up unused resources
docker system prune -a
```

