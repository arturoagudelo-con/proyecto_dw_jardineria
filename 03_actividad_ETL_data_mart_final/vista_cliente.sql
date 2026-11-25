CREATE OR REPLACE VIEW vista_cliente AS
SELECT 
    ID_cliente,
    UPPER(TRIM(nombre_cliente)) AS nombre_cliente,
    UPPER(TRIM(COALESCE(nombre_contacto, 'SIN CONTACTO'))) AS nombre_contacto,
    UPPER(TRIM(COALESCE(apellido_contacto, ''))) AS apellido_contacto,
    UPPER(TRIM(CONCAT(COALESCE(nombre_contacto, ''), ' ', COALESCE(apellido_contacto, '')))) AS contacto_completo,
    UPPER(TRIM(ciudad)) AS ciudad,
    UPPER(TRIM(COALESCE(NULLIF(region, ''), 'SIN REGION'))) AS region,
    CASE 
        WHEN UPPER(TRIM(pais)) = 'SPAIN' THEN 'ESPAÑA'
        WHEN UPPER(TRIM(pais)) = 'USA' THEN 'ESTADOS UNIDOS'
        ELSE UPPER(TRIM(COALESCE(pais, 'NO ESPECIFICADO')))
    END AS pais,
    ID_empleado_rep_ventas,
    COALESCE(limite_credito, 0.00) AS limite_credito,
    CASE 
        WHEN limite_credito >= 50000 THEN 'ALTO'
        WHEN limite_credito >= 10000 THEN 'MEDIO'
        ELSE 'BAJO'
    END AS seg_credito
FROM stg_cliente;