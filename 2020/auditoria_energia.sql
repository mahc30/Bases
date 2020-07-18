# Julio 9 TABD
# Auditoría de Energía
# Mariadb
# Usuario/esquema: audit_energía@tabd

# ====================
# Creación de Tablas
# ====================
CREATE OR REPLACE DATABASE tabd;
USE tabd;
# tabla: Estratos
CREATE TABLE estratos
(
	estrato INT NOT NULL,
	descripcion VARCHAR(28) NOT NULL
);

# Comentarios Estratos
ALTER TABLE estratos COMMENT 'Estratos Socioeconómicos';
ALTER TABLE estratos CHANGE estrato estrato INT NOT NULL COMMENT "Código del Estrato";
ALTER TABLE estratos CHANGE descripcion descripcion VARCHAR(28) NOT NULL COMMENT 'Descripción del Estrato';

# Constrains Estratos
ALTER TABLE estratos ADD CONSTRAINT estratos_pk PRIMARY KEY(estrato);

/*
INSERT INTO estratos (estrato, descripcion) VALUES (1, "Estrato 1");
INSERT INTO estratos (estrato, descripcion) VALUES (2, "Estrato 2");
INSERT INTO estratos (estrato, descripcion) VALUES (3, "Estrato 3");
INSERT INTO estratos (estrato, descripcion) VALUES (4, "Estrato 4");
INSERT INTO estratos (estrato, descripcion) VALUES (5, "Estrato 5");
INSERT INTO estratos (estrato, descripcion) VALUES (6, "Estrato 6");
*/

SELECT * FROM estratos;

# Tabla: Municipios
CREATE TABLE municipios
(
	municipio INT NOT NULL,
	descripcion VARCHAR(28) NOT NULL
);

# Comentarios Municipios
ALTER TABLE municipios COMMENT 'Municipios del Área Metropolitana';
ALTER TABLE municipios CHANGE municipio municipio INT NOT NULL COMMENT "Código del Municipio";
ALTER TABLE municipios CHANGE descripcion descripcion VARCHAR(28) NOT NULL COMMENT "Descripción del Municipio";

# Constrains Municipios
ALTER TABLE municipios ADD CONSTRAINT municipios_pk PRIMARY KEY(municipio);

# INSERT INTO municipios(municipio, descripcion) VALUES (1, "Medellín");
SELECT * FROM municipios;

# Tabla Hogares
CREATE TABLE hogares(
	hogar INT NOT NULL,
	municipio INT NOT NULL,
	estrato INT NOT NULL
	
);

# Comentarios Hogares
ALTER TABLE hogares COMMENT 'Hogares del Área Metropolitana';
ALTER TABLE hogares CHANGE hogar hogar INT NOT NULL COMMENT "Código del Hogar";
ALTER TABLE hogares CHANGE estrato estrato INT NOT NULL COMMENT "Código del Estrato al que pertenece el Hogar";
ALTER TABLE hogares CHANGE municipio municipio INT NOT NULL COMMENT "Código del Municipio Al que Pertenece el Hogar";

# Constrains Hogares
ALTER TABLE hogares ADD CONSTRAINT hogares_pk PRIMARY KEY(hogar);
ALTER TABLE hogares ADD CONSTRAINT estrato_fk FOREIGN KEY (estrato) REFERENCES estratos (estrato);
ALTER TABLE hogares ADD CONSTRAINT municipio_fk FOREIGN KEY (municipio) REFERENCES municipios (municipio);

# INSERT INTO hogares (hogar, estrato, municipio) VALUES (1, 3, 1);
SELECT * FROM hogares;

# Tabla Años
CREATE TABLE años(
	año INT NOT NULL,
	descripcion VARCHAR(28)
);

# Comentarios Años
ALTER TABLE años COMMENT 'Años';
ALTER TABLE años CHANGE año año INT NOT NULL COMMENT "Código del Año";
ALTER TABLE años CHANGE descripcion descripcion VARCHAR(28) NOT NULL COMMENT "Descripcion del Año";

# Constrains Años
ALTER TABLE años ADD CONSTRAINT años_año_pk PRIMARY KEY (año);

# Tabla meses
CREATE TABLE meses(
	año INT NOT NULL,
	mes INT NOT NULL
);

# Comentarios Meses
ALTER TABLE meses COMMENT 'Meses';
ALTER TABLE meses CHANGE año año INT NOT NULL COMMENT "Código del Año";
ALTER TABLE meses CHANGE mes mes INT NOT NULL COMMENT "Mes del Año";

# Constrains Meses
ALTER TABLE meses ADD CONSTRAINT meses_mes_pk PRIMARY KEY (mes, año);
ALTER TABLE meses ADD CONSTRAINT meses_año_fk FOREIGN KEY (año) REFERENCES años(año);

# Tabla Tarifas
CREATE TABLE tarifas(
	municipio INT NOT NULL,
	estrato INT NOT NULL,
	año int NOT NULL,
	valor float NOT NULL
);

# Comentarios Tarifas
ALTER TABLE tarifas COMMENT 'Tarifas para los municipios y estratos';
ALTER TABLE tarifas CHANGE municipio municipio INT NOT NULL COMMENT "Código del Municipio de la Tarifa";
ALTER TABLE tarifas CHANGE estrato estrato INT NOT NULL COMMENT "Código del Estrato de la Tarifa";
ALTER TABLE tarifas CHANGE año año INT NOT NULL COMMENT "Código del Año de la Tarifa";
ALTER TABLE tarifas CHANGE valor valor FLOAT NOT NULL COMMENT "Valor de la Tarifa";

# Constrains Tarifas
ALTER TABLE tarifas ADD CONSTRAINT tarifas_pk PRIMARY KEY( estrato, municipio, año);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_municipio_fk FOREIGN KEY (municipio) REFERENCES municipios(municipio);
ALTER TABLE tarifas ADD CONSTRAINT tarifa_estrato_fk FOREIGN KEY (estrato) REFERENCES estratos(estrato);
ALTER TABLE tarifas ADD CONSTRAINT año_fk FOREIGN KEY (año) REFERENCES años (año);

SELECT * FROM tarifas;

# Tabla Consumo
CREATE TABLE consumos	(
	hogar INT NOT NULL,
	año INT NOT NULL,
	mes INT NOT NULL,
	kwh float NOT NULL
);

# Comentarios Consumos
ALTER TABLE consumos COMMENT 'Consumos en kwh de los hogares';
ALTER TABLE consumos CHANGE hogar hogar INT NOT NULL COMMENT "Código del Hogar";
ALTER TABLE consumos CHANGE año año INT NOT NULL COMMENT "Año del Consumo";
ALTER TABLE consumos CHANGE mes mes INT NOT NULL COMMENT "Mes del Consumo";
ALTER TABLE consumos CHANGE kwh kwh FLOAT NOT NULL COMMENT "Consumo en kwh";

# Constrains Consumos
ALTER TABLE consumos ADD CONSTRAINT consumo_pk PRIMARY KEY(hogar, año, mes);
ALTER TABLE consumos ADD CONSTRAINT hogar_fk FOREIGN KEY (hogar) REFERENCES hogares (hogar);
ALTER TABLE consumos ADD CONSTRAINT consumo_año_fk FOREIGN KEY (año) REFERENCES años (año);
ALTER TABLE consumos ADD CONSTRAINT consumo_mes_fk FOREIGN KEY (mes) REFERENCES meses (mes);

# Tabla subsidios
CREATE TABLE subsidios(
	año INT NOT NULL,
	mes INT NOT NULL,
	estrato INT NOT NULL,
	subsidio FLOAT NOT null
);

# Comentarios Subsidios
ALTER TABLE subsidios COMMENT 'Subsidios para el pago de la factura';
ALTER TABLE subsidios CHANGE estrato estrato INT NOT NULL COMMENT "Código del Estrato del Subsidio";
ALTER TABLE subsidios CHANGE año año INT NOT NULL COMMENT "Año del Subsidio";
ALTER TABLE subsidios CHANGE mes mes INT NOT NULL COMMENT "Mes del Subsidio";
ALTER TABLE subsidios CHANGE subsidio subsidio FLOAT NOT NULL COMMENT "Valor del Subsidio, de 0 a 1";

# Constrains Subsidios
ALTER TABLE subsidios ADD CONSTRAINT subsidio_pk PRIMARY KEY (año, mes, estrato);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_estrato_fk FOREIGN KEY (estrato) REFERENCES estratos (estrato);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_año_fk FOREIGN KEY (año) REFERENCES años (año);
ALTER TABLE subsidios ADD CONSTRAINT subsidios_mes_fk FOREIGN KEY (mes) REFERENCES meses (mes);

# Tabla facturas
CREATE TABLE facturas(
	facturacion_codigo INT NOT NULL,
	hogar INT NOT NULL,
	año INT NOT NULL,
	mes INT NOT NULL,
	valor FLOAT NOT NULL,
	fecha DATE NOT NULL
);

# Comentarios facturas
ALTER TABLE facturas COMMENT 'Facturas';

ALTER TABLE facturas CHANGE hogar hogar INT NOT NULL COMMENT "Código del hogar de la Factura";
ALTER TABLE facturas CHANGE año año INT NOT NULL COMMENT "Código del año de la Factura";
ALTER TABLE facturas CHANGE mes mes INT NOT NULL COMMENT "Código del mes de la Factura";
ALTER TABLE facturas CHANGE valor valor FLOAT NOT NULL COMMENT "Valor de la Factura";
ALTER TABLE facturas CHANGE fecha fecha DATE NOT NULL COMMENT "Fecha de la Factura";

# Constrains Facturas
ALTER TABLE facturas CHANGE facturacion_codigo facturacion_codigo INT NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT "Código de la Factura";
ALTER TABLE facturas ADD CONSTRAINT facturas_estrato_fk FOREIGN KEY (hogar) REFERENCES hogares (hogar);
ALTER TABLE facturas ADD CONSTRAINT facturas_año_fk FOREIGN KEY (año) REFERENCES años (año);
ALTER TABLE facturas ADD CONSTRAINT facturas_mes_fk FOREIGN KEY (mes) REFERENCES meses (mes);
SELECT * FROM facturas;


# Views
# Estrato x Municipio
CREATE OR REPLACE VIEW estratos_x_mpio AS (
	SELECT DISTINCT 
	m.municipio,
	m.descripcion descripcion_municipio,
	e.estrato,
	e.descripcion descripcion_estrato
	FROM estratos e, municipios m
);

# Info Hogares
CREATE OR REPLACE VIEW info_hogares AS (
	SELECT DISTINCT 
	h.hogar,
	e.descripcion AS desc_estrato,
	m.descripcion AS des_municipio
	FROM hogares h JOIN estratos e ON h.estrato = e.estrato
						JOIN municipios m ON m.municipio = h.municipio
);

# Total Hogares
CREATE OR REPLACE VIEW total_hogares AS (
	SELECT DISTINCT 
	m.descripcion municipio,
	e.descripcion estrato,
	COUNT(h.hogar) total_hogares
	FROM hogares h join estratos e ON h.estrato = e.estrato
						JOIN municipios m ON m.municipio = h.municipio
);

# ===============================
# 				Funciones
# ===============================

# Obtener Estrato
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
AND estrato = p_estrato;

if (l_total_registros > 0) then
	SELECT subsidio_codigo into l_subsidios FROM subsidios WHERE año = p_año AND mes = p_mes AND estrato = p_estrato;
END IF;	

RETURN l_subsidios;
END $$
DELIMITER ;

# Calcular el valor facturado de un hogar por año y mes
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
	
	# Obtener el municipio
	SELECT municipio INTO l_municipio FROM hogares 
	WHERE hogar = p_hogar;
	# Obtener el estrato
	SELECT estrato INTO l_estrato FROM hogares 
	WHERE hogar = p_hogar;
	# Obtener la tarifa
	SELECT valor INTO l_tarifa FROM tarifas 
	WHERE municipio = l_municipio
	AND estrato = l_estrato
	AND año = p_año;
	
	# Obtener subsidio
	SET @l_subsidio = f_obtener_subsidio(p_año, p_mes, l_estrato);
	
	# Obtener consumo
	SELECT kwh INTO l_consumo FROM consumos
	WHERE hogar = p_hogar
	AND año = p_año
	AND mes = p_mes;
	
	SET l_valor_factura = l_consumo * (1 - l_subsidio);
	RETURN l_valor_factura;
END $$
DELIMITER ;

SELECT f_calcula_factura(1,1,1);

# ===============================
# 			 Procedimientos
# ===============================

# Procedimiento Actualizar Registro Factura
DELIMITER $$
CREATE OR REPLACE PROCEDURE p_actualizar_registro_factura(
IN p_hogar INT,
IN p_año INT,
IN p_mes INT,
IN p_valor FLOAT
)

BEGIN 
DECLARE l_total_registros INT default 0;

# Validar si hay registros para ese hogar, año y mes
SELECT COUNT(valor) INTO l_total_registros
	FROM facturas
	WHERE hogar = p_hogar
	AND año = p_año
	AND mes = p_mes;

# Si hay registro se actualiza el valor
if (l_total_registros > 0) then 
	UPDATE facturas f
	SET valor = p_valor,
	fecha = SYSDATE()
	WHERE hogar = p_hogar
	AND año = p_año
	AND mes = p_mes;

# Si no, se inserta
ELSE 
	INSERT INTO facturas(hogar, año, mes, valor, fecha)
	VALUES (p_hogar, p_año, p_mes, p_valor, SYSDATE());
END if;

# Confirmar Transacción
COMMIT;

END$$
DELIMITER ;

# Procedimiento Actualizar Facturas x Municipio
DELIMITER $$
CREATE OR REPLACE PROCEDURE p_actualizar_facturas_municipio(
IN p_municipio INT, 
IN p_año INT,
IN p_mes INT
)
BEGIN 
DECLARE l_cursor_finished INT DEFAULT 0;
DECLARE l_hogar INT DEFAULT 0;
DECLARE l_valor_factura FLOAT DEFAULT 0;

# Cursor de Hogares para el municipio
DECLARE hogares_c  CURSOR FOR
	SELECT hogar 
	FROM hogares 
	WHERE municipio = p_municipio;

