#!/usr/bin/env bash
# ============================================================
# seed-mongo.sh — load a dataset's collections and data.
# Usage: ./scripts/seed/seed-mongo.sh <ecommerce|social|saas|jobs|all>
# ============================================================
set -euo pipefail

DATASETS=(ecommerce social saas jobs)
DATASET="${1:-}"
URI_ROOT="mongodb://127.0.0.1:27017"

if [[ -z "$DATASET" ]]; then
    echo "Usage: ./scripts/seed/seed-mongo.sh <${DATASETS[*]}|all>"
    exit 1
fi
if [[ "$DATASET" != "all" && ! " ${DATASETS[*]} " =~ " ${DATASET} " ]]; then
    echo "❌ Unknown dataset '$DATASET'. Choose one of: ${DATASETS[*]} (or 'all')"
    exit 1
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if ! command -v mongosh &>/dev/null; then
    echo "❌ mongosh not found. Install it: https://www.mongodb.com/docs/mongodb-shell/install/"
    exit 1
fi

# Preflight: fail with an actionable message if the server is down,
# instead of dumping a raw connection error from mongosh.
if ! mongosh --quiet "$URI_ROOT/?serverSelectionTimeoutMS=3000" \
        --eval 'db.runCommand({ ping: 1 }).ok' >/dev/null 2>&1; then
    echo "❌ Cannot reach MongoDB on localhost:27017."
    echo "   Start it:  brew services start mongodb-community@8.0"
    echo "   Check:     brew services list | grep mongodb"
    echo "   Log:       tail -f \$(brew --prefix)/var/log/mongodb/mongo.log"
    exit 1
fi

seed_one() {
    local ds="$1"
    local file="$ROOT/shared/datasets/$ds.mongo.js"

    if [[ ! -f "$file" ]]; then
        echo "❌ Dataset file not found: $file"
        exit 1
    fi

    echo "🌱 Seeding MongoDB database '$ds' from $file ..."
    mongosh --quiet --file "$file"

    # Verify the seed actually landed: an empty database means failure,
    # and the sentinel prefix makes the parse immune to shell banners.
    local verify count collections
    verify="$(mongosh --quiet "$URI_ROOT/$ds" \
        --eval 'print("SEEDCHECK|" + db.getCollectionNames().length + "|" + db.getCollectionNames().join(", "))')"
    verify="${verify##*SEEDCHECK|}"
    count="${verify%%|*}"
    collections="${verify#*|}"

    if [[ -z "$count" || "$count" -eq 0 ]]; then
        echo "❌ Seeding '$ds' produced no collections — something went wrong."
        exit 1
    fi
    echo "   ✓ $count collections: $collections"
}

if [[ "$DATASET" == "all" ]]; then
    for ds in "${DATASETS[@]}"; do
        seed_one "$ds"
    done
    echo "✅ Done. Connect with:  mongosh ecommerce   (or social | saas | jobs)"
else
    seed_one "$DATASET"
    echo "✅ Done. Connect with:  mongosh $DATASET"
fi
