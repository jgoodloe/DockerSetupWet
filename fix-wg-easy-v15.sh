#!/bin/bash
# Fix wg-easy v15 configuration migration

set -e

echo "=== Fixing wg-easy v15 Configuration ==="
echo ""

# Backup
if [ -f docker-compose.yml ]; then
    cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Created backup"
else
    echo "❌ docker-compose.yml not found!"
    exit 1
fi

echo "[1/4] Stopping wg-easy container..."
docker compose stop wg-easy 2>/dev/null || true

echo ""
echo "[2/4] Backing up wg-easy data (if exists)..."
if [ -d "./wg-easy/data" ]; then
    cp -r ./wg-easy/data ./wg-easy/data.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
    echo "✅ Data backed up"
fi

echo ""
echo "[3/4] Note: wg-easy v15 requires data migration."
echo "If you have existing WireGuard configs, you may need to:"
echo "  1. Export your configs from v14"
echo "  2. Clear the data directory: rm -rf ./wg-easy/data/*"
echo "  3. Let v15 create a fresh config"
echo ""
read -p "Clear existing wg-easy data? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Clearing wg-easy data directory..."
    rm -rf ./wg-easy/data/* 2>/dev/null || true
    echo "✅ Data cleared"
else
    echo "⚠️  Keeping existing data - migration may fail if format is incompatible"
fi

echo ""
echo "[4/4] Recreating container with v15 configuration..."
docker compose up -d --force-recreate wg-easy

echo ""
echo "Waiting 10 seconds for container to start..."
sleep 10

echo ""
echo "=== Checking Logs ==="
docker compose logs wg-easy | tail -20

echo ""
echo "=== Fix Complete ==="
echo ""
echo "If you still see errors, check:"
echo "  1. https://wg-easy.github.io/wg-easy/latest/advanced/migrate/from-14-to-15/"
echo "  2. Ensure data directory is empty or migrated"
echo "  3. Verify environment variables are correct"

