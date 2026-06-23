# PostgreSQL Pagila Security Automation

Práctica de automatización, seguridad e integridad en PostgreSQL utilizando la base de datos de ejemplo Pagila.

El proyecto automatiza la preparación de la base de datos, la creación de roles y usuarios, la asignación de permisos, la creación de una vista de consulta y la implementación de un trigger de control sobre alquileres. También incluye un script de mantenimiento para ejecutar tareas básicas de optimización sobre tablas principales.

## Objetivo

El objetivo de esta práctica es demostrar tareas de administración de PostgreSQL aplicando automatización, control de permisos, seguridad básica, reglas de integridad y mantenimiento de base de datos.

## Tecnologías utilizadas

- Ubuntu Server 24.04
- PostgreSQL
- Pagila
- Bash scripting
- SQL
- PL/pgSQL
- Git y GitHub

## Estructura del repositorio

    postgresql-pagila-security-automation/
    ├── README.md
    ├── .gitignore
    ├── scripts/
    │   ├── setup.sh
    │   ├── prepare-pagila.sh
    │   └── maintenance.sh
    ├── sql/
    │   ├── 01-roles.sql
    │   ├── 02-permissions.sql
    │   ├── 03-views.sql
    │   └── 04-triggers.sql
    └── docs/
        └── memoria.md

## Funcionamiento general

El script principal `setup.sh` ejecuta el proceso completo de configuración:

1. Prepara la base de datos Pagila.
2. Crea los roles y usuarios necesarios.
3. Aplica permisos según el tipo de usuario.
4. Crea una vista de inventario.
5. Crea un trigger para bloquear nuevos alquileres si el cliente tiene alquileres pendientes antiguos o deuda.

El script `maintenance.sh` ejecuta tareas básicas de mantenimiento sobre tablas importantes de la base de datos.

## Instalación de dependencias

    sudo apt update
    sudo apt install -y postgresql postgresql-contrib git

Comprobación del servicio:

    sudo systemctl status postgresql

## Ejecución del proyecto

Dar permisos de ejecución:

    chmod +x scripts/setup.sh
    chmod +x scripts/maintenance.sh
    chmod +x scripts/prepare-pagila.sh

Ejecutar la configuración completa:

    ./scripts/setup.sh

Ejecutar el mantenimiento:

    ./scripts/maintenance.sh

## Scripts incluidos

### scripts/setup.sh

Script principal de configuración. Prepara la base de datos y ejecuta todos los scripts SQL en orden.

### scripts/prepare-pagila.sh

Clona el repositorio de Pagila, elimina una instalación anterior si existe, crea la base de datos y carga el esquema y los datos.

### scripts/maintenance.sh

Ejecuta tareas de mantenimiento sobre las tablas `rental`, `inventory` y `film`, incluyendo:

    VACUUM ANALYZE;
    REINDEX TABLE;

## Scripts SQL

### sql/01-roles.sql

Crea roles de grupo y usuarios de prueba para separar permisos según el perfil.

### sql/02-permissions.sql

Revoca permisos generales y aplica permisos específicos sobre la base de datos, el esquema, las tablas y las secuencias.

### sql/03-views.sql

Crea la vista `vista_inventario`, que permite consultar la disponibilidad de películas por tienda.

### sql/04-triggers.sql

Crea una función y un trigger que impide insertar nuevos alquileres si el cliente tiene alquileres pendientes de más de 30 días o deuda pendiente.

## Comprobaciones realizadas

Se comprobaron los siguientes puntos:

- Servicio PostgreSQL activo.
- Base de datos `pagila` creada correctamente.
- Tablas cargadas desde el esquema de Pagila.
- Roles y usuarios creados.
- Permisos aplicados correctamente.
- Vista `vista_inventario` funcionando.
- Trigger bloqueando alquileres no permitidos.
- Script de mantenimiento ejecutando `VACUUM ANALYZE` y `REINDEX`.

Ejemplo de comprobación de la vista:

    sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"

Ejemplo de comprobación de roles:

    sudo -u postgres psql -d pagila -c "\du"

## Logs

Los scripts generan logs dentro de la carpeta `logs/`.

Esta carpeta no se sube al repositorio porque contiene archivos generados durante la ejecución local.

## Documentación completa

La explicación detallada del proceso, comandos utilizados, comprobaciones y errores encontrados se encuentra en:

    docs/memoria.md

## Resultado

La práctica queda organizada como laboratorio de administración de PostgreSQL, aplicando automatización, seguridad básica mediante roles y permisos, vistas, triggers de integridad y tareas de mantenimiento.
