-- Julio 9 TABD
-- Auditoría de Energía
-- Mariadb
-- Usuario/esquema: audit_energía

-- ====================
-- Creación de Tablas
-- ====================

--Tabla: Estratos
CREATE TABLE estratos
(
	estrato_codigo INT NOT NULL,
	estrato_desc VARCHAR(28) NOT NULL
);

--Comentarios Estratos
ALTER TABLE estratos COMMENT 'Estratos Socioeconómicos';
ALTER TABLE estratos CHANGE estrato_codigo estrato_codigo INT NOT NULL COMMENT "Código del Estrato";
ALTER TABLE estratos CHANGE estrato_desc estrato_desc VARCHAR(28) NOT NULL COMMENT 'Descripción del Estrato';

--Constrains Estratos
ALTER TABLE estratos ADD CONSTRAINT estratos_pk PRIMARY KEY(estrato_codigo);

INSERT INTO estratos (estrato_codigo, estrato_desc) VALUES (1, "Estrato 1");
INSERT INTO estratos (estrato_codigo, estrato_desc) VALUES (2, "Estrato 2");
INSERT INTO estratos (estrato_codigo, estrato_desc) VALUES (3, "Estrato 3");
INSERT INTO estratos (estrato_codigo, estrato_desc) VALUES (4, "Estrato 4");
INSERT INTO estratos (estrato_codigo, estrato_desc) VALUES (5, "Estrato 5");
INSERT INTO estratos (estrato_codigo, estrato_desc) VALUES (6, "Estrato 6");

SELECT * FROM estratos;

--Tabla: Municipios
CREATE TABLE municipios
(
	mpio_codigo INT NOT NULL,
	mpio_desc VARCHAR(28) NOT NULL
);

-- Comentarios Municipios
ALTER TABLE municipios COMMENT 'Municipios del Área Metropolitana';
ALTER TABLE municipios CHANGE mpio_codigo mpio_codigo INT NOT NULL COMMENT "Código del Municipio";
ALTER TABLE municipios CHANGE mpio_desc mpio_desc VARCHAR(28) NOT NULL COMMENT "Descripción del Municipio";

-- Constrains Municipios
ALTER TABLE municipios ADD CONSTRAINT municipios_pk PRIMARY KEY(mpio_codigo);

INSERT INTO municipios(mpio_codigo, mpio_desc) VALUES (1, "Medellín");
SELECT * FROM municipios;

--Tabla Hogares
CREATE TABLE hogares(
	hogar_codigo INT NOT NULL,
	hogar_estrato INT NOT NULL,
	hogar_mpio INT NOT NULL
);

-- Comentarios Hogares
ALTER TABLE hogares COMMENT 'Hogares del Área Metropolitana';
ALTER TABLE hogares CHANGE hogar_codigo hogar_codigo INT NOT NULL COMMENT "Código del Hogar";
ALTER TABLE hogares CHANGE hogar_estrato hogar_estrato INT NOT NULL COMMENT "Código del Estrato al que pertenece el Hogar";
ALTER TABLE hogares CHANGE hogar_mpio hogar_mpio INT NOT NULL COMMENT "Código del Municipio Al que Pertenece el Hogar";

-- Constrains Hogares
ALTER TABLE hogares ADD CONSTRAINT hogares_pk PRIMARY KEY(hogar_codigo);
ALTER TABLE hogares ADD CONSTRAINT hogar_estrato_fk FOREIGN KEY (hogar_estrato) REFERENCES estratos (estrato_codigo);
ALTER TABLE hogares ADD CONSTRAINT hogar_mpio_fk FOREIGN KEY (hogar_mpio) REFERENCES municipios (mpio_codigo);

INSERT INTO hogares (hogar_codigo, hogar_estrato, hogar_mpio) VALUES (1, 3, 1);
SELECT * FROM hogares;

--Tabla Tarifas
CREATE TABLE tarifas(
	tarifa_codigo INT NOT NULL,
	tarifa_mpio INT NOT NULL,
	tarifa_estrato INT NOT NULL,
	tarifa_año int NOT NULL,
	tarifa_valor float NOT NULL
);

-- Comentarios Tarifas
ALTER TABLE tarifas COMMENT 'Tarifas para los municipios y estratos';
ALTER TABLE tarifas CHANGE tarifa_codigo tarifa_codigo INT NOT NULL COMMENT "Código de la Tarifa";
ALTER TABLE tarifas CHANGE tarifa_mpio tarifa_mpio INT NOT NULL COMMENT "Código del Municipio de la Tarifa";
ALTER TABLE tarifas CHANGE tarifa_estrato tarifa_estrato INT NOT NULL COMMENT "Código del Estrato de la Tarifa";
ALTER TABLE tarifas CHANGE tarifa_año tarifa_año INT NOT NULL COMMENT "Código del Año de la Tarifa";
ALTER TABLE tarifas CHANGE tarifa_valor tarifa_valor FLOAT NOT NULL COMMENT "Valor de la Tarifa";

