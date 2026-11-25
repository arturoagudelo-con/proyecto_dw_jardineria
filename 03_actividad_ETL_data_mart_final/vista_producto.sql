CREATE OR REPLACE VIEW vista_producto AS
SELECT 
    ID_producto,
    UPPER(TRIM(nombre)) AS nombre_producto,
    Categoria,
    UPPER(TRIM(COALESCE(NULLIF(dimensiones, ''), 'NO ESPECIFICADA'))) AS dimensiones,
    UPPER(TRIM(COALESCE(NULLIF(proveedor, ''), 'SIN PROVEEDOR'))) AS proveedor,
    COALESCE(NULLIF(TRIM(descripcion), ''), 'SIN DATOS') AS descripcion,
    COALESCE(cantidad_en_stock, 0) AS cantidad_en_stock,
    COALESCE(precio_venta, 0.00) AS precio_venta,
    COALESCE(precio_proveedor, 0.00) AS precio_proveedor,
    (precio_venta - COALESCE(precio_proveedor, 0.00)) AS margen_ganancia,
    CASE 
        WHEN precio_venta > 0 THEN ROUND(((precio_venta - COALESCE(precio_proveedor, 0.00)) / precio_venta) * 100, 2)
        ELSE 0.00
    END AS porcentaje_margen,
    CASE 
        WHEN cantidad_en_stock = 0 THEN 'AGOTADO'
        WHEN cantidad_en_stock <= 15 THEN 'STOCK BAJO'
        ELSE 'DISPONIBLE'
    END AS estado_stock
FROM stg_producto;