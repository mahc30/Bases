# Julio 21 TABD
# Incapacidades Estudiantes
# Mariadb
# Usuario/esquema: admin_inc@incapacidades_estudiantes
# Miguel Ángel Hincapié Calle ID: 000148441
# ====================
# Creación de Usuario
# ====================

CREATE USER 'admin_inc'@'localhost' IDENTIFIED BY 'securePassword';
GRANT SELECT, INSERT, UPDATE, ALTER, DROP ON incapacidades_estudiantes.* TO 'admin_inc'@'localhost';
GRANT CREATE ON incapacidades_estudiantes.* TO 'admin_inc'@'localhost';
GRANT CREATE ROUTINE  ON incapacidades_estudiantes.* TO 'admin_inc'@'localhost';
GRANT CREATE VIEW ON incapacidades_estudiantes.* TO 'admin_inc'@'localhost';
GRANT TRIGGER  ON incapacidades_estudiantes.* TO 'admin_inc'@'localhost';
GRANT FILE ON *.* TO 'admin_inc'@'localhost';
FLUSH PRIVILEGES;
FLUSH HOSTS;

# ====================
# Creación de Tablas
# ====================
CREATE OR REPLACE DATABASE incapacidades_estudiantes;
USE incapacidades_estudiantes;

# Tabla: Municipios
CREATE TABLE municipios
(
	id INT NOT NULL,
	nombre VARCHAR(28) NOT NULL
);

# Comentarios Municipios
ALTER TABLE municipios COMMENT 'Municipios';
ALTER TABLE municipios CHANGE id id INT NOT NULL COMMENT "Código del Municipio";
ALTER TABLE municipios CHANGE nombre nombre VARCHAR(28) NOT NULL COMMENT "Nombre del Municipio";

# Constrains Municipios
ALTER TABLE municipios ADD CONSTRAINT municipios_pk PRIMARY KEY(id);

SELECT * FROM municipios;

# TABLA Enfermedades
CREATE TABLE enfermedades
(
	id INT NOT NULL COMMENT "ID de la Enfermedad",
	nombre VARCHAR(28) NOT NULL COMMENT "Nombre de la Enfermedad"
);

ALTER TABLE enfermedades COMMENT 'Enfermedades';
ALTER TABLE enfermedades ADD CONSTRAINT enfermedades_pk PRIMARY KEY (id);


# TABLA Colegios
CREATE TABLE colegios
(
	id INT NOT NULL COMMENT "ID del Colegio",
	nombre VARCHAR(28) NOT NULL COMMENT "Nombre del Colegio",
	id_municipio INT NOT NULL COMMENT "ID del Municipio al que pertenece el Colegio"
);

ALTER TABLE colegios COMMENT 'Colegios';
ALTER TABLE colegios ADD CONSTRAINT colegios_pk PRIMARY KEY(id);
ALTER TABLE colegios ADD CONSTRAINT colegios_municipio_fk FOREIGN KEY (id_municipio) REFERENCES municipios(id);

# TABLA Alumnos
CREATE TABLE alumnos
(
	id INT NOT NULL COMMENT "ID del Alumno",
	nombre VARCHAR(28) NOT NULL COMMENT "Nombre del Alumno",
	edad INT NOT NULL COMMENT "Edad del Alumno",
	genero VARCHAR(1) NOT NULL COMMENT "Género del Alumno",
	id_colegio INT NOT NULL COMMENT "ID del colegio al que pertenece el alumno"
);

ALTER TABLE alumnos COMMENT 'Alumnos';
ALTER TABLE alumnos ADD CONSTRAINT alumnos_pk PRIMARY KEY(id);
ALTER TABLE alumnos ADD CONSTRAINT alumnos_colegio_fk FOREIGN KEY (id_colegio) REFERENCES colegios (id);

