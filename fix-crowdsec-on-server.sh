#!/bin/bash
# Fix CrowdSec collection name from "nginx" to "crowdsecurity/nginx"

set -e

echo "=== Fixing CrowdSec Collection Name ==="
echo ""

# Backup the file first
if [ -f docker-compose.yml ]; then
    cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Created backup: docker-compose.yml.backup.*"
else
    echo "❌ docker-compose.yml not found!"
    exit 1
fi

# Check current state
echo "Checking current CrowdSec COLLECTIONS setting..."
if grep -A 5 "crowdsec:" docker-compose.yml | grep -q 'COLLECTIONS=nginx'; then
    echo "⚠️  Found COLLECTIONS=nginx (needs to be fixed)"
elif grep -A 5 "crowdsec:" docker-compose.yml | grep -q 'COLLECTIONS=crowdsecurity/nginx'; then
    echo "✅ Already has COLLECTIONS=crowdsecurity/nginx (correct)"
    echo ""
    echo "If you're still seeing errors, try:"
    echo "  1. docker exec crowdsec cscli hub update"
    echo "  2. docker exec crowdsec cscli collections install crowdsecurity/nginx"
    exit 0
else
    echo "⚠️  No COLLECTIONS setting found in crowdsec section"
fi

# Fix the collection name
echo ""
echo "Fixing COLLECTIONS=nginx to COLLECTIONS=crowdsecurity/nginx..."

# Fix in environment section
sed -i '/crowdsec:/,/^  [a-z]/ {
    s/COLLECTIONS=nginx/COLLECTIONS=crowdsecurity\/nginx/
    s/- COLLECTIONS=nginx/- COLLECTIONS=crowdsecurity\/nginx/
}' docker-compose.yml

# Also fix if it's in quotes
sed -i 's/COLLECTIONS="nginx"/COLLECTIONS="crowdsecurity\/nginx"/g' docker-compose.yml
sed -i "s/COLLECTIONS='nginx'/COLLECTIONS='crowdsecurity\/nginx'/g" docker-compose.yml

# Verify the fix
echo ""
echo "Verifying fix..."
if grep -A 5 "crowdsec:" docker-compose.yml | grep -q "COLLECTIONS=crowdsecurity/nginx"; then
    echo "✅ Successfully changed to COLLECTIONS=crowdsecurity/nginx"
elif grep -A 5 "crowdsec:" docker-compose.yml | grep -q "COLLECTIONS=nginx"; then
    echo "❌ Still has COLLECTIONS=nginx - manual fix needed"
    echo ""
    echo "Please manually edit docker-compose.yml and change:"
    echo "  COLLECTIONS=nginx"
    echo "to:"
    echo "  COLLECTIONS=crowdsecurity/nginx"
    exit 1
else
    echo "⚠️  Could not verify - please check manually"
fi

# Show the crowdsec section
echo ""
echo "CrowdSec environment section:"
grep -A 10 "crowdsec:" docker-compose.yml | grep -E "(COLLECTIONS|environment)" | head -5

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Now run:"
echo "  docker compose up -d --force-recreate crowdsec"
echo ""
echo "Or install manually:"
echo "  docker exec crowdsec cscli hub update"
echo "  docker exec crowdsec cscli collections install crowdsecurity/nginx"

