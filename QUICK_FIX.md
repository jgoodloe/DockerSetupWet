# Quick Fix Guide

## Watchtower: "unknown flag: --timeout"

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

## After Fixes

1. Restart affected services:
   ```bash
   docker compose restart watchtower crowdsec
   ```

2. Verify they're running:
   ```bash
   docker compose ps
   ```

3. Check logs for errors:
   ```bash
   docker compose logs watchtower
   docker compose logs crowdsec
   ```

