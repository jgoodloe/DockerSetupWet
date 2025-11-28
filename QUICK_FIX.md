# Quick Fix Guide

## Watchtower: "unknown flag: --timeout"

**IMPORTANT:** The configuration file is correct, but the container is using cached/old configuration. You MUST force recreate it.

**Problem:** Container is using old cached configuration.

**Solution:**
```bash
# Force recreate the watchtower container with new config
docker compose up -d --force-recreate watchtower

# Verify it's running correctly
docker compose logs watchtower | tail -20
```

The configuration file already has the correct flag (`--stop-timeout=30s`), but the container needs to be recreated to pick it up.

## CrowdSec: "can't find 'nginx' in collections"

**Problem:** The nginx collection name format may have changed or needs manual installation.

**Solution Option 1 - Manual Installation (Recommended):**
```bash
# Remove COLLECTIONS from environment (edit docker-compose.yml)
# Then install manually:
docker exec crowdsec cscli hub update
docker exec crowdsec cscli collections install crowdsecurity/nginx
```

**Solution Option 2 - Update CrowdSec Version:**
Edit `docker-compose.yml` and change:
```yaml
image: crowdsecurity/crowdsec:v1.7.2
```
to:
```yaml
image: crowdsecurity/crowdsec:latest
# or
image: crowdsecurity/crowdsec:v1.7.3
```

Then restart:
```bash
docker compose up -d --force-recreate crowdsec
```

**Solution Option 3 - Remove Automatic Installation:**
1. Edit `docker-compose.yml`
2. Remove or comment out the `COLLECTIONS` line:
   ```yaml
   environment:
     # - COLLECTIONS=crowdsecurity/nginx  # Commented out - install manually
     - TZ=America/New_York
   ```
3. Install collection manually after container starts (see Option 1)

## Docker Compose Version Warning

The warning about `version: '3.9'` being obsolete is harmless. It's been removed from the file, so this warning should disappear after restarting services.

## Prometheus: "permission denied" on queries.active

**Problem:** Prometheus runs as user `nobody` (UID 65534) but the data directory is owned by root.

**Solution:**
```bash
# Fix permissions on the Prometheus data directory
sudo chown -R 65534:65534 ./prometheus/data

# Or if you prefer, make it writable by all (less secure)
sudo chmod -R 777 ./prometheus/data

# Then restart Prometheus
docker compose up -d --force-recreate prometheus
```

**Alternative:** The configuration now includes a user directive, but you still need to fix existing directory permissions.

## After Fixes

1. **Fix Watchtower (CRITICAL - must force recreate):**
   ```bash
   docker compose stop watchtower
   docker compose rm -f watchtower
   docker compose up -d watchtower
   # Or use force recreate:
   docker compose up -d --force-recreate watchtower
   ```

2. **Fix Prometheus permissions:**
   ```bash
   sudo chown -R 65534:65534 ./prometheus/data
   docker compose up -d --force-recreate prometheus
   ```

3. **Fix CrowdSec (if needed):**
   ```bash
   docker exec crowdsec cscli hub update
   docker exec crowdsec cscli collections install crowdsecurity/nginx
   ```

4. Verify they're running:
   ```bash
   docker compose ps
   ```

5. Check logs for errors:
   ```bash
   docker compose logs watchtower
   docker compose logs prometheus
   docker compose logs crowdsec
   ```

