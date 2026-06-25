# Memoria técnica - PostgreSQL Pagila Security Automation

## 1. Resumen de la práctica

Esta práctica consiste en automatizar tareas básicas de administración, seguridad e integridad en PostgreSQL utilizando la base de datos de ejemplo Pagila.

El objetivo principal es preparar un entorno de base de datos desde cero, cargar Pagila, crear roles y usuarios, aplicar permisos, generar una vista de consulta, configurar un trigger de control y ejecutar tareas básicas de mantenimiento mediante scripts Bash y SQL.

La práctica se ha reorganizado en formato de repositorio profesional para que sea más clara, reutilizable y fácil de revisar desde GitHub.

---

## 2. Entorno utilizado

La práctica se ha realizado sobre una máquina virtual Ubuntu Server.

Entorno de trabajo:

* Sistema operativo: Ubuntu Server 24.04
* Base de datos: PostgreSQL
* Base de datos de ejemplo: Pagila
* Lenguajes utilizados: Bash, SQL y PL/pgSQL
* Herramientas: Git, GitHub y terminal Linux
* Máquina utilizada: `asgbdpagila`
* Usuario de trabajo: `dosorio`

En esta máquina se realiza la instalación de PostgreSQL, la clonación de Pagila, la creación de scripts, la ejecución de la práctica, las comprobaciones y la generación de logs.

---

## 3. Instalación inicial

Primero se actualizan los repositorios del sistema y se instalan PostgreSQL, sus herramientas adicionales y Git.

```bash
dosorio@asgbdpagila:~$ sudo apt update
dosorio@asgbdpagila:~$ sudo apt install -y postgresql postgresql-contrib git
```

Después se comprueba que el servicio de PostgreSQL está instalado y activo.

```bash
dosorio@asgbdpagila:~$ sudo systemctl status postgresql
```

Salida esperada:

```text
postgresql.service - PostgreSQL RDBMS
Loaded: loaded
Active: active (exited)
```

Con esto se verifica que PostgreSQL está funcionando correctamente.

También se comprueba el acceso al servidor de base de datos con el usuario `postgres`.

```bash
dosorio@asgbdpagila:~$ sudo -u postgres psql -c "\l"
```

Salida resumida:

```text
List of databases
Name       | Owner
-----------+----------
postgres   | postgres
template0  | postgres
template1  | postgres
```

En este punto todavía no existe la base de datos `pagila`, ya que se creará posteriormente mediante el script de preparación.

---

## 4. Estructura del repositorio

La práctica se ha reorganizado con una estructura más limpia que la estructura inicial de trabajo.

Estructura actual del repositorio:

```text
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

La estructura separa claramente:

* Documentación general.
* Scripts Bash.
* Scripts SQL.
* Memoria técnica de la práctica.

La versión inicial de la práctica usaba nombres como `configura.sh`, `manteniment.sh` y `scripts-sql/`. Para dejar el repositorio más profesional se han renombrado y organizado como `scripts/` y `sql/`.

---

## 5. Funcionamiento general del proyecto

El script principal del proyecto es:

```bash
./scripts/setup.sh
```

Este script orquesta toda la configuración de la práctica.

Tareas que realiza:

1. Ejecuta el script de preparación de Pagila.
2. Clona el repositorio oficial de Pagila.
3. Elimina una base de datos anterior si ya existía.
4. Crea de nuevo la base de datos `pagila`.
5. Carga el esquema y los datos.
6. Ejecuta los scripts SQL en orden.
7. Crea roles y usuarios.
8. Aplica permisos.
9. Crea una vista de inventario.
10. Crea un trigger de integridad.
11. Guarda la salida en `logs/setup.log`.

El orden de ejecución es importante porque primero debe existir la base de datos y después se aplican roles, permisos, vistas y triggers.

---

## 6. Script principal de configuración

Archivo:

```text
scripts/setup.sh
```

Este script actúa como punto de entrada de la práctica.

Contenido principal:

```bash
#!/bin/bash

set -euo pipefail

DB_NAME="pagila"
LOG_DIR="logs"
LOG="$LOG_DIR/setup.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG") 2>&1

echo "=================================="
echo "INICIO DE CONFIGURACION DE PAGILA"
echo "=================================="

echo "Paso 1: preparar base de datos Pagila"
bash scripts/prepare-pagila.sh

echo "Paso 2: crear roles y usuarios"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f sql/01-roles.sql

echo "Paso 3: aplicar permisos"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f sql/02-permissions.sql