-- Constrains Tarifas
ALTER TABLE tarifas ADD CONSTRAINT tarifas_pk PRIMARY KEY(tarifa_codigo, tarifa_estrato, tarifa_mpio, año);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_mpio_fk FOREIGN KEY (tarifa_mpio) REFERENCES municipios (mpio_codigo);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_estrato_fk FOREIGN KEY (tarifa_estrato) REFERENCES estratos (estrato_codigo);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_año_fk FOREIGN KEY (tarifa_año) REFERENCES años (año);

INSERT INTO tarifas (tarifa_codigo, tarifa_mpio, tarifa_estrato, tarifa_ano, tarifa_valor) VALUES (1, 3, 1);

SELECT * FROM tarifas;

-- Tabla Consumo
CREATE TABLE consumos	(
	consumo_codigo INT NOT NULL,
	consumo_hogar INT NOT NULL,
	año INT NOT NULL,
	mes INT NOT NULL,
	kwh float NOT NULL
);

-- Comentarios Consumos
ALTER TABLE consumos COMMENT 'Consumos en kwh de los hogares';
ALTER TABLE consumos CHANGE consumo_codigo consumo_codigo INT NOT NULL COMMENT "Código del Consumo";
ALTER TABLE consumos CHANGE consumo_hogar consumo_hogar INT NOT NULL COMMENT "Código del Hogar";
ALTER TABLE consumos CHANGE año año INT NOT NULL COMMENT "Año del Consumo";
ALTER TABLE consumos CHANGE mes mes INT NOT NULL COMMENT "Mes del Consumo";
ALTER TABLE consumos CHANGE kwh kwh FLOAT NOT NULL COMMENT "Consumo en kwh";

-- Constrains Consumos
ALTER TABLE consumos ADD CONSTRAINT consumo_pk PRIMARY KEY(consumo_hogar, año, mes);
ALTER TABLE consumos ADD CONSTRAINT consumo_hogar_fk FOREIGN KEY (consumo_hogar) REFERENCES hogares (hogar_codigo);
ALTER TABLE consumos ADD CONSTRAINT consumo_año_fk FOREIGN KEY (año) REFERENCES años (año);
ALTER TABLE consumos ADD CONSTRAINT consumo_mes_fk FOREIGN KEY (mes) REFERENCES meses (mes)

-- Tabla subsidios
CREATE TABLE subsidios(
	subsidio_codigo INT NOT NULL,
	subsidio_estrato INT NOT NULL,
	año INT NOT NULL,
	mes INT NOT NULL,
	subsidio FLOAT NOT null
);

-- Comentarios Subsidios
ALTER TABLE subsidios COMMENT 'Subsidios para el pago de la factura';
ALTER TABLE subsidios CHANGE subsidio_codigo subsidio_codigo INT NOT NULL COMMENT "Código del Subsidio";
ALTER TABLE subsidios CHANGE subsidio_estrato subsidio_estrato INT NOT NULL COMMENT "Código del Estrato del Subsidio";
ALTER TABLE subsidios CHANGE año año INT NOT NULL COMMENT "Año del Subsidio";
ALTER TABLE subsidios CHANGE mes mes INT NOT NULL COMMENT "Mes del Subsidio";
ALTER TABLE subsidios CHANGE subsidio subsidio FLOAT NOT NULL COMMENT "Valor del Subsidio, de 0 a 1";

-- Constrains Subsidios
ALTER TABLE subsidios ADD CONSTRAINT subsidio_pk PRIMARY KEY (subsidio_codigo, año, mes);
ALTER TABLE subsidios ADD CONSTRAINT subsidio_estrato_fk FOREIGN KEY (subsidio_estrato) REFERENCES estratos (estrato_codigo);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_año_fk FOREIGN KEY (año) REFERENCES años (año);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_mes_fk FOREIGN KEY (mes) REFERENCES meses (mes);

-- Tabla Facturaciones
CREATE TABLE facturaciones(
	facturacion_codigo INT NOT NULL,
	hogar INT NOT NULL,
	año INT NOT NULL,
	mes INT NOT NULL,
	valor FLOAT NOT NULL,
	fecha DATE NOT NULL
);

