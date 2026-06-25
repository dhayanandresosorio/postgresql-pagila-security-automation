# \# Memoria tÃ©cnica - PostgreSQL Pagila Security Automation

#

# \## 1. Resumen de la prÃ¡ctica

#

# Esta prÃ¡ctica consiste en automatizar tareas de administraciÃ³n, seguridad e integridad en PostgreSQL utilizando la base de datos de ejemplo Pagila.

#

# El proyecto incluye scripts Bash y SQL para preparar la base de datos, crear roles y usuarios, aplicar permisos, generar una vista de consulta, crear un trigger de control y ejecutar tareas bÃ¡sicas de mantenimiento.

#

# El objetivo principal es dejar un laboratorio reproducible, ordenado y documentado, con una estructura mÃ¡s cercana a un repositorio profesional que a una entrega de clase.

#

# \---

#

# \## 2. Entorno utilizado

#

# La prÃ¡ctica estÃ¡ pensada para ejecutarse en una mÃ¡quina Linux con PostgreSQL instalado localmente.

#

# Entorno previsto:

#

# \* Sistema operativo: Ubuntu Server 24.04

# \* Base de datos: PostgreSQL

# \* Base de datos de ejemplo: Pagila

# \* Lenguajes utilizados: Bash, SQL y PL/pgSQL

# \* Herramientas: Git, GitHub y terminal Linux

#

# Los scripts utilizan el usuario `postgres` mediante `sudo -u postgres`, por lo que es necesario ejecutar la prÃ¡ctica en un entorno donde el usuario tenga permisos de administraciÃ³n.

#

# \---

#

# \## 3. Estructura del repositorio

#

# ```text

# postgresql-pagila-security-automation/

# â”œâ”€â”€ README.md

# â”œâ”€â”€ .gitignore

# â”œâ”€â”€ .gitattributes

# â”œâ”€â”€ scripts/

# â”‚   â”œâ”€â”€ setup.sh

# â”‚   â”œâ”€â”€ prepare-pagila.sh

# â”‚   â””â”€â”€ maintenance.sh

# â”œâ”€â”€ sql/

# â”‚   â”œâ”€â”€ 01-roles.sql

# â”‚   â”œâ”€â”€ 02-permissions.sql

# â”‚   â”œâ”€â”€ 03-views.sql

# â”‚   â””â”€â”€ 04-triggers.sql

# â””â”€â”€ docs/

# &#x20;   â””â”€â”€ memoria.md

# ```

#

# La estructura separa claramente la documentaciÃ³n, los scripts Bash y los scripts SQL.

#

# \---

#

# \## 4. InstalaciÃ³n de dependencias

#

# Antes de ejecutar la prÃ¡ctica se instalan PostgreSQL, herramientas adicionales y Git:

#

# ```bash

# sudo apt update

# sudo apt install -y postgresql postgresql-contrib git

# ```

#

# DespuÃ©s se comprueba el estado del servicio:

#

# ```bash

# sudo systemctl status postgresql

# ```

#

# El servicio debe estar activo antes de continuar.

#

# \---

#

# \## 5. Funcionamiento general

#

# El proceso principal se ejecuta mediante el script:

#

# ```bash

# ./scripts/setup.sh

# ```

#

# Este script realiza las siguientes tareas:

#

# 1\. Ejecuta `scripts/prepare-pagila.sh`.

# 2\. Clona el repositorio de Pagila.

# 3\. Elimina una base de datos anterior si ya existÃ­a.

# 4\. Crea de nuevo la base de datos `pagila`.

# 5\. Carga el esquema y los datos.

# 6\. Ejecuta los scripts SQL en orden.

# 7\. Genera un log en `logs/setup.log`.

#

# El orden de ejecuciÃ³n es importante porque primero debe existir la base de datos y despuÃ©s se aplican roles, permisos, vistas y triggers.

#

# \---

#

# \## 6. Script de preparaciÃ³n de Pagila

#

# Archivo:

#

# ```text

# scripts/prepare-pagila.sh

# ```

#

# Este script se encarga de preparar la base de datos desde cero.

#

# Tareas principales:

