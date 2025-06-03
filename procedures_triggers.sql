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

-- 8
DELIMITER //

CREATE TRIGGER increment_sou_jugador
BEFORE UPDATE ON persones
FOR EACH ROW
BEGIN
	DECLARE es_jugador INT;
    
    SELECT COUNT(*) INTO es_jugador
    FROM jugadors
    WHERE persones_id = OLD.id;
    
    IF  es_jugador > 0 AND NEW.sou > OLD.sou THEN
		INSERT INTO canvis_sou_jugadors (jugador_id, sou_antic, sou_nou)
        VALUES (OLD.id, OLD.sou, NEW.sou);
	END IF;
END //

DELIMITER ;

-- 9
DELIMITER //

CREATE TRIGGER log_canvi_president
AFTER UPDATE ON equips
FOR EACH ROW
BEGIN
	IF OLD.nom_president <> NEW.nom_president THEN
		INSERT INTO log_equips_modificats (nom_equip, president_antic, president_nou, data_canvi)
		VALUES (NEW.nom, OLD.nom_president, NEW.nom_president, NOW());
	END IF;
END; //

DELIMITER ;

-- 10
DELIMITER //

CREATE TRIGGER trg_control_jornada_repetida
BEFORE INSERT ON jornades
FOR EACH ROW
BEGIN
    DECLARE num_jornades INT;

    SELECT COUNT(*) INTO num_jornades
    FROM jornades
    WHERE jornada = NEW.jornada AND lligues_id = NEW.lligues_id;

    IF num_jornades > 0 THEN
        INSERT INTO log_errors_jornades (jornada, lligues_id, missatge_error)
        VALUES (NEW.jornada, NEW.lligues_id, 'Jornada repetida per a la mateixa lliga');
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Ja existeix aquesta jornada per a la lliga indicada.';
    END IF;
END; //

DELIMITER ;

-- 11
drop trigger abans_esborrar_jugador;
DELIMITER //

CREATE TRIGGER abans_esborrar_jugador
BEFORE DELETE ON jugadors
FOR EACH ROW
BEGIN
    DECLARE v_nom VARCHAR(45);
    DECLARE v_cognoms VARCHAR(45);
    DECLARE v_data_naixement DATE;
    DECLARE v_nivell_motivacio INT;
    DECLARE v_sou FLOAT;
    DECLARE v_tipus_persona VARCHAR(45);

    -- Obtenemos datos de la persona relacionada
    SELECT nom, cognoms, data_naixement, nivell_motivacio, sou, tipus_persona
    INTO v_nom, v_cognoms, v_data_naixement, v_nivell_motivacio, v_sou, v_tipus_persona
    FROM persones
    WHERE id = OLD.persones_id;

    -- Insertamos en jugadors_eliminats
    INSERT INTO jugadors_eliminats (
        persones_id, nom, cognoms, data_naixement, nivell_motivacio,
        sou, tipus_persona, dorsal, qualitat, posicions_id
    )
    VALUES (
        OLD.persones_id, v_nom, v_cognoms, v_data_naixement, v_nivell_motivacio,
        v_sou, v_tipus_persona, OLD.dorsal, OLD.qualitat, OLD.posicions_id
    );
END //

DELIMITER ;

-- 13
DELIMITER //

CREATE PROCEDURE estadistiques_jugador (
    IN jugador_id INT
)
BEGIN
    DECLARE total_gols INT DEFAULT 0;
    DECLARE total_partits INT DEFAULT 0;

    -- Contar total de goles del jugador
    SELECT COUNT(*) INTO total_gols
    FROM partits_gols
    WHERE jugadors_id = jugador_id;

    -- Contar total de partidos en los que el jugador ha marcado
    SELECT COUNT(DISTINCT partits_id) INTO total_partits
    FROM partits_gols
    WHERE jugadors_id = jugador_id;

    -- Mostrar resultados
    SELECT 
        jugador_id AS 'ID jugador',
        total_gols AS 'Total de goles',
        total_partits AS 'Total de partidos jugados (con goles)';
END //

DELIMITER ;

-- 14
drop procedure reassignar_entrenador;
DELIMITER //

