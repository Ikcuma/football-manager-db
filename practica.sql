DROP database botiga_productes;
CREATE database botiga_productes;
USE botiga_productes;

CREATE TABLE dades_producte (
	codi INT auto_increment,
    nom VARCHAR(50) NOT NULL,
    categoria VARCHAR(50),
    preu DECIMAL (10,2),
    CONSTRAINT pk_dades_producte PRIMARY KEY (codi)
);

CREATE TABLE errors (
	data1 DATE,
    descripcio VARCHAR(100), 
    CONSTRAINT pk_errors PRIMARY KEY (data1, descripcio)
);

INSERT INTO dades_producte (nom, categoria, preu) VALUES
('Portàtil ASUS', 'Electrònica', 650.00),
('Televisor LG 55"', 'Electrònica', 720.00),
('Auriculars Sony', 'Accessoris', 120.00),
('Cafetera Nespresso', 'Electrodomèstics', 150.00),
('Smartphone Xiaomi', 'Electrònica', 300.00),
('Aspiradora Dyson', 'Electrodomèstics', 790.00),
('Tablet Samsung', 'Electrònica', 350.00),
('Monitor Dell 27"', 'Informàtica', 400.00),
('Impressora HP', 'Informàtica', 160.00),
('Consola Nintendo Switch', 'Oci', 320.00);

CALL mostrar_productes();

CALL mostrar_productes_preu(150, 400);

SET @resultat = 0;

CALL preu_mitja_categoria ('Electrònica', @resultat);

SELECT @resultat AS preu_mig;

select preu_IVA(100, 21);
select preu_IVA(50, 10);
select preu_IVA(200, 4);

SELECT 
    CODI,
    NOM,
    CATEGORIA,
    PREU AS preu_sense_iva,
    preuAmbIVA(PREU, 21) AS preu_amb_iva
FROM DADES_PRODUCTE;

SELECT 
    NOM,
    PREU AS preu_original,
    preu_IVA(PREU, 21) AS preu_amb_iva
FROM DADES_PRODUCTE
WHERE CATEGORIA = 'Electrònica';

SELECT comptar_productes_categoria('Electrònica');