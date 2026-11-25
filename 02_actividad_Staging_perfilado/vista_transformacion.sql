USE staging_jardineria;
-- en este paso se crearon las vistas para cada una de las tablas Staging, las cuales nos ayudan con el 
-- ETL para poder enviar nuestros datos limpios a la bodega de datos, se creta la vista con un nombre o alias
-- luego con COALESCE para limpiar datos nulos y reemplazarlos por algun texto, luego tenemos las funciones
-- UPPER que transforman nuestros texto de minusculas a mayusculas, tenemos la funcion TRIM que elimina los espacios en blanco
-- tanto al final como al principio de cada dato en una columna
CREATE OR REPLACE VIEW vista_cliente AS
SELECT
ID_cliente,
COALESCE(ID_empleado_rep_ventas, -1) AS ID_empleado_rep_ventas,
-- limpieza para la columna de nombre_cliente se pone en mayuscula, se limpian los espacios y se le da un alias 
-- en estos casos con el mismo nombre
UPPER(TRIM(nombre_cliente)) AS nombre_cliente,
-- limpieza de la columna nombre contacto lo transformamos en mayuscula, quitamos espacios, luego con un NULLIF 
-- le decimos si hay una fila vacia o null la cambie por un frase y luego le ponemos el nombre de la columna
UPPER(TRIM(COALESCE(NULLIF(nombre_contacto, ''), 'SIN_CONTACTO'))) AS nombre_contacto,
-- limpieza de la columna apellido contacto lo transformamos en mayuscula, quitamos espacios, luego con un NULLIF 
-- le decimos si hay una fila vacia o null la cambie por un frase y luego le ponemos el nombre de la columna
UPPER(TRIM(COALESCE(NULLIF(apellido_contacto, ''), 'SIN APELLIDO'))) AS apellido_contacto,
-- en esta linea lo que tenemos es poner esa columna en mayuscula, quitar los espacios, y concatenar el nombre y apellido
-- o sea unir esas dos columas y tengamos el nombre completo en una nueva columna
UPPER(TRIM(CONCAT(COALESCE(NULLIF(nombre_contacto, ''), 'SIN_CONTACTO'), ' ',
COALESCE(NULLIF(apellido_contacto, ''), '')))) AS contacto_completo,
-- en este caso de nuevo ponemos mayusculas, quitamos espacios y con un NULLIF si la columna ciudad esta vacia la cambiamos
-- por una expresion y luego le pones un alias
UPPER(TRIM(COALESCE(NULLIF(ciudad, ''), 'SIN CIUDAD'))) AS ciudad,
-- en este caso de nuevo ponemos mayusculas, quitamos espacios y con un NULLIF si la columna pais esta vacia la cambiamos
-- por una expresion y luego le pones un alias
UPPER(TRIM(COALESCE(NULLIF(pais, ''), 'SIN PAIS'))) AS pais,
-- en este caso en el limite de credito es null lo cambia por un 0
COALESCE(limite_credito, 0) AS limite_credito,
-- aqui creamos un caso para poder corregir los nombres que estan mal en la columna region, donde le decimos
-- cuando en la columa region la palabra empiece por estas siglas reempelezar por esta palabra
CASE
WHEN UPPER(TRIM(region)) LIKE "%CATALU%" THEN 'CATALUÑA'
ELSE UPPER(TRIM(COALESCE(NULLIF(region, ''), 'SIN REGION')))
END AS region,
-- creamos otro caso donde clasificamos nuestro limite de creditos donde con un WHEN le decimos que por cada rango
-- lo clasifique entre 4 parametros, el BETWEEN nos ayuda a tener un rango de datos para compararlos el THEN significa
-- que debe hacer despues de analizar cada rango 
CASE
	WHEN COALESCE(limite_credito, 0) = 0 THEN 'SIN CREDITO'
    WHEN limite_credito < 10000 THEN 'BAJO'
    WHEN limite_credito BETWEEN 10000 AND 50000 THEN 'MEDIO'
    ELSE 'ALTO'
END AS seg_credito,
stg_fecha_carga
-- aqui selesccionado la base de datos y la tabla a la cual se le vamos el proceso de transformacion.
FROM staging_jardineria.staging_cliente
WHERE ID_cliente IS NOT NULL;

SELECT * FROM staging_jardineria.vista_cliente;

SELECT * FROM staging_producto;

-- VISTA PARA LA TABLA PRODUCTO
-- aqui creamos la vista para la tabla producto
CREATE OR REPLACE VIEW vista_producto AS SELECT 

UPPER(TRIM(ID_producto)) AS ID_producto,
-- ponemos los datos en mayuscula , luego quitamos espacios y con un NULLIF preguntamos que si hay un datos null
-- luego de si encuentra un dato sin llenado lo cambie por la declaracion que le dimos
-- esto se hace para cada una de las lineas de este bloquee la misma sintaxis 
UPPER(TRIM(COALESCE(NULLIF(nombre, ''), 'PRODUCTO SIN NOMBRE'))) AS nombre_producto,
COALESCE(Categoria, -1) AS Categoria,
UPPER(TRIM(COALESCE(NULLIF(dimensiones, ''), 'NO ESPECIFICADA'))) AS dimensiones,
UPPER(TRIM(COALESCE(NULLIF(proveedor,''), 'DESCONOCIDO'))) AS proveedor,
TRIM(COALESCE(NULLIF(descripcion, ''), 'SIN DATOS')) AS descripcion,

