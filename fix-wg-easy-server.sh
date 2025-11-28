#!/bin/bash
# Complete fix for wg-easy v15 on the server

set -e

echo "=== Complete wg-easy v15 Fix ==="
echo ""

# Backup
if [ -f docker-compose.yml ]; then
    cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Created docker-compose.yml backup"
else
    echo "❌ docker-compose.yml not found!"
    exit 1
fi

# Backup data
if [ -d "./wg-easy/data" ]; then
    echo "Backing up wg-easy data..."
    cp -r ./wg-easy/data ./wg-easy/data.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
    echo "✅ Data backed up"
fi

echo ""
echo "[1/5] Stopping wg-easy container..."
docker compose stop wg-easy 2>/dev/null || true
docker compose rm -f wg-easy 2>/dev/null || true

echo ""
echo "[2/5] Fixing environment variables in docker-compose.yml..."

# Fix all the environment variable names
sed -i 's/WEBSERVER_PORT=/PORT=/g' docker-compose.yml
sed -i 's/PASSWORD_HASH=/PASSWORD=/g' docker-compose.yml
sed -i 's/ENABLE_PROMETHEUS_METRICS=/METRICS=/g' docker-compose.yml

# Verify the changes
echo "Verifying changes..."
if grep -A 10 "wg-easy:" docker-compose.yml | grep -q "PORT="; then
    echo "✅ PORT variable found"
else
    echo "⚠️  PORT variable not found - may need manual fix"
fi

if grep -A 10 "wg-easy:" docker-compose.yml | grep -q "PASSWORD="; then
    echo "✅ PASSWORD variable found"
else
    echo "⚠️  PASSWORD variable not found - may need manual fix"
fi

echo ""
echo "[3/5] Clearing wg-easy data directory (v15 requires new format)..."
echo "⚠️  WARNING: This will delete existing WireGuard configurations!"
echo "   (Backup was created above)"
read -p "Clear data directory? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ./wg-easy/data/* 2>/dev/null || true
    rm -rf ./wg-easy/data/.* 2>/dev/null || true
    echo "✅ Data directory cleared"
else
    echo "⚠️  Keeping existing data - migration may fail"
    echo "   If errors persist, you'll need to clear it manually:"
    echo "   rm -rf ./wg-easy/data/*"
fi

echo ""
echo "[4/5] Validating docker-compose.yml..."
if docker compose config > /dev/null 2>&1; then
    echo "✅ docker-compose.yml is valid"
else
    echo "❌ docker-compose.yml has errors!"
    docker compose config
    exit 1
fi

echo ""
echo "[5/5] Recreating wg-easy container..."
docker compose up -d --force-recreate wg-easy

echo ""
echo "Waiting 15 seconds for container to start..."
sleep 15

echo ""
echo "=== Checking Logs ==="
docker compose logs wg-easy | tail -30

echo ""
echo "=== Verification ==="
if docker compose logs wg-easy 2>&1 | grep -q "invalid Configuration"; then
    echo "❌ Still seeing configuration errors!"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check the wg-easy section in docker-compose.yml:"
    echo "   grep -A 15 'wg-easy:' docker-compose.yml"
    echo ""
    echo "2. Ensure data directory is completely empty:"
    echo "   ls -la ./wg-easy/data/"
    echo ""
    echo "3. Try using wg-easy v14 instead (if migration is too complex):"
    echo "   Change image to: ghcr.io/wg-easy/wg-easy:14"
    echo ""
    echo "4. Check the official migration guide:"
    echo "   https://wg-easy.github.io/wg-easy/latest/advanced/migrate/from-14-to-15/"
else
    echo "✅ No configuration errors found!"
    echo ""
    if docker ps | grep -q wg-easy; then
        echo "✅ Container is running"
        echo ""
        echo "Access the web UI at: http://$(hostname -I | awk '{print $1}'):51821"
    else
        echo "⚠️  Container is not running - check logs above"
    fi
fi

