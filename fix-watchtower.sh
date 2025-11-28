#!/bin/bash
# Force fix Watchtower container - removes and recreates with correct config

set -e

echo "=== Fixing Watchtower Container ==="
echo ""

# Stop the container
echo "[1/4] Stopping watchtower container..."
docker compose stop watchtower 2>/dev/null || true

# Remove the container
echo "[2/4] Removing watchtower container..."
docker compose rm -f watchtower 2>/dev/null || true

# Remove any orphaned containers with the same name
echo "[3/4] Cleaning up any orphaned containers..."
docker rm -f watchtower 2>/dev/null || true

# Recreate with new configuration
echo "[4/4] Recreating watchtower with correct configuration..."
docker compose up -d --force-recreate --no-deps watchtower

echo ""
echo "=== Verification ==="
echo "Waiting 5 seconds for container to start..."
sleep 5

# Check if it's running
if docker ps | grep -q watchtower; then
    echo "✅ Watchtower container is running"
    echo ""
    echo "Checking logs for errors..."
    docker compose logs watchtower | tail -20
    echo ""
    
    # Check for the error
    if docker compose logs watchtower 2>&1 | grep -q "unknown flag: --timeout"; then
        echo "❌ ERROR: Still seeing --timeout error!"
        echo "This might be a Docker Compose cache issue."
        echo ""
        echo "Try these additional steps:"
        echo "  1. docker compose down"
        echo "  2. docker system prune -f"
        echo "  3. docker compose up -d"
    else
        echo "✅ No --timeout errors found. Watchtower should be working correctly!"
    fi
else
    echo "❌ ERROR: Watchtower container is not running"
    echo "Check logs: docker compose logs watchtower"
fi

