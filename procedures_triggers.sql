-- 1
DELIMITER //

CREATE TRIGGER comprobar_entrenador
BEFORE INSERT ON entrenar_equips
FOR EACH ROW
BEGIN
	IF EXISTS (
		SELECT 1
        FROM entrenar_equips
        WHERE equips_id = NEW.equips_id
			AND data_baixa IS NULL
	) THEN
		SIGNAL SQLSTATE '45000'
        SET message_text = 'Només pot haver-hi un entrenador actiu per equip.';
	END IF;
END; //

DELIMITER ;

-- 2

DELIMITER //

CREATE TRIGGER comprobar_capacidad_estadi
BEFORE INSERT ON estadis 
FOR EACH ROW
BEGIN
	IF NEW.num_espectadors < 5000 THEN
		SET NEW.num_espectadors = 5000;
	ELSEIF NEW.num_espectadors > 100000 THEN
		SET NEW.num_espectadors = 100000;
	END IF;
END; //

DELIMITER ;

DELIMITER //

CREATE TRIGGER comprobar_capacidad_estadi
BEFORE UPDATE ON estadis
FOR EACH ROW
BEGIN
	IF NEW.num_espectadors < 5000 THEN
		SET NEW.num_espectadors = 5000;
	ELSEIF NEW.num_espectadors > 100000 THEN
		SET NEW.num_espectadors = 100000;
	END IF;
END //

DELIMITER ;

-- 3

DELIMITER //

CREATE TRIGGER comprobar_entrenador_equip
BEFORE INSERT ON entrenar_equips
FOR EACH ROW
BEGIN
	IF EXISTS (
		SELECT 1 FROM entrenar_equips
        WHERE entreandor_id = NEW.entrenadors_id
			AND data_baixa IS NULL
	) THEN
    SIGNAL SQLSTATE '45000'
    SET message_text = 'Error: entrenador ja té un contacte vigent';
    END IF;
END //

DELIMITER ;

-- no se puede debido a que no puedes hacer un UPDATE en la misma tabla que está siendo modificada por la instrucción que disparó el trigger
DELIMITER //

CREATE TRIGGER actualizar_contracte_entrenador
BEFORE INSERT ON entrenar_equips
FOR EACH ROW
BEGIN
	IF EXISTS (
		SELECT 1 FROM entrenar_equips
        WHERE entrenadors_id = NEW.entrenadors_id
			AND data_baixa IS NULL
	) THEN
    UPDATE entrenar_equips
    SET data_baixa = NEW.data_fitxatge
    WHERE entrenadors_id = NEW.entrenadors_id
		AND data_baiXa IS NULL;
	END IF;
END //

DELIMITER ;

-- 4

DELIMITER //

CREATE TRIGGER nom_cognoms_format
BEFORE INSERT ON persones
FOR EACH ROW
BEGIN
	SET NEW.nom = CONCAT (
		UPPER(SUBSTRING(NEW.nom, 1, 1)),
        LOWER(SUBSTRING(NEW.nom, 2))
	);
    SET NEW.cognoms = CONCAT(
		UPPER(SUBSTRING(NEW.cognoms, 1, 1)),
        LOWER(SUBSTRING(NEW.cognoms, 2))
	);
END //

CREATE TRIGGER nom_cognoms_format_update
BEFORE UPDATE ON persones
FOR EACH ROW
BEGIN
	SET NEW.nom = CONCAT (
		UPPER(SUBSTRING(NEW.nom, 1, 1)),
        LOWER(SUBSTRING(NEW.nom, 2))
	);
    SET NEW.cognoms = CONCAT(
		UPPER(SUBSTRING(NEW.cognoms, 1, 1)),
        LOWER(SUBSTRING(NEW.cognoms, 2))
	);
END //

DELIMITER ;

-- 5

DELIMITER //

CREATE TRIGGER limit_jugadors_equips
BEFORE INSERT ON jugadors_equips
FOR EACH ROW
BEGIN
	DECLARE num_jugadors_actius INT;
    
    SELECT COUNT(*) INTO num_jugadors_actius
    FROM jugadors_equips
    WHERE equips_id = NEW.equips_id
		AND data_baixa IS NULL;
	
    IF num_jugadors_actius >= 25 THEN
		SIGNAL SQLSTATE '4500'
        SET message_text = 'El equip ja té 25 jugadors actius, no es pot afegir més.';
	END IF;
END //

DELIMITER ;

-- 6

DELIMITER //

CREATE TRIGGER partits_duplicats
BEFORE INSERT ON partits
FOR EACH ROW
BEGIN
	DECLARE id_lliga_actual INT;
    
    SELECT lligues_id INTO id_lliga_actual
    FROM jornades
    WHERE id = NEW.jornades_id;
    
    IF EXISTS (
		SELECT 1
        FROM partits
        INNER JOIN jornades ON partits.jornades_id = jornades.id
        WHERE jornades.lligues_id = id_lliga_actual
        AND jornades.jornada = (SELECT jornada FROM jornades WHERE id = NEW.jornades_id)
        AND (
			(partits.equips_id_local = NEW.equips_id_local AND partits.equips_id_visitant = NEW.equips_id_visitant)
            OR
            (partits.equips_id_local = NEW.equips_id_visitant AND partits.equips_id_visitant = NEW.equips_id_local)
            )
		) THEN
			SIGNAL SQLSTATE '45000'
            SET message_text = 'Aquest partit ja existeix en la mateixa jornada i lliga amb aquests equips';
		END IF;
END //

DELIMITER ;

-- 7

DELIMITER //

CREATE TRIGGER partit_duplicat_equip
BEFORE INSERT ON partits
FOR EACH ROW
BEGIN
	DECLARE id_lliga_actual INT;
    DECLARE jornada_actual INT;
    
    SELECT lligues_id, jornada INTO id_lliga_actual, jornada_actual
    FROM jornades
    WHERE id = NEW.jornades_id;
    
    IF EXISTS (
		SELECT 1
        FROM partits
        INNER JOIN jornades ON partits.jornades_id = jornades.id
        WHERE jornades.lligues_id = id_lliga_actual
        AND jornades.jornada = jornada_actual
        AND (partits.equips_id_local = NEW.equips_id_local OR partits.equips_id_visitant = NEW.equips_id_local)
	) THEN
		SIGNAL SQLSTATE '45000'
        SET message_text = 'Equip local ja té un partit programat en aquesta jornada i lliga.';
	END IF;
    
    IF EXISTS (
		SELECT 1
        FROM partits
        INNER JOIN jornades ON partits.jornades_id = jornades.id
        WHERE jornades.lligues_id = id_lliga_actual
        AND jornades.jornada = jornada_actual
        AND (partits.equips_id_local = NEW.equips_id_visitant OR partits.equips_id_visitant = NEW.equips_id_visitant)
    ) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Equip visitant ja té un partit programat en aquesta jornada i lliga.';
    END IF;
END //

DELIMITER ;

-- Hola mundo
-- Hola mundo