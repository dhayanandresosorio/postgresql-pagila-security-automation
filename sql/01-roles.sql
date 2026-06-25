-- Eliminar usuarios y roles si ya existen
DROP ROLE IF EXISTS daxxmanager;
DROP ROLE IF EXISTS daxxstaff;
DROP ROLE IF EXISTS grup_gerencia;
DROP ROLE IF EXISTS grup_atencio;

-- Crear roles de grupo sin login
CREATE ROLE grup_gerencia NOLOGIN;
CREATE ROLE grup_atencio NOLOGIN;

-- Crear usuarios de laboratorio con passwords placeholder
CREATE USER daxxmanager WITH PASSWORD 'CHANGE_ME_MANAGER_PASSWORD';
CREATE USER daxxstaff WITH PASSWORD 'CHANGE_ME_STAFF_PASSWORD';

-- Asignar usuarios a sus grupos
GRANT grup_gerencia TO daxxmanager;
GRANT grup_atencio TO daxxstaff;
