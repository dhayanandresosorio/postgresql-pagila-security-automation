-- Corregir la funcion get_customer_balance incluida en Pagila.
-- La version original usa IF(), que es sintaxis de MySQL. En PostgreSQL se usa CASE WHEN.
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
    -- Calcular el coste de los alquileres anteriores
    SELECT COALESCE(SUM(f.rental_rate), 0)
    INTO v_rentfees
    FROM film f
    JOIN inventory i
        ON f.film_id = i.film_id
    JOIN rental r
        ON i.inventory_id = r.inventory_id
    WHERE r.rental_date <= p_effective_date
      AND r.customer_id = p_customer_id;

    -- Calcular los dias de retraso
    SELECT COALESCE(SUM(
        CASE
            WHEN r.return_date IS NOT NULL
             AND (r.return_date::date - r.rental_date::date) > f.rental_duration
            THEN ((r.return_date::date - r.rental_date::date) - f.rental_duration)::numeric
            ELSE 0::numeric
        END
    ), 0)
    INTO v_overfees
    FROM rental r
    JOIN inventory i
        ON i.inventory_id = r.inventory_id
    JOIN film f
        ON f.film_id = i.film_id
    WHERE r.rental_date <= p_effective_date
      AND r.customer_id = p_customer_id;

    -- Calcular pagos realizados por el cliente
    SELECT COALESCE(SUM(p.amount), 0)
    INTO v_payments
    FROM payment p
    WHERE p.payment_date <= p_effective_date
      AND p.customer_id = p_customer_id;

    RETURN v_rentfees + v_overfees - v_payments;
END;
$function$;

-- Eliminar trigger y funcion si ya existen
DROP TRIGGER IF EXISTS trigger_comprobar_alquiler ON rental;
DROP FUNCTION IF EXISTS comprobar_alquiler();

-- Funcion del trigger que impide alquileres si hay deuda o alquileres antiguos pendientes
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

-- Crear trigger antes de insertar un alquiler
CREATE TRIGGER trigger_comprobar_alquiler
BEFORE INSERT ON rental
FOR EACH ROW
EXECUTE FUNCTION comprobar_alquiler();
