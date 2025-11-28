#!/bin/bash
# Complete fix for CrowdSec - removes COLLECTIONS env var and installs manually

set -e

echo "=== Complete CrowdSec Fix ==="
echo ""

# Backup
if [ -f docker-compose.yml ]; then
    cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Created backup"
else
    echo "❌ docker-compose.yml not found!"
    exit 1
fi

echo "[1/4] Fixing docker-compose.yml..."

# Option 1: Fix the collection name
sed -i 's/COLLECTIONS=nginx/COLLECTIONS=crowdsecurity\/nginx/g' docker-compose.yml
sed -i 's/- COLLECTIONS=nginx/- COLLECTIONS=crowdsecurity\/nginx/g' docker-compose.yml

# Option 2: Comment out COLLECTIONS to disable auto-install (safer)
# This prevents the container from trying to auto-install on every restart
sed -i '/crowdsec:/,/^  [a-z]/ {
    s/^\([[:space:]]*- COLLECTIONS=\)/#\1/
}' docker-compose.yml

echo "✅ Updated docker-compose.yml"

echo ""
echo "[2/4] Stopping and removing CrowdSec container..."
docker compose stop crowdsec 2>/dev/null || true
docker compose rm -f crowdsec 2>/dev/null || true

echo ""
echo "[3/4] Recreating CrowdSec container..."
docker compose up -d crowdsec

echo ""
echo "[4/4] Waiting for container to start, then installing collection manually..."
sleep 10

# Force hub update
echo "Updating CrowdSec hub..."
docker exec crowdsec cscli hub update --force

# Install the collection manually
echo "Installing crowdsecurity/nginx collection..."
docker exec crowdsec cscli collections install crowdsecurity/nginx

# Verify installation
echo ""
echo "=== Verification ==="
if docker exec crowdsec cscli collections list | grep -q "crowdsecurity/nginx"; then
    echo "✅ Collection installed successfully!"
    docker exec crowdsec cscli collections list | grep nginx
else
    echo "⚠️  Collection may not be installed. Checking available collections..."
    docker exec crowdsec cscli collections list | head -20
fi

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Note: If you want to re-enable auto-install, uncomment the COLLECTIONS line"
echo "in docker-compose.yml and change it to: COLLECTIONS=crowdsecurity/nginx"

