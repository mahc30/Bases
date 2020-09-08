# Base de Datos Sismos para visualización con medoo
# Por:
# - Carolina Monsalve Vásquez ID: 000367045
# - Dan Ellis Echavarría ID: 000366765
# - Miguel Ángel Hincapié Calle ID: 000148441

create database if not exists sismos_db CHARACTER SET utf8 COLLATE utf8_general_ci;

/*
#Usuario con el que se trabajó
CREATE USER 'sismos_usr'@'%' IDENTIFIED BY 'UnaClav3';
GRANT SELECT, INSERT, UPDATE, ALTER, DROP ON sismos_db.* TO 'sismos_usr';
GRANT CREATE ON sismos_db.* TO 'sismos_usr'@'%';
GRANT CREATE ROUTINE ON sismos_db.* TO 'sismos_usr'@'%';
GRANT CREATE VIEW ON sismos_db.* TO 'sismos_usr'@'%';
GRANT TRIGGER ON sismos_db.* TO 'sismos_usr'@'%';
GRANT FILE ON *.* TO 'sismos_usr'@'%';
FLUSH PRIVILEGES;
FLUSH HOSTS;
*/

use sismos_db;

# Creación de Tablas

select *
from temp;

create table `regiones`
(
    id     int primary key not null auto_increment comment 'Id de la región',
    region varchar(256)    not null
);

CREATE TABLE `sismos`
(
    `fecha`       date  NOT NULL comment 'Fecha del sismo',
    `hora`        int   not null comment 'Hora del sismo',
    `latitud`     float not null comment '(Coordenada) Latitud',
    `longitud`    float not null comment '(Coordenada) Longitud',
    `profundidad` float not null comment 'Profundidad en Kms',
    `magnitud`    float not null comment 'Magnitud del sismo',
    `id_region`   int   NOT NULL comment 'Municipios en que se detectó el sismo'


);
alter table sismos
    add constraint sismos_region_fk foreign key (id_region) references sismos_db.regiones (id);


# =============================
#           Llenar tablas
# =============================

truncate table sismos;
drop table sismos;

insert into regiones(region)
select distinct Región
from Proyecto04_SismosAntioquia_datos_2019_20200901;
select *
from regiones;

INSERT INTO sismos(fecha, hora, latitud, longitud, profundidad, magnitud, id_region)
SELECT cast(t.`Fecha-Hora  (UTC)` as date),
       TIME_FORMAT(t.`Fecha-Hora  (UTC)`, "%H"),
        cast(REPLACE(t.Latitud,",",".") as float),
        cast(REPLACE(t.Longitud,",",".") as float),
        cast(REPLACE(t.`Profundidad en Kms`,",",".") as float),
    cast(REPLACE(t.Magnitud,",",".") as float),
       r.id
FROM Proyecto04_SismosAntioquia_datos_2019_20200901 t
         join regiones r on t.Región = r.region;
select *
from sismos;

select longitud from sismos;
create view v_req01 as
(
select distinct hora as hora_dia, count(*) as total_temblores
from sismos
group by hora
    );

create view v_req02 as
(
select distinct fecha as fecha, count(*) as total_temblores
from sismos
group by fecha
    );

create view v_req03 as
(
select distinct r.region           as region,
                count(*)           as total_temblores,
                avg(s.profundidad) as promedio_profundidad
from sismos s
         join regiones r on s.id_region = r.id
group by region
    );

create view v_req04 as
(
WITH `range1` AS (
    SELECT COUNT(*) AS `count`
    FROM `sismos`
    WHERE `magnitud` >= 0
      AND `magnitud` < 1
),
     `range2` AS (
         SELECT COUNT(*) AS `count`
         FROM `sismos`
         WHERE `magnitud` >= 1
           AND `magnitud` < 2
     ),
     `range3` AS (
         SELECT COUNT(*) AS `count`
         FROM `sismos`
         WHERE `magnitud` >= 2
           AND `magnitud` < 3
     ),
     `range4` AS (
         SELECT COUNT(*) AS `count`
         FROM `sismos`
         WHERE `magnitud` >= 3
           AND `magnitud` < 4
     ),
     `range5` AS (
         SELECT COUNT(*) AS `count`
         FROM `sismos`
         WHERE `magnitud` >= 4
     )
SELECT `range1`.`count` AS `desde_0_a0_99`,
       `range2`.`count` AS `desde_1_a1_99`,
       `range3`.`count` AS `desde_2_a2_99`,
       `range4`.`count` AS `desde_3_a3_99`,
       `range5`.`count` AS `mas_de_4`
FROM `range1`
         CROSS JOIN `range2`
         CROSS JOIN `range3`
         CROSS JOIN `range4`
         CROSS JOIN `range5`
    );

create view temblores as
(
select *
from sismos s
    );
