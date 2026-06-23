#!/bin/bash

# Configuration log
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/setup.log"

# Guardar todo en pantalla y en el log
exec > >(tee -a "$LOG") 2>&1

echo "==============================="
echo "INICIO DE CONFIGURACION PAGILA"
echo "==============================="

# Paso 1: Preparar base de datos
echo "Paso 1: preparar base de datos"
bash scripts/prepare-pagila.sh
if [ $? -ne 0 ]; then
    echo "Error en 00-prepara-pagila.sh"
    exit 1
fi

# Paso 2: Crear roles y usuarios
echo "Paso 2: crear roles y usuarios"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/01-roles.sql
if [ $? -ne 0 ]; then
    echo "Error en 01-rols.sql"
    exit 1
fi

# Paso 3: Dar permisos
echo "Paso 3: dar permisos"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/02-permissions.sql
if [ $? -ne 0 ]; then
    echo "Error en 02-permisos.sql"
    exit 1
fi

# Paso 4: Crear vista
echo "Paso 4: crear vista"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/03-views.sql
if [ $? -ne 0 ]; then
    echo "Error en 03-vistes.sql"
    exit 1
fi

# Paso 5: Crear trigger
echo "Paso 5: crear trigger"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/04-triggers.sql
if [ $? -ne 0 ]; then
    echo "Error en 04-triggers.sql"
    exit 1
fi

echo "=================================="
echo "CONFIGURACION TERMINADA CORRECTAMENTE"
echo "=================================="




