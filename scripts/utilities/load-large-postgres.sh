#!/usr/bin/env bash
# ============================================================
# load-large-postgres.sh — create the perf_lab database and load
# ~500k rows for the performance / indexing / EXPLAIN lessons.
# Usage: ./scripts/utilities/load-large-postgres.sh
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DB="perf_lab"

if psql -lqt 2>/dev/null | cut -d'|' -f 1 | grep -qw "$DB"; then
    echo "🗑  Recreating database '$DB'..."
    dropdb --force "$DB"
fi
createdb "$DB"

echo "🚀 Generating ~500k rows (this takes ~10-30 seconds)..."
psql -d "$DB" -v ON_ERROR_STOP=1 -q -f "$ROOT/scripts/utilities/generate-large-postgres.sql"

echo "✅ perf_lab ready. Connect with:  psql -d perf_lab"
echo "   Row counts:"
psql -d "$DB" -t -c "SELECT 'big_users: '        || count(*) FROM big_users
                   UNION ALL SELECT 'big_products: '     || count(*) FROM big_products
                   UNION ALL SELECT 'big_orders: '       || count(*) FROM big_orders
                   UNION ALL SELECT 'big_order_items: '  || count(*) FROM big_order_items;"
