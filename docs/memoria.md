# Automatización, Seguridad e Integridad en PostgreSQL con Pagila

## Máquina y entorno utilizado

### Máquina 1 - VM Ubuntu 24.04 Server

En esta máquina haremos uso, instalación y configuration de lo siguiente:

- Instalación de PostgreSQL
- Clonación de BBDD Pagila
- Creación de los scripts
- Ejecución y pruebas de la práctica
- Generación de los logs

## Instalación inicial en la máquina

En primer lugar, haremos la instalación de PostgreSQL. Para ello haremos uso de los siguientes comandos:

```bash
dosorio@asgbdpagila:~$ sudo apt update
dosorio@asgbdpagila:~$ sudo apt install -y postgresql postgresql-contrib git
```

Seguidamente, comprobamos el estado para verificar que se ha instalado correctamente y está en funcionamiento:

```bash
dosorio@asgbdpagila:~$ sudo systemctl status postgresql
â— postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/usr/lib/systemd/system/postgresql.service; enabled; prese>
     Active: active (exited) since Wed 2026-04-22 17:28:04 UTC; 32s ago
   Main PID: 3573 (code=exited, status=0/SUCCESS)
        CPU: 3ms

abr 22 17:28:04 asgbdpagila systemd[1]: Starting postgresql.service - PostgreSQ>
abr 22 17:28:04 asgbdpagila systemd[1]: Finished postgresql.service - PostgreSQ>
lines 1-8/8 (END)
```

Luego hacemos una prueba rápida de acceso para terminar de verificarlo:

```bash
dosorio@asgbdpagila:~$ sudo -u postgres psql -c "\l"

                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 postgres  | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(3 rows)
```

## Estructura de carpetas

Para poder poner todo en orden, haremos una estructura ordenada de carpetas y archivos para poder trabajar de forma más limpia y eficaz. Para ello usaremos las siguientes órdenes:

```bash
dosorio@asgbdpagila:~$ mkdir -p ~/practica-pagila/sql
dosorio@asgbdpagila:~$ cd ~/practica-pagila
dosorio@asgbdpagila:~/practica-pagila$ touch documentacio.md configura.sh manteniment.sh
dosorio@asgbdpagila:~/practica-pagila$ touch scripts/prepare-pagila.sh
dosorio@asgbdpagila:~/practica-pagila$ touch sql/01-roles.sql
dosorio@asgbdpagila:~/practica-pagila$ touch sql/02-permissions.sql
dosorio@asgbdpagila:~/practica-pagila$ touch sql/03-views.sql
dosorio@asgbdpagila:~/practica-pagila$ touch sql/04-triggers.sql
```

Una vez creadas, la estructura nos quedaría bien ordenada de la forma siguiente:

```bash
dosorio@asgbdpagila:~/practica-pagila$ tree
.
â”œâ”€â”€ configura.sh
â”œâ”€â”€ documentacio.md
â”œâ”€â”€ manteniment.sh
â””â”€â”€ sql
    â”œâ”€â”€ 00-prepara-pagila.sh
    â”œâ”€â”€ 01-rols.sql
    â”œâ”€â”€ 02-permisos.sql
    â”œâ”€â”€ 03-vistes.sql
    â””â”€â”€ 04-triggers.sql

2 directories, 8 files
```

## Contenido de cada fichero

Seguidamente, pasaremos a meter la información necesaria en cada fichero, iniciando por el siguiente, que se encarga de crear el log, llamar al script de preparación y ejecutar los SQL en orden:

```bash
dosorio@asgbdpagila:~/practica-pagila$ nano configura.sh
```

Dentro, dejaremos el siguiente contenido:

```bash
dosorio@asgbdpagila:~/practica-pagila$ cat configura.sh
```

