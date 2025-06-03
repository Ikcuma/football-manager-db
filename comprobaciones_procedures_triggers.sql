select * from ciutats;


-- pruebas para comprobar si funciona

-- 8
CREATE TABLE canvis_sou_jugadors (
	jugador_id INT NOT NULL,
    sou_antic FLOAT NOT NULL,
    sou_nou FLOAT NOT NULL,
    data_canvi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FOREIGN KEY (jugador_id) REFERENCES jugadors (persones_id)
);

select * from persones;
select * from jugadors;


update persones
set sou = 9000000
where id = 21;

select * from canvis_sou_jugadors;

-- 9
drop table log_equips_modificats;
CREATE TABLE log_equips_modificats (
	id INT AUTO_INCREMENT,
    nom_equip VARCHAR (45) NOT NULL,
    president_antic VARCHAR (45) DEFAULT NULL,
    president_nou VARCHAR(45) DEFAULT NULL,
    data_canvi DATETIME NOT NULL,
    CONSTRAINT pk_log_equips_modificats PRIMARY KEY (id)
);

select * from equips;

update equips
set nom_president = 'Marta Lopez'
where id = 1 ;

select * from log_equips_modificats;

-- 10
drop table log_errors_jornades;
CREATE TABLE log_errors_jornades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    jornada INT NOT NULL,
    lligues_id INT NOT NULL,
    data_error DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    missatge_error VARCHAR(255) NOT NULL
);

select * from jornades;
INSERT INTO jornades (jornada, data, lligues_id) VALUES (1, '2025-10-08', 1);

-- 11
drop table jugadors_eliminats2;
CREATE TABLE jugadors_eliminats (
    persones_id INT PRIMARY KEY,
    nom VARCHAR(45),
    cognoms VARCHAR(45),
    data_naixement DATE,
    nivell_motivacio INT,
    sou FLOAT,
    tipus_persona VARCHAR(45),
    dorsal INT,
    qualitat INT,
    posicions_id INT,
    eliminat_a TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select * from persones;

delete from jugadors where persones_id = 25;
-- No, funciona en todos los casos
-- El trigger no funciona si hay claves foráneas que impiden borrar al jugador, ya que MySQL bloquea la eliminación para mantener la integridad de datos. Por eso, falla cuando existen referencias en otras tablas que no se eliminan antes.

-- 13
select * from partits_gols;
select * from partits;
CALL estadistiques_jugador(25);

-- 14
select * from persones;
select * from equips;
select * from estadis;
select * from ciutats;
call reassignar_entrenador(2, 2);
select * from entrenar_equips;
insert into estadis (nom, num_espectadors) values ('Estadio', 85000);
insert into ciutats (nom) values ('Ciudad');
insert into equips (nom, any_fundacio, nom_president, ciutats_id, estadis_id) values ('Equipo', 1995, 'Presidente', 18, 28);

-- 15
CREATE TABLE IF NOT EXISTS golejadors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  categoria VARCHAR(20), -- Ex: '+10 gols'
  total_jugadors INT,
  lliga VARCHAR(100),
  data_calcul TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select * from golejadors where lliga = 'La Liga EA Sports';
call estadistica_gols_per_lliga('La Liga EA Sports');

-- 16
select * from persones;
select * from jugadors;
select * from equips;
select * from jugadors_equips;
call transferir_jugador(21, 1, 2);