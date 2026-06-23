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
