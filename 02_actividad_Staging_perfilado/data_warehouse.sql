-- aqui se creo la base de datos warehouse para poder tener nuestra bodega y asi poder depositar nuestros datos limpios
-- con las vistas que hicimos anteriormente.
CREATE DATABASE IF NOT EXISTS dw_jardineria
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE dw_jardineria;
-- creamos nuestra primera tabla de dimension la cual es cliente, esta contiene los mismos campos de la tabla 
-- staging cliente, para poder hacer una migracion de los datos identicas para no perder ningun dato
-- aunque se le agrego un columna con una llave primaria para incrementar por cada fila,
-- le especificamos que la unica llave primaria va hacer ID_cliente.
CREATE TABLE IF NOT EXISTS dim_cliente (
  sk_cliente int AUTO_INCREMENT PRIMARY KEY,	
  ID_cliente int NOT NULL,
  nombre_cliente varchar(50) ,
  nombre_contacto varchar(30) ,
  apellido_contacto varchar(30) ,
  contacto_completo varchar(50),
  ciudad varchar(50) ,
  region varchar(50) ,
  pais varchar(50) ,
  ID_empleado_rep_ventas int ,
  limite_credito decimal(15,2),
  seg_credito VARCHAR(20),
  fecha_carga_dw datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_id_cliente (ID_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- aqui se hace la migracion de los datos de staging_jardineria, de la tabla staging_cliente a traves de la vista cliente
-- a nuestra tabla dim_cliente ya que con la vista los datos quedaron transformados. 
INSERT INTO dw_jardineria.dim_cliente(
	 ID_cliente,
    nombre_cliente,
    nombre_contacto,
    apellido_contacto,
    contacto_completo,
    ciudad,
    region,
    pais,
    ID_empleado_rep_ventas,
    limite_credito,
    seg_credito
) 
SELECT 
    ID_cliente,
    nombre_cliente,
    nombre_contacto,
    apellido_contacto,
    contacto_completo,
    ciudad,
    region,
    pais,
    ID_empleado_rep_ventas,
    limite_credito,
    seg_credito
FROM staging_jardineria.vista_cliente;

SELECT * FROM dw_jardineria.dim_cliente;

-- creamos nuestra primera tabla de dimension la cual es pago, esta contiene los mismos campos de la tabla 
-- staging pago, para poder hacer una migracion de los datos identicas para no perder ningun dato
-- aunque se le agrego un columna con una llave primaria para incrementar por cada fila,
-- le especificamos que la unica llave primaria va hacer id_transaccion.

CREATE TABLE IF NOT EXISTS  dim_pago (
    sk_pago int NOT NULL AUTO_INCREMENT,
  ID_cliente int DEFAULT NULL,
  forma_pago varchar(40) DEFAULT NULL,
  id_transaccion varchar(50) NOT NULL,
  fecha_pago date DEFAULT NULL,
  total decimal(15,2) DEFAULT NULL,
  estado_pago varchar(30) DEFAULT NULL,
  fecha_carga_dw  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (sk_pago),
  UNIQUE KEY uk_id_transaccion (id_transaccion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- aqui se hace la migracion de los datos de staging_jardineria, de la tabla staging_pago a traves de la vista cliente
-- a nuestra tabla dim_pago ya que con la vista los datos quedaron transformados. 

INSERT INTO dw_jardineria.dim_pago (
    ID_cliente, 
    forma_pago, 
    id_transaccion, 
    fecha_pago, 
    total, 
    estado_pago
)
SELECT 
    ID_cliente, 
    forma_pago, 
    id_transaccion, 
    fecha_pago, 
    pago, 
    estado_pago
FROM staging_jardineria.vista_pago;

SELECT * FROM dw_jardineria.dim_pago;

-- creamos nuestra primera tabla de dimension la cual es pedido, esta contiene los mismos campos de la tabla 
-- staging pedido, para poder hacer una migracion de los datos identicas para no perder ningun dato
-- aunque se le agrego un columna con una llave primaria para incrementar por cada fila.

CREATE TABLE IF NOT EXISTS  dim_pedido (
  sk_pedido int NOT NULL AUTO_INCREMENT, 	
  ID_pedido int NOT NULL,
  fecha_pedido date DEFAULT NULL,
  fecha_esperada date DEFAULT NULL,
  fecha_entrega date DEFAULT NULL,
  estado varchar(15) DEFAULT NULL,
  comentarios text,
  clasificacion_estado VARCHAR(30),
  fecha_carga_dw datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (sk_pedido)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- aqui se hace la migracion de los datos de staging_jardineria, de la tabla staging_pedido a traves de la vista cliente
-- a nuestra tabla dim_pedido ya que con la vista los datos quedaron transformados.

INSERT IGNORE INTO dw_jardineria.dim_pedido (
    ID_pedido,
    fecha_pedido,
    fecha_esperada,
    fecha_entrega,
    estado,
    comentarios,
    clasificacion_estado
)
SELECT 
    ID_pedido,
    fecha_pedido,
    fecha_esperada,
    fecha_entrega,
    estado,
    comentarios,
    clasificacion_estado
FROM staging_jardineria.vista_pedido;

SELECT * FROM dw_jardineria.dim_pedido;

-- creamos nuestra primera tabla de dimension la cual es producto, esta contiene los mismos campos de la tabla 
-- staging producto, para poder hacer una migracion de los datos identicas para no perder ningun dato
-- aunque se le agrego un columna con una llave primaria para incrementar por cada fila.

CREATE TABLE IF NOT EXISTS  dim_producto (
  sk_producto int NOT NULL AUTO_INCREMENT,	
  ID_producto varchar(15) NOT NULL,
  nombre_producto varchar(70) DEFAULT NULL,
  Categoria int DEFAULT NULL,
  dimensiones varchar(25) DEFAULT NULL,
  proveedor varchar(50) DEFAULT NULL,
  descripcion text,
  cantidad_en_stock smallint DEFAULT NULL,
  precio_venta decimal(15,2) DEFAULT NULL,
  precio_proveedor decimal(15,2) DEFAULT NULL,
  margen_ganancia decimal(15,2) DEFAULT NULL,
  porcentaje_margen decimal(15,2) DEFAULT NULL,
  estado_stock VARCHAR(30),
  fecha_carga_dw datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (sk_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- aqui se hace la migracion de los datos de staging_jardineria, de la tabla staging_producto a traves de la vista cliente
-- a nuestra tabla dim_producto ya que con la vista los datos quedaron transformados.

INSERT IGNORE INTO dw_jardineria.dim_producto (
    ID_producto,
    nombre_producto,
    Categoria,
    dimensiones,
    proveedor,
    descripcion,
    cantidad_en_stock,
    precio_venta,
    precio_proveedor,
    margen_ganancia,
    porcentaje_margen,
    estado_stock
)
SELECT DISTINCT
    ID_producto,
    nombre_producto,
    Categoria,
    dimensiones,
    proveedor,
    descripcion,
    cantidad_en_stock,
    precio_venta,
    precio_proveedor,
    margen_ganacia,
    porcentaje_margen,
    estado_stock
FROM staging_jardineria.vista_producto;

SELECT * FROM dw_jardineria.dim_producto;

-- aqui llegamos a la tabla mas importante de toda esta limpieza, transformacion y carga de los datos 
-- que es nuestra tabla de hechos donde se guardaran todos estos datos para futuras consultas, 
-- sin tener que hacerla sobre la base de datos original, esta contiene las llaves primarias para poder hacer la migracion
-- es donde hacemos la parte matematica, creamos la llaves foraneas que vienen de nuestras tablas, dim 
--
CREATE TABLE hechos_jardineria(
	Id_hecho INT NOT NULL AUTO_INCREMENT,
    
    sk_cliente INT NOT NULL,
    sk_pedido INT DEFAULT NULL,
    sk_pago INT DEFAULT NULL,
    sk_producto INT DEFAULT NULL,
    
    total_pago DECIMAL(15,2) DEFAULT 0.00,
    estado_entrega VARCHAR(30)  DEFAULT NULL,
    dias_entrega INT DEFAULT NULL,
    cantidad_transacciones INT DEFAULT 1,
    
    fecha_carga_dw DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_hecho),
    
    CONSTRAINT fk_hecho_cliente FOREIGN KEY (sk_cliente) REFERENCES dim_cliente(sk_cliente),
    CONSTRAINT fk_hecho_pedido FOREIGN KEY (sk_pedido) REFERENCES dim_pedido(sk_pedido),
    CONSTRAINT fk_hecho_pago FOREIGN KEY (sk_pago) REFERENCES dim_pago(sk_pago),
    CONSTRAINT fk_hecho_producto FOREIGN KEY (sk_producto) REFERENCES dim_producto(sk_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- aqui hacemos el insert  para hacer nuestra primera consulta de nuestra tabla de hechos jardineria 
-- utilizamos los INNER JOIN para unir nuestras tablas y generar el resultado esperado, le ponemos un alias
-- a nuestra tabla dim_pago y dim cliente por su ID_cliente de cada una de las tablas
INSERT INTO hechos_jardineria (
    sk_cliente,
    sk_pago,
    total_pago,
    cantidad_transacciones
)
SELECT 
    dc.sk_cliente,
    dpa.sk_pago,
    COALESCE(dpa.total, 0) AS total_pago,
    1 AS cantidad_transaccionesstaging_clientestaging_pagostaging_pagostaging_pedidostaging_productostaging_clientestaging_cliente
FROM dw_jardineria.dim_pago dpa
INNER JOIN dw_jardineria.dim_cliente dc 
    ON dpa.ID_cliente = dc.ID_cliente;


SELECT * FROM dw_jardineria.hechos_jardineria ;

SELECT 
    dc.pais,
    dc.ciudad,
    dc.seg_credito,
    COUNT(DISTINCT h.sk_pago) AS total_pagos,
    SUM(h.total_pago) AS dinero_recaudado
FROM dw_jardineria.hechos_jardineria h
INNER JOIN dw_jardineria.dim_cliente dc ON h.sk_cliente = dc.sk_cliente
GROUP BY dc.pais, dc.ciudad, dc.seg_credito
ORDER BY dinero_recaudado DESC;
