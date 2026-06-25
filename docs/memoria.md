# Memoria técnica - PostgreSQL Pagila Security Automation



## 1. Resumen de la práctica



Esta práctica consiste en automatizar tareas de administración, seguridad e integridad en PostgreSQL utilizando la base de datos de ejemplo Pagila.



El proyecto incluye scripts Bash y SQL para preparar la base de datos, crear roles y usuarios, aplicar permisos, generar una vista de consulta, crear un trigger de control y ejecutar tareas básicas de mantenimiento.



El objetivo principal es dejar un laboratorio reproducible, ordenado y documentado, con una estructura más cercana a un repositorio profesional que a una entrega de clase.



\---



## 2. Entorno utilizado



La práctica está pensada para ejecutarse en una máquina Linux con PostgreSQL instalado localmente.



Entorno previsto:



\* Sistema operativo: Ubuntu Server 24.04

\* Base de datos: PostgreSQL

\* Base de datos de ejemplo: Pagila

\* Lenguajes utilizados: Bash, SQL y PL/pgSQL

\* Herramientas: Git, GitHub y terminal Linux



Los scripts utilizan el usuario `postgres` mediante `sudo -u postgres`, por lo que es necesario ejecutar la práctica en un entorno donde el usuario tenga permisos de administración.



\---



## 3. Estructura del repositorio



```text

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

&#x20;   └── memoria.md

```



La estructura separa claramente la documentación, los scripts Bash y los scripts SQL.



\---



## 4. Instalación de dependencias



Antes de ejecutar la práctica se instalan PostgreSQL, herramientas adicionales y Git:



```bash

sudo apt update

sudo apt install -y postgresql postgresql-contrib git

```



Después se comprueba el estado del servicio:



```bash

sudo systemctl status postgresql

```



El servicio debe estar activo antes de continuar.



\---



## 5. Funcionamiento general



El proceso principal se ejecuta mediante el script:



```bash

./scripts/setup.sh

```



Este script realiza las siguientes tareas:



1\. Ejecuta `scripts/prepare-pagila.sh`.

2\. Clona el repositorio de Pagila.

3\. Elimina una base de datos anterior si ya existía.

4\. Crea de nuevo la base de datos `pagila`.

5\. Carga el esquema y los datos.

6\. Ejecuta los scripts SQL en orden.

7\. Genera un log en `logs/setup.log`.



El orden de ejecución es importante porque primero debe existir la base de datos y después se aplican roles, permisos, vistas y triggers.



\---



## 6. Script de preparación de Pagila



Archivo:



```text

scripts/prepare-pagila.sh

```



Este script se encarga de preparar la base de datos desde cero.



Tareas principales:



\* Clonar el repositorio de Pagila.

\* Borrar la carpeta local `pagila/` si ya existe.

\* Eliminar la base de datos `pagila` si ya estaba creada.

\* Crear una nueva base de datos `pagila`.

\* Cargar el esquema.

\* Cargar los datos.



Este enfoque permite repetir la práctica de forma limpia sin tener que borrar todo manualmente.



\---



## 7. Script principal de configuración



Archivo:



```text

scripts/setup.sh

```



Este script actúa como orquestador de toda la práctica.



Ejecuta en orden:



```text

scripts/prepare-pagila.sh

sql/01-roles.sql

sql/02-permissions.sql

sql/03-views.sql

sql/04-triggers.sql

```



Además, guarda la salida de ejecución en:



```text

logs/setup.log

```



El script utiliza:



```bash

set -euo pipefail

```



Esto hace que la ejecución se detenga si aparece un error, si se utiliza una variable no definida o si falla una parte importante del proceso.



\---



## 8. Roles y usuarios



Archivo:



```text

sql/01-roles.sql

```



Este script crea dos roles de grupo:



\* `grup\_gerencia`

\* `grup\_atencio`



Y dos usuarios de laboratorio:



\* `daxxmanager`

\* `daxxstaff`



Los usuarios se asignan a sus grupos correspondientes.



Las contraseñas incluidas son valores placeholder, no contraseñas reales:



```sql

CREATE USER daxxmanager WITH PASSWORD 'CHANGE\_ME\_MANAGER\_PASSWORD';

CREATE USER daxxstaff WITH PASSWORD 'CHANGE\_ME\_STAFF\_PASSWORD';

```



\---



## 9. Permisos



Archivo:



```text

sql/02-permissions.sql

```



Este script aplica permisos según el perfil de usuario.



