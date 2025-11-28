#!/bin/bash
# Diagnose Watchtower container to see what command is actually being used

echo "=== Watchtower Container Diagnosis ==="
echo ""

# Check if container exists
if ! docker ps -a | grep -q watchtower; then
    echo "❌ Watchtower container not found"
    exit 1
fi

echo "[1] Checking docker-compose.yml configuration..."
if grep -A 10 "watchtower:" docker-compose.yml | grep -q "--stop-timeout"; then
    echo "✅ docker-compose.yml has --stop-timeout (correct)"
else
    echo "❌ docker-compose.yml does NOT have --stop-timeout"
fi

echo ""
echo "[2] Checking for docker-compose.override.yml..."
if [ -f docker-compose.override.yml ]; then
    echo "⚠️  Found docker-compose.override.yml - this might override settings!"
    if grep -A 10 "watchtower:" docker-compose.override.yml | grep -q "timeout"; then
        echo "❌ docker-compose.override.yml contains timeout setting!"
        grep -A 10 "watchtower:" docker-compose.override.yml
    fi
else
    echo "✅ No docker-compose.override.yml found"
fi

echo ""
echo "[3] Inspecting actual running container command..."
CONTAINER_CMD=$(docker inspect watchtower --format='{{range .Config.Cmd}}{{.}} {{end}}' 2>/dev/null)
echo "Container CMD: $CONTAINER_CMD"

CONTAINER_ENTRYPOINT=$(docker inspect watchtower --format='{{range .Config.Entrypoint}}{{.}} {{end}}' 2>/dev/null)
echo "Container Entrypoint: $CONTAINER_ENTRYPOINT"

echo ""
echo "[4] Checking docker compose config (what compose thinks it should run)..."
docker compose config | grep -A 15 "watchtower:" | head -20

echo ""
echo "[5] Checking container logs for the actual error..."
docker compose logs watchtower 2>&1 | grep -i "timeout" | tail -5

echo ""
echo "[6] Checking if there's a .env file with watchtower settings..."
if [ -f .env ]; then
    if grep -i "watchtower.*timeout" .env; then
        echo "⚠️  Found timeout setting in .env file!"
    else
        echo "✅ No timeout setting in .env"
    fi
fi

echo ""
echo "=== Diagnosis Complete ==="