echo "Paso 4: crear vista de inventario"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f sql/03-views.sql

echo "Paso 5: crear trigger de integridad"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f sql/04-triggers.sql

echo "=================================="
echo "CONFIGURACION TERMINADA"
echo "=================================="
```

Se utiliza:

```bash
set -euo pipefail
```

Esto mejora la seguridad del script porque hace que se detenga si aparece un error, si se usa una variable no definida o si falla una parte importante de la ejecución.

También se usa:

```bash
exec > >(tee -a "$LOG") 2>&1
```

Con esto se muestra la salida por pantalla y, al mismo tiempo, se guarda en un archivo de log.

---

## 7. Preparación de Pagila

Archivo:

```text
scripts/prepare-pagila.sh
```

Este script se encarga de preparar la base de datos Pagila desde cero.

Tareas principales:

* Clonar el repositorio de Pagila.
* Eliminar la carpeta local `pagila/` si ya existía.
* Eliminar la base de datos `pagila` si ya estaba creada.
* Crear una nueva base de datos `pagila`.
* Cargar el esquema.
* Cargar los datos.

Contenido principal:

```bash
#!/bin/bash

set -euo pipefail

PAGILA_REPO="https://github.com/devrimgunduz/pagila.git"
DB_NAME="pagila"

echo "Clonando repositorio de Pagila"

if [ -d "pagila" ]; then
    echo "El directorio pagila ya existe, eliminandolo"
    rm -rf pagila
fi

git clone "$PAGILA_REPO" pagila

echo "Eliminando base de datos anterior si existe"
sudo -u postgres dropdb --if-exists "$DB_NAME"

echo "Creando base de datos $DB_NAME"
sudo -u postgres createdb "$DB_NAME"

echo "Cargando esquema"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f pagila/pagila-schema.sql

echo "Cargando datos"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -f pagila/pagila-insert-data.sql

echo "Pagila preparada correctamente"
```

Este script permite repetir la práctica varias veces sin tener que borrar manualmente la base de datos ni la carpeta clonada.

---

## 8. Roles y usuarios

Archivo:

```text
sql/01-roles.sql
```

Este script crea los roles de grupo y los usuarios de laboratorio.

Roles creados:

* `grup_gerencia`
* `grup_atencio`

Usuarios creados:

* `daxxmanager`
* `daxxstaff`

Contenido principal:

```sql
DROP ROLE IF EXISTS daxxmanager;
DROP ROLE IF EXISTS daxxstaff;
DROP ROLE IF EXISTS grup_gerencia;
DROP ROLE IF EXISTS grup_atencio;

CREATE ROLE grup_gerencia NOLOGIN;
CREATE ROLE grup_atencio NOLOGIN;

CREATE USER daxxmanager WITH PASSWORD 'CHANGE_ME_MANAGER_PASSWORD';
CREATE USER daxxstaff WITH PASSWORD 'CHANGE_ME_STAFF_PASSWORD';

GRANT grup_gerencia TO daxxmanager;
GRANT grup_atencio TO daxxstaff;
```

En la versión inicial de la práctica se usaban contraseñas escritas directamente en el SQL. Para mejorar la seguridad del repositorio, se han sustituido por valores placeholder.

Esto evita publicar contraseñas reales o poco seguras en GitHub.

---

## 9. Permisos

Archivo:

```text
sql/02-permissions.sql
```

Este script aplica permisos según el perfil de cada grupo.

Acciones principales:

* Revocar permisos generales.
* Permitir conexión a la base de datos.
* Permitir uso del esquema `public`.
* Dar permisos de consulta y modificación a gerencia.
* Dar permisos más limitados al grupo de atención.
* Conceder permisos sobre secuencias necesarias para inserciones.

Contenido principal:

```sql
REVOKE ALL PRIVILEGES ON DATABASE pagila FROM public;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM public;

GRANT CONNECT ON DATABASE pagila TO grup_gerencia;
GRANT CONNECT ON DATABASE pagila TO grup_atencio;

GRANT USAGE ON SCHEMA public TO grup_gerencia;
GRANT USAGE ON SCHEMA public TO grup_atencio;

GRANT SELECT, INSERT, UPDATE ON TABLE film TO grup_gerencia;
GRANT SELECT, INSERT, UPDATE ON TABLE inventory TO grup_gerencia;
GRANT SELECT, INSERT, UPDATE ON TABLE rental TO grup_gerencia;

