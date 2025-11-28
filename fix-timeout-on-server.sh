#!/bin/bash
# Fix the --timeout flag to --stop-timeout in docker-compose.yml on the server

set -e

echo "=== Fixing --timeout to --stop-timeout in docker-compose.yml ==="
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
echo "Checking current state..."
if grep -q "--timeout=30s" docker-compose.yml; then
    echo "⚠️  Found --timeout=30s (needs to be fixed)"
elif grep -q "--stop-timeout=30s" docker-compose.yml; then
    echo "✅ Already has --stop-timeout=30s (correct)"
    exit 0
else
    echo "⚠️  Neither --timeout nor --stop-timeout found in watchtower section"
fi

# Fix the timeout flag in watchtower section
echo ""
echo "Fixing --timeout to --stop-timeout..."

# Use sed to replace --timeout=30s with --stop-timeout=30s in the watchtower command section
sed -i '/watchtower:/,/^  [a-z]/ {
    s/--timeout=30s/--stop-timeout=30s/
    s/- --timeout=30s/- --stop-timeout=30s/
}' docker-compose.yml

# Also fix if it's in string format
sed -i 's/--timeout=30s/--stop-timeout=30s/g' docker-compose.yml

# Verify the fix
echo ""
echo "Verifying fix..."
if grep -A 10 "watchtower:" docker-compose.yml | grep -q "--stop-timeout=30s"; then
    echo "✅ Successfully changed to --stop-timeout=30s"
elif grep -A 10 "watchtower:" docker-compose.yml | grep -q "--timeout=30s"; then
    echo "❌ Still has --timeout=30s - manual fix needed"
    echo ""
    echo "Please manually edit docker-compose.yml and change:"
    echo "  --timeout=30s"
    echo "to:"
    echo "  --stop-timeout=30s"
    exit 1
else
    echo "⚠️  Could not verify - please check manually"
fi

# Show the watchtower section
echo ""
echo "Watchtower command section:"
grep -A 10 "watchtower:" docker-compose.yml | grep -E "(command|--)" | head -10

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Now run:"
echo "  docker compose up -d --force-recreate watchtower"

