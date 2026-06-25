-- Remove users and roles if they already exist
DROP ROLE IF EXISTS daxxmanager;
DROP ROLE IF EXISTS daxxstaff;
DROP ROLE IF EXISTS grup_gerencia;
DROP ROLE IF EXISTS grup_atencio;

-- Create group roles without login
CREATE ROLE grup_gerencia NOLOGIN;
CREATE ROLE grup_atencio NOLOGIN;

-- Create lab users with placeholder passwords
CREATE USER daxxmanager WITH PASSWORD 'CHANGE_ME_MANAGER_PASSWORD';
CREATE USER daxxstaff WITH PASSWORD 'CHANGE_ME_STAFF_PASSWORD';

-- Assign users to their groups
GRANT grup_gerencia TO daxxmanager;
GRANT grup_atencio TO daxxstaff;
