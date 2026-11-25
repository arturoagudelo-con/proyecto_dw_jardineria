USE staging_jardineria;

DROP TABLE staging_pedido;

CREATE TABLE `staging_pedido` (
  `ID_pedido` int NOT NULL ,
  `fecha_pedido` date  NULL,
  `fecha_esperada` date  NULL,
  `fecha_entrega` date DEFAULT NULL,
  `estado` varchar(15) NULL,
  `comentarios` text,
  `ID_cliente` int  NULL,
  `ID_producto` varchar(15) NULL,
  `cantidad` int NULL,
  `precio_unidad` decimal(15,2) NULL,
  
  stg_fecha_carga datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
  
  
  
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

TRUNCATE TABLE staging_pedido;

INSERT INTO staging_pedido(
    ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, ID_cliente,
    ID_producto, cantidad, precio_unidad
)
SELECT
    p.ID_pedido, p.fecha_pedido, p.fecha_esperada, p.fecha_entrega, p.estado, p.comentarios, p.ID_cliente,
    d.ID_producto, d.cantidad, d.precio_unidad
FROM jardineria.pedido p
INNER JOIN jardineria.detalle_pedido d 
ON p.ID_pedido = d.ID_pedido;

DESCRIBE staging_pedido;
SHOW COLUMNS FROM staging_pedido;

SELECT COUNT(*) FROM staging_jardineria.staging_pedido WHERE fecha_pedido IS NULL;
SELECT COUNT(*) FROM staging_jardineria.staging_pedido WHERE fecha_esperada IS NULL;
SELECT COUNT(*) FROM staging_jardineria.staging_pedido WHERE fecha_entrega IS NULL;
SELECT "estado" AS columna, COUNT(DISTINCT estado) AS total FROM staging_jardineria.staging_pedido;

SELECT estado, COUNT(*) AS cantidad
FROM staging_jardineria.staging_pedido
GROUP BY estado
ORDER BY cantidaD DESC;

SELECT * FROM staging_pedido;