```bash
#!/bin/bash

# Log de la configuration
LOG="logs/setup.log"

# Guardar todo en pantalla y en el log
exec > >(tee -a "$LOG") 2>&1

echo "==============================="
echo "INICIO DE CONFIGURACION PAGILA"
echo "==============================="

# Paso 1: Preparar base de datos
echo "Paso 1: preparar base de datos"
bash scripts/prepare-pagila.sh
if [ $? -ne 0 ]; then
    echo "Error en 00-prepara-pagila.sh"
    exit 1
fi

# Paso 2: Crear roles y usuarios
echo "Paso 2: crear roles y usuarios"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/01-roles.sql
if [ $? -ne 0 ]; then
    echo "Error en 01-rols.sql"
    exit 1
fi

# Paso 3: Dar permisos
echo "Paso 3: dar permisos"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/02-permissions.sql
if [ $? -ne 0 ]; then
    echo "Error en 02-permisos.sql"
    exit 1
fi

# Paso 4: Crear vista
echo "Paso 4: crear vista"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/03-views.sql
if [ $? -ne 0 ]; then
    echo "Error en 03-vistes.sql"
    exit 1
fi

# Paso 5: Crear trigger
echo "Paso 5: crear trigger"
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -f sql/04-triggers.sql
if [ $? -ne 0 ]; then
    echo "Error en 04-triggers.sql"
    exit 1
fi

echo "=================================="
echo "CONFIGURACION TERMINADA CORRECTAMENTE"
echo "=================================="
```

Ahora haremos lo mismo en el archivo que prepara la base de datos desde cero:

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ nano 00-prepara-pagila.sh
```

Dentro dejaremos lo siguiente:

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ cat 00-prepara-pagila.sh
```

```bash
#!/bin/bash

# Clonamos el repositorio de Pagila
echo "Clonando repositorio de Pagila..."

# Si ya existe la carpeta, la borramos
if [ -d "pagila" ]; then
    echo "El directorio 'pagila' ya existe, eliminándolo..."
    rm -rf pagila  # Eliminamos la carpeta 'pagila' para asegurarnos de tener una copia limpia
fi

# Clonamos el repositorio
git clone https://github.com/devrimgunduz/pagila.git

if [ $? -ne 0 ]; then
    echo "Error al clonar el repositorio"
    exit 1
fi

# Eliminamos la base de datos si ya existe
echo "Eliminando base de datos pagila si existía..."
sudo -u postgres dropdb --if-exists pagila

# Creamos la base de datos
echo "Creando base de datos pagila..."
sudo -u postgres createdb pagila
if [ $? -ne 0 ]; then
    echo "Error al crear la base de datos"
    exit 1
fi

# Cargamos el esquema y los datos
echo "Cargando esquema..."
sudo -u postgres psql -d pagila -f pagila/pagila-schema.sql
if [ $? -ne 0 ]; then
    echo "Error al cargar el esquema"
    exit 1
fi

echo "Cargando datos..."
sudo -u postgres psql -d pagila -f pagila/pagila-insert-data.sql
if [ $? -ne 0 ]; then
    echo "Error al cargar los datos"
    exit 1
fi

echo "Base de datos Pagila preparada correctamente"
```

Lo mismo con el archivo de creación de usuarios y roles:

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ nano 01-rols.sql
```

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ cat 01-rols.sql
```

```sql
-- Eliminar roles si ya existen
DROP ROLE IF EXISTS grup_gerencia;
DROP ROLE IF EXISTS grup_atencio;
DROP ROLE IF EXISTS daxxmanager;
DROP ROLE IF EXISTS daxxstaff;

-- Con estos comandos creamos los roles de grupo, que en este caso no cuentan con permisos de login.
CREATE ROLE grup_gerencia NOLOGIN;
CREATE ROLE grup_atencio NOLOGIN;

-- Con esto, creamos usuarios con passwords seguras
CREATE USER daxxmanager WITH PASSWORD 'CHANGE_ME_MANAGER_PASSWORD';
CREATE USER daxxstaff WITH PASSWORD 'CHANGE_ME_STAFF_PASSWORD';

-- Asignamos los usuarios a los grupos
GRANT grup_gerencia TO daxxmanager;
GRANT grup_atencio TO daxxstaff;
```

Seguidamente con el archivo que da los permisos:

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ nano 02-permisos.sql
```

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ cat 02-permisos.sql
```

