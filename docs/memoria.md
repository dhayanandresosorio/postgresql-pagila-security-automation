# Memoria tecnica - PostgreSQL Pagila Security Automation

## 1. Resumen

Este proyecto consiste en automatizar tareas basicas de administracion, seguridad e integridad en PostgreSQL usando la base de datos de ejemplo Pagila.

El repositorio incluye scripts Bash y SQL para preparar la base de datos, crear roles y usuarios, aplicar permisos, crear una vista de inventario, configurar un trigger de control y ejecutar tareas basicas de mantenimiento.

La idea principal es tener un laboratorio reproducible, ordenado y facil de entender, con una estructura parecida a la de un repositorio profesional.

## 2. Entorno utilizado

La practica esta pensada para ejecutarse en una maquina Linux con PostgreSQL instalado localmente.

Entorno previsto:

* Ubuntu Server 24.04
* PostgreSQL
* Base de datos Pagila
* Bash
* SQL
* PL/pgSQL
* Git y GitHub

Los scripts usan el usuario postgres mediante sudo, por lo que el usuario que ejecute la practica debe tener permisos de administracion.

## 3. Estructura del repositorio

```
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
```

La estructura separa la documentacion, los scripts Bash y los scripts SQL.

## 4. Instalacion de dependencias

Antes de ejecutar la practica, se deben instalar PostgreSQL y Git:

```
sudo apt update
sudo apt install -y postgresql postgresql-contrib git
```

Despues se comprueba que el servicio de PostgreSQL este activo:

```
sudo systemctl status postgresql
```

## 5. Funcionamiento general

El script principal del proyecto es:

```
./scripts/setup.sh
```

Este script ejecuta el proceso completo de configuracion.

Tareas que realiza:

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

```
scripts/prepare-pagila.sh
```

Este script se encarga de preparar la base de datos desde cero.

Tareas principales:

* Clonar el repositorio de Pagila.
* Eliminar la carpeta local pagila si ya existia.
* Eliminar la base de datos pagila si ya estaba creada.
* Crear una nueva base de datos pagila.
* Cargar el esquema de Pagila.
* Cargar los datos de Pagila.

Este enfoque permite repetir la practica varias veces sin tener que limpiar la base de datos manualmente.

## 7. Script principal de configuracion

Archivo:

```
scripts/setup.sh
```

Este script actua como orquestador de toda la practica.

Ejecuta los archivos en este orden:

```
scripts/prepare-pagila.sh
sql/01-roles.sql
sql/02-permissions.sql
sql/03-views.sql
sql/04-triggers.sql
```

Tambien guarda la salida de ejecucion en:

```
logs/setup.log
```

El script utiliza:

```
set -euo pipefail
```

Esto hace que el script se detenga si aparece un error, si se usa una variable no definida o si falla una parte importante del proceso.

## 8. Roles y usuarios

Archivo:

```
sql/01-roles.sql
```

Este script crea roles de grupo y usuarios de laboratorio.

Roles creados:

* grup_gerencia
* grup_atencio

Usuarios creados:

* daxxmanager
* daxxstaff

Los usuarios se asignan a sus grupos correspondientes.

Las contrasenas incluidas en el proyecto son placeholders:

```
CHANGE_ME_MANAGER_PASSWORD
CHANGE_ME_STAFF_PASSWORD
```

No son contrasenas reales y no deben usarse en produccion.

## 9. Permisos

Archivo:

```
sql/02-permissions.sql
```

Este script aplica permisos segun el perfil de cada rol.

Acciones principales:

* Revocar permisos generales a public.
* Permitir conexion a la base de datos.
* Permitir uso del esquema public.
* Dar permisos de consulta y modificacion a gerencia.
* Dar permisos mas limitados al grupo de atencion.
* Conceder permisos sobre secuencias necesarias para inserciones.

La idea es aplicar el principio de minimos privilegios.

## 10. Vista de inventario

Archivo:

```
sql/03-views.sql
```

Este script crea la vista:

```
vista_inventario
```

La vista permite consultar informacion de peliculas e inventario por tienda.

Informacion que muestra:

* Titulo de la pelicula.
* Tienda.
* Cantidad total.
* Cantidad disponible.

Comprobacion de ejemplo:

```
sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"
```

Esta vista simplifica la consulta de inventario y evita tener que consultar directamente varias tablas.

## 11. Trigger de integridad

Archivo:

```
sql/04-triggers.sql
```

Este script crea una funcion y un trigger para controlar nuevos alquileres.

El trigger impide insertar un nuevo alquiler si el cliente cumple alguna de estas condiciones:

* Tiene alquileres pendientes de mas de 30 dias.
* Tiene deuda pendiente.

Esto permite aplicar una regla de negocio directamente dentro de PostgreSQL.

Tambien se corrige la funcion get_customer_balance incluida en Pagila, ya que la version original utiliza una sintaxis tipo MySQL, mientras que PostgreSQL requiere otra forma de expresarlo.

## 12. Script de mantenimiento

Archivo:

```
scripts/maintenance.sh
```

Este script ejecuta tareas basicas de mantenimiento sobre tablas importantes de la base de datos.

Tablas usadas:

* rental
* inventory
* film

Operaciones utilizadas:

```
VACUUM ANALYZE;
REINDEX TABLE;
```

La salida se guarda en:

```
logs/maintenance.log
```

El script recorre las tablas mediante un array para evitar repetir codigo innecesario.

## 13. Comprobaciones realizadas

Durante la practica se comprobaron los siguientes puntos:

* PostgreSQL instalado y activo.
* Base de datos pagila creada correctamente.
* Esquema y datos cargados.
* Tablas disponibles.
* Roles y usuarios creados.
* Permisos aplicados.
* Vista vista_inventario funcionando.
* Trigger creado correctamente.
* Script de mantenimiento ejecutado.
* Logs generados en la carpeta logs.

Comprobacion de bases de datos:

```
sudo -u postgres psql -c "\l"
```

Comprobacion de tablas:

```
sudo -u postgres psql -d pagila -c "\dt"
```

Comprobacion de roles:

```
sudo -u postgres psql -d pagila -c "\du"
```

Comprobacion de la vista:

```
sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"
```

## 14. Logs

Los scripts generan logs dentro de la carpeta:

```
logs/
```

Archivos generados:

```
logs/setup.log
logs/maintenance.log
```

Estos archivos no se suben al repositorio porque son generados durante la ejecucion local.

La carpeta logs esta ignorada mediante .gitignore.

## 15. Archivos ignorados

El repositorio ignora archivos temporales o generados automaticamente:

```
logs/
*.log
pagila/
.env
.vscode/
```

La carpeta pagila no forma parte del repositorio porque se descarga automaticamente al ejecutar el script de preparacion.

## 16. Seguridad

Las contrasenas del laboratorio son valores placeholder.

En un entorno real no se deberian guardar contrasenas directamente dentro de scripts SQL versionados.

Lo correcto en produccion seria usar:

* Variables de entorno.
* Ficheros de configuracion no versionados.
* Un gestor de secretos.
* Politicas de rotacion de credenciales.

## 17. Resultado final

El resultado final es un laboratorio reproducible de PostgreSQL que demuestra:

* Automatizacion con Bash.
* Administracion basica de PostgreSQL.
* Carga de una base de datos de ejemplo.
* Gestion de roles y permisos.
* Creacion de vistas.
* Uso de triggers para reglas de integridad.
* Mantenimiento basico de tablas.
