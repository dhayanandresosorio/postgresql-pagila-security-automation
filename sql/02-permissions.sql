-- Revocar permisos generales para evitar accesos innecesarios
REVOKE ALL PRIVILEGES ON DATABASE pagila FROM public;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM public;

-- Permiso de conexion a la base de datos
GRANT CONNECT ON DATABASE pagila TO grup_gerencia;
GRANT CONNECT ON DATABASE pagila TO grup_atencio;

-- Permiso de uso sobre el esquema public
GRANT USAGE ON SCHEMA public TO grup_gerencia;
GRANT USAGE ON SCHEMA public TO grup_atencio;

-- Permisos para gerencia: consulta y modificacion sobre tablas clave
GRANT SELECT, INSERT, UPDATE ON TABLE film TO grup_gerencia;
GRANT SELECT, INSERT, UPDATE ON TABLE inventory TO grup_gerencia;
GRANT SELECT, INSERT, UPDATE ON TABLE rental TO grup_gerencia;

-- Permisos para atencion: consulta de peliculas e inventario
GRANT SELECT ON TABLE film TO grup_atencio;
GRANT SELECT ON TABLE inventory TO grup_atencio;

-- Atencion puede consultar, crear alquileres y marcar devoluciones
GRANT SELECT, INSERT ON TABLE rental TO grup_atencio;
GRANT UPDATE (return_date, last_update) ON TABLE rental TO grup_atencio;

-- Permisos sobre secuencias necesarias para inserciones
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO grup_gerencia;
GRANT USAGE, SELECT ON SEQUENCE rental_rental_id_seq TO grup_atencio;
