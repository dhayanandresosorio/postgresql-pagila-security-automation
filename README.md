# PostgreSQL Pagila Security Automation

Práctica de automatización, seguridad e integridad en PostgreSQL utilizando la base de datos de ejemplo Pagila.

El proyecto automatiza la preparación de la base de datos, la creación de roles y usuarios, la asignación de permisos, la creación de una vista de consulta, la implementación de un trigger de control sobre alquileres y tareas básicas de mantenimiento mediante scripts Bash y SQL.

> [!NOTE]
> Este repositorio está preparado como laboratorio técnico de administración de PostgreSQL. No está pensado como despliegue de producción, sino como práctica documentada de automatización, permisos, integridad y mantenimiento.

## Objetivo

El objetivo de esta práctica es demostrar tareas de administración de PostgreSQL aplicando automatización, control de permisos, seguridad básica, reglas de integridad y mantenimiento de base de datos.

## Qué demuestra este proyecto

* Automatización de tareas de administración en PostgreSQL.
* Carga de una base de datos de ejemplo desde un repositorio externo.
* Separación de permisos mediante roles y usuarios.
* Aplicación de permisos sobre base de datos, esquema, tablas y secuencias.
* Creación de una vista para consultar información de inventario.
* Implementación de un trigger para aplicar reglas de integridad.
* Ejecución de tareas básicas de mantenimiento con `VACUUM ANALYZE` y `REINDEX`.
* Organización de una práctica técnica en formato de repositorio profesional.

## Tecnologías utilizadas

* Ubuntu Server 24.04
* PostgreSQL
* Pagila
* Bash scripting
* SQL
* PL/pgSQL
* Git y GitHub

## Estructura del repositorio

```
postgresql-pagila-security-automation/
├── README.md
├── .gitignore
├── .gitattributes
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
```

## Funcionamiento general

El script principal `setup.sh` ejecuta el proceso completo de configuración:

1. Prepara la base de datos Pagila.
2. Crea los roles y usuarios necesarios.
3. Aplica permisos según el tipo de usuario.
4. Crea una vista de inventario.
5. Crea un trigger para bloquear nuevos alquileres si el cliente tiene alquileres pendientes antiguos o deuda.
6. Genera un log con la salida del proceso.

El script `maintenance.sh` ejecuta tareas básicas de mantenimiento sobre tablas importantes de la base de datos.

## Requisitos previos

El laboratorio está pensado para ejecutarse en una máquina Linux con PostgreSQL instalado.

> [!IMPORTANT]
> Los scripts usan `sudo -u postgres`, por lo que deben ejecutarse en una máquina donde PostgreSQL esté instalado localmente y el usuario tenga permisos de administración.

Dependencias necesarias:

```
sudo apt update
sudo apt install -y postgresql postgresql-contrib git
```

Comprobación del servicio:

```
sudo systemctl status postgresql
```

## Ejecución del proyecto

Dar permisos de ejecución a los scripts:

```
chmod +x scripts/setup.sh
chmod +x scripts/maintenance.sh
chmod +x scripts/prepare-pagila.sh
```

Ejecutar la configuración completa:

```
./scripts/setup.sh
```

Ejecutar el mantenimiento:

```
./scripts/maintenance.sh
```

> [!TIP]
> El script `setup.sh` está pensado para ejecutarse desde la raíz del repositorio, ya que utiliza rutas relativas hacia las carpetas `scripts/` y `sql/`.

## Scripts incluidos

### scripts/setup.sh

Script principal de configuración. Se encarga de ejecutar el proceso completo en orden: preparación de Pagila, creación de roles, asignación de permisos, creación de vista y creación del trigger.

### scripts/prepare-pagila.sh

Clona el repositorio de Pagila, elimina una instalación anterior si existe, crea la base de datos y carga el esquema y los datos.

### scripts/maintenance.sh

Ejecuta tareas de mantenimiento sobre las tablas `rental`, `inventory` y `film`, incluyendo:

```
VACUUM ANALYZE;
REINDEX TABLE;
```

## Scripts SQL

### sql/01-roles.sql

Crea roles de grupo y usuarios de laboratorio para separar permisos según el perfil.

Incluye:

* Rol de gerencia.
* Rol de atención.
* Usuario de gerencia.
* Usuario de atención.
* Asignación de usuarios a sus grupos correspondientes.

### sql/02-permissions.sql

Revoca permisos generales y aplica permisos específicos sobre la base de datos, el esquema, las tablas y las secuencias.

La idea principal es aplicar permisos mínimos según el rol de cada usuario.

### sql/03-views.sql

Crea la vista `vista_inventario`, que permite consultar la disponibilidad de películas por tienda.

Esta vista simplifica la consulta de inventario y evita tener que consultar directamente varias tablas.

### sql/04-triggers.sql

Crea una función y un trigger que impide insertar nuevos alquileres si el cliente tiene alquileres pendientes de más de 30 días o deuda pendiente.

Este punto demuestra una regla de integridad aplicada directamente en la base de datos.

## Comprobaciones realizadas

Se comprobaron los siguientes puntos:

* Servicio PostgreSQL activo.
* Base de datos `pagila` creada correctamente.
* Tablas cargadas desde el esquema de Pagila.
* Roles y usuarios creados.
* Permisos aplicados correctamente.
* Vista `vista_inventario` funcionando.
* Trigger bloqueando alquileres no permitidos.
* Script de mantenimiento ejecutando `VACUUM ANALYZE` y `REINDEX`.
* Logs generados correctamente durante la ejecución.

Ejemplo de comprobación de la vista:

```
sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"
```

Ejemplo de comprobación de roles:

```
sudo -u postgres psql -d pagila -c "\du"
```

Ejemplo de comprobación de tablas:

```
sudo -u postgres psql -d pagila -c "\dt"
```

## Logs

Los scripts generan logs dentro de la carpeta `logs/`.

Esta carpeta no se sube al repositorio porque contiene archivos generados durante la ejecución local.

Archivos generados:

```
logs/setup.log
logs/maintenance.log
```

## Nota de seguridad

> [!WARNING]
> Las contraseñas incluidas en los scripts SQL son valores placeholder para laboratorio. En un entorno real no se deberían guardar contraseñas directamente en archivos versionados.

En producción, lo correcto sería utilizar variables de entorno, un gestor de secretos o un sistema de configuración externo.

## Archivos ignorados

El repositorio ignora archivos generados o temporales como:

```
logs/
*.log
pagila/
.env
.vscode/
```

La carpeta `pagila/` se genera automáticamente al ejecutar el script de preparación y no forma parte del repositorio.

## Documentación completa

La explicación detallada del proceso, comandos utilizados, comprobaciones y pruebas realizadas se encuentra en:

```
docs/memoria.md
```

## Resultado

La práctica queda organizada como laboratorio de administración de PostgreSQL, aplicando automatización, seguridad básica mediante roles y permisos, vistas, triggers de integridad y tareas de mantenimiento.
