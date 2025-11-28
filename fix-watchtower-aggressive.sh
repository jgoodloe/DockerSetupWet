#!/bin/bash
# Aggressive fix for Watchtower - completely removes everything and recreates

set -e

echo "=== Aggressive Watchtower Fix ==="
echo ""

# Stop all services to avoid conflicts
echo "[1/6] Stopping all services..."
docker compose down

# Remove watchtower container specifically
echo "[2/6] Removing watchtower container..."
docker rm -f watchtower 2>/dev/null || true

# Remove watchtower image to force fresh pull
echo "[3/6] Removing watchtower image..."
docker rmi containrrr/watchtower:latest 2>/dev/null || true

# Clean Docker system cache
echo "[4/6] Cleaning Docker system cache..."
docker system prune -f

# Validate compose file
echo "[5/6] Validating docker-compose.yml..."
docker compose config > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ docker-compose.yml is valid"
else
    echo "❌ docker-compose.yml has errors!"
    exit 1
fi

# Show what command will be used
echo ""
echo "[6/6] Showing watchtower configuration from docker-compose.yml:"
docker compose config | grep -A 10 "watchtower:" | grep -E "(command|image)" | head -5

# Recreate watchtower
echo ""
echo "Recreating watchtower container..."
docker compose up -d --force-recreate --no-deps watchtower

echo ""
echo "Waiting 5 seconds for container to start..."
sleep 5

# Check logs
echo ""
echo "=== Checking Logs ==="
docker compose logs watchtower | tail -30

# Final check
if docker compose logs watchtower 2>&1 | grep -q "unknown flag: --timeout"; then
    echo ""
    echo "❌ ERROR: Still seeing --timeout error!"
    echo ""
    echo "This suggests the issue might be:"
    echo "  1. A docker-compose.override.yml file overriding settings"
    echo "  2. An environment variable setting the command"
    echo "  3. A cached Docker Compose configuration"
    echo ""
    echo "Try running: ./diagnose-watchtower.sh"
else
    echo ""
    echo "✅ SUCCESS: No --timeout errors found!"
    echo "Watchtower should be working correctly now."
fi

