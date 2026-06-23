#!/bin/bash

# Clonamos el repositorio de Pagila
echo "Clonando repositorio de Pagila..."

# Si ya existe la carpeta, la borramos
if [ -d "pagila" ]; then
    echo "El directorio 'pagila' ya existe, eliminándolo..."
    rm -rf pagila  # Eliminamos la carpeta 'pagila' para asegurarnos de tener una copia limpia
fi

# Clonamos el repositorio
git clone https://github.com/devrimgunduz/pagila.git

if [ $? -ne 0 ]; then
    echo "Error al clonar el repositorio"
    exit 1
fi

# Eliminamos la base de datos si ya existe
echo "Eliminando base de datos pagila si existía..."
sudo -u postgres dropdb --if-exists pagila

# Creamos la base de datos
echo "Creando base de datos pagila..."
sudo -u postgres createdb pagila
if [ $? -ne 0 ]; then
    echo "Error al crear la base de datos"
    exit 1
fi

# Cargamos el esquema y los datos
echo "Cargando esquema..."
sudo -u postgres psql -d pagila -f pagila/pagila-schema.sql
if [ $? -ne 0 ]; then
    echo "Error al cargar el esquema"
    exit 1
fi

echo "Cargando datos..."
sudo -u postgres psql -d pagila -f pagila/pagila-insert-data.sql
if [ $? -ne 0 ]; then
    echo "Error al cargar los datos"
    exit 1
fi

echo "Base de datos Pagila preparada correctamente"
