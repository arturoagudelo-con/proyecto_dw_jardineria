CREATE DATABASE IF NOT EXISTS staging_jardineria
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE staging_jardineria;

DROP TABLE staging_cliente;

CREATE TABLE `staging_cliente` (
  `ID_cliente` int  NOT NULL ,
  `nombre_cliente` varchar(50)  NULL,
  `nombre_contacto` varchar(30) DEFAULT NULL,
  `apellido_contacto` varchar(30) DEFAULT NULL,
  `ciudad` varchar(50)  NULL,
  `region` varchar(50) DEFAULT NULL,
  `pais` varchar(50) DEFAULT NULL,
  `ID_empleado_rep_ventas` int DEFAULT NULL,
  `limite_credito` decimal(15,2) DEFAULT NULL,
  
  stg_fecha_carga datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`ID_cliente`)
  
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


TRUNCATE TABLE staging_jardineria.staging_cliente;

INSERT INTO staging_jardineria.staging_cliente (
ID_cliente ,nombre_cliente , nombre_contacto, apellido_contacto ,
  ciudad, region, pais,  ID_empleado_rep_ventas, limite_credito
) SELECT 
ID_cliente ,
nombre_cliente ,nombre_contacto,apellido_contacto ,
ciudad,region,pais,ID_empleado_rep_ventas,limite_credito FROM jardineria.cliente;
  
  SELECT * FROM staging_cliente;
  

  
  UPDATE staging_cliente
  SET apellido_contacto = REPLACE(apellido_contacto, "MuÃ±oz", "Muñoz") 
  WHERE  apellido_contacto LIKE "%MuÃ±oz%";
  
  UPDATE staging_cliente
  SET pais = REPLACE(pais, "Spain", "España")
  WHERE pais LIKE "%Spain%";
  
  SELECT "cliente" AS tabla, COUNT(*) AS total_filas FROM staging_jardineria.staging_cliente;
 SELECT "ciudad" AS columna, COUNT(DISTINCT ciudad) AS total FROM staging_jardineria.staging_cliente;
  SELECT "region" AS columna, COUNT(DISTINCT region) AS total FROM staging_jardineria.staging_cliente;
  SELECT "pais" AS columna, COUNT(DISTINCT pais) AS total FROM staging_jardineria.staging_cliente;
  SELECT COUNT(*) FROM staging_jardineria.staging_cliente WHERE nombre_cliente IS NULL;
  SELECT "id_empleado" AS tabla, COUNT(*) AS total_filas FROM staging_jardineria.staging_cliente;
  
  SELECT pais, COUNT(*) AS cantidad_cliente
FROM staging_jardineria.staging_cliente
GROUP BY pais
ORDER BY cantidad_cliente