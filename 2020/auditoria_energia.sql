-- Julio 9 TABD
-- Auditoría de Energía
--Mariadb
--Usuario/esquema: audit_energía
-- ====================
-- Creación de Tablatabds
-- ====================
--Tabla: Estratos
CREATE TABLE estratos
(
	estrato_codigo INT NOT NULL,
	estrato_desc VARCHAR(28) NOT NULL
);
ALTER TABLE estratos ADD CONSTRAINT estratos_pk PRIMARY KEY(estrato_codigo);

COMMENT ON TABLE estratos IS 'Estratos Socioeconómicos';
COMMENT ON COLUMN estratos.estrato_codigo IS 'Codigo del Estrato';
COMMENT ON COLUMN estratos.estrato_desc IS 'Descripción del Estrato';

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

ALTER TABLE municipios ADD CONSTRAINT municipios_pk PRIMARY KEY(mpio_codigo);

COMMENT ON TABLE municipios IS 'Municipios del Área Metropolitana';
COMMENT ON COLUMN municipios.mpio_codigo IS 'Codigo del Municipio';
COMMENT ON COLUMN municipios.mpio_desc IS 'Descripción del Municipio';

INSERT INTO municipios(mpio_codigo, mpio_desc) VALUES (1, "Medellín");
--Tabla Hogares
CREATE TABLE hogares(
	hogar_codigo INT NOT NULL,
	hogar_estrato INT NOT NULL,
	hogar_mpio INT NOT NULL
);

ALTER TABLE hogares ADD CONSTRAINT hogares_pk PRIMARY KEY(hogar_codigo);
ALTER TABLE hogares ADD CONSTRAINT hogar_estrato_fk FOREIGN KEY (hogar_estrato) REFERENCES estratos (estrato_codigo);
ALTER TABLE hogares ADD CONSTRAINT hogar_mpio_fk FOREIGN KEY (hogar_mpio) REFERENCES municipios (mpio_codigo);

INSERT INTO hogares (hogar_codigo, hogar_estrato, hogar_mpio) VALUES (1, 3, 1);

--Tabla Tarifas
CREATE TABLE tarifas(
	tarifa_codigo INT NOT NULL,
	tarifa_mpio INT NOT NULL,
	tarifa_estrato INT NOT NULL,
	tarifa_año int NOT NULL,
	tarifa_valor float NOT NULL
);

ALTER TABLE tarifas ADD CONSTRAINT tarifas_pk PRIMARY KEY(tarifa_codigo);
ALTER TABLE tarifas ADD CONSTRAINT tarifas_estrato_pk PRIMARY KEY(tarifa_estrato);
ALTER TABLE tarifas ADD CONSTRAINT tarifas_mpio_pk PRIMARY KEY(tarifa_mpio);
ALTER TABLE tarifas ADD CONSTRAINT tarifas_año_pk PRIMARY KEY (año);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_mpio_fk FOREIGN KEY (tarifa_mpio) REFERENCES municipios (mpio_codigo);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_estrato_fk FOREIGN KEY (tarifa_estrato) REFERENCES estratos (estrato_codigo);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_año_fk FOREIGN KEY (tarifa_año) REFERENCES años (año);

INSERT INTO tarifas (tarifa_codigo, tarifa_mpio, tarifa_estrato, tarifa_ano, tarifa_valor) VALUES (1, 3, 1);

COMMENT ON TABLE tarifas IS 'Hogares del Área Metropolitana';
COMMENT ON COLUMN tarifas.hogar_codigo IS 'Codigo del Municipio';
COMMENT ON COLUMN tarifas.hogar_desc IS 'Descripción del Municipio';

SELECT * FROM tarifas;

-- Tabla Consumo
CREATE TABLE consumos	(
	consumo_codigo INT NOT NULL,
	consumo_hogar INT NOT NULL,
	año INT NOT NULL,
	mes INT NOT NULL,
	kwh float NOT NULL
);

ALTER TABLE consumos ADD CONSTRAINT consumo_pk PRIMARY KEY(consumo_codigo);
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

ALTER TABLE subsidios ADD CONSTRAINT subsidio_pk PRIMARY KEY (subsidio_codigo);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_año_pk PRIMARY KEY (año);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_mes_pk PRIMARY KEY (mes);
ALTER TABLE subsidios ADD CONSTRAINT subsidio_estrato_fk FOREIGN KEY (subsidio_estrato) REFERENCES estratos (estrato_codigo);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_año_fk FOREIGN KEY (año) REFERENCES años (año);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_mes_fk FOREIGN KEY (mes) REFERENCES meses (mes);

-- Tabla Facturaciones
CREATE TABLE facturaciones(
	facturacion_codigo INT NOT NULL,
	consumo INT NOT NULL,
	valor DOUBLE NOT NULL
);

ALTER TABLE facturaciones ADD CONSTRAINT facturacion_pk PRIMARY KEY(facturacion_codigo);
ALTER TABLE facturaciones ADD CONSTRAINT facturacion_consumo_fk FOREIGN KEY (consumo) REFERENCES consumos (consumo_codigo);

-- Tabla Años
CREATE TABLE años(
	año INT NOT NULL,
	descripcion VARCHAR(28)
);

ALTER TABLE años ADD CONSTRAINT años_año_pk PRIMARY KEY (año);

-- Tabla meses
CREATE TABLE meses(
	mes INT NOT NULL,
	año INT NOT null
);

ALTER TABLE meses ADD CONSTRAINT meses_mes_pk PRIMARY KEY (mes);
ALTER TABLE meses ADD CONSTRAINT meses_año_pk PRIMARY KEY (año);
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
-- Calcular el valor facturado de un hogar por año y mes
DELIMITER $$
CREATE OR REPLACE FUNCTION f_calcula_factura(p_hogar INT, p_año INT, p_mes INT) RETURNS FLOAT DETERMINISTIC

BEGIN
	DECLARE l_municipio INT DEFAULT 0;
	DECLARE l_estrato INT DEFAULT 0;
	DECLARE l_tarifa INT DEFAULT 0;
	DECLARE l_consumo FLOAT DEFAULT 0;
	DECLARE l_subsidio FLOAT DEFAULT 0;
	DECLARE l_valor_factura FLOAT DEFAULT 0;

	-- Obtener el municipio
	SELECT hogar_mpio INTO l_municipio FROM hogares WHERE hogar_codigo = p_hogar;
	-- Obtener el estrato
	SELECT hogar_estrato INTO l_estrato FROM hogares WHERE hogar_codigo = p_hogar;
	-- Obtener la tarifa
	SELECT tarifa_valor INTO l_tarifa FROM tarifas WHERE tarifa_mpio = l_municipio
	AND tarifa_estrato = l_estrato
	AND tarifa_año = p_año;
	
	-- Obtener subsidio
	SELECT subsidio INTO l_subsidio FROM subsidios 
	WHERE año = p_año
	AND mes = p_mes
	AND subsidio_estrato = l_estrato;
	
	-- Obtener consumo
	SELECT kwh INTO l_consumo FROM consumos
	WHERE consumo_hogar = p_hogar
	AND año = p_año
	AND mes = p_mes;
	
	SET l_valor_factura = l_consumo * (1 - l_subsidio);
	RETURN l_valor_factura;
END
DELIMITER ;

SELECT f_calcula_factura(1,1,1);
-- Custom queries
SELECT DISTINCT 
	h.hogar_codigo,
	e.estrato_desc,
	m.mpio_desc
FROM hogares h JOIN estratos e ON e.estrato_codigo = h.hogar_estrato
	JOIN municipios m ON m.mpio_codigo = h.hogar_mpio;


-- Comentarios de Tablas
SELECT table_comment 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE table_schema='tabd' ;

-- Comentarios de Columnas
SELECT * 
FROM USER_COL_COMMENTS;

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