-- aqui le decimos que cuando encuentre un valor null lo cambio por el valor 0 
-- esto aplica para cada linea de este bloque
COALESCE(cantidad_en_stock,0) AS cantidad_en_stock,
COALESCE(precio_venta, 0) AS precio_venta,
COALESCE(precio_proveedor, 0) AS precio_proveedor,
-- aqui creamos una nueva columna donde hacemos una operacion para saber cual es el margen de ganancia entre el precio
-- de venta y del proveedor que va entrar en nuestro warehouse y tener un informe completo
(COALESCE(precio_venta, 0) - COALESCE(precio_proveedor, 0)) AS margen_ganacia,

-- creamos una nueva columna para sacar nuestro procentaje y agregarla. a nuestra base de datos hacemos nuestra operacion
-- de restar luego divimos para nuestro porcentaje 
CASE
WHEN COALESCE(precio_venta, 0) > 0 THEN
ROUND(((precio_venta - COALESCE(precio_proveedor, 0)) / precio_venta) * 100,2)
ELSE 0
END AS porcentaje_margen,
-- en esta linea tenemos la creacion de una nueva columna para saber si un producto esta diponible o agotado 
-- por eso hacemos una comparacion de valores igual a 0 para poder definir cada elemento
CASE
WHEN COALESCE(cantidad_en_stock, 0) = 0 THEN 'AGOTADO'
ELSE 'DISPONIBLE'
END AS estado_stock,

stg_fecha_carga

-- aqui hacemos la consulta en nuestra base de datos para poder hacer la limpieza y que quede creada nuestra vista
FROM staging_jardineria.staging_producto
WHERE ID_producto IS NOT NULL
AND TRIM(ID_producto) <> '';

SELECT * FROM staging_jardineria.vista_producto LIMIT 20;

-- VISTA PARA LA TABLA PAGO

SELECT * FROM staging_pago;
-- aqui creamos la vista pago 
CREATE OR REPLACE VIEW vista_pago AS SELECT
-- en estas lineas volvemos a utlizar las funciones que estamos en todas nuestras vistas, que es el 
-- UPPER para tener todo en mayuscula, el TRIM para eliminar espacios al final y principio, el NULLIF para preguntar
-- por un valor nulo y luego reemplezarlo
UPPER(TRIM(ID_cliente)) AS ID_cliente,
UPPER(TRIM(COALESCE(NULLIF(forma_pago, ''), 'SIN INFORMACION' ))) AS forma_pago,
UPPER(TRIM(COALESCE(NULLIF(id_transaccion, ''), 'CAMPO VACIO' ))) AS id_transaccion,
CAST(fecha_pago AS DATE) AS fecha_pago,
COALESCE(total, 0) AS pago,

-- creamos un caso para preguntar si un pago es igual a 0 o mayor y asi poder definir una columna con el resultado
CASE 
WHEN COALESCE(total, 0 ) = 0 THEN 'SIN PAGO'
ELSE 'PAGO CANCELADO'
END AS estado_pago,

stg_fecha_carga
-- aqui hacemos la consulta para nuestra vista
FROM staging_jardineria.staging_pago
WHERE ID_cliente IS NOT NULL
AND TRIM(ID_cliente) <>'';

SELECT * FROM staging_jardineria.vista_pago;

-- vista pedido

SELECT * FROM staging_pedido;
-- se crea la vista para la tabla pedido, se usan las funciones para tener los textos en mayuscula, para quitar espacios
-- y poder limpiar nuestros datos
CREATE OR REPLACE VIEW vista_pedido AS SELECT 
UPPER(TRIM(ID_pedido)) AS ID_pedido,
UPPER(TRIM(COALESCE(NULLIF(comentarios,''), 'SIN COMENTARIO' ))) AS comentarios,
UPPER(TRIM(COALESCE(NULLIF(estado,''), 'CAMPO VACIO' ))) AS estado,

-- en esta linea creamos un caso para poder analizar la fila fecha por año y saber si esta vacio y llenar ese espacio
-- con un texto y luego de eso ponerle un alias a este caso, esto se aplica para las tres columnas de fecha.
CASE
WHEN fecha_pedido IS NULL OR YEAR(fecha_pedido) = 0 THEN 'FECHA VACIA'
ELSE CAST(fecha_pedido AS CHAR)
END AS fecha_pedido,

CASE
WHEN fecha_esperada IS NULL OR YEAR(fecha_esperada) = 0 THEN 'FECHA VACIA'
ELSE CAST(fecha_esperada AS CHAR)
END AS fecha_esperada,

CASE
WHEN fecha_entrega IS NULL OR YEAR(fecha_entrega) = 0 THEN 'FECHA VACIA'
ELSE CAST(fecha_entrega AS CHAR)
END AS fecha_entrega,

-- aqui creamos un caso con la intencion de clasificar cada texto de nuestra columna estado 
-- donde lo clasificamos cuando es entregado 10, pendiente 5 y rechazado 0 y asi tomar decisiones
-- sobre que puede estar pasando con los pedidos 
CASE
WHEN UPPER(TRIM(estado)) LIKE 'ENTREG%' THEN 10
WHEN UPPER(TRIM(estado)) LIKE 'PENDI%' THEN 5
WHEN UPPER(TRIM(estado)) LIKE 'RECHA%' THEN 0
ELSE NULL
END AS clasificacion_estado,

stg_fecha_carga
-- aqui hacemos la consulta y poder crear nuestra vista pedido
FROM staging_jardineria.staging_pedido
WHERE ID_pedido IS NOT NULL;

SELECT * FROM staging_jardineria.vista_pedido LIMIT 20;