```sql
-- Primero quitamos permisos generales para evitar accesos innecesarios
REVOKE ALL PRIVILEGES ON DATABASE pagila FROM public;

-- Damos permiso para conectarse a la base de datos
GRANT CONNECT ON DATABASE pagila TO grup_gerencia;
GRANT CONNECT ON DATABASE pagila TO grup_atencio;

-- Damos permiso para usar el esquema public
GRANT USAGE ON SCHEMA public TO grup_gerencia;
GRANT USAGE ON SCHEMA public TO grup_atencio;

-- Permisos para gerencia: puede consultar y modificar tablas clave
GRANT SELECT, INSERT, UPDATE ON film TO grup_gerencia;
GRANT SELECT, INSERT, UPDATE ON inventory TO grup_gerencia;
GRANT SELECT, INSERT, UPDATE ON rental TO grup_gerencia;

-- Permisos para atención: puede consultar películas e inventario
GRANT SELECT ON film TO grup_atencio;
GRANT SELECT ON inventory TO grup_atencio;

-- Atención puede consultar, crear alquileres y marcar devoluciones
GRANT SELECT, INSERT ON rental TO grup_atencio;
GRANT UPDATE (return_date, last_update) ON rental TO grup_atencio;

-- Damos permisos sobre las secuencias necesarias para insertar datos
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO grup_gerencia;
GRANT USAGE, SELECT ON SEQUENCE rental_rental_id_seq TO grup_atencio;
```

El archivo para crear una vista de recepción con información útil:

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ nano 03-vistes.sql
```

Y dentro:

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ cat 03-vistes.sql
```

```sql
-- Eliminamos la vista si ya existe para poder repetir el script sin errores
DROP VIEW IF EXISTS vista_inventario;

-- Creamos una vista para ver películas y disponibilidad por tienda
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
JOIN inventory i ON f.film_id = i.film_id
GROUP BY f.title, i.store_id
ORDER BY f.title, i.store_id;

-- Damos permiso de lectura sobre la vista
GRANT SELECT ON vista_inventario TO grup_atencio;
GRANT SELECT ON vista_inventario TO grup_gerencia;
```

Seguidamente vamos a hacer un trigger sencillo y entendible. Lo que este trigger hará es que si el cliente tiene algún alquiler sin devolver desde hace más de 30 días, no podrá alquilar otra película. Para ello, trabajaremos en el siguiente archivo:

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ nano 04-triggers.sql
```

Y dentro:

```bash
dosorio@asgbdpagila:~/practica-pagila/sql$ cat 04-triggers.sql
```

```sql
-- Corregimos la funcion get_customer_balance que viene en Pagila.
-- El problema es que trae IF(), que es de MySQL, y PostgreSQL usa CASE WHEN.
CREATE OR REPLACE FUNCTION public.get_customer_balance(
p_customer_id integer,
p_effective_date timestamp with time zone
)
RETURNS numeric
LANGUAGE plpgsql
AS $function$
DECLARE
v_rentfees NUMERIC(10,2);
v_overfees NUMERIC(10,2);
v_payments NUMERIC(10,2);
BEGIN
-- Calculamos el coste de los alquileres anteriores
SELECT COALESCE(SUM(film.rental_rate), 0)
INTO v_rentfees
FROM film, inventory, rental
WHERE film.film_id = inventory.film_id
AND inventory.inventory_id = rental.inventory_id
AND rental.rental_date <= p_effective_date
AND rental.customer_id = p_customer_id;

-- Calculamos los dias de retraso.
-- Usamos CASE WHEN porque PostgreSQL no acepta IF() dentro de un SELECT.
SELECT COALESCE(SUM(
CASE
WHEN rental.return_date IS NOT NULL
AND (rental.return_date::date - rental.rental_date::date) > film.rental_duration
THEN ((rental.return_date::date - rental.rental_date::date) - film.rental_duration)::numeric
ELSE 0::numeric
END
), 0)
INTO v_overfees
FROM rental, inventory, film
WHERE film.film_id = inventory.film_id
AND inventory.inventory_id = rental.inventory_id
AND rental.rental_date <= p_effective_date
AND rental.customer_id = p_customer_id;

