ccreate database if not exists covid19 CHARACTER SET utf8 COLLATE utf8_general_ci;
use covid19;
# Creación de Tablas

CREATE TABLE `atenciones`
(
    `id`    int unsigned NOT NULL AUTO_INCREMENT comment 'Código de la atención',
    `descr` varchar(32)  NOT NULL comment 'Descripción de la atención',

    PRIMARY KEY (`id`)
);

CREATE TABLE `departamentos`
(
    `id`    int unsigned NOT NULL comment 'Código del Departamento',
    `descr` varchar(64)  NOT NULL comment 'Nombre del Departamento',
    `sigla` varchar(3)   NOT NULL comment 'Abreviación/sigla del Departamento',

    PRIMARY KEY (`id`)
);

CREATE TABLE `ciudades`
(
    `id`            int unsigned NOT NULL comment 'Código de la ciudad',
    `nombre_ciudad` varchar(32)  NOT NULL comment 'Nombre de la ciudad',
    `departamento`  int unsigned NOT NULL comment 'Código del Departamento al que pertenece la ciudad',

    PRIMARY KEY (`id`),
    KEY `departamento` (`departamento`),
    CONSTRAINT `fk_ciudades_departamento` FOREIGN KEY `departamento` (`departamento`) REFERENCES `departamentos` (`id`)
);

CREATE TABLE `estados`
(
    `id`    int unsigned NOT NULL AUTO_INCREMENT comment 'Código del estado de la enfermedad',
    `descr` varchar(32)  NULL comment 'Descripción del estado de la enfermedad',

    PRIMARY KEY (`id`)
);

CREATE TABLE `casos`
(
    `id`                  int unsigned NOT NULL AUTO_INCREMENT comment 'Código del caso',
    `atencion`            int unsigned NOT NULL comment 'Código del tipo de atención',
    `estado`              int unsigned NOT NULL comment 'Código del tipo de estado',
    `ciudad`              int unsigned NOT NULL comment 'Código de la ciudad en que se encuentra el caso',
    `edad`                int unsigned NOT NULL comment 'Edad del paciente que reporta el caso',
    `sexo`                varchar(1)   NOT NULL comment 'Sexo del paciente que reporta el caso',
    `fecha_inicio`        date comment 'Fecha de Inicio de la enfermedad en el paciente',
    `fecha_fallecimiento` date comment 'Fecha de Fallecimiento del paciente',
    `fecha_diagnostico`   date comment 'Fecha de Diagnóstico de la enfermedad en el paciente',
    `fecha_recuperacion`  date comment 'Fecha de Recuperación del paciente',
    `fecha_reporte`       date         NOT NULL comment 'Fecha del Reporte de la enfermedad',

    PRIMARY KEY (`id`),
    KEY `atencion` (`atencion`),
    CONSTRAINT `fk_casos_atencion` FOREIGN KEY `atencion` (`atencion`) REFERENCES `atenciones` (`id`),
    KEY `estado` (`estado`),
    CONSTRAINT `fk_casos_estado` FOREIGN KEY `estado` (`estado`) REFERENCES `estados` (`id`),
    KEY `ciudad` (`ciudad`),
    CONSTRAINT `fk_casos_ciudad` FOREIGN KEY `ciudad` (`ciudad`) REFERENCES `ciudades` (`id`)
);

create table tipo_registros
(
    id    int not null auto_increment primary key comment 'ID del Tipo de Registro',
    descr varchar(16) comment 'Descripción Tipo registro'
);

CREATE TABLE consolidados
(
    fecha        date         not null,
    tipo         int unsigned not null,
    departamento int unsigned not null,
    acumulado    int          not null,

    PRIMARY KEY (`fecha`, `departamento`, `tipo`),
    KEY `departamento` (`departamento`),
    CONSTRAINT `fk_consolidados_departamento` FOREIGN KEY `departamento` (`departamento`) REFERENCES departamentos (`id`),
    KEY `tipo` (`tipo`),
    CONSTRAINT `fk_consolidados_tipo` FOREIGN KEY `tipo` (`tipo`) REFERENCES estados (`id`)
);

# =============================
#           Llenar tablas
# =============================

INSERT INTO atenciones (descr)
SELECT distinct i.atencion
FROM import_table i;

# La columna de Estados tiene registros nulos
# Sin embargo es necesario que no hayan campos nulos para importar los datos
# de casos completos, para mantener el estándar de nombres y registros
# Se reemplazan los NULL por "N/A" así como en la tabla de Atenciones

update import_table
set Estado = 'N/A'
where Estado is null;

INSERT INTO estados (descr)
SELECT distinct i.Estado
FROM import_table i;

INSERT INTO departamentos (id, descr, sigla)
SELECT distinct i.codigo_departamento, i.nombre_departamento, i.sigla_departamento
FROM import_table i;

INSERT INTO ciudades (id, nombre_ciudad, departamento)
SELECT distinct i.Codigo_ciudad, i.nombre_ciudad, i.codigo_departamento
FROM import_table i;

# La tabla de importación de datos 'import_table' tiene problemas de consistencia en la columna de
# id_caso, del id_caso 4155 salta al 4170, por esta razón, se reinicia/corrige esta columna con la siguiente consulta
ALTER TABLE import_table
    DROP id_caso;
ALTER TABLE import_table
    AUTO_INCREMENT = 1;
ALTER TABLE import_table
    ADD id_caso int UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

