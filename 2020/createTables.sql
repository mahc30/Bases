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
	tarifa_ano DATE NOT NULL,
	tarifa_valor DOUBLE NOT NULL
);

ALTER TABLE tarifas ADD CONSTRAINT tarifas_pk PRIMARY KEY(tarifa_codigo);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_mpio_fk FOREIGN KEY (tarifa_mpio) REFERENCES municipios (mpio_codigo);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_estrato_fk FOREIGN KEY (tarifa_estrato) REFERENCES estratos (estrato_codigo);

INSERT INTO tarifas (tarifa_codigo, tarifa_mpio, tarifa_estrato, tarifa_ano, tarifa_valor) VALUES (1, 3, 1);

COMMENT ON TABLE tarifas IS 'Hogares del Área Metropolitana';
COMMENT ON COLUMN tarifas.hogar_codigo IS 'Codigo del Municipio';
COMMENT ON COLUMN tarifas.hogar_desc IS 'Descripción del Municipio';

SELECT * FROM tarifas;

--Tabla Consumo
CREATE TABLE consumos	(
	consumo_codigo INT NOT NULL,
	consumo_hogar INT NOT NULL,
	ano DATE NOT NULL,
	consumo DOUBLE NOT NULL
);

ALTER TABLE consumos ADD CONSTRAINT consumo_pk PRIMARY KEY(consumo_codigo);
ALTER TABLE consumos ADD CONSTRAINT consumo_hogar_fk FOREIGN KEY (consumo_hogar) REFERENCES hogares (hogar_codigo);

-- Tabla subsidios
CREATE TABLE subsidios(
	subsidio_codigo INT NOT NULL,
	subsidio_estrato INT NOT NULL,
	subsidio_descuento DOUBLE NOT NULL
);

ALTER TABLE subsidios ADD CONSTRAINT subsidio_pk PRIMARY KEY (subsidio_codigo);
ALTER TABLE subsidios ADD CONSTRAINT subsidio_estrato_fk FOREIGN KEY (subsidio_estrato) REFERENCES estratos (estrato_codigo);

CREATE TABLE facturaciones(
	facturacion_codigo INT NOT NULL,
	facturacion_hogar INT NOT NULL,
	ano DATE NOT NULL,
	valor DOUBLE NOT NULL
);

ALTER TABLE facturaciones ADD CONSTRAINT facturacion_pk PRIMARY KEY(facturacion_codigo);
ALTER TABLE facturaciones ADD CONSTRAINT facturacion_hogar_fk FOREIGN KEY (facturacion_hogar) REFERENCES hogares (hogar_codigo);

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