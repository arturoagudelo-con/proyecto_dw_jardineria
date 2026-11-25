USE staging_jardineria;

DROP TABLE IF EXISTS staging_pago;

CREATE TABLE `staging_pago` (
  `ID_cliente` int NOT NULL,
  `forma_pago` varchar(40)  NULL,
  `id_transaccion` varchar(50) NOT NULL,
  `fecha_pago` date  NULL,
  `total` decimal(15,2)  NULL,
  
  stg_fecha_carga datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`id_transaccion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

TRUNCATE TABLE staging_pago;

INSERT INTO staging_pago(
ID_cliente,forma_pago,id_transaccion,fecha_pago,total
) SELECT
ID_cliente,forma_pago,id_transaccion,fecha_pago,total
  FROM jardineria.pago;
  
SELECT DISTINCT forma_pago FROM staging_jardineria.staging_pago;

SELECT "forma pago" AS COLUMNA, COUNT(DISTINCT forma_pago) FROM staging_jardineria.staging_pago;

SELECT DISTINCT forma_pago ,COUNT(forma_pago) AS cantidad FROM staging_jardineria.staging_pago
GROUP BY forma_pago;

SELECT SUM(total) AS total_general FROM staging_jardineria.staging_pago;
SELECT * FROM pago;
  
  SELECT * FROM staging_pago;
