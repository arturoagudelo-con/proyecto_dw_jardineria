CREATE DATABASE bodega_jardineria;
USE bodega_jardineria;

CREATE TABLE dim_producto(
	id_producto VARCHAR(50) PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL
    
);

CREATE TABLE dim_tiempo(
	id_tiempo INT PRIMARY KEY,
    fecha DATE NOT NULL,
    anio INT NOT NULL,
    mes INT NOT NULL,
    DIA INT NOT NULL,
    trimestre INT NOT NULL
);

CREATE TABLE hechos_venta(
	id_secuencia INT AUTO_INCREMENT PRIMARY KEY,
    id_producto VARCHAR(50),
    id_tiempo INT,
    cantidad INT NOT NULL,
    total_monto DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES dim_producto(id_producto),
    FOREIGN KEY (id_tiempo) REFERENCES dim_tiempo(id_tiempo)
    );
    
    INSERT INTO bodega_jardineria.dim_producto(id_producto, nombre_producto, categoria, precio_unitario)
    SELECT 
    codigo_producto,
    nombre,
    Categoria,
    precio_venta
    FROM jardineria.producto;
    
    INSERT IGNORE INTO bodega_jardineria.dim_tiempo
    SELECT DISTINCT 
		YEAR(fecha_pedido)*10000 + MONTH(fecha_pedido)*100 + DAY(fecha_pedido),
        fecha_pedido,
        YEAR(fecha_pedido),
        MONTH(fecha_pedido),
        DAY(fecha_pedido),
        QUARTER(fecha_pedido)
        FROM jardineria.pedido
        WHERE fecha_pedido IS NOT NULL;
      
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE hechos_venta;

	INSERT INTO bodega_jardineria.hechos_venta(id_producto, id_tiempo, cantidad, total_monto)
    SELECT 
    dp.id_producto,
    YEAR(p.fecha_pedido)*10000 + MONTH(p.fecha_pedido)*100 + DAY(p.fecha_pedido),
    dp.cantidad,
    (dp.cantidad * dp.precio_unidad)
    FROM jardineria.detalle_pedido dp
    JOIN jardineria.pedido p ON dp.id_pedido = p.id_pedido;
    
    SET FOREIGN_KEY_CHECKS = 1;
    
    SELECT 
    t.anio AS 'Año Con Más Ventas', 
    SUM(v.total_monto) AS 'Total Recaudado ($)'
FROM hechos_venta v
JOIN dim_tiempo t ON v.id_tiempo = t.id_tiempo
GROUP BY t.anio
ORDER BY SUM(v.total_monto) DESC
LIMIT 1;

SELECT 
    COALESCE(p.nombre_producto, v.id_producto) AS 'Producto Más Vendido', 
    SUM(v.cantidad) AS 'Total Unidades Vendidas'
FROM hechos_venta v
LEFT JOIN dim_producto p ON TRIM(v.id_producto) = TRIM(p.id_producto)
GROUP BY v.id_producto, p.nombre_producto
ORDER BY SUM(v.cantidad) DESC
LIMIT 1;

SELECT 
    categoria AS 'Categoría Con Más Productos', 
    COUNT(id_producto) AS 'Cantidad de Productos Disponibles'
FROM dim_producto
GROUP BY categoria
ORDER BY COUNT(id_producto) DESC
LIMIT 1;