GRANT SELECT ON TABLE film TO grup_atencio;
GRANT SELECT ON TABLE inventory TO grup_atencio;

GRANT SELECT, INSERT ON TABLE rental TO grup_atencio;
GRANT UPDATE (return_date, last_update) ON TABLE rental TO grup_atencio;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO grup_gerencia;
GRANT USAGE, SELECT ON SEQUENCE rental_rental_id_seq TO grup_atencio;
```

La idea principal es aplicar el principio de mínimos privilegios.

Gerencia tiene permisos más amplios, mientras que atención tiene permisos limitados a las tareas necesarias.

---

## 10. Vista de inventario

Archivo:

```text
sql/03-views.sql
```

Este script crea la vista:

```text
vista_inventario
```

La vista permite consultar información de películas e inventario por tienda.

Contenido principal:

```sql
DROP VIEW IF EXISTS vista_inventario;

CREATE VIEW vista_inventario AS
SELECT
    f.title AS titulo,
    i.store_id AS tienda,
    COUNT(i.inventory_id) AS cantidad_total,
    SUM(
        CASE
            WHEN inventory_in_stock(i.inventory_id) THEN 1
            ELSE 0
        END
    ) AS cantidad_disponible
FROM film f
JOIN inventory i
    ON f.film_id = i.film_id
GROUP BY
    f.title,
    i.store_id
ORDER BY
    f.title,
    i.store_id;

GRANT SELECT ON vista_inventario TO grup_atencio;
GRANT SELECT ON vista_inventario TO grup_gerencia;
```

Esta vista simplifica la consulta de disponibilidad de películas sin tener que hacer consultas manuales sobre varias tablas.

---

## 11. Trigger de integridad

Archivo:

```text
sql/04-triggers.sql
```

Este script crea una función y un trigger para controlar nuevos alquileres.

El trigger impide insertar un nuevo alquiler si el cliente cumple alguna de estas condiciones:

* Tiene alquileres pendientes de más de 30 días.
* Tiene deuda pendiente.

También se corrige la función `get_customer_balance` incluida en Pagila, ya que la versión original utiliza una sintaxis más parecida a MySQL. En PostgreSQL se usa una estructura con `CASE WHEN`.

Parte principal del trigger:

```sql
CREATE OR REPLACE FUNCTION comprobar_alquiler()
RETURNS TRIGGER AS $$
DECLARE
    alquileres_pendientes INTEGER;
    deuda_cliente NUMERIC(10,2);
BEGIN
    SELECT COUNT(*)
    INTO alquileres_pendientes
    FROM rental
    WHERE customer_id = NEW.customer_id
      AND return_date IS NULL
      AND rental_date < CURRENT_TIMESTAMP - INTERVAL '30 days';

    IF alquileres_pendientes > 0 THEN
        RAISE EXCEPTION
            'No se puede crear el alquiler. El cliente % tiene alquileres pendientes de hace mas de 30 dias.',
            NEW.customer_id;
    END IF;

    SELECT COALESCE(get_customer_balance(NEW.customer_id, CURRENT_TIMESTAMP), 0)
    INTO deuda_cliente;

    IF deuda_cliente > 0 THEN
        RAISE EXCEPTION
            'No se puede crear el alquiler. El cliente % tiene una deuda pendiente de %.',
            NEW.customer_id,
            deuda_cliente;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_comprobar_alquiler
BEFORE INSERT ON rental
FOR EACH ROW
EXECUTE FUNCTION comprobar_alquiler();
```

Este punto es importante porque demuestra una regla de negocio aplicada directamente dentro de PostgreSQL.

---

## 12. Script de mantenimiento

Archivo:

```text
scripts/maintenance.sh
```

Este script ejecuta tareas básicas de mantenimiento sobre tablas importantes de la base de datos.

Tablas usadas:

* `rental`
* `inventory`
* `film`

Operaciones utilizadas:

```sql
VACUUM ANALYZE;
REINDEX TABLE;
```

Contenido principal:

```bash
#!/bin/bash

set -euo pipefail

DB_NAME="pagila"
LOG_DIR="logs"
LOG="$LOG_DIR/maintenance.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG") 2>&1

TABLES=("rental" "inventory" "film")

for TABLE in "${TABLES[@]}"; do
    echo "Ejecutando VACUUM ANALYZE en $TABLE"
    sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -c "VACUUM ANALYZE $TABLE;"
done

