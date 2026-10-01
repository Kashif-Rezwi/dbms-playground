#!/usr/bin/env bash
# ============================================================
# setup-mongo.sh — verify MongoDB is reachable, then seed the
# four practice databases. MongoDB creates databases lazily
# on first write, so seeding IS the setup step.
# Requires: mongosh + mongod running (brew services start mongodb-community@8.0)
# Usage: ./scripts/setup/setup-mongo.sh
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "🚀 Setting up MongoDB practice databases..."

if ! command -v mongosh &>/dev/null; then
    echo "❌ mongosh not found. Install it: brew install mongosh"
    exit 1
fi

if ! mongosh --quiet "mongodb://127.0.0.1:27017/?serverSelectionTimeoutMS=3000" \
        --eval 'db.runCommand({ ping: 1 }).ok' >/dev/null 2>&1; then
    echo "❌ Cannot reach MongoDB on localhost:27017."
    echo "   Start it:  brew services start mongodb-community@8.0"
    exit 1
fi

echo "   ✓ MongoDB is reachable on localhost:27017"
"$ROOT/scripts/seed/seed-mongo.sh" all

echo ""
echo "Next:"
echo "  mongosh ecommerce"
echo "  ./scripts/reset/reset-mongo.sh ecommerce   # drop + reseed anytime"