-- Calculamos los pagos hechos por el cliente
SELECT COALESCE(SUM(payment.amount), 0)
INTO v_payments
FROM payment
WHERE payment.payment_date <= p_effective_date
AND payment.customer_id = p_customer_id;

-- Devolvemos el balance final del cliente
RETURN v_rentfees + v_overfees - v_payments;
END;
$function$;


-- Eliminamos el trigger si ya existe
DROP TRIGGER IF EXISTS trigger_comprobar_alquiler ON rental;

-- Eliminamos la funcion del trigger si ya existe
DROP FUNCTION IF EXISTS comprobar_alquiler();

-- Funcion del trigger que impide alquiler si hay deuda o alquileres antiguos pendientes
CREATE OR REPLACE FUNCTION comprobar_alquiler()
RETURNS TRIGGER AS $$
DECLARE
alquileres_pendientes INTEGER;
deuda_cliente NUMERIC(10,2);
BEGIN
-- Contamos los alquileres no devueltos de hace mas de 30 dias
SELECT COUNT(*)
INTO alquileres_pendientes
FROM rental
WHERE customer_id = NEW.customer_id
AND return_date IS NULL
AND rental_date < CURRENT_TIMESTAMP - INTERVAL '30 days';

-- Si tiene alquileres pendientes antiguos, no puede alquilar
IF alquileres_pendientes > 0 THEN
RAISE EXCEPTION 'No se puede crear el alquiler. El cliente % tiene alquileres pendientes de hace mas de 30 dias.', NEW.customer_id;
END IF;

-- Comprobamos si el cliente tiene deuda pendiente
SELECT COALESCE(get_customer_balance(NEW.customer_id, CURRENT_TIMESTAMP), 0)
INTO deuda_cliente;

-- Si tiene deuda, no puede alquilar
IF deuda_cliente > 0 THEN
RAISE EXCEPTION 'No se puede crear el alquiler. El cliente % tiene una deuda pendiente de %.', NEW.customer_id, deuda_cliente;
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creamos el trigger antes de insertar un alquiler
CREATE TRIGGER trigger_comprobar_alquiler
BEFORE INSERT ON rental
FOR EACH ROW
EXECUTE FUNCTION comprobar_alquiler();
```

Seguidamente, pasamos a un script de mantenimiento:

```bash
dosorio@asgbdpagila:~/practica-pagila$ nano manteniment.sh
```

Y dentro:

```bash
dosorio@asgbdpagila:~/practica-pagila$ cat manteniment.sh
```

```bash
#!/bin/bash

LOG="logs/maintenance.log"

# Guardar todo en pantalla y en el log
exec > >(tee -a "$LOG") 2>&1

echo "========================="
echo "INICIO DEL MANTENIMIENTO"
echo "========================="

# Ejecutamos VACUUM ANALYZE en las tablas clave
echo "Haciendo VACUUM ANALYZE en rental..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "VACUUM ANALYZE rental;"

if [ $? -ne 0 ]; then
    echo "Error haciendo VACUUM ANALYZE en rental"
    exit 1
fi

echo "Haciendo VACUUM ANALYZE en inventory..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "VACUUM ANALYZE inventory;"

if [ $? -ne 0 ]; then
    echo "Error haciendo VACUUM ANALYZE en inventory"
    exit 1
fi

echo "Haciendo VACUUM ANALYZE en film..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "VACUUM ANALYZE film;"

if [ $? -ne 0 ]; then
    echo "Error haciendo VACUUM ANALYZE en film"
    exit 1
fi

# Ejecutamos REINDEX en las tablas clave
echo "Haciendo REINDEX en rental..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "REINDEX TABLE rental;"

if [ $? -ne 0 ]; then
    echo "Error haciendo REINDEX en rental"
    exit 1
fi

echo "Haciendo REINDEX en inventory..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "REINDEX TABLE inventory;"

if [ $? -ne 0 ]; then
    echo "Error haciendo REINDEX en inventory"
    exit 1
fi

echo "Haciendo REINDEX en film..."
sudo -u postgres psql -v ON_ERROR_STOP=1 -d pagila -c "REINDEX TABLE film;"