La idea principal es evitar permisos generales innecesarios y aplicar permisos mínimos según el rol.



Acciones principales:



\* Revocar permisos generales a `public`.

\* Permitir conexión a la base de datos.

\* Permitir uso del esquema `public`.

\* Dar permisos de consulta y modificación a gerencia.

\* Dar permisos más limitados al grupo de atención.

\* Conceder uso de secuencias necesarias para inserciones.



Esto permite separar responsabilidades dentro de la base de datos.



\---



## 10. Vista de inventario



Archivo:



```text

sql/03-views.sql

```



Este script crea la vista:



```text

vista\_inventario

```



La vista muestra información útil sobre películas e inventario por tienda:



\* Título de la película.

\* Tienda.

\* Cantidad total.

\* Cantidad disponible.



La vista simplifica consultas que, de otra forma, requerirían acceder directamente a varias tablas.



Comprobación:



```bash

sudo -u postgres psql -d pagila -c "SELECT \* FROM vista\_inventario LIMIT 10;"

```



\---



## 11. Trigger de integridad



Archivo:



```text

sql/04-triggers.sql

```



Este script crea una función y un trigger para controlar nuevos alquileres.



El trigger impide insertar un nuevo alquiler si el cliente cumple alguna de estas condiciones:



\* Tiene alquileres pendientes de más de 30 días.

\* Tiene deuda pendiente.



Esto permite aplicar una regla de negocio directamente en la base de datos.



También se corrige la función `get\_customer\_balance` de Pagila, ya que la versión original utiliza una sintaxis tipo MySQL (`IF()`), mientras que PostgreSQL requiere `CASE WHEN`.



\---



## 12. Script de mantenimiento



Archivo:



```text

scripts/maintenance.sh

```



Este script ejecuta tareas básicas de mantenimiento sobre tablas importantes:



\* `rental`

\* `inventory`

\* `film`



Operaciones realizadas:



```sql

VACUUM ANALYZE;

REINDEX TABLE;

```



La salida se guarda en:



```text

logs/maintenance.log

```



El script está preparado para recorrer las tablas mediante un array, evitando repetir bloques de código innecesarios.



\---



## 13. Comprobaciones realizadas



Durante la práctica se comprobaron los siguientes puntos:



\* PostgreSQL instalado y activo.

\* Base de datos `pagila` creada correctamente.

\* Esquema y datos cargados.

\* Tablas disponibles.

\* Roles y usuarios creados.

\* Permisos aplicados.

\* Vista `vista\_inventario` funcionando.

\* Trigger bloqueando alquileres no permitidos.

\* Script de mantenimiento ejecutado correctamente.

\* Logs generados en la carpeta `logs/`.



Comprobación de bases de datos:



```bash

sudo -u postgres psql -c "\\l"

```



Comprobación de tablas:



```bash

sudo -u postgres psql -d pagila -c "\\dt"

```



Comprobación de roles:



```bash

sudo -u postgres psql -d pagila -c "\\du"

```



Comprobación de la vista:



```bash

sudo -u postgres psql -d pagila -c "SELECT \* FROM vista\_inventario LIMIT 10;"

```



\---



## 14. Logs



Los scripts generan logs dentro de la carpeta:



```text

logs/

```



Archivos generados:



```text

logs/setup.log

logs/maintenance.log

```



Estos archivos no se suben al repositorio porque son generados durante la ejecución local.



La carpeta está ignorada mediante `.gitignore`.



\---



## 15. Archivos ignorados



El repositorio ignora archivos temporales o generados automáticamente:



```text

logs/

\*.log

pagila/

.env

.vscode/

```



La carpeta `pagila/` no forma parte del repositorio porque se descarga automáticamente al ejecutar el script de preparación.



\---



## 16. Nota de seguridad



Las contraseñas del proyecto son valores de laboratorio.



En un entorno real no se deberían guardar contraseñas directamente dentro de scripts SQL versionados.



Lo correcto en producción sería usar:



\* Variables de entorno.

\* Ficheros de configuración no versionados.

\* Un gestor de secretos.

\* Políticas de rotación de credenciales.



\---



## 17. Resultado final



El resultado final es un laboratorio reproducible de administración de PostgreSQL que demuestra:



\* Automatización con Bash.

\* Administración básica de PostgreSQL.

\* Carga de una base de datos de ejemplo.

\* Gestión de roles y permisos.

\* Creación de vistas.

\* Uso de triggers para reglas de integridad.

\* Mantenimiento básico de tablas.
