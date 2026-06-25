# PostgreSQL Pagila Security Automation

Práctica técnica de automatización, seguridad e integridad en PostgreSQL utilizando la base de datos de ejemplo Pagila.

El proyecto automatiza la preparación de la base de datos, la creación de roles y usuarios, la aplicación de permisos, la creación de una vista de inventario, la implementación de un trigger de control sobre alquileres y la ejecución de tareas básicas de mantenimiento.

Está planteado como un laboratorio reproducible de administración de PostgreSQL, organizado en formato de repositorio profesional.

---

## Objetivo

El objetivo de esta práctica es demostrar tareas reales de administración de bases de datos PostgreSQL aplicando:

* Automatización con scripts Bash.
* Carga de una base de datos de ejemplo.
* Gestión de roles y usuarios.
* Separación de permisos por perfil.
* Creación de vistas SQL.
* Implementación de triggers con PL/pgSQL.
* Comprobación de reglas de integridad.
* Tareas básicas de mantenimiento.
* Generación de logs.
* Organización limpia del proyecto en GitHub.

---

## Qué demuestra este proyecto

Este repositorio demuestra conocimientos prácticos relacionados con administración de sistemas, bases de datos y automatización.

En concreto:

* Instalación y uso de PostgreSQL en Ubuntu Server.
* Preparación automática de una base de datos desde cero.
* Uso de scripts Bash para ordenar procesos repetibles.
* Ejecución de SQL desde scripts.
* Control de permisos mediante roles de grupo.
* Aplicación del principio de mínimos privilegios.
* Creación de una vista para consultar inventario.
* Creación de un trigger para bloquear alquileres no permitidos.
* Ejecución de `VACUUM ANALYZE` y `REINDEX`.
* Gestión de logs generados durante la ejecución.
* Uso de `.gitignore` y `.gitattributes` para mantener el repositorio limpio.

> [!NOTE]
> Este proyecto está pensado como práctica técnica y laboratorio de aprendizaje. No está diseñado como despliegue de producción.

---

## Tecnologías utilizadas

* Ubuntu Server 24.04
* PostgreSQL
* Pagila
* Bash scripting
* SQL
* PL/pgSQL
* Git
* GitHub

---

## Estructura del repositorio

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

La estructura separa claramente la documentación, los scripts Bash y los scripts SQL.

---

## Funcionamiento general

El script principal del proyecto es:

```bash
./scripts/setup.sh
```

Este script ejecuta el flujo completo de configuración:

1. Prepara la base de datos Pagila.
2. Clona el repositorio de Pagila.
3. Elimina una base de datos anterior si ya existía.
4. Crea de nuevo la base de datos `pagila`.
5. Carga el esquema y los datos.
6. Crea roles y usuarios.
7. Aplica permisos según el tipo de usuario.
8. Crea una vista de inventario.
9. Crea un trigger de integridad.
10. Guarda la salida en `logs/setup.log`.

El script de mantenimiento se ejecuta aparte:

```bash
./scripts/maintenance.sh
```

Este script realiza tareas básicas de optimización sobre tablas importantes de la base de datos.

---

## Requisitos previos

El laboratorio está pensado para ejecutarse en una máquina Linux con PostgreSQL instalado localmente.

Instalar dependencias:

```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib git
```

Comprobar el servicio:

```bash
sudo systemctl status postgresql
```

Comprobar acceso a PostgreSQL:

```bash
sudo -u postgres psql -c "\l"
```

> [!IMPORTANT]
> Los scripts usan `sudo -u postgres`, por lo que deben ejecutarse en una máquina donde PostgreSQL esté instalado localmente y el usuario tenga permisos de administración.

---

## Ejecución del proyecto

Dar permisos de ejecución a los scripts:

```bash
chmod +x scripts/setup.sh
chmod +x scripts/prepare-pagila.sh
chmod +x scripts/maintenance.sh
```

También se puede hacer de forma más directa:

```bash
chmod +x scripts/*.sh
```

Ejecutar la configuración completa:

```bash
./scripts/setup.sh
```

Ejecutar el mantenimiento:

```bash
./scripts/maintenance.sh
```

> [!TIP]
> Los scripts deben ejecutarse desde la raíz del repositorio, ya que utilizan rutas relativas hacia las carpetas `scripts/` y `sql/`.

---

## Scripts incluidos

### `scripts/setup.sh`

Es el script principal del proyecto.

Se encarga de ejecutar el proceso completo en orden:

```text
scripts/prepare-pagila.sh
sql/01-roles.sql
sql/02-permissions.sql
sql/03-views.sql
sql/04-triggers.sql
```

También genera el log principal:

```text
logs/setup.log
```

---

### `scripts/prepare-pagila.sh`

Prepara la base de datos Pagila desde cero.

Realiza estas tareas:

* Clona el repositorio de Pagila.
* Elimina la carpeta local `pagila/` si ya existía.
* Elimina la base de datos `pagila` si ya estaba creada.
* Crea una nueva base de datos `pagila`.
* Carga el esquema.
* Carga los datos.

Esto permite repetir la práctica sin tener que limpiar manualmente la base de datos.

---

### `scripts/maintenance.sh`

Ejecuta mantenimiento básico sobre tablas importantes:

* `rental`
* `inventory`
* `film`

Operaciones utilizadas:

```sql
VACUUM ANALYZE;
REINDEX TABLE;
```

La salida se guarda en:

```text
logs/maintenance.log
```

---

## Scripts SQL

### `sql/01-roles.sql`

Crea roles de grupo y usuarios de laboratorio.

Roles:

* `grup_gerencia`
* `grup_atencio`

Usuarios:

* `daxxmanager`
* `daxxstaff`

Las contraseñas se han dejado como valores placeholder:

```text
CHANGE_ME_MANAGER_PASSWORD
CHANGE_ME_STAFF_PASSWORD
```

---

### `sql/02-permissions.sql`

Aplica permisos según el perfil de cada rol.

Acciones principales:

* Revoca permisos generales a `public`.
* Permite conexión a la base de datos.
* Permite uso del esquema `public`.
* Da permisos de consulta y modificación a gerencia.
* Da permisos más limitados al grupo de atención.
* Concede permisos sobre secuencias necesarias para inserciones.

La idea principal es aplicar el principio de mínimos privilegios.

---

### `sql/03-views.sql`

Crea la vista:

```text
vista_inventario
```

Esta vista permite consultar disponibilidad de películas por tienda.

Muestra:

* Título de la película.
* Tienda.
* Cantidad total.
* Cantidad disponible.

Ejemplo de comprobación:

```bash
sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"
```

---

### `sql/04-triggers.sql`

Crea una función y un trigger para controlar nuevos alquileres.

El trigger impide insertar un nuevo alquiler si el cliente cumple alguna de estas condiciones:

* Tiene alquileres pendientes de más de 30 días.
* Tiene deuda pendiente.

Este punto demuestra cómo aplicar una regla de negocio directamente dentro de PostgreSQL mediante PL/pgSQL.

---

## Comprobaciones realizadas

Durante la práctica se comprobaron los siguientes puntos:

* Servicio PostgreSQL activo.
* Base de datos `pagila` creada correctamente.
* Esquema y datos cargados.
* Tablas disponibles.
* Roles y usuarios creados.
* Permisos aplicados.
* Vista `vista_inventario` funcionando.
* Trigger bloqueando alquileres no permitidos.
* Script de mantenimiento ejecutado correctamente.
* Logs generados en la carpeta `logs/`.

---

## Comandos de comprobación

Comprobar bases de datos:

```bash
sudo -u postgres psql -c "\l"
```

Comprobar tablas de Pagila:

```bash
sudo -u postgres psql -d pagila -c "\dt"
```

Comprobar roles y usuarios:

```bash
sudo -u postgres psql -d pagila -c "\du"
```

Comprobar la vista:

```bash
sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"
```

Comprobar clientes con alquileres pendientes antiguos:

```bash
sudo -u postgres psql -d pagila -c "
SELECT customer_id, COUNT(*)
FROM rental
WHERE return_date IS NULL
  AND rental_date < CURRENT_TIMESTAMP - INTERVAL '30 days'
GROUP BY customer_id
LIMIT 10;
"
```

Probar el trigger:

```bash
sudo -u postgres psql -d pagila -c "
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 1, 87, 1);
"
```

Salida esperada si el trigger funciona:

```text
ERROR:  No se puede crear el alquiler. El cliente 87 tiene alquileres pendientes de hace mas de 30 dias.
```

---

## Logs

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

Comprobar logs:

```bash
ls -l logs/
```

Ver el final del log principal:

```bash
tail -n 10 logs/setup.log
```

---

## Archivos ignorados

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

## Control de saltos de línea

El archivo `.gitattributes` fuerza el uso de saltos de línea LF en los archivos importantes del proyecto.

Esto evita problemas al trabajar desde Windows y ejecutar scripts en Linux.

Reglas principales:

```text
*.sh text eol=lf
*.sql text eol=lf
*.md text eol=lf
.gitignore text eol=lf
.gitattributes text eol=lf
```

---

## Seguridad

> [!WARNING]
> Las contraseñas incluidas en los scripts SQL son valores placeholder de laboratorio. No deben usarse como contraseñas reales en producción.

En un entorno real sería recomendable usar:

* Variables de entorno.
* Archivos de configuración no versionados.
* Un gestor de secretos.
* Políticas de rotación de credenciales.

También se limita el acceso mediante roles y permisos, aplicando el principio de mínimos privilegios.

---

## Documentación completa

La explicación detallada del proceso, comandos utilizados, comprobaciones, pruebas del trigger, ejecución del mantenimiento y revisión de logs se encuentra en:

```text
docs/memoria.md
```