if [ $? -ne 0 ]; then
    echo "Error haciendo REINDEX en film"
    exit 1
fi

echo "Mantenimiento terminado correctamente"
```

Este script realiza VACUUM ANALYZE sobre las tablas rental, inventory y film, y un REINDEX en las mismas tablas.

El siguiente paso consiste en dar permisos de ejecución a todos los archivos. Para ello haremos uso de los siguientes comandos:

```bash
dosorio@asgbdpagila:~/practica-pagila$ chmod +x configura.sh
dosorio@asgbdpagila:~/practica-pagila$ chmod +x manteniment.sh
dosorio@asgbdpagila:~/practica-pagila$ chmod +x scripts/prepare-pagila.sh
```

Una vez les hemos concedido los permisos necesarios, probaremos a ejecutarlos para ir comprobando el funcionamiento de la práctica. En primer lugar, ejecutamos el script configura.sh, que orquesta todo el proceso de instalación, creación de la base de datos y configuration de la base de datos:

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo ./configura.sh
===============================
INICIO DE CONFIGURACION PAGILA
===============================
Paso 1: preparar base de datos
Clonando repositorio de Pagila...
El directorio 'pagila' ya existe, eliminándolo...
Cloning into 'pagila'...
â€¦
â€¦
â€¦
Paso 4: crear vista
CREATE VIEW
GRANT
GRANT

Paso 5: crear trigger
CREATE FUNCTION
CREATE TRIGGER

==================================
CONFIGURACION TERMINADA CORRECTAMENTE
==================================
```

Una vez que hemos comprobado que el script principal funciona, debemos ir paso a paso comprobando que funciona, como por ejemplo mirando si realmente existe la base de datos:

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo -u postgres psql -c "\l"
                                                         List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |    Access privileges     
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+--------------------------
 pagila    | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | =Tc/postgres            +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres   +
           |          |          |                 |             |             |            |           | grup_gerencia=c/postgres+
           |          |          |                 |             |             |            |           | grup_atencio=c/postgres
 postgres  | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | =c/postgres             +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | es_ES.UTF-8 | es_ES.UTF-8 |            |           | =c/postgres             +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(4 rows)
```

Ya comprobado que existe la base, procedemos a entrar a ella:

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo -u postgres psql -d pagila
psql (16.13 (Ubuntu 16.13-0ubuntu0.24.04.1))
Type "help" for help.

pagila=#
```

Por lo pronto, nos ha dejado entrar sin problema a la misma, por lo cual ahora haremos verificaciones a través de alguna consulta para ver si se han cargado correctamente las tablas:

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo -u postgres psql -d pagila -c "\dt"
                    List of relations
 Schema |       Name       |       Type        |  Owner   
--------+------------------+-------------------+----------
 public | actor            | table             | postgres
 public | address          | table             | postgres
 public | category         | table             | postgres
 public | city             | table             | postgres
 public | country          | table             | postgres
 public | customer         | table             | postgres
 public | film             | table             | postgres
 public | film_actor       | table             | postgres
 public | film_category    | table             | postgres
 public | inventory        | table             | postgres
 public | language         | table             | postgres
 public | payment          | partitioned table | postgres
 public | payment_p2022_01 | table             | postgres
 public | payment_p2022_02 | table             | postgres
 public | payment_p2022_03 | table             | postgres
 public | payment_p2022_04 | table             | postgres
 public | payment_p2022_05 | table             | postgres
 public | payment_p2022_06 | table             | postgres
 public | payment_p2022_07 | table             | postgres
 public | rental           | table             | postgres
 public | staff            | table             | postgres
 public | store            | table             | postgres
(22 rows)
```

Luego verificamos que existen los usuarios y grupos creados:

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo -u postgres psql -d pagila -c "\du"
                               List of roles
   Role name   |                         Attributes                         
---------------+------------------------------------------------------------
 daxxmanager   | 
 daxxstaff     | 
 grup_atencio  | Cannot login
 grup_gerencia | Cannot login
 postgres      | Superuser, Create role, Create DB, Replication, Bypass RLS
```

