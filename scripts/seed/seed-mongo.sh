#!/usr/bin/env bash
# ============================================================
# seed-mongo.sh — load a dataset's collections and data.
# Usage: ./scripts/seed/seed-mongo.sh <ecommerce|social|saas|jobs>
# ============================================================
set -euo pipefail

DATASETS=(ecommerce social saas jobs)
DATASET="${1:-}"

if [[ -z "$DATASET" ]]; then
    echo "Usage: ./scripts/seed/seed-mongo.sh <${DATASETS[*]}>"
    exit 1
fi
if [[ ! " ${DATASETS[*]} " =~ " ${DATASET} " ]]; then
    echo "❌ Unknown dataset '$DATASET'. Choose one of: ${DATASETS[*]}"
    exit 1
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$ROOT/shared/datasets/$DATASET.mongo.js"

if ! command -v mongosh &>/dev/null; then
    echo "❌ mongosh not found. Install it: https://www.mongodb.com/docs/mongodb-shell/install/"
    exit 1
fi

echo "🌱 Seeding MongoDB database '$DATASET' from $FILE ..."
mongosh --quiet --file "$FILE"
echo "✅ Done. Connect with:  mongosh $DATASET"