# NOT FOUND handler
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_cursor_finished = 1;
        
OPEN hogares_c;
getValores: LOOP 
	FETCH hogares_c INTO l_hogar;
	IF l_cursor_finished = 1 THEN 
			LEAVE getValores;
	END IF;
	SET @l_valor_factura = f_calcula_factura(l_hogar, p_año, p_mes);
	
	# Insertar/Actualizar Facturas
	CALL p_actualizar_registro_factura(l_hogar, p_año, p_mes, l_valor_factura);
	
END LOOP getValores;	
CLOSE hogares_c;

END$$
DELIMITER ;

# Procedimiento Actualizar Facturas x Estrato
DELIMITER $$
CREATE OR REPLACE PROCEDURE p_actualizar_facturas_estrato(
IN p_estrato INT, 
IN p_año INT,
IN p_mes INT
)
BEGIN 
DECLARE l_cursor_finished INT DEFAULT 0;
DECLARE l_hogar INT DEFAULT 0;
DECLARE l_valor_factura FLOAT DEFAULT 0;

# Cursor de Hogares para el municipio
DECLARE hogares_c  CURSOR FOR
	SELECT hogar 
	FROM hogares 
	WHERE estrato = p_estrato;

# NOT FOUND handler
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_cursor_finished = 1;
        
OPEN hogares_c;
getValores: LOOP 
	FETCH hogares_c INTO l_hogar;
	IF l_cursor_finished = 1 THEN 
			LEAVE getValores;
	END IF;
	SET @l_valor_factura = f_calcula_factura(l_hogar, p_año, p_mes);
	
	# Insertar/Actualizar Facturas
	CALL p_actualizar_registro_factura(l_hogar, p_año, p_mes, l_valor_factura);
	
END LOOP getValores;	
CLOSE hogares_c;

END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE PROCEDURE p_actualizar_facturas_hogar(
IN p_hogar INT 
)

BEGIN 
DECLARE l_cursor_finished INT DEFAULT 0;
DECLARE l_consumo INT DEFAULT 0;
DECLARE l_valor_factura FLOAT DEFAULT 0;

# Cursor de Hogares para el municipio
DECLARE consumos_c  CURSOR FOR
	SELECT c.`año`, c.mes
	FROM consumos c
	WHERE c.hogar = p_hogar;

# NOT FOUND handler
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_cursor_finished = 1;
        
OPEN consumos_c;
getValores: LOOP 
	FETCH consumos_c INTO l_consumo;
	IF l_cursor_finished = 1 THEN 
			LEAVE getValores;
	END IF;
	
	/*
	El video se corta y no estoy seguro de que hace el profe aquí :c
	SET @l_valor_factura = f_calcula_factura(p_hogar, p_año, p_mes);
	
	# Insertar/Actualizar Facturas
	CALL p_actualizar_registro_factura(l_hogar, p_año, p_mes, l_valor_factura);
	*/
END LOOP getValores;	
CLOSE consumos_c;

END$$
DELIMITER ;
# Procedimiento para ejecutar las facturas de los hogares
# de un municipio, por año y por mes
DELIMITER $$
CREATE OR REPLACE PROCEDURE p_ejecutar_facturas_hogares()
BEGIN 
DECLARE l_meses INT DEFAULT 1;
	while l_meses <=12 DO 
			call p_actualizar_facturas_municipio(1, 1, l_meses);
			SET l_meses = l_meses + 1;
		END while;
END $$
DELIMITER ;

# Custom queries
# Ver Hogares
SELECT DISTINCT 
	h.hogar,
	e.descripcion,
	m.descripcion
FROM hogares h JOIN estratos e ON e.estrato = h.estrato
	JOIN municipios m ON m.municipio = h.municipio;

# Consumos Pendientes Por Facturar
SELECT DISTINCT año, mes, COUNT(hogar) total_hogares
FROM consumos
WHERE(hogar,año,mes) NOT IN 
	(SELECT DISTINCT hogar,año,mes
	 FROM facturas)
GROUP BY año,mes 
ORDER BY 1,2,3;

# ==================================================
#		Sentencias de Validación del modelo de datos
# ==================================================

# Comentarios de Tablas
SELECT TABLE_NAME, table_comment 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE table_schema='tabd' ;

# Comentarios de Columnas
SELECT `table_name`,`column_name`, `column_type`, `column_default`, `column_comment`
from `information_schema`.`COLUMNS` 
WHERE table_schema='tabd'
ORDER BY `table_name` ;

# Sentencia para ver los constraints
SELECT TABLE_NAME,
       COLUMN_NAME,
       CONSTRAINT_NAME,
       REFERENCED_TABLE_NAME,
       REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = "tabd" 
      AND REFERENCED_COLUMN_NAME IS NOT NULL
ORDER BY TABLE_NAME;
