# Fixes Applied - November 28, 2025

## Issues Fixed

### 1. Watchtower: "unknown flag: --timeout" Error

**Problem:** Container was using cached configuration with old `--timeout` flag instead of `--stop-timeout=30s`.

**Root Cause:** Docker Compose was using a cached command from a previous container start.

**Solution Applied:**
- Configuration file already had correct flag (`--stop-timeout=30s`)
- Added clear instructions to force recreate the container

**Action Required:**
```bash
# Force recreate Watchtower container
docker compose stop watchtower
docker compose rm -f watchtower
docker compose up -d watchtower

# Or one command:
docker compose up -d --force-recreate watchtower
```

### 2. Prometheus: "permission denied" on queries.active

**Problem:** Prometheus runs as user `nobody` (UID 65534) but the mounted data directory was owned by root, causing permission errors when trying to create the query log file.

**Root Cause:** Volume mount permissions mismatch between container user and host directory ownership.

**Solution Applied:**
1. Added `user: "65534:65534"` directive to Prometheus service in `docker-compose.yml`
2. Updated `install.sh` to automatically set correct permissions on `prometheus/data` directory
3. Added explicit query log path in command arguments

**Action Required (if directory already exists):**
```bash
# Fix permissions on existing directory
sudo chown -R 65534:65534 ./prometheus/data

# Restart Prometheus
docker compose up -d --force-recreate prometheus
```

**For New Installations:**
The `install.sh` script now automatically sets these permissions, so no manual action is needed.

## Files Modified

1. **docker-compose.yml**
   - Added `user: "65534:65534"` to Prometheus service
   - Added query log path to Prometheus command arguments

2. **install.sh**
   - Added automatic permission fix for `prometheus/data` directory after creation

3. **README.md**
   - Updated troubleshooting section with detailed fix instructions for both issues

4. **QUICK_FIX.md**
   - Added comprehensive troubleshooting steps for both issues

## Verification

After applying fixes, verify services are running:

```bash
# Check container status
docker compose ps

# Check Watchtower logs (should show no --timeout errors)
docker compose logs watchtower | tail -20

# Check Prometheus logs (should show no permission errors)
docker compose logs prometheus | tail -20
```

## Next Steps

1. **Immediate:** Force recreate Watchtower and fix Prometheus permissions (see commands above)
2. **Future:** New installations will automatically have correct permissions via `install.sh`
3. **Monitoring:** Watch logs for any remaining issues