for TABLE in "${TABLES[@]}"; do
    echo "Ejecutando REINDEX en $TABLE"
    sudo -u postgres psql -v ON_ERROR_STOP=1 -d "$DB_NAME" -c "REINDEX TABLE $TABLE;"
done

echo "Mantenimiento terminado correctamente"
```

En la versión inicial se repetía el mismo bloque para cada tabla. En esta versión se ha optimizado usando un array y bucles para evitar duplicar código.

---

## 13. Permisos de ejecución

Antes de ejecutar los scripts, se dan permisos de ejecución.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ chmod +x scripts/setup.sh
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ chmod +x scripts/prepare-pagila.sh
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ chmod +x scripts/maintenance.sh
```

También se puede hacer en una sola línea:

```bash
chmod +x scripts/*.sh
```

---

## 14. Ejecución del script principal

Una vez preparados los permisos, se ejecuta el script principal.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ ./scripts/setup.sh
```

Salida representativa:

```text
==================================
INICIO DE CONFIGURACION DE PAGILA
==================================
Paso 1: preparar base de datos Pagila
Clonando repositorio de Pagila
Cloning into 'pagila'...

Paso 2: crear roles y usuarios
CREATE ROLE
CREATE ROLE
CREATE ROLE
CREATE ROLE
GRANT
GRANT

Paso 3: aplicar permisos
REVOKE
REVOKE
GRANT
GRANT

Paso 4: crear vista de inventario
CREATE VIEW
GRANT
GRANT

Paso 5: crear trigger de integridad
CREATE FUNCTION
CREATE TRIGGER

==================================
CONFIGURACION TERMINADA
==================================
```

Esta salida indica que el proceso completo se ha ejecutado correctamente.

---

## 15. Comprobación de la base de datos

Después de ejecutar el script principal, se comprueba que la base de datos `pagila` existe.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ sudo -u postgres psql -c "\l"
```

Salida resumida:

```text
List of databases
Name       | Owner
-----------+----------
pagila     | postgres
postgres   | postgres
template0  | postgres
template1  | postgres
```

También se comprueba que se puede acceder a la base de datos:

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ sudo -u postgres psql -d pagila
```

Salida:

```text
psql (16.13)
Type "help" for help.

pagila=#
```

Con esto se confirma que la base de datos se ha creado y se puede administrar.

---

## 16. Comprobación de tablas

Se comprueba que las tablas de Pagila se han cargado correctamente.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ sudo -u postgres psql -d pagila -c "\dt"
```

Salida representativa:

```text
List of relations
Schema | Name            | Type
-------+-----------------+----------------
public | actor           | table
public | address         | table
public | category        | table
public | city            | table
public | country         | table
public | customer        | table
public | film            | table
public | inventory       | table
public | language        | table
public | payment         | partitioned table
public | rental          | table
public | staff           | table
public | store           | table
```

La salida confirma que el esquema y los datos de Pagila se han cargado correctamente.

---

## 17. Comprobación de roles

Se comprueba que los roles y usuarios se han creado correctamente.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ sudo -u postgres psql -d pagila -c "\du"
```

Salida representativa:

```text
List of roles
Role name      | Attributes
---------------+------------------------------
daxxmanager    |
daxxstaff      |
grup_atencio   | Cannot login
grup_gerencia  | Cannot login
postgres       | Superuser, Create role, Create DB
```

Con esto se confirma que existen los usuarios de laboratorio y los roles de grupo.

---

## 18. Comprobación de la vista

Se comprueba que la vista `vista_inventario` funciona correctamente.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"
```

Salida real obtenida:

```text
titulo           | tienda | cantidad_total | cantidad_disponible
-----------------+--------+----------------+---------------------
ACADEMY DINOSAUR |      1 |              4 |                   4
ACADEMY DINOSAUR |      2 |              4 |                   3
ACE GOLDFINGER   |      2 |              3 |                   2
ADAPTATION HOLES |      2 |              4 |                   4
AFFAIR PREJUDICE |      1 |              4 |                   4
AFFAIR PREJUDICE |      2 |              3 |                   2
AFRICAN EGG      |      2 |              3 |                   2
AGENT TRUMAN     |      1 |              3 |                   3
AGENT TRUMAN     |      2 |              3 |                   3
AIRPLANE SIERRA  |      1 |              2 |                   2
```

La consulta devuelve películas, tienda, cantidad total y cantidad disponible. Por tanto, la vista se ha creado y funciona correctamente.

---

## 19. Comprobación del trigger

