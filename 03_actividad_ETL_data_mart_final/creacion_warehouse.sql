DROP DATABASE IF EXISTS dw_jardineria;
CREATE DATABASE dw_jardineria CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE dw_jardineria;
SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;



CREATE TABLE dim_cliente (
  sk_cliente INT AUTO_INCREMENT PRIMARY KEY,
  ID_cliente INT NOT NULL UNIQUE,
  nombre_cliente VARCHAR(50),
  nombre_contacto VARCHAR(30),
  apellido_contacto VARCHAR(30),
  contacto_completo VARCHAR(70),
  ciudad VARCHAR(50),
  region VARCHAR(50),
  pais VARCHAR(50),
  ID_empleado_rep_ventas INT,
  limite_credito DECIMAL(15,2),
  seg_credito VARCHAR(20),
  fecha_carga_dw DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE dim_producto (
  sk_producto INT AUTO_INCREMENT PRIMARY KEY,
  ID_producto VARCHAR(15) NOT NULL UNIQUE,
  nombre_producto VARCHAR(70),
  Categoria INT,
  dimensiones VARCHAR(25),
  proveedor VARCHAR(50),
  descripcion TEXT,
  cantidad_en_stock SMALLINT,
  precio_venta DECIMAL(15,2),
  precio_proveedor DECIMAL(15,2),
  margen_ganancia DECIMAL(15,2),
  porcentaje_margen DECIMAL(15,2),
  estado_stock VARCHAR(30),
  fecha_carga_dw DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE dim_pedido (
  sk_pedido INT AUTO_INCREMENT PRIMARY KEY,
  ID_pedido INT NOT NULL UNIQUE,
  fecha_pedido DATE,
  fecha_esperada DATE,
  fecha_entrega DATE NULL,
  estado VARCHAR(20),
  comentarios TEXT,
  clasificacion_estado VARCHAR(30),
  fecha_carga_dw DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE dim_pago (
  sk_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_transaccion VARCHAR(50) NOT NULL UNIQUE,
  forma_pago VARCHAR(40),
  fecha_pago DATE,
  estado_pago VARCHAR(30),
  fecha_carga_dw DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE dim_tiempo (
  sk_tiempo INT PRIMARY KEY,
  fecha DATE NOT NULL UNIQUE,
  anio INT,
  trimestre INT,
  mes INT,
  nombre_mes VARCHAR(15),
  dia INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



CREATE TABLE hechos_jardineria (
  id_hecho INT AUTO_INCREMENT PRIMARY KEY,
  sk_cliente INT NOT NULL,
  sk_pedido INT NULL,
  sk_pago INT NULL,
  sk_tiempo INT NOT NULL,
  monto_pago DECIMAL(15,2) DEFAULT 0.00,
  dias_entrega INT NULL,
  cantidad_operaciones INT DEFAULT 1,
  fecha_carga_dw DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hecho_cliente FOREIGN KEY (sk_cliente) REFERENCES dim_cliente(sk_cliente),
  CONSTRAINT fk_hecho_pedido FOREIGN KEY (sk_pedido) REFERENCES dim_pedido(sk_pedido),
  CONSTRAINT fk_hecho_pago FOREIGN KEY (sk_pago) REFERENCES dim_pago(sk_pago),
  CONSTRAINT fk_hecho_tiempo FOREIGN KEY (sk_tiempo) REFERENCES dim_tiempo(sk_tiempo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO dim_cliente (ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, contacto_completo, ciudad, region, pais, ID_empleado_rep_ventas, limite_credito, seg_credito)
SELECT ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, contacto_completo, ciudad, region, pais, ID_empleado_rep_ventas, limite_credito, seg_credito
FROM staging_jardineria.vista_cliente;

INSERT INTO dim_producto (ID_producto, nombre_producto, Categoria, dimensiones, proveedor, descripcion, cantidad_en_stock, precio_venta, precio_proveedor, margen_ganancia, porcentaje_margen, estado_stock)
SELECT ID_producto, nombre_producto, Categoria, dimensiones, proveedor, descripcion, cantidad_en_stock, precio_venta, precio_proveedor, margen_ganancia, porcentaje_margen, estado_stock
FROM staging_jardineria.vista_producto;

INSERT INTO dim_pedido (ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, clasificacion_estado)
SELECT ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, clasificacion_estado
FROM staging_jardineria.vista_pedido;

INSERT INTO dim_pago (id_transaccion, forma_pago, fecha_pago, estado_pago)
SELECT id_transaccion, forma_pago, fecha_pago, estado_pago
FROM staging_jardineria.vista_pago;

SET lc_time_names = 'es_ES';
INSERT IGNORE INTO dim_tiempo (sk_tiempo, fecha, anio, trimestre, mes, nombre_mes, dia)
SELECT DISTINCT 
    DATE_FORMAT(fecha, '%Y%m%d'),
    fecha,
    YEAR(fecha),
    QUARTER(fecha),
    MONTH(fecha),
    UPPER(MONTHNAME(fecha)),
    DAY(fecha)
FROM (
    SELECT fecha_pago AS fecha FROM staging_jardineria.vista_pago WHERE fecha_pago IS NOT NULL
    UNION
    SELECT fecha_pedido AS fecha FROM staging_jardineria.vista_pedido WHERE fecha_pedido IS NOT NULL
) fechas;


INSERT INTO hechos_jardineria (sk_cliente, sk_pago, sk_tiempo, monto_pago, cantidad_operaciones)
SELECT 
    dc.sk_cliente,
    dp.sk_pago,
    DATE_FORMAT(vp.fecha_pago, '%Y%m%d'),
    vp.total,
    1
FROM staging_jardineria.vista_pago vp
INNER JOIN dim_cliente dc ON vp.ID_cliente = dc.ID_cliente
INNER JOIN dim_pago dp ON vp.id_transaccion = dp.id_transaccion;

INSERT INTO hechos_jardineria (sk_cliente, sk_pedido, sk_tiempo, dias_entrega, cantidad_operaciones)
SELECT 
    dc.sk_cliente,
    dped.sk_pedido,
    DATE_FORMAT(vped.fecha_pedido, '%Y%m%d'),
    vped.dias_entrega,
    1
FROM staging_jardineria.vista_pedido vped
INNER JOIN dim_cliente dc ON vped.ID_cliente = dc.ID_cliente
INNER JOIN dim_pedido dped ON vped.ID_pedido = dped.ID_pedido;