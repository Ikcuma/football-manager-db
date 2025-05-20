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