Para comprobar el trigger, primero se busca un cliente que tenga alquileres pendientes desde hace más de 30 días.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ sudo -u postgres psql -d pagila -c "
SELECT customer_id, COUNT(*)
FROM rental
WHERE return_date IS NULL
  AND rental_date < CURRENT_TIMESTAMP - INTERVAL '30 days'
GROUP BY customer_id
LIMIT 10;
"
```

Salida obtenida:

```text
customer_id | count
------------+-------
87          | 1
229         | 1
267         | 2
550         | 1
394         | 1
448         | 2
80          | 1
52          | 1
190         | 1
438         | 1
```

Después se intenta crear un nuevo alquiler para el cliente `87`.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ sudo -u postgres psql -d pagila -c "
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 1, 87, 1);
"
```

Salida obtenida:

```text
ERROR:  No se puede crear el alquiler. El cliente 87 tiene alquileres pendientes de hace mas de 30 dias.
CONTEXT:  PL/pgSQL function comprobar_alquiler() line 16 at RAISE
```

El error confirma que el trigger se ejecuta correctamente y bloquea la operación cuando el cliente incumple la regla establecida.

---

## 20. Ejecución del mantenimiento

Después de comprobar la base de datos, se ejecuta el script de mantenimiento.

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ ./scripts/maintenance.sh
```

Salida obtenida:

```text
=========================
INICIO DEL MANTENIMIENTO
=========================
Ejecutando VACUUM ANALYZE en rental
VACUUM
Ejecutando VACUUM ANALYZE en inventory
VACUUM
Ejecutando VACUUM ANALYZE en film
VACUUM
Ejecutando REINDEX en rental
REINDEX
Ejecutando REINDEX en inventory
REINDEX
Ejecutando REINDEX en film
REINDEX
Mantenimiento terminado correctamente
```

Esto confirma que las tareas de mantenimiento se han ejecutado correctamente.

---

## 21. Comprobación de logs

Los scripts generan logs dentro de la carpeta:

```text
logs/
```

Archivos generados:

```text
logs/setup.log
logs/maintenance.log
```

La carpeta `logs/` no se sube al repositorio porque contiene archivos generados durante la ejecución local.

Ejemplo de comprobación:

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ ls -l logs/
```

Salida representativa:

```text
-rw-r--r-- 1 dosorio dosorio 1027494 setup.log
-rw-r--r-- 1 dosorio dosorio    1410 maintenance.log
```

El log de configuración puede ser bastante largo porque recoge toda la salida de la clonación, carga del esquema, carga de datos y ejecución de scripts SQL.

Comprobación del final del log:

```bash
dosorio@asgbdpagila:~/postgresql-pagila-security-automation$ tail -n 10 logs/setup.log
```

Salida representativa:

```text
Paso 5: crear trigger de integridad
CREATE FUNCTION
DROP TRIGGER
DROP FUNCTION
CREATE FUNCTION
CREATE TRIGGER
==================================
CONFIGURACION TERMINADA
==================================
```

---

## 22. Archivos ignorados

El repositorio ignora archivos temporales y generados automáticamente.

Contenido principal de `.gitignore`:

```text
logs/
*.log
pagila/
*.tmp
*.bak
.DS_Store
.env
.vscode/
```

Esto evita subir al repositorio:

* Logs locales.
* Carpeta clonada de Pagila.
* Archivos temporales.
* Variables de entorno.
* Configuración local del editor.

---

## 23. Seguridad

Las contraseñas incluidas en los scripts SQL son valores placeholder.

Ejemplo:

```text
CHANGE_ME_MANAGER_PASSWORD
CHANGE_ME_STAFF_PASSWORD
```

En un entorno real no se deberían guardar contraseñas directamente en archivos versionados.

Lo correcto sería usar:

* Variables de entorno.
* Archivos de configuración no versionados.
* Un gestor de secretos.
* Políticas de rotación de credenciales.

También se limita el acceso mediante roles y permisos, aplicando el principio de mínimos privilegios.

---

## 24. Resultado final

El resultado final es un laboratorio reproducible de PostgreSQL que demuestra:

* Instalación y preparación de PostgreSQL.
* Automatización con Bash.
* Carga de la base de datos Pagila.
* Gestión de roles y usuarios.
* Aplicación de permisos por perfil.
* Creación de una vista de inventario.
* Implementación de un trigger de integridad.
* Ejecución de mantenimiento con `VACUUM ANALYZE` y `REINDEX`.
* Generación de logs.
