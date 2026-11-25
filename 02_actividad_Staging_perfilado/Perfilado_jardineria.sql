USE jardineria;

SELECT region, count(*) AS cantidad
FROM jardineria.cliente
GROUP BY region;

SELECT count(*),
count(distinct region)
FROM jardineria.cliente;

SELECT MIN(total), MAX(total), AVG(total), SUM(total<=0)
FROM jardineria.pago;

SELECT id_categoria, COUNT(*) AS conteo_categoria
FROM jardineria.Categoria_producto
GROUP BY Id_Categoria
ORDER BY Id_Categoria DESC;

-- Perfilado de la tabla por la tabla cliente

DESCRIBE cliente;
SHOW COLUMNS FROM cliente;

SELECT "cliente" AS tabla, COUNT(*) AS total_filas FROM jardineria.cliente;
SELECT "ciudad" AS columna, COUNT(DISTINCT ciudad) AS total FROM jardineria.cliente;
SELECT "region" AS columna, COUNT(DISTINCT region) AS total FROM jardineria.cliente;
SELECT "pais" AS columna, COUNT(DISTINCT pais) AS total FROM jardineria.cliente;
SELECT COUNT(*) FROM jardineria.cliente WHERE nombre_cliente IS NULL;
SELECT "id_empleado" AS tabla, COUNT(*) AS total_filas FROM jardineria.cliente;

SELECT pais, COUNT(*) AS cantidad_cliente
FROM jardineria.cliente
GROUP BY pais
ORDER BY cantidad_cliente;

-- Perfilado por la tabla pedido

SELECT * FROM pedido;

DESCRIBE pedido;
SHOW COLUMNS FROM pedido;

SELECT COUNT(*) FROM jardineria.pedido WHERE fecha_pedido IS NULL;
SELECT COUNT(*) FROM jardineria.pedido WHERE fecha_esperada IS NULL;
SELECT COUNT(*) FROM jardineria.pedido WHERE fecha_entrega IS NULL;
SELECT "estado" AS columna, COUNT(DISTINCT estado) AS total FROM jardineria.pedido;

SELECT estado, COUNT(*) AS cantidad
FROM jardineria.pedido
GROUP BY estado
ORDER BY cantidaD DESC;

-- Perfilado de datos producto

SELECT * FROM producto;

DESCRIBE producto;

SHOW COLUMNS FROM producto;

START TRANSACTION;
UPDATE producto 
SET dimensiones_decimal = CASE 
    WHEN REPLACE(SUBSTRING_INDEX(dimensiones, '-', 1), ',', '.') REGEXP '^[0-9]+(\.[0-9]+)?$' 
    THEN CAST(REPLACE(SUBSTRING_INDEX(dimensiones, '-', 1), ',', '.') AS DECIMAL(15,2))
    ELSE NULL 
END;

SELECT dimensiones, dimensiones_decimal FROM producto;

UPDATE producto
SET dimensiones_decimal = 0.00
WHERE dimensiones_decimal IS NULL;


ALTER TABLE producto DROP COLUMN dimensiones;
ALTER TABLE producto RENAME COLUMN dimensiones_decimal TO dimensiones;
SELECT Categoria AS id_categoria, COUNT(*) AS conteo  
FROM jardineria.producto
GROUP BY Categoria;

SELECT nombre , COUNT(*) AS conteo  
FROM jardineria.producto
GROUP BY nombre
ORDER BY conteo DESC;

SELECT "proveedor" columna, COUNT(DISTINCT proveedor) AS total FROM jardineria.producto;
SELECT "ID_prducto" columna, COUNT(DISTINCT ID_producto) AS total FROM jardineria.producto;

SELECT nombre,  SUM(cantidad_en_stock) AS total_general
FROM jardineria.producto
GROUP BY nombre
ORDER BY total_general ASC;

SELECT nombre, precio_proveedor, precio_venta, SUM(cantidad_en_stock) AS total
FROM jardineria.producto
WHERE precio_venta < precio_proveedor
GROUP BY nombre, precio_proveedor, precio_venta
ORDER BY total DESC;

-- perfilado tabla de pago
SELECT DISTINCT forma_pago FROM jardineria.pago;
SELECT "forma pago" AS COLUMNA, COUNT(DISTINCT forma_pago) FROM jardineria.pago;
SELECT DISTINCT forma_pago ,COUNT(forma_pago) AS cantidad FROM jardineria.pago
GROUP BY forma_pago;
SELECT SUM(total) AS total_general FROM jardineria.pago;
SELECT * FROM pago;