-- Comentarios Facturaciones
ALTER TABLE facturaciones COMMENT 'Facturas';
ALTER TABLE facturaciones CHANGE facturacion_codigo facturacion_codigo INT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT "Código de la Factura";
ALTER TABLE facturaciones CHANGE hogar hogar INT NOT NULL COMMENT "Código del hogar de la Factura";
ALTER TABLE facturaciones CHANGE año año INT NOT NULL COMMENT "Código del año de la Factura";
ALTER TABLE facturaciones CHANGE mes mes INT NOT NULL COMMENT "Código del mes de la Factura";
ALTER TABLE facturaciones CHANGE valor valor FLOAT NOT NULL COMMENT "Valor de la Factura";
ALTER TABLE facturaciones CHANGE fecha fecha DATE NOT NULL COMMENT "Fecha de la Factura";

SELECT * FROM facturaciones;
-- Tabla Años
CREATE TABLE años(
	año INT NOT NULL,
	descripcion VARCHAR(28)
);

-- Comentarios Años
ALTER TABLE años COMMENT 'Años';
ALTER TABLE años CHANGE año año INT NOT NULL COMMENT "Código del Año";
ALTER TABLE años CHANGE descripcion descripcion VARCHAR(28) NOT NULL COMMENT "Descripcion del Año";

-- Constrains Años
ALTER TABLE años ADD CONSTRAINT años_año_pk PRIMARY KEY (año);

-- Tabla meses
CREATE TABLE meses(
	mes INT NOT NULL,
	año INT NOT null
);

-- Comentarios Meses
ALTER TABLE meses COMMENT 'Meses';
ALTER TABLE meses CHANGE año año INT NOT NULL COMMENT "Código del Año";
ALTER TABLE meses CHANGE mes mes INT NOT NULL COMMENT "Mes del Año";

-- Constrains Meses
ALTER TABLE meses ADD CONSTRAINT meses_mes_pk PRIMARY KEY (mes, año);
ALTER TABLE meses ADD CONSTRAINT meses_año_fk FOREIGN KEY (año) REFERENCES años(año);

-- Views
-- Estrato x Municipio
CREATE OR REPLACE VIEW estratos_x_mpio AS (
	SELECT DISTINCT 
	m.mpio_codigo,
	m.mpio_desc descripcion_municipio,
	e.estrato_codigo,
	e.estrato_desc descripcion_estrato
	FROM estratos e, municipios
);

-- Info Hogares
CREATE OR REPLACE VIEW info_hogares AS (
	SELECT DISTINCT 
	h.hogar_codigo,
	e.estrato_desc,
	m.mpio_desc
	FROM hogares h JOIN estratos e ON h.hogar_estrato = e.estrato_codigo
						JOIN municipios m ON m.mpio_codigo = h.hogar_mpio
);

-- Total Hogares
CREATE OR REPLACE VIEW total_hogares AS (
	SELECT DISTINCT 
	m.mpio_desc municipio,
	e.estrato_desc estrato,
	COUNT(h.hogar_codigo) total_hogares
	FROM hogares h join estratos e ON h.hogar_estrato = e.estrato_codigo
						JOIN municipios m ON m.mpio_codigo = h.hogar_mpio
);

-- ===============================
-- 				Funciones
-- ===============================

-- Obtener Estrato
DELIMITER $$
CREATE OR REPLACE FUNCTION f_obtener_subsidio(
p_año INT,
p_mes INT,
p_estrato INT) RETURNS INT DETERMINISTIC 
BEGIN
DECLARE l_total_registros INT default 0;
DECLARE l_subsidios INT default 0;

SELECT COUNT(subsidio_codigo) INTO l_total_registros
FROM subsidios 
WHERE año = p_año 
AND mes = p_mes 
AND subsidio_estrato = p_estrato;

if (l_total_registros > 0) then
	SELECT subsidio_codigo into l_subsidios FROM subsidios WHERE año = p_año AND mes = p_mes AND subsidio_estrato = p_estrato;
END IF;	

RETURN l_subsidios;
END $$
DELIMITER ;

-- Calcular el valor facturado de un hogar por año y mes
DELIMITER $$
CREATE OR REPLACE FUNCTION f_calcula_factura(
p_hogar INT,
p_año INT,
p_mes INT)
RETURNS FLOAT DETERMINISTIC

BEGIN
DECLARE l_municipio INT DEFAULT 0;
DECLARE l_estrato INT DEFAULT 0;
DECLARE l_tarifa INT DEFAULT 0;
DECLARE l_consumo FLOAT DEFAULT 0;
DECLARE l_subsidio FLOAT DEFAULT 0;
DECLARE l_valor_factura FLOAT DEFAULT 0;
	
	-- Obtener el municipio
	SELECT hogar_mpio INTO l_municipio FROM hogares 
	WHERE hogar_codigo = p_hogar;
	-- Obtener el estrato
	SELECT hogar_estrato INTO l_estrato FROM hogares 
	WHERE hogar_codigo = p_hogar;
	-- Obtener la tarifa
	SELECT tarifa_valor INTO l_tarifa FROM tarifas 
	WHERE tarifa_mpio = l_municipio
	AND tarifa_estrato = l_estrato
	AND tarifa_año = p_año;
	
	-- Obtener subsidio
	SET @l_subsidio = f_obtener_subsidio(p_año, p_mes, l_estrato);
	
	-- Obtener consumo
	SELECT kwh INTO l_consumo FROM consumos
	WHERE consumo_hogar = p_hogar
	AND año = p_año
	AND mes = p_mes;
	
	SET l_valor_factura = l_consumo * (1 - l_subsidio);
	RETURN l_valor_factura;
END $$
DELIMITER ;

SELECT f_calcula_factura(1,1,1);

-- ===============================
-- 			 Procedimientos
-- ===============================

-- Procedimiento Actualizar Registro Factura
DELIMITER $$
CREATE OR REPLACE PROCEDURE p_actualizar_registro_factura(
IN p_hogar INT,
IN p_año INT,
IN p_mes INT,
IN p_valor FLOAT
)

BEGIN 
DECLARE l_total_registros INT default 0;

-- Validar si hay registros para ese hogar, año y mes
SELECT COUNT(valor) INTO l_total_registros
	FROM facturaciones
	WHERE hogar = p_hogar
	AND año = p_año
	AND mes = p_mes;

-- Si hay registro se actualiza el valor
if (l_total_registros > 0) then 
	UPDATE facturaciones f
	SET valor = p_valor,
	fecha = SYSDATE()
	WHERE hogar = p_hogar
	AND año = p_año
	AND mes = p_mes;

-- Si no, se inserta
ELSE 
	INSERT INTO facturaciones(hogar, año, mes, valor, fecha)
	VALUES (p_hogar, p_año, p_mes, p_valor, SYSDATE());
END if;

-- Confirmar Transacción
COMMIT;

END$$
DELIMITER ;

-- Procedimiento Actualizar Facturas Municipio
DELIMITER $$
CREATE OR REPLACE PROCEDURE p_actualizar_facturas_municipio(
IN p_municipio INT, 
IN p_año INT,
IN p_mes INT,
IN p_hogar INT,
IN p_valor FLOAT
)
BEGIN 
DECLARE l_cursor_finished INT DEFAULT 0;
DECLARE l_hogar INT DEFAULT 0;
DECLARE l_valor_factura FLOAT DEFAULT 0;

-- Cursor de Hogares para el municipio
DECLARE hogares_c  CURSOR FOR
	SELECT hogar_codigo 
	FROM hogares 
	WHERE hogar_mpio = p_municipio;

-- NOT FOUND handler
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_cursor_finished = 1;
        
OPEN hogares_c;
getValores: LOOP 
	FETCH hogares_c INTO l_hogar;
	IF l_cursor_finished = 1 THEN 
			LEAVE getValores;
	END IF;
	SET @l_valor_factura = f_calcula_factura(l_hogar, p_año, p_mes);
	
	-- Insertar/Actualizar Facturas
	CALL p_actualizar_registro_factura(l_hogar, p_año, p_mes, l_valor_factura);
	
END LOOP getValores;	
CLOSE hogares_c;

END$$
DELIMITER ;

-- Custom queries
SELECT DISTINCT 
	h.hogar_codigo,
	e.estrato_desc,
	m.mpio_desc
FROM hogares h JOIN estratos e ON e.estrato_codigo = h.hogar_estrato
	JOIN municipios m ON m.mpio_codigo = h.hogar_mpio;

USE INFORMATION_SCHEMA;
-- Comentarios de Tablas
SELECT table_comment 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE table_schema='tabd' ;

-- Comentarios de Columnas
select `column_name`, `column_type`, `column_default`, `column_comment`
from `information_schema`.`COLUMNS` 
WHERE table_schema='tabd' ;

--Sentencias de Validación del modelo de datos
SELECT OBJECT_NAME, OBJECT_TYPE, STATUS
FROM user_objects;



-- Sentencia para ver los constraints
USE INFORMATION_SCHEMA;
SELECT TABLE_NAME,
       COLUMN_NAME,
       CONSTRAINT_NAME,
       REFERENCED_TABLE_NAME,
       REFERENCED_COLUMN_NAME
FROM KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = "tabd" 
      AND REFERENCED_COLUMN_NAME IS NOT NULL;

USE tabd;
