CREATE OR REPLACE VIEW vista_pago AS
SELECT 
    ID_cliente,
    UPPER(TRIM(forma_pago)) AS forma_pago,
    UPPER(TRIM(id_transaccion)) AS id_transaccion,
    fecha_pago,
    COALESCE(total, 0.00) AS total,
    CASE 
        WHEN total > 0 THEN 'PAGO CONFIRMADO'
        ELSE 'PAGO ANULADO'
    END AS estado_pago
FROM stg_pago;