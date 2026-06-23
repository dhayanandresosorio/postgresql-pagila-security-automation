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