# Tabla Incapacidades
CREATE TABLE incapacidades
(
	id INT NOT NULL COMMENT "ID de la Incapacidad",
	id_alumno INT NOT NULL COMMENT "ID del Alumno",
	id_enfermedad INT NOT NULL COMMENT "ID de la enfermedad",
	fecha_inicio VARCHAR(28) NOT NULL COMMENT "Fecha de inicio de la Incapacidad",
	duracion_dias INT NOT NULL COMMENT "Duración de la Incapacidad"
);

ALTER TABLE incapacidades COMMENT 'Incapacidades';
ALTER TABLE incapacidades ADD CONSTRAINT incapacidades_pk PRIMARY KEY(id);
ALTER TABLE incapacidades ADD CONSTRAINT incapacidades_alumno_fk FOREIGN KEY (id_alumno) REFERENCES alumnos (id);
ALTER TABLE incapacidades ADD CONSTRAINT incapacidades_enfermedad_fk FOREIGN KEY (id_enfermedad) REFERENCES enfermedades (id);


# ==================================================
#								VIEWS
# ==================================================

# Detalle Alumno
CREATE OR REPLACE VIEW detalle_alumno AS (
	SELECT DISTINCT 
	a.nombre AS nombre_alumno,
	a.edad AS edad_alumno,
	a.genero AS genero_alumno,
	c.nombre AS nombre_colegio,
	m.nombre AS nombre_municipio
	FROM alumnos a JOIN colegios c ON a.id_colegio = c.id
						join municipios m ON c.id_municipio = m.id
		
);

# Detalle Incapacidad
CREATE OR REPLACE VIEW detalle_incapacidad AS (
	SELECT DISTINCT 
	a.nombre AS nombre_alumno,
	a.edad AS edad_alumno,
	a.genero AS genero_alumno,
	c.nombre AS nombre_colegio,
	m.nombre AS nombre_municipio,
	e.nombre AS nombre_enfermedad,
	i.fecha_inicio AS inicio_incapacidad,
	i.duracion_dias AS duracion_incapacidad
	FROM alumnos a JOIN colegios c ON a.id_colegio = c.id
						join municipios m ON c.id_municipio = m.id
						JOIN incapacidades i ON i.id_alumno = a.id
						join enfermedades e ON i.id_enfermedad = e.id
		
);

# Mayor Incapacidad de Enfermedad x Municipio
CREATE OR REPLACE VIEW mayor_enfermedad AS (
	SELECT DISTINCT 
	m.nombre AS nombre_municipio,
	e.nombre AS nombre_enfermedad,
	COUNT(i.id_enfermedad) AS numero_de_incapacidades
	FROM alumnos a JOIN colegios c ON a.id_colegio = c.id
						JOIN municipios m ON c.id_municipio = m.id
						JOIN incapacidades i ON i.id_alumno = a.id
						JOIN enfermedades e ON i.id_enfermedad = e.id
	GROUP BY nombre_municipio
);

# Promedio edad estudiante incapacitado por cada enfermedad
CREATE OR REPLACE VIEW promedio_enfermedad AS (
	SELECT DISTINCT 
	e.nombre AS nombre_enfermedad,
	AVG(a.edad) AS promedio_edad
	FROM alumnos a JOIN colegios c ON a.id_colegio = c.id
						JOIN municipios m ON c.id_municipio = m.id
						JOIN incapacidades i ON i.id_alumno = a.id
						JOIN enfermedades e ON i.id_enfermedad = e.id
	GROUP BY nombre_enfermedad
);
# ==================================================
#		Sentencias de Validación del modelo de datos
# ==================================================

# Comentarios de Tablas
SELECT TABLE_NAME, table_comment 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE table_schema='incapacidades_estudiantes';

# Comentarios de Columnas
SELECT `table_name`,`column_name`, `column_type`, `column_default`, `column_comment`
from `information_schema`.`COLUMNS` 
WHERE table_schema='incapacidades_estudiantes'
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