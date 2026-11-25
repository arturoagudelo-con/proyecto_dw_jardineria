CREATE OR REPLACE VIEW vista_pedido AS
SELECT DISTINCT
    ID_pedido,
    fecha_pedido,
    fecha_esperada,
    fecha_entrega,
    UPPER(TRIM(estado)) AS estado,
    UPPER(TRIM(COALESCE(NULLIF(comentarios, ''), 'SIN COMENTARIO'))) AS comentarios,
    ID_cliente,
    CASE 
        WHEN UPPER(TRIM(estado)) = 'ENTREGADO' AND fecha_entrega <= fecha_esperada THEN 'A TIEMPO'
        WHEN UPPER(TRIM(estado)) = 'ENTREGADO' AND fecha_entrega > fecha_esperada THEN 'CON RETRASO'
        WHEN UPPER(TRIM(estado)) = 'ENTREGADO' AND fecha_entrega IS NULL THEN 'ENTREGADO SIN FECHA'
        WHEN UPPER(TRIM(estado)) = 'PENDIENTE' THEN 'EN PROCESO'
        ELSE 'CANCELADO / RECHAZADO'
    END AS clasificacion_estado,
    DATEDIFF(fecha_entrega, fecha_pedido) AS dias_entrega
FROM stg_pedido;