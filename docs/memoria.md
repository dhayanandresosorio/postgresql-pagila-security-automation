# Memoria tecnica - PostgreSQL Pagila Security Automation

## 1. Resumen

Este proyecto consiste en automatizar tareas basicas de administracion, seguridad e integridad en PostgreSQL usando la base de datos de ejemplo Pagila.

El repositorio incluye scripts Bash y SQL para preparar la base de datos, crear roles y usuarios, aplicar permisos, crear una vista de inventario, configurar un trigger de control y ejecutar tareas basicas de mantenimiento.

La idea principal es tener un laboratorio reproducible, ordenado y facil de entender, con una estructura parecida a la de un repositorio profesional.

## 2. Entorno utilizado

La practica esta pensada para ejecutarse en una maquina Linux con PostgreSQL instalado localmente.

Entorno previsto:

- Ubuntu Server 24.04
- PostgreSQL
- Base de datos Pagila
- Bash
- SQL
- PL/pgSQL
- Git y GitHub

Los scripts usan el usuario postgres mediante sudo, por lo que el usuario que ejecute la practica debe tener permisos de administracion.

## 3. Estructura del repositorio

    postgresql-pagila-security-automation/
    |-- README.md
    |-- .gitignore
    |-- .gitattributes
    |-- scripts/
    |   |-- setup.sh
    |   |-- prepare-pagila.sh
    |   |-- maintenance.sh
    |-- sql/
    |   |-- 01-roles.sql
    |   |-- 02-permissions.sql
    |   |-- 03-views.sql
    |   |-- 04-triggers.sql
    |-- docs/
    |   |-- memoria.md

## 4. Instalacion de dependencias

Antes de ejecutar la practica, se deben instalar PostgreSQL y Git:

    sudo apt update
    sudo apt install -y postgresql postgresql-contrib git

Despues se comprueba que el servicio de PostgreSQL este activo:

    sudo systemctl status postgresql

## 5. Funcionamiento general

El script principal del proyecto es:

    ./scripts/setup.sh

Este script ejecuta el proceso completo de configuracion:

1. Ejecuta el script de preparacion de Pagila.
2. Clona el repositorio de Pagila.
3. Elimina una base de datos anterior si ya existia.
4. Crea de nuevo la base de datos pagila.
5. Carga el esquema y los datos.
6. Ejecuta los scripts SQL en orden.
7. Guarda la salida en logs/setup.log.

El orden es importante porque primero debe existir la base de datos y despues se aplican roles, permisos, vistas y triggers.

## 6. Preparacion de Pagila

Archivo:

    scripts/prepare-pagila.sh

Este script prepara la base de datos desde cero.

Tareas principales:

- Clonar el repositorio de Pagila.
- Eliminar la carpeta local pagila si ya existia.
- Eliminar la base de datos pagila si ya estaba creada.
- Crear una nueva base de datos pagila.
- Cargar el esquema de Pagila.
- Cargar los datos de Pagila.

## 7. Roles y usuarios

Archivo:

    sql/01-roles.sql

Este script crea roles de grupo y usuarios de laboratorio.

Roles creados:

- grup_gerencia
- grup_atencio

Usuarios creados:

- daxxmanager
- daxxstaff

Las contrasenas incluidas son placeholders y no deben usarse en produccion.

## 8. Permisos

Archivo:

    sql/02-permissions.sql

Este script revoca permisos generales y aplica permisos concretos segun el perfil de cada rol.

La idea es aplicar el principio de minimos privilegios.

## 9. Vista de inventario

Archivo:

    sql/03-views.sql

Este script crea la vista vista_inventario.

La vista permite consultar informacion de peliculas e inventario por tienda.

Comprobacion de ejemplo:

    sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"

## 10. Trigger de integridad

Archivo:

    sql/04-triggers.sql

Este script crea una funcion y un trigger para controlar nuevos alquileres.

El trigger impide insertar un nuevo alquiler si el cliente tiene alquileres pendientes de mas de 30 dias o deuda pendiente.

## 11. Mantenimiento

Archivo:

    scripts/maintenance.sh

Este script ejecuta tareas basicas de mantenimiento sobre tablas importantes:

- rental
- inventory
- film

Operaciones utilizadas:

    VACUUM ANALYZE;
    REINDEX TABLE;

La salida se guarda en logs/maintenance.log.

## 12. Comprobaciones

Durante la practica se comprobaron estos puntos:

- PostgreSQL instalado y activo.
- Base de datos pagila creada correctamente.
- Esquema y datos cargados.
- Roles y usuarios creados.
- Permisos aplicados.
- Vista vista_inventario funcionando.
- Trigger creado correctamente.
- Script de mantenimiento ejecutado.
- Logs generados correctamente.

Comprobaciones utiles:

    sudo -u postgres psql -c "\l"
    sudo -u postgres psql -d pagila -c "\dt"
    sudo -u postgres psql -d pagila -c "\du"
    sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"

## 13. Seguridad

Las contrasenas del laboratorio son valores placeholder.

En un entorno real se deberian usar variables de entorno, ficheros de configuracion no versionados o un gestor de secretos.

## 14. Resultado final

El resultado final es un laboratorio reproducible de PostgreSQL que demuestra automatizacion, administracion basica, control de permisos, vistas, triggers y mantenimiento de tablas.
