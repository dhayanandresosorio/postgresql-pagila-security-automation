-- Revoke general permissions
REVOKE ALL PRIVILEGES ON DATABASE pagila FROM public;
REVOKE ALL PRIVILEGES ON SCHEMA public FROM public;

-- Allow connection to the database
GRANT CONNECT ON DATABASE pagila TO grup_gerencia;
GRANT CONNECT ON DATABASE pagila TO grup_atencio;

-- Allow usage of the public schema
GRANT USAGE ON SCHEMA public TO grup_gerencia;
GRANT USAGE ON SCHEMA public TO grup_atencio;

-- Management permissions
GRANT SELECT, INSERT, UPDATE ON TABLE film TO grup_gerencia;
GRANT SELECT, INSERT, UPDATE ON TABLE inventory TO grup_gerencia;
GRANT SELECT, INSERT, UPDATE ON TABLE rental TO grup_gerencia;

-- Staff read permissions
GRANT SELECT ON TABLE film TO grup_atencio;
GRANT SELECT ON TABLE inventory TO grup_atencio;

-- Staff rental permissions
GRANT SELECT, INSERT ON TABLE rental TO grup_atencio;
GRANT UPDATE (return_date, last_update) ON TABLE rental TO grup_atencio;

-- Sequence permissions
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO grup_gerencia;
GRANT USAGE, SELECT ON SEQUENCE rental_rental_id_seq TO grup_atencio;
