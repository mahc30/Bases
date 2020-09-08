create database if not exists sismos_db CHARACTER SET utf8 COLLATE utf8_general_ci;
use sismos_db;


CREATE USER 'sismos_usr'@'%' IDENTIFIED BY 'UnaClav3';
GRANT SELECT, INSERT, UPDATE, ALTER, DROP ON sismos_db.* TO 'sismos_usr';
GRANT CREATE ON sismos_db.* TO 'sismos_usr'@'%';
GRANT CREATE ROUTINE ON sismos_db.* TO 'sismos_usr'@'%';
GRANT CREATE VIEW ON sismos_db.* TO 'sismos_usr'@'%';
GRANT TRIGGER ON sismos_db.* TO 'sismos_usr'@'%';
GRANT FILE ON *.* TO 'sismos_usr'@'%';
FLUSH PRIVILEGES;
FLUSH HOSTS;

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
       cast(t.Latitud as float),
       cast(t.Longitud as float),
       cast(t.`Profundidad en Kms` as float),
       cast(t.Magnitud as float),
       r.id
FROM Proyecto04_SismosAntioquia_datos_2019_20200901 t
         join regiones r on t.Región = r.region;
select *
from sismos;

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
select distinct region           as region,
                count(*)         as total_temblores,
                avg(profundidad) as promedio_profundidad
from sismos
group by region "desde_0_a0_99",
                            "desde_1_a1_99",
                            "desde_2_a2_99",
                            "desde_3_a3_99",
                            "mas_de_4"
    );
select '0-1' as Range1, coalesce(avg(magnitud), 0) as "desde_0_a0_99"
from sismos
where magnitud > 0
  and magnitud <= 1
union
select '1-2' as Range1, coalesce(avg(magnitud), 0) as "desde_1_a1_99"
from sismos
where magnitud > 1
  and magnitud <= 2
union
select '2-3' as Range1, coalesce(avg(magnitud), 0) as "desde_2_a2_99"
from sismos
where magnitud > 2
  and magnitud <= 3
union
select '3-4' as Range1, coalesce(avg(magnitud), 0) as "desde_3_a3_99"
from sismos
where magnitud > 3
  and magnitud <= 4
union
select '4+' as Range1, coalesce(avg(magnitud), 0) as "mas_de_4"
from sismos
where magnitud > 4;

create view temblores as
(
select *
from sismos s
    );
