#!/usr/bin/env bash
# ============================================================
# reset-mongo.sh — drop a database and reseed it fresh.
# Usage: ./scripts/reset/reset-mongo.sh <ecommerce|social|saas|jobs>
# ============================================================
set -euo pipefail

DATASETS=(ecommerce social saas jobs)
DATASET="${1:-}"

if [[ -z "$DATASET" ]]; then
    echo "Usage: ./scripts/reset/reset-mongo.sh <${DATASETS[*]}>"
    exit 1
fi
if [[ ! " ${DATASETS[*]} " =~ " ${DATASET} " ]]; then
    echo "❌ Unknown dataset '$DATASET'. Choose one of: ${DATASETS[*]}"
    exit 1
fi

echo "🗑  Dropping MongoDB database '$DATASET'..."
mongosh --quiet --eval "db.getSiblingDB('$DATASET').dropDatabase()"

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
"$ROOT/scripts/seed/seed-mongo.sh" "$DATASET"
