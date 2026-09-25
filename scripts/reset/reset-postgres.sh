#!/usr/bin/env bash
# ============================================================
# reset-postgres.sh — drop a database and reseed it fresh.
# Resetting is a normal part of experimenting, not failure.
# Usage: ./scripts/reset/reset-postgres.sh <ecommerce|social|saas|jobs>
# ============================================================
set -euo pipefail

DATASETS=(ecommerce social saas jobs)
DATASET="${1:-}"

if [[ -z "$DATASET" ]]; then
    echo "Usage: ./scripts/reset/reset-postgres.sh <${DATASETS[*]}>"
    exit 1
fi
if [[ ! " ${DATASETS[*]} " =~ " ${DATASET} " ]]; then
    echo "❌ Unknown dataset '$DATASET'. Choose one of: ${DATASETS[*]}"
    exit 1
fi

if psql -lqt 2>/dev/null | cut -d'|' -f 1 | grep -qw "$DATASET"; then
    echo "🗑  Dropping database '$DATASET'..."
    dropdb --force "$DATASET"
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
"$ROOT/scripts/seed/seed-postgres.sh" "$DATASET"