Y finalmente una consulta simple sobre la vista creada:

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo -u postgres psql -d pagila -c "SELECT * FROM vista_inventario LIMIT 10;"
      titulo      | tienda | cantidad_total | cantidad_disponible 
------------------+--------+----------------+---------------------
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
(10 rows)
```

Ahora comprobaremos que el trigger se ejecuta correctamente, insertando un alquiler con un cliente con alquileres pendientes.

Primero, verificamos algún cliente que nos sirva:

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo -u postgres psql -d pagila -c "
SELECT customer_id, COUNT(*)
FROM rental
WHERE return_date IS NULL
  AND rental_date < CURRENT_TIMESTAMP - INTERVAL '30 days'
GROUP BY customer_id
LIMIT 10;
"
 customer_id | count 
-------------+-------
          87 |     1
         229 |     1
         267 |     2
         550 |     1
         394 |     1
         448 |     2
          80 |     1
          52 |     1
         190 |     1
         438 |     1
(10 rows)
```

Ahora vamos a intentar insertar un nuevo alquiler para ese cliente para comprobar que el trigger funciona correctamente y que se lanza un error si el cliente tiene alquileres pendientes.

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo -u postgres psql -d pagila -c "
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 1, 87, 1);
"
ERROR:  No se puede crear el alquiler. El cliente 87 tiene alquileres pendientes de hace mas de 30 dias.
CONTEXT:  PL/pgSQL function comprobar_alquiler() line 16 at RAISE
```

Como podemos comprobar, nos salta el trigger indicando el error de que no se puede crear un alquiler más para este cliente.

El siguiente paso, una vez hemos podido comprobar que efectivamente los datos han sido cargados sin ningún tipo de problema y que el trigger funciona, es ejecutar el mantenimiento:

```bash
dosorio@asgbdpagila:~/practica-pagila$ sudo ./manteniment.sh
=========================
INICIO DEL MANTENIMIENTO
=========================
Haciendo VACUUM ANALYZE en rental...
VACUUM
Haciendo VACUUM ANALYZE en inventory...
VACUUM
Haciendo VACUUM ANALYZE en film...
VACUUM
Haciendo REINDEX en rental...
REINDEX
Haciendo REINDEX en inventory...
REINDEX
Haciendo REINDEX en film...
REINDEX
Mantenimiento terminado correctamente
```

Hemos podido comprobar que el mantenimiento se ha realizado correctamente, por lo cual ahora podemos comprobar los logs generados:

```bash
dosorio@asgbdpagila:~/practica-pagila$ ls -l *.log
-rw-r--r-- 1 root    root    1027494 abr 30 20:28 logs/setup.log
-rw-rw-r-- 1 dosorio dosorio    1410 abr 30 20:31 logs/maintenance.log
```

Una vez hemos verificado que se han creado los archivos con los logs, debemos comprobar que han guardado correctamente la información.

Como el log de configuration es muy largo, entraremos en él y miraremos el inicio y el final:

```bash
dosorio@asgbdpagila:~/practica-pagila$ nano logs/setup.log
```

```bash
GNU nano 7.2                                             logs/setup.log

===============================
INICIO DE CONFIGURACION PAGILA
===============================
Paso 1: preparar base de datos
Clonando repositorio de Pagila...
â€¦
â€¦
â€¦
DROP FUNCTION
CREATE FUNCTION
CREATE TRIGGER
==================================
CONFIGURACION TERMINADA CORRECTAMENTE
==================================
```

El log de mantenimiento simplemente nos muestra si lo hemos ejecutado y cuántas veces. Al ser la primera vez que lo lanzamos, solamente aparece una vez:

```bash
dosorio@asgbdpagila:~/practica-pagila$ cat logs/maintenance.log
=========================
INICIO DEL MANTENIMIENTO
=========================
Haciendo VACUUM ANALYZE en rental...
VACUUM
Haciendo VACUUM ANALYZE en inventory...
VACUUM
Haciendo VACUUM ANALYZE en film...
VACUUM
Haciendo REINDEX en rental...
REINDEX
Haciendo REINDEX en inventory...
REINDEX
Haciendo REINDEX en film...
REINDEX
Mantenimiento terminado correctamente
```


