#!/usr/bin/env bash
# ============================================================
# seed-postgres.sh — load a dataset's tables and data.
# Usage: ./scripts/seed/seed-postgres.sh <ecommerce|social|saas|jobs>
# ============================================================
set -euo pipefail

DATASETS=(ecommerce social saas jobs)
DATASET="${1:-}"

if [[ -z "$DATASET" ]]; then
    echo "Usage: ./scripts/seed/seed-postgres.sh <${DATASETS[*]}>"
    exit 1
fi
if [[ ! " ${DATASETS[*]} " =~ " ${DATASET} " ]]; then
    echo "❌ Unknown dataset '$DATASET'. Choose one of: ${DATASETS[*]}"
    exit 1
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="$ROOT/shared/datasets/$DATASET.sql"

# Create the database if it doesn't exist yet
if ! psql -lqt 2>/dev/null | cut -d'|' -f 1 | grep -qw "$DATASET"; then
    createdb "$DATASET"
    echo "   ✓ created database '$DATASET'"
fi

echo "🌱 Seeding PostgreSQL database '$DATASET' from $FILE ..."
psql -d "$DATASET" -v ON_ERROR_STOP=1 -f "$FILE"
echo "✅ Done. Connect with:  psql -d $DATASET"