#

# \* Clonar el repositorio de Pagila.

# \* Borrar la carpeta local `pagila/` si ya existe.

# \* Eliminar la base de datos `pagila` si ya estaba creada.

# \* Crear una nueva base de datos `pagila`.

# \* Cargar el esquema.

# \* Cargar los datos.

#

# Este enfoque permite repetir la prÃ¡ctica de forma limpia sin tener que borrar todo manualmente.

#

# \---

#

# \## 7. Script principal de configuraciÃ³n

#

# Archivo:

#

# ```text

# scripts/setup.sh

# ```

#

# Este script actÃºa como orquestador de toda la prÃ¡ctica.

#

# Ejecuta en orden:

#

# ```text

# scripts/prepare-pagila.sh

# sql/01-roles.sql

# sql/02-permissions.sql

# sql/03-views.sql

# sql/04-triggers.sql

# ```

#

# AdemÃ¡s, guarda la salida de ejecuciÃ³n en:

#

# ```text

# logs/setup.log

# ```

#

# El script utiliza:

#

# ```bash

# set -euo pipefail

# ```

#

# Esto hace que la ejecuciÃ³n se detenga si aparece un error, si se utiliza una variable no definida o si falla una parte importante del proceso.

#

# \---

#

# \## 8. Roles y usuarios

#

# Archivo:

#

# ```text

# sql/01-roles.sql

# ```

#

# Este script crea dos roles de grupo:

#

# \* `grup\_gerencia`

# \* `grup\_atencio`

#

# Y dos usuarios de laboratorio:

#

# \* `daxxmanager`

# \* `daxxstaff`

#

# Los usuarios se asignan a sus grupos correspondientes.

#

# Las contraseÃ±as incluidas son valores placeholder, no contraseÃ±as reales:

#

# ```sql

# CREATE USER daxxmanager WITH PASSWORD 'CHANGE\_ME\_MANAGER\_PASSWORD';

# CREATE USER daxxstaff WITH PASSWORD 'CHANGE\_ME\_STAFF\_PASSWORD';

# ```

#

# \---

#

# \## 9. Permisos

#

# Archivo:

#

# ```text

# sql/02-permissions.sql

# ```

#

# Este script aplica permisos segÃºn el perfil de usuario.

#

# La idea principal es evitar permisos generales innecesarios y aplicar permisos mÃ­nimos segÃºn el rol.

#

# Acciones principales:

#

# \* Revocar permisos generales a `public`.

# \* Permitir conexiÃ³n a la base de datos.

# \* Permitir uso del esquema `public`.

# \* Dar permisos de consulta y modificaciÃ³n a gerencia.

# \* Dar permisos mÃ¡s limitados al grupo de atenciÃ³n.

# \* Conceder uso de secuencias necesarias para inserciones.

#

# Esto permite separar responsabilidades dentro de la base de datos.

#

# \---

#

# \## 10. Vista de inventario

#

# Archivo:

#

# ```text

# sql/03-views.sql

# ```

#

# Este script crea la vista:

#

# ```text

# vista\_inventario

# ```

#

# La vista muestra informaciÃ³n Ãºtil sobre pelÃ­culas e inventario por tienda:

#

# \* TÃ­tulo de la pelÃ­cula.

# \* Tienda.

# \* Cantidad total.

# \* Cantidad disponible.

#

# La vista simplifica consultas que, de otra forma, requerirÃ­an acceder directamente a varias tablas.

#

# ComprobaciÃ³n:

#

# ```bash

# sudo -u postgres psql -d pagila -c "SELECT \* FROM vista\_inventario LIMIT 10;"

# ```

#

# \---

#

# \## 11. Trigger de integridad

#

# Archivo:

#

# ```text

# sql/04-triggers.sql

# ```

#

# Este script crea una funciÃ³n y un trigger para controlar nuevos alquileres.

#

# El trigger impide insertar un nuevo alquiler si el cliente cumple alguna de estas condiciones:

#

# \* Tiene alquileres pendientes de mÃ¡s de 30 dÃ­as.

# \* Tiene deuda pendiente.

#

