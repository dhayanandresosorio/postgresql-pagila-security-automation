#!/bin/bash

set -euo pipefail

LOG_DIR="logs"
LOG="$LOG_DIR/setup.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG") 2>&1

echo "==============================="
echo "INICIO DE CONFIGURACION PAGILA"
echo "==============================="

echo "Paso 1: preparar base de datos"
bash scripts/prepare-pagila.sh

echo "Paso 2: crear roles y usuarios"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/01-roles.sql

echo "Paso 3: aplicar permisos"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/02-permissions.sql

echo "Paso 4: crear vista de inventario"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/03-views.sql

echo "Paso 5: crear trigger de integridad"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/04-triggers.sql

echo "=================================="
echo "CONFIGURACION TERMINADA CORRECTAMENTE"
echo "=================================="