CREATE PROCEDURE reassignar_entrenador (
    IN p_equip_id INT,
    IN p_entrenador_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Finalizar contrato activo del entrenador (si existe)
    UPDATE entrenar_equips
    SET data_baixa = CURDATE()
    WHERE entrenadors_id = p_entrenador_id AND data_baixa IS NULL;

    -- Finalizar contrato activo del equipo (si existe)
    UPDATE entrenar_equips
    SET data_baixa = CURDATE()
    WHERE equips_id = p_equip_id AND data_baixa IS NULL;

    -- Insertar nuevo contrato
    INSERT INTO entrenar_equips (data_fitxatge, entrenadors_id, equips_id, data_baixa)
    VALUES (CURDATE(), p_entrenador_id, p_equip_id, NULL);

    COMMIT;
END //

DELIMITER ;

-- 15
drop procedure estadistica_gols_per_lliga;
DELIMITER //

CREATE PROCEDURE estadistica_gols_per_lliga (
    IN p_lliga_nom VARCHAR(100)
)
BEGIN
    DECLARE v_lliga_id INT;

    -- Obtener el ID de la lliga
    SELECT id INTO v_lliga_id
    FROM lligues
    WHERE nom = p_lliga_nom;

    -- Crear tabla temporal con goles por jugador en esa liga
    CREATE TEMPORARY TABLE IF NOT EXISTS gols_per_jugador AS
    SELECT 
        pg.jugadors_id,
        COUNT(*) AS total_gols
    FROM partits_gols pg
    JOIN partits p ON pg.partits_id = p.id
    JOIN jornades j ON p.jornades_id = j.id
    WHERE j.lligues_id = v_lliga_id
    GROUP BY pg.jugadors_id;

    -- Inserciones individuales para evitar el error 1137
    INSERT INTO golejadors (categoria, total_jugadors, lliga, data_calcul)
    SELECT '+10 gols', COUNT(*), p_lliga_nom, NOW()
    FROM gols_per_jugador
    WHERE total_gols > 10;

    INSERT INTO golejadors (categoria, total_jugadors, lliga, data_calcul)
    SELECT '+20 gols', COUNT(*), p_lliga_nom, NOW()
    FROM gols_per_jugador
    WHERE total_gols > 20;

    INSERT INTO golejadors (categoria, total_jugadors, lliga, data_calcul)
    SELECT '+30 gols', COUNT(*), p_lliga_nom, NOW()
    FROM gols_per_jugador
    WHERE total_gols > 30;

    -- Limpiar
    DROP TEMPORARY TABLE IF EXISTS gols_per_jugador;

END //

DELIMITER ;

-- 16
DELIMITER //

CREATE PROCEDURE transferir_jugador (
    IN p_jugador_id INT,
    IN p_equip_origen INT,
    IN p_equip_nou INT
)
BEGIN
    DECLARE jugador_exist INT DEFAULT 0;
    DECLARE equip_origen_exist INT DEFAULT 0;
    DECLARE equip_nou_exist INT DEFAULT 0;
    DECLARE vinculacion_actual INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error en la transferencia, transacción cancelada';
    END;

    START TRANSACTION;

    -- Verificar que el jugador existe
    SELECT COUNT(*) INTO jugador_exist FROM jugadors WHERE persones_id = p_jugador_id;
    IF jugador_exist = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jugador no existe';
    END IF;

    -- Verificar que el equipo origen existe
    SELECT COUNT(*) INTO equip_origen_exist FROM equips WHERE id = p_equip_origen;
    IF equip_origen_exist = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Equipo origen no existe';
    END IF;

    -- Verificar que el equipo nuevo existe
    SELECT COUNT(*) INTO equip_nou_exist FROM equips WHERE id = p_equip_nou;
    IF equip_nou_exist = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Equipo nuevo no existe';
    END IF;

    -- Verificar que el jugador está vinculado al equipo origen y sin baja
    SELECT COUNT(*) INTO vinculacion_actual
    FROM jugadors_equips
    WHERE jugadors_id = p_jugador_id AND equips_id = p_equip_origen AND data_baixa IS NULL;

    IF vinculacion_actual = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jugador no está vinculado al equipo origen o ya tiene fecha de baja';
    END IF;

    -- Actualizar fecha de baja en la vinculación actual
    UPDATE jugadors_equips
    SET data_baixa = CURDATE()
    WHERE jugadors_id = p_jugador_id AND equips_id = p_equip_origen AND data_baixa IS NULL;

    -- Insertar nueva vinculación con el nuevo equipo
    INSERT INTO jugadors_equips (data_fitxatge, jugadors_id, equips_id, data_baixa)
    VALUES (CURDATE(), p_jugador_id, p_equip_nou, NULL);

    COMMIT;
END //

DELIMITER ;