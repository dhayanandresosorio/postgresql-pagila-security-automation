DROP VIEW IF EXISTS vista_inventario;

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
JOIN inventory i
    ON f.film_id = i.film_id
GROUP BY
    f.title,
    i.store_id
ORDER BY
    f.title,
    i.store_id;

GRANT SELECT ON vista_inventario TO grup_atencio;
GRANT SELECT ON vista_inventario TO grup_gerencia;
