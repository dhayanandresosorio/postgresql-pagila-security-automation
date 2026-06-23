-- Eliminar roles si ya existen
DROP ROLE IF EXISTS grup_gerencia;
DROP ROLE IF EXISTS grup_atencio;
DROP ROLE IF EXISTS daxxmanager;
DROP ROLE IF EXISTS daxxstaff;

-- Con estos comandos creamos los roles de grupo, que en este caso no cuentan con  permisos de login.
CREATE ROLE grup_gerencia NOLOGIN;
CREATE ROLE grup_atencio NOLOGIN;

-- Con esto, creamos usuarios con passwords seguras
CREATE USER daxxmanager WITH PASSWORD 'CHANGE_ME_MANAGER_PASSWORD';
CREATE USER daxxstaff WITH PASSWORD 'CHANGE_ME_STAFF_PASSWORD';

-- Asignamos los usuarios a los grupos
GRANT grup_gerencia TO daxxmanager;
GRANT grup_atencio TO daxxstaff;




