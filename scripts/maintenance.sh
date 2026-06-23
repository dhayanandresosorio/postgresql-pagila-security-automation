#!/bin/bash

LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/maintenance.log"

# Guardar todo en pantalla y en el log
exec > >(tee -a "$LOG") 2>&1

echo "========================="
echo "INICIO DEL MANTENIMIENTO"
echo "========================="

# Ejecutamos VACUUM ANALYZE en las tablas clave
echo "Haciendo VACUUM ANALYZE en rental..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "VACUUM ANALYZE rental;"

if [ $? -ne 0 ]; then
    echo "Error haciendo VACUUM ANALYZE en rental"
    exit 1
fi

echo "Haciendo VACUUM ANALYZE en inventory..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "VACUUM ANALYZE inventory;"

if [ $? -ne 0 ]; then
    echo "Error haciendo VACUUM ANALYZE en inventory"
    exit 1
fi

echo "Haciendo VACUUM ANALYZE en film..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "VACUUM ANALYZE film;"

if [ $? -ne 0 ]; then
    echo "Error haciendo VACUUM ANALYZE en film"
    exit 1
fi

# Ejecutamos REINDEX en las tablas clave
echo "Haciendo REINDEX en rental..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "REINDEX TABLE rental;"

if [ $? -ne 0 ]; then
    echo "Error haciendo REINDEX en rental"
    exit 1
fi

echo "Haciendo REINDEX en inventory..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "REINDEX TABLE inventory;"

if [ $? -ne 0 ]; then
    echo "Error haciendo REINDEX en inventory"
    exit 1
fi

echo "Haciendo REINDEX en film..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "REINDEX TABLE film;"

if [ $? -ne 0 ]; then
    echo "Error haciendo REINDEX en film"
    exit 1
fi

echo "Mantenimiento terminado correctamente"

