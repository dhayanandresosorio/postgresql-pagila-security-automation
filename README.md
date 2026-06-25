# PostgreSQL Pagila Security Automation

Laboratorio tecnico de automatizacion, seguridad e integridad en PostgreSQL utilizando la base de datos de ejemplo Pagila.

El proyecto prepara la base de datos, crea roles y usuarios, aplica permisos, genera una vista de inventario, configura un trigger de control y ejecuta tareas basicas de mantenimiento mediante Bash y SQL.

> [!NOTE]
> Este repositorio esta planteado como practica tecnica de administracion de PostgreSQL. No esta pensado como despliegue de produccion.

## Objetivo

Demostrar tareas de administracion de PostgreSQL aplicando automatizacion, control de permisos, seguridad basica, reglas de integridad y mantenimiento de base de datos.

## Que demuestra este proyecto

- Automatizacion de tareas de administracion en PostgreSQL.
- Carga de una base de datos de ejemplo.
- Separacion de permisos mediante roles y usuarios.
- Aplicacion de permisos sobre base de datos, esquema, tablas y secuencias.
- Creacion de una vista de inventario.
- Implementacion de un trigger de integridad.
- Ejecucion de mantenimiento con VACUUM ANALYZE y REINDEX.
- Organizacion de una practica tecnica en formato de repositorio profesional.

## Tecnologias utilizadas

- Ubuntu Server 24.04
- PostgreSQL
- Pagila
- Bash scripting
- SQL
- PL/pgSQL
- Git y GitHub

## Estructura del repositorio

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

## Funcionamiento general

El script principal es:

    ./scripts/setup.sh

Este script ejecuta el proceso completo:

1. Prepara la base de datos Pagila.
2. Crea roles y usuarios.
3. Aplica permisos.
4. Crea una vista de inventario.
5. Crea un trigger de integridad.
6. Genera un log de ejecucion.

El script maintenance.sh ejecuta tareas basicas de mantenimiento sobre tablas principales.

## Requisitos previos

Instalar dependencias:

    sudo apt update
    sudo apt install -y postgresql postgresql-contrib git

Comprobar PostgreSQL:

    sudo systemctl status postgresql

> [!IMPORTANT]
> Los scripts usan sudo -u postgres, por lo que deben ejecutarse en una maquina donde PostgreSQL este instalado localmente y el usuario tenga permisos de administracion.

## Ejecucion

Dar permisos de ejecucion:

    chmod +x scripts/setup.sh
    chmod +x scripts/prepare-pagila.sh
    chmod +x scripts/maintenance.sh

Ejecutar la configuracion completa:

    ./scripts/setup.sh

Ejecutar mantenimiento:

    ./scripts/maintenance.sh

> [!TIP]
> Ejecuta los scripts desde la raiz del repositorio, porque usan rutas relativas hacia scripts/ y sql/.

## Scripts incluidos

### scripts/setup.sh

Script principal. Ejecuta la preparacion de Pagila y despues aplica los scripts SQL en orden.

### scripts/prepare-pagila.sh

Clona Pagila, elimina una instalacion anterior si existe, crea la base de datos y carga esquema y datos.

### scripts/maintenance.sh

Ejecuta VACUUM ANALYZE y REINDEX sobre tablas importantes.

## Scripts SQL

### sql/01-roles.sql

Crea roles de grupo y usuarios de laboratorio.

### sql/02-permissions.sql

Revoca permisos generales y aplica permisos especificos por rol.

### sql/03-views.sql

Crea la vista vista_inventario para consultar disponibilidad de peliculas por tienda.

### sql/04-triggers.sql

Crea una funcion y un trigger que bloquea alquileres si el cliente tiene deuda o alquileres antiguos pendientes.

## Logs

Los logs se generan dentro de la carpeta logs/, que no se sube al repositorio.

## Documentacion completa

La memoria tecnica se encuentra en:

    docs/memoria.md

## Nota de seguridad

> [!WARNING]
> Las contrasenas incluidas en los SQL son placeholders de laboratorio. En produccion se deberian usar variables de entorno o un gestor de secretos.
