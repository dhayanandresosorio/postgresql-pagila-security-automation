#!/bin/bash

set -euo pipefail

PAGILA_REPO="https://github.com/devrimgunduz/pagila.git"
DB_NAME="pagila"

echo "Clonando repositorio de Pagila..."

if [ -d "pagila" ]; then
    echo "El directorio 'pagila' ya existe, eliminandolo..."
    rm -rf pagila
fi

git clone "$PAGILA_REPO"

echo "Eliminando base de datos $DB_NAME si existia..."
sudo -u postgres dropdb --if-exists "$DB_NAME"

echo "Creando base de datos $DB_NAME..."
sudo -u postgres createdb "$DB_NAME"

echo "Cargando esquema de Pagila..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f pagila/pagila-schema.sql

echo "Cargando datos de Pagila..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f pagila/pagila-insert-data.sql

echo "Base de datos Pagila preparada correctamente"
