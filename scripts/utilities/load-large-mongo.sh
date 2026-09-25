#!/usr/bin/env bash
# ============================================================
# load-large-mongo.sh — load the perf_lab database for
# performance / index / explain() lessons.
# Usage: ./scripts/utilities/load-large-mongo.sh
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if ! command -v mongosh &>/dev/null; then
    echo "❌ mongosh not found."
    exit 1
fi

echo "🚀 Generating ~255k documents (this takes ~30-60 seconds)..."
mongosh --quiet --file "$ROOT/scripts/utilities/generate-large-mongo.js"
echo "✅ Connect with:  mongosh perf_lab"
