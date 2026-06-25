#!/bin/bash

set -euo pipefail

DB_NAME="pagila"
LOG_DIR="logs"
LOG="$LOG_DIR/maintenance.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG") 2>&1

echo "========================="
echo "INICIO DEL MANTENIMIENTO"
echo "========================="

TABLES=("rental" "inventory" "film")

for TABLE in "${TABLES[@]}"; do
    echo "Haciendo VACUUM ANALYZE en $TABLE..."
    sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -c "VACUUM ANALYZE $TABLE;"
done

for TABLE in "${TABLES[@]}"; do
    echo "Haciendo REINDEX en $TABLE..."
    sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -c "REINDEX TABLE $TABLE;"
done

echo "Mantenimiento terminado correctamente"
