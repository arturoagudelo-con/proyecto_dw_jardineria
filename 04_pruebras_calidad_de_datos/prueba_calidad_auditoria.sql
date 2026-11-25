SELECT '1. Total_clientes' AS metrica,
 (SELECT COUNT(*) FROM jardineria.cliente) AS origen,
 (SELECT COUNT(*) FROM staging_jardineria.stg_cliente) AS staging,
 (SELECT COUNT(*) FROM dw_jardineria.dim_cliente) AS data_mart
 UNION ALL
 SELECT '2. Total_productos',
 (SELECT COUNT(*) FROM jardineria.producto) AS origen,
 (SELECT COUNT(*) FROM staging_jardineria.stg_producto) AS staging,
 (SELECT COUNT(*) FROM dw_jardineria.dim_producto) AS data_mart
 UNION ALL
 SELECT'3_total_pedidos',
 (SELECT COUNT(*) FROM jardineria.pedido) AS origen,
 (SELECT COUNT(DISTINCT ID_pedido) FROM staging_jardineria.stg_pedido_detalle) AS staging,
 (SELECT COUNT(*) FROM dw_jardineria.dim_pedido) AS data_mart
 UNION ALL
 SELECT '4. Lineas de venta',
 (SELECT COUNT(*) FROM jardineria.detalle_pedido) AS origen,
 (SELECT COUNT(*) FROM staging_jardineria.vista_ventas_detalle) AS staging,
 (SELECT COUNT(*) FROM dw_jardineria.hechos_jardineria WHERE tipo_registro = 'VENTA') AS data_mart
 UNION ALL
 SELECT '5 suma_ventas',
 (SELECT SUM(cantidad*precio_unidad) FROM jardineria.detalle_pedido) AS origen,
 (SELECT SUM(subtotal_venta) FROM staging_jardineria.vista_ventas_detalle) AS staging,
 (SELECT SUM(total_venta) FROM dw_jardineria.hechos_jardineria WHERE tipo_registro = 'VENTA') AS data_mart
 UNION ALL
 SELECT '6. suma Pagos',
 (SELECT SUM(total) FROM jardineria.pago),
 (SELECT SUM(total) FROM staging_jardineria.stg_pago),
 (SELECT SUM(monto_pago) FROM dw_jardineria.hechos_jardineria WHERE tipo_registro = 'PAGO');
 
 -- Pruebas de integridad en el data mart
 
 SELECT COUNT(*) AS sin_clientes
 FROM dw_jardineria.hechos_jardineria h
LEFT JOIN dw_jardineria.dim_cliente c ON h.sk_cliente = c.sk_cliente
WHERE c.sk_cliente IS NULL; 

SELECT COUNT(*) AS sin_fecha
FROM dw_jardineria.hechos_jardineria h
LEFT JOIN dw_jardineria.dim_tiempo t ON h.sk_tiempo = t.sk_tiempo
WHERE t.sk_tiempo IS NULL;

-- IDENTIFICACION DE INCONSISTENCIAS
SELECT
ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, clasificacion_estado
FROM dw_jardineria.dim_pedido
WHERE clasificacion_estado IN ('FECHA_IMPOSIBLE', 'ENTREGADO SIN FECHA');

-- PRUEBAS DE COMPLETITUD
SELECT
SUM(CASE WHEN region IS NULL OR region = '' THEN 1 ELSE 0 END) AS region_vacia,
SUM(CASE WHEN pais IS NULL OR pais = '' THEN 1 ELSE 0 END) AS pais_vacia,
SUM(CASE WHEN seg_credito IS NULL THEN 1 ELSE 0 END) AS segmentos_nulos
FROM dw_jardineria.dim_cliente;