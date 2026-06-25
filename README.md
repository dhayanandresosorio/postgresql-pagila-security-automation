# PostgreSQL Pagila Security Automation

PrÃ¡ctica de automatizaciÃ³n, seguridad e integridad en PostgreSQL utilizando la base de datos de ejemplo Pagila.

El proyecto automatiza la preparaciÃ³n de la base de datos, la creaciÃ³n de roles y usuarios, la asignaciÃ³n de permisos, la creaciÃ³n de una vista de consulta, la implementaciÃ³n de un trigger de control sobre alquileres y tareas bÃ¡sicas de mantenimiento mediante scripts Bash y SQL.

> [!NOTE]
> Este repositorio estÃ¡ preparado como laboratorio tÃ©cnico de administraciÃ³n de PostgreSQL. No estÃ¡ pensado como despliegue de producciÃ³n, sino como prÃ¡ctica documentada de automatizaciÃ³n, permisos, integridad y mantenimiento.

## Objetivo

El objetivo de esta prÃ¡ctica es demostrar tareas de administraciÃ³n de PostgreSQL aplicando automatizaciÃ³n, control de permisos, seguridad bÃ¡sica, reglas de integridad y mantenimiento de base de datos.

## QuÃ© demuestra este proyecto

* AutomatizaciÃ³n de tareas de administraciÃ³n en PostgreSQL.
* Carga de una base de datos de ejemplo desde un repositorio externo.
* SeparaciÃ³n de permisos mediante roles y usuarios.
* AplicaciÃ³n de permisos sobre base de datos, esquema, tablas y secuencias.
* CreaciÃ³n de una vista para consultar informaciÃ³n de inventario.
* ImplementaciÃ³n de un trigger para aplicar reglas de integridad.
* EjecuciÃ³n de tareas bÃ¡sicas de mantenimiento con `VACUUM ANALYZE` y `REINDEX`.
* OrganizaciÃ³n de una prÃ¡ctica tÃ©cnica en formato de repositorio profesional.

## TecnologÃ­as utilizadas

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
â”œâ”€â”€ README.md
â”œâ”€â”€ .gitignore
â”œâ”€â”€ .gitattributes
â”œâ”€â”€ scripts/
â”‚   â”œâ”€â”€ setup.sh
â”‚   â”œâ”€â”€ prepare-pagila.sh
â”‚   â””â”€â”€ maintenance.sh
â”œâ”€â”€ sql/
â”‚   â”œâ”€â”€ 01-roles.sql
â”‚   â”œâ”€â”€ 02-permissions.sql
â”‚   â”œâ”€â”€ 03-views.sql
â”‚   â””â”€â”€ 04-triggers.sql
â””â”€â”€ docs/
    â””â”€â”€ memoria.md
