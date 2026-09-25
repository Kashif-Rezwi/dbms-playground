#!/usr/bin/env bash
# ============================================================
# setup-postgres.sh — create the four practice databases.
# Requires: PostgreSQL installed & running (brew services start postgresql@16)
# Usage: ./scripts/setup/setup-postgres.sh
# ============================================================
set -euo pipefail

DATABASES=(ecommerce social saas jobs)

echo "🚀 Setting up PostgreSQL practice databases..."
for db in "${DATABASES[@]}"; do
    if psql -lqt 2>/dev/null | cut -d'|' -f 1 | grep -qw "$db"; then
        echo "   • database '$db' already exists — skipping"
    else
        createdb "$db"
        echo "   ✓ created database '$db'"
    fi
done

echo ""
echo "Next: seed data with:"
echo "  ./scripts/seed/seed-postgres.sh ecommerce"
echo "  ./scripts/reset/reset-postgres.sh <dataset>   # drop + reseed anytime"