# Esto permite aplicar una regla de negocio directamente en la base de datos.

#

# TambiÃ©n se corrige la funciÃ³n `get\_customer\_balance` de Pagila, ya que la versiÃ³n original utiliza una sintaxis tipo MySQL (`IF()`), mientras que PostgreSQL requiere `CASE WHEN`.

#

# \---

#

# \## 12. Script de mantenimiento

#

# Archivo:

#

# ```text

# scripts/maintenance.sh

# ```

#

# Este script ejecuta tareas bÃ¡sicas de mantenimiento sobre tablas importantes:

#

# \* `rental`

# \* `inventory`

# \* `film`

#

# Operaciones realizadas:

#

# ```sql

# VACUUM ANALYZE;

# REINDEX TABLE;

# ```

#

# La salida se guarda en:

#

# ```text

# logs/maintenance.log

# ```

#

# El script estÃ¡ preparado para recorrer las tablas mediante un array, evitando repetir bloques de cÃ³digo innecesarios.

#

# \---

#

# \## 13. Comprobaciones realizadas

#

# Durante la prÃ¡ctica se comprobaron los siguientes puntos:

#

# \* PostgreSQL instalado y activo.

# \* Base de datos `pagila` creada correctamente.

# \* Esquema y datos cargados.

# \* Tablas disponibles.

# \* Roles y usuarios creados.

# \* Permisos aplicados.

# \* Vista `vista\_inventario` funcionando.

# \* Trigger bloqueando alquileres no permitidos.

# \* Script de mantenimiento ejecutado correctamente.

# \* Logs generados en la carpeta `logs/`.

#

# ComprobaciÃ³n de bases de datos:

#

# ```bash

# sudo -u postgres psql -c "\\l"

# ```

#

# ComprobaciÃ³n de tablas:

#

# ```bash

# sudo -u postgres psql -d pagila -c "\\dt"

# ```

#

# ComprobaciÃ³n de roles:

#

# ```bash

# sudo -u postgres psql -d pagila -c "\\du"

# ```

#

# ComprobaciÃ³n de la vista:

#

# ```bash

# sudo -u postgres psql -d pagila -c "SELECT \* FROM vista\_inventario LIMIT 10;"

# ```

#

# \---

#

# \## 14. Logs

#

# Los scripts generan logs dentro de la carpeta:

#

# ```text

# logs/

# ```

#

# Archivos generados:

#

# ```text

# logs/setup.log

# logs/maintenance.log

# ```

#

# Estos archivos no se suben al repositorio porque son generados durante la ejecuciÃ³n local.

#

# La carpeta estÃ¡ ignorada mediante `.gitignore`.

#

# \---

#

# \## 15. Archivos ignorados

#

# El repositorio ignora archivos temporales o generados automÃ¡ticamente:

#

# ```text

# logs/

# \*.log

# pagila/

# .env

# .vscode/

# ```

#

# La carpeta `pagila/` no forma parte del repositorio porque se descarga automÃ¡ticamente al ejecutar el script de preparaciÃ³n.

#

# \---

#

# \## 16. Nota de seguridad

#

# Las contraseÃ±as del proyecto son valores de laboratorio.

#

# En un entorno real no se deberÃ­an guardar contraseÃ±as directamente dentro de scripts SQL versionados.

#

# Lo correcto en producciÃ³n serÃ­a usar:

#

# \* Variables de entorno.

# \* Ficheros de configuraciÃ³n no versionados.

# \* Un gestor de secretos.

# \* PolÃ­ticas de rotaciÃ³n de credenciales.

#

# \---

#

# \## 17. Resultado final

#

# El resultado final es un laboratorio reproducible de administraciÃ³n de PostgreSQL que demuestra:

#

# \* AutomatizaciÃ³n con Bash.

# \* AdministraciÃ³n bÃ¡sica de PostgreSQL.

# \* Carga de una base de datos de ejemplo.

# \* GestiÃ³n de roles y permisos.

# \* CreaciÃ³n de vistas.

# \* Uso de triggers para reglas de integridad.

# \* Mantenimiento bÃ¡sico de tablas.
