USE staging_jardineria;

CREATE TABLE `staging_producto` (
  `ID_producto` varchar(15) NOT NULL,
  `nombre` varchar(70)  NULL,
  `Categoria` int  NULL,
  `dimensiones` varchar(25) DEFAULT NULL,
  `proveedor` varchar(50) DEFAULT NULL,
  `descripcion` text,
  `cantidad_en_stock` smallint  NULL,
  `precio_venta` decimal(15,2)  NULL,
  `precio_proveedor` decimal(15,2) DEFAULT NULL,
  
   stg_fecha_carga datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`ID_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

TRUNCATE TABLE staging_jardineria.staging_producto;

INSERT INTO staging_jardineria.staging_producto(
ID_producto,
  nombre,
  Categoria,
  dimensiones,
  proveedor,
  descripcion ,
  cantidad_en_stock,
  precio_venta,
  precio_proveedor
) SELECT
ID_producto,
  nombre,
  Categoria,
  dimensiones,
  proveedor,
  descripcion ,
  cantidad_en_stock,
  precio_venta,
  precio_proveedor
  FROM jardineria.producto;
  
  SELECT * FROM producto;

DESCRIBE staging_producto;

SHOW COLUMNS FROM staging_producto;


UPDATE staging_producto 
SET dimensiones_decimal = CASE 
    WHEN REPLACE(SUBSTRING_INDEX(dimensiones, '-', 1), ',', '.') REGEXP '^[0-9]+(\.[0-9]+)?$' 
    THEN CAST(REPLACE(SUBSTRING_INDEX(dimensiones, '-', 1), ',', '.') AS DECIMAL(15,2))
    ELSE NULL 
END;

SELECT dimensiones, dimensiones_decimal FROM staging_producto;

UPDATE staging_producto
SET dimensiones_decimal = 0.00
WHERE dimensiones_decimal IS NULL;


ALTER TABLE producto DROP COLUMN dimensiones;
ALTER TABLE producto RENAME COLUMN dimensiones_decimal TO dimensiones;
SELECT Categoria AS id_categoria, COUNT(*) AS conteo  
FROM jardineria.producto
GROUP BY Categoria;

SELECT nombre , COUNT(*) AS conteo  
FROM staging_jardineria.staging_producto
GROUP BY nombre
ORDER BY conteo DESC;

SELECT "proveedor" columna, COUNT(DISTINCT proveedor) AS total FROM staging_jardineria.staging_producto;
SELECT "ID_prducto" columna, COUNT(DISTINCT ID_producto) AS total FROM staging_jardineria.staging_producto;

SELECT nombre,  SUM(cantidad_en_stock) AS total_general
FROM staging_jardineria.staging_producto
GROUP BY nombre
ORDER BY total_general ASC;

SELECT nombre, precio_proveedor, precio_venta, SUM(cantidad_en_stock) AS total
FROM staging_jardineria.staging_producto
WHERE precio_venta < precio_proveedor
GROUP BY nombre, precio_proveedor, precio_venta
ORDER BY total DESC;
  
  SELECT * FROM staging_producto;



