create database if not exists covid19 CHARACTER SET utf8 COLLATE utf8_general_ci;
use covid19;
# Creación de Tablas

CREATE TABLE `atenciones`
(
 `id`    int unsigned NOT NULL AUTO_INCREMENT comment 'Código de la atención',
 `descr` varchar(32) NOT NULL comment 'Descripción de la atención',

PRIMARY KEY (`id`)
);

CREATE TABLE `departamentos`
(
 `id`    int unsigned NOT NULL comment  'Código del Departamento',
 `descr` varchar(64) NOT NULL comment 'Nombre del Departamento',
 `sigla` varchar(3) NOT NULL comment 'Abreviación/sigla del Departamento',

PRIMARY KEY (`id`)
);

CREATE TABLE `ciudades`
(
 `id`            int unsigned NOT NULL comment 'Código de la ciudad' ,
 `nombre_ciudad` varchar(32) NOT NULL comment  'Nombre de la ciudad',
 `departamento`  int unsigned NOT NULL comment  'Código del Departamento al que pertenece la ciudad',

PRIMARY KEY (`id`),
KEY `departamento` (`departamento`),
CONSTRAINT `fk_ciudades_departamento` FOREIGN KEY `departamento` (`departamento`) REFERENCES `departamentos` (`id`)
);

CREATE TABLE `estados`
(
 `id`    int unsigned NOT NULL AUTO_INCREMENT comment 'Código del estado de la enfermedad',
 `descr` varchar(32) NULL comment 'Descripción del estado de la enfermedad',

PRIMARY KEY (`id`)
);


CREATE TABLE `seguimientos`
(
 `id`                  int unsigned NOT NULL AUTO_INCREMENT comment 'Código del Seguimiento',
 `fecha_inicio`        date comment 'Fecha de Inicio de la enfermedad en el paciente',
 `fecha_fallecimiento` date comment 'Fecha de Fallecimiento del paciente',
 `fecha_diagnostico`   date comment 'Fecha de Diagnóstico de la enfermedad en el paciente',
 `fecha_recuperacion`  date comment 'Fecha de Recuperación del paciente',
 `fecha_reporte`       date NOT NULL comment 'Fecha del Reporte de la enfermedad',

PRIMARY KEY (`id`)
);

CREATE TABLE `casos`
(
 `id`            int unsigned NOT NULL AUTO_INCREMENT comment 'Código del caso',
 `atencion`      int unsigned NOT NULL comment 'Código del tipo de atención',
 `estado`        int unsigned NOT NULL comment 'Código del tipo de estado',
 `ciudad` int unsigned NOT NULL comment 'Código de la ciudad en que se encuentra el caso',
 `edad`          int unsigned NOT NULL comment 'Edad del paciente que reporta el caso',
 `sexo`          varchar(1) NOT NULL comment 'Sexo del paciente que reporta el caso',
 `seguimiento`   int unsigned NOT NULL comment 'Código del Seguimiento del caso',

PRIMARY KEY (`id`),
KEY `atencion` (`atencion`),
CONSTRAINT `fk_casos_atencion` FOREIGN KEY `atencion` (`atencion`) REFERENCES `atenciones` (`id`),
KEY `estado` (`estado`),
CONSTRAINT `fk_casos_estado` FOREIGN KEY `estado` (`estado`) REFERENCES `estados` (`id`),
KEY `ciudad` (`ciudad`),
CONSTRAINT `fk_casos_ciudad` FOREIGN KEY `ciudad` (`ciudad`) REFERENCES `ciudades` (`id`),
KEY `seguimiento` (`seguimiento`),
CONSTRAINT `fk_casos_seguimiento` FOREIGN KEY `seguimiento` (`seguimiento`) REFERENCES `seguimientos` (`id`)
);

# Llenar tablas
INSERT INTO atenciones (descr)
SELECT distinct i.atencion
FROM import_table i;

# La columna de Estados tiene registros nulos
# Sin embargo es necesario que no hayan campos nulos para importar los datos
# de casos completos, para mantener el estándar de nombres y registros
# Se reemplazan los NULL por "N/A" así como en la tabla de Atenciones

update import_table set Estado = "N/A" where Estado is null;

INSERT INTO estados (descr)
SELECT distinct i.Estado
FROM import_table i;

INSERT INTO departamentos (id, descr, sigla)
SELECT distinct i.codigo_departamento, i.nombre_departamento, i.sigla_departamento
FROM import_table i;

INSERT INTO ciudades (id, nombre_ciudad, departamento)
SELECT distinct i.Codigo_ciudad, i.nombre_ciudad, i.codigo_departamento
FROM import_table i;

INSERT INTO seguimientos(fecha_inicio, fecha_fallecimiento, fecha_diagnostico, fecha_recuperacion, fecha_reporte)
SELECT STR_TO_DATE(i.fecha_inicio_sintomas,'%d/%m/%Y'), STR_TO_DATE(i.fecha_fallecimiento,'%d/%m/%Y'), STR_TO_DATE(i.fecha_diagnostico,'%d/%m/%Y'), STR_TO_DATE(i.fecha_recuperacion,'%d/%m/%Y'), STR_TO_DATE(i.fecha_reporte,'%d/%m/%Y')
FROM import_table i;

# La tabla de importación de datos 'import_table' tiene problemas de consistencia en la columna de
# id_caso, del id_caso 4155 salta al 4170, por esta razón, se reinicia/corrige esta columna con la siguiente consulta
ALTER TABLE import_table DROP id_caso;
ALTER TABLE import_table AUTO_INCREMENT = 1;
ALTER TABLE import_table ADD id_caso int UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

#En este punto todos los problemas de calidad de datos deberían estar solucionados
#Por lo que finalmente podemos llenar la tabla de casos
INSERT INTO casos(atencion, estado, ciudad, edad, sexo, seguimiento)
SELECT a.id, e.id, c.id, i.Edad, i.Sexo, s.id
FROM import_table i
      join atenciones a on a.descr = i.atencion
     join estados e on e.descr = i.Estado
     join ciudades c on c.id = i.Codigo_ciudad
    join seguimientos s on s.id = i.id_caso;

select count(*) from seguimientos;
select count(*) from casos;
select count(*) from import_table i;

select * from casos where seguimiento not in (select id from seguimientos);
select * from import_table where Estado is null;
select * from casos
where atencion is null
or estado is null
or ciudad is null
or edad is null
or sexo is null
or seguimiento is null;

select * from casos where
id not in (select id from seguimientos)
or seguimiento not in (select id from seguimientos);

select * from casos where id != seguimiento;
select * from seguimientos where id > 4100;
select coalesce(Estado, "N/A") from import_table;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE table atenciones;
TRUNCATE table ciudades;
TRUNCATE table departamentos;
TRUNCATE table estados;
TRUNCATE table seguimientos;
TRUNCATE table casos;
SET FOREIGN_KEY_CHECKS = 1;