```

## Funcionamiento general

El script principal `setup.sh` ejecuta el proceso completo de configuraciÃ³n:

1. Prepara la base de datos Pagila.
2. Crea los roles y usuarios necesarios.
3. Aplica permisos segÃºn el tipo de usuario.
4. Crea una vista de inventario.
5. Crea un trigger para bloquear nuevos alquileres si el cliente tiene alquileres pendientes antiguos o deuda.
6. Genera un log con la salida del proceso.

El script `maintenance.sh` ejecuta tareas bÃ¡sicas de mantenimiento sobre tablas importantes de la base de datos.

## Requisitos previos

El laboratorio estÃ¡ pensado para ejecutarse en una mÃ¡quina Linux con PostgreSQL instalado.

> [!IMPORTANT]
> Los scripts usan `sudo -u postgres`, por lo que deben ejecutarse en una mÃ¡quina donde PostgreSQL estÃ© instalado localmente y el usuario tenga permisos de administraciÃ³n.

Dependencias necesarias:

```
sudo apt update
sudo apt install -y postgresql postgresql-contrib git
```

ComprobaciÃ³n del servicio:

```
sudo systemctl status postgresql
```

## EjecuciÃ³n del proyecto

Dar permisos de ejecuciÃ³n a los scripts:

```
chmod +x scripts/setup.sh
chmod +x scripts/maintenance.sh
chmod +x scripts/prepare-pagila.sh
```

Ejecutar la configuraciÃ³n completa:

```
./scripts/setup.sh
```

Ejecutar el mantenimiento:

```
./scripts/maintenance.sh
```

> [!TIP]
> El script `setup.sh` estÃ¡ pensado para ejecutarse desde la raÃ­z del repositorio, ya que utiliza rutas relativas hacia las carpetas `scripts/` y `sql/`.

## Scripts incluidos

### scripts/setup.sh

Script principal de configuraciÃ³n. Se encarga de ejecutar el proceso completo en orden: preparaciÃ³n de Pagila, creaciÃ³n de roles, asignaciÃ³n de permisos, creaciÃ³n de vista y creaciÃ³n del trigger.

### scripts/prepare-pagila.sh

Clona el repositorio de Pagila, elimina una instalaciÃ³n anterior si existe, crea la base de datos y carga el esquema y los datos.

### scripts/maintenance.sh

Ejecuta tareas de mantenimiento sobre las tablas `rental`, `inventory` y `film`, incluyendo:

```
VACUUM ANALYZE;
REINDEX TABLE;
```

## Scripts SQL

### sql/01-roles.sql

Crea roles de grupo y usuarios de laboratorio para separar permisos segÃºn el perfil.

Incluye:

* Rol de gerencia.
* Rol de atenciÃ³n.
* Usuario de gerencia.
* Usuario de atenciÃ³n.
* AsignaciÃ³n de usuarios a sus grupos correspondientes.

### sql/02-permissions.sql

Revoca permisos generales y aplica permisos especÃ­ficos sobre la base de datos, el esquema, las tablas y las secuencias.

La idea principal es aplicar permisos mÃ­nimos segÃºn el rol de cada usuario.

### sql/03-views.sql

Crea la vista `vista_inventario`, que permite consultar la disponibilidad de pelÃ­culas por tienda.

Esta vista simplifica la consulta de inventario y evita tener que consultar directamente varias tablas.

### sql/04-triggers.sql

Crea una funciÃ³n y un trigger que impide insertar nuevos alquileres si el cliente tiene alquileres pendientes de mÃ¡s de 30 dÃ­as o deuda pendiente.

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
* Logs generados correctamente durante la ejecuciÃ³n.

Ejemplo de comprobaciÃ³n de la vista:

```
sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"
```

Ejemplo de comprobaciÃ³n de roles:

```
sudo -u postgres psql -d pagila -c "\du"
```

Ejemplo de comprobaciÃ³n de tablas:

```
sudo -u postgres psql -d pagila -c "\dt"
```

## Logs

Los scripts generan logs dentro de la carpeta `logs/`.

Esta carpeta no se sube al repositorio porque contiene archivos generados durante la ejecuciÃ³n local.

Archivos generados:

```
logs/setup.log
logs/maintenance.log
```

## Nota de seguridad

> [!WARNING]
> Las contraseÃ±as incluidas en los scripts SQL son valores placeholder para laboratorio. En un entorno real no se deberÃ­an guardar contraseÃ±as directamente en archivos versionados.

En producciÃ³n, lo correcto serÃ­a utilizar variables de entorno, un gestor de secretos o un sistema de configuraciÃ³n externo.

## Archivos ignorados

El repositorio ignora archivos generados o temporales como:

```
logs/
*.log
pagila/
.env
.vscode/
```

La carpeta `pagila/` se genera automÃ¡ticamente al ejecutar el script de preparaciÃ³n y no forma parte del repositorio.

## DocumentaciÃ³n completa

La explicaciÃ³n detallada del proceso, comandos utilizados, comprobaciones y pruebas realizadas se encuentra en:

```
docs/memoria.md
```

## Resultado

La prÃ¡ctica queda organizada como laboratorio de administraciÃ³n de PostgreSQL, aplicando automatizaciÃ³n, seguridad bÃ¡sica mediante roles y permisos, vistas, triggers de integridad y tareas de mantenimiento.
