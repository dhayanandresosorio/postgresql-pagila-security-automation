#!/bin/bash

set -euo pipefail

PAGILA_REPO="https://github.com/devrimgunduz/pagila.git"
DB_NAME="pagila"

echo "Clonando repositorio de Pagila"

if [ -d "pagila" ]; then
    echo "El directorio pagila ya existe, eliminandolo"
    rm -rf pagila
fi

git clone "$PAGILA_REPO" pagila

echo "Eliminando base de datos anterior si existe"
sudo -u postgres dropdb --if-exists "$DB_NAME"

echo "Creando base de datos $DB_NAME"
sudo -u postgres createdb "$DB_NAME"

echo "Cargando esquema"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f pagila/pagila-schema.sql

echo "Cargando datos"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f pagila/pagila-insert-data.sql

echo "Pagila preparada correctamente"