#En este punto todos los problemas de calidad de datos deberían estar solucionados
#Por lo que finalmente podemos llenar la tabla de casos
INSERT INTO casos(atencion, estado, ciudad, edad, sexo,
                  fecha_inicio, fecha_fallecimiento, fecha_diagnostico,
                  fecha_recuperacion, fecha_reporte)
SELECT a.id,
       e.id,
       c.id,
       i.Edad,
       i.Sexo,
       STR_TO_DATE(i.fecha_inicio_sintomas, '%d/%m/%Y'),
       STR_TO_DATE(i.fecha_fallecimiento, '%d/%m/%Y'),
       STR_TO_DATE(i.fecha_diagnostico, '%d/%m/%Y'),
       STR_TO_DATE(i.fecha_recuperacion, '%d/%m/%Y'),
       STR_TO_DATE(i.fecha_reporte, '%d/%m/%Y')
FROM import_table i
         join atenciones a on a.descr = i.atencion
         join estados e on e.descr = i.Estado
         join ciudades c on c.id = i.Codigo_ciudad;

insert into tipo_registros(id, descr)
VALUES (1, 'Contagio'),
       (2, 'Fallecimiento'),
       (3, 'Recuperado'),
       (4, 'Activo');

# Para verificar que todos los registros fueron importados correctamente
SELECT 'Cantidad_Casos' casos, COUNT(*)
FROM casos
UNION
SELECT 'Casos_Por_Importar' import_table, COUNT(*)
FROM import_table;

# =======================================
#                 Funciones
# =======================================
# Obtener Casos x Departamento hasta la fecha
DROP FUNCTION f_contar_casos_x_departamento;
DELIMITER $$
CREATE FUNCTION f_contar_casos_x_departamento(p_departamento int,
                                              p_fecha date) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE l_total_casos INT default 0;

    SELECT COUNT(c.id)
    INTO l_total_casos
    FROM casos c
             JOIN ciudades c2 on c.ciudad = c2.id
    WHERE c2.departamento = p_departamento
      AND c.fecha_reporte <= p_fecha;

    RETURN l_total_casos;
END $$
DELIMITER ;

# VALIDAR TIPO DE REGISTRO
DELIMITER $$

CREATE FUNCTION f_validar_tipo_registro(fecha_fallecimiento date,
                                        fecha_recuperacion date) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE l_id_tipo int default 1;
    #Por defecto todos son contagiados
# Verificar si es recuperado
    IF (fecha_recuperacion IS NULL AND fecha_fallecimiento IS NULL) THEN
        SELECT id from tipo_registros WHERE descr = 'Activo' INTO l_id_tipo;
    ELSEIF (fecha_recuperacion IS NOT NULL AND fecha_fallecimiento IS NULL) THEN
        SELECT id from tipo_registros WHERE descr = 'Recuperado' INTO l_id_tipo;
    ELSEIF (fecha_fallecimiento IS NOT NULL) THEN
        SELECT id from tipo_registros WHERE descr = 'Fallecimiento' INTO l_id_tipo;
    END IF;

    return l_id_tipo;
END $$
DELIMITER ;

# =======================================
#           PROCEDIMIENTOS
# =======================================

# Consolidado por Fechas
DROP PROCEDURE p_consolidado_fechas;
DELIMITER $$
CREATE PROCEDURE p_consolidado_fechas()

BEGIN
    DECLARE l_accum int;
    DECLARE l_tipo int DEFAULT 1; #Contagio
    DECLARE l_cursor_finishedD INT DEFAULT 0;
    DECLARE l_id_departamento INT;

    DECLARE departamentos_c CURSOR FOR SELECT distinct id FROM departamentos;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_cursor_finishedD = 1;
    DEPARTAMENTOS:
    BEGIN
        # Cursor de departamentos
        OPEN departamentos_c;
        departamentosLoop:
        LOOP
            FETCH departamentos_c INTO l_id_departamento;
            IF l_cursor_finishedD = 1 THEN
                LEAVE departamentosLoop;
            END IF;

            #Cursor Fechas
            FECHAS:
            BEGIN
                DECLARE l_cursor_finishedF INT DEFAULT 0;
                DECLARE l_fecha_rep date;
                DECLARE fechas_c CURSOR FOR SELECT distinct fecha_reporte FROM casos;
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_cursor_finishedF = 1;
                OPEN fechas_c;

                fechasLoop:
                LOOP
                    FETCH fechas_c INTO l_fecha_rep;
                    IF l_cursor_finishedF = 1 THEN
                        LEAVE fechasLoop;
                    END IF;

                    SET l_accum = f_contar_casos_x_departamento(l_id_departamento, l_fecha_rep);
                    INSERT INTO consolidados(fecha, tipo, departamento, acumulado) VALUE (l_fecha_rep, l_tipo, l_id_departamento, l_accum);

                END LOOP fechasLoop;
                CLOSE fechas_c;
            END FECHAS;

        END LOOP departamentosLoop;
        CLOSE departamentos_c;
    END DEPARTAMENTOS;
# Confirmar Transacción
    COMMIT;

END$$
DELIMITER ;

SELECT distinct fecha, count(tipo) FROM consolidados GROUP BY fecha;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE table consolidados;
TRUNCATE table atenciones;
TRUNCATE table ciudades;
TRUNCATE table departamentos;
TRUNCATE table estados;
TRUNCATE table casos;
SET FOREIGN_KEY_CHECKS = 1;