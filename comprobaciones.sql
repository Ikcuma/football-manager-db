-- 1
select * from entrenar_equips;

INSERT INTO entrenar_equips (data_fitxatge, entrenadors_id, equips_id)
VALUES ('2024-08-01', 3, 1);  -- ⚠️ Esto lanzará un error si ya hay un entrenador activo en ese equip

-- 2
select * from estadis;
delete from estadis where id = 26;
INSERT INTO estadis (nom, num_espectadors) VALUES ('Alfied', 2000);

-- 3
select * from entrenar_equips;
select * from ciutats;
select * from estadis;
select * from equips;

-- Crear nuevo equipo para comprobarlo
insert into ciutats (nom) values ('Londres');
insert into estadis (nom, num_espectadors) values ('Stamford Bridge', 5500);
INSERT INTO equips (nom, any_fundacio, nom_president, ciutats_id, estadis_id)
VALUES ('Stamford Bridge', 1905, 'Era Boehly', 17, 27);
INSERT INTO entrenar_equips (data_fitxatge, entrenadors_id, equips_id)
VALUES ('2025-05-20', 1, 25);

-- 4
select * from persones;
delete from persones where id = 121;
INSERT INTO persones (nom, cognoms, data_naixement, nivell_motivacio, sou, tipus_persona) 
VALUES ('jOaN', 'viDal', '1985-04-12', 7, 25000, 'jugador');

SELECT nom, cognoms FROM persones;