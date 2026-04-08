-- TESTEO
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;



--INSERTAR COMUNIDADES AUTONOMAS
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Andalucía', 1.02);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Aragón', 1.3);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Asturias', 1.02);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Islas Baleares', 1.07);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Canarias', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Cantabria', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Castilla-La Mancha', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Castilla y León', 1.2);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Cataluña', 1.05);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Comunidad Valenciana', 1.07);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Extremadura', 1.02);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Galicia', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Comunidad de Madrid', 1.07);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Región de Murcia', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('Navarra', 1.07);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('País Vasco', 1.07);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('La Rioja', 1.03);

--PROVINCIAS
-- Andalucía (1)
INSERT INTO provincia (idccaa,nombre) VALUES (1,'Almería');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'Cádiz');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'Córdoba');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'Granada');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'Huelva');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'Jaén');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'Málaga');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'Sevilla');

-- Aragón (2)
INSERT INTO provincia (idccaa,nombre) VALUES (2,'Huesca');
INSERT INTO provincia (idccaa,nombre) VALUES (2,'Teruel');
INSERT INTO provincia (idccaa,nombre) VALUES (2,'Zaragoza');

-- Asturias (3)
INSERT INTO provincia (idccaa,nombre) VALUES (3,'Asturias');

-- Baleares (4)
INSERT INTO provincia (idccaa,nombre) VALUES (4,'Islas Baleares');

-- Canarias (5)
INSERT INTO provincia (idccaa,nombre) VALUES (5,'Las Palmas');
INSERT INTO provincia (idccaa,nombre) VALUES (5,'Santa Cruz de Tenerife');

-- Cantabria (6)
INSERT INTO provincia (idccaa,nombre) VALUES (6,'Cantabria');

-- Castilla-La Mancha (7)
INSERT INTO provincia (idccaa,nombre) VALUES (7,'Albacete');
INSERT INTO provincia (idccaa,nombre) VALUES (7,'Ciudad Real');
INSERT INTO provincia (idccaa,nombre) VALUES (7,'Cuenca');
INSERT INTO provincia (idccaa,nombre) VALUES (7,'Guadalajara');
INSERT INTO provincia (idccaa,nombre) VALUES (7,'Toledo');

-- Castilla y León (8)
INSERT INTO provincia (idccaa,nombre) VALUES (8,'Ávila');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'Burgos');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'León');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'Palencia');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'Salamanca');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'Segovia');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'Soria');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'Valladolid');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'Zamora');

-- Cataluña (9)
INSERT INTO provincia (idccaa,nombre) VALUES (9,'Barcelona');
INSERT INTO provincia (idccaa,nombre) VALUES (9,'Girona');
INSERT INTO provincia (idccaa,nombre) VALUES (9,'Lleida');
INSERT INTO provincia (idccaa,nombre) VALUES (9,'Tarragona');

-- Comunidad Valenciana (10)
INSERT INTO provincia (idccaa,nombre) VALUES (10,'Alicante');
INSERT INTO provincia (idccaa,nombre) VALUES (10,'Castellón');
INSERT INTO provincia (idccaa,nombre) VALUES (10,'Valencia');

-- Extremadura (11)
INSERT INTO provincia (idccaa,nombre) VALUES (11,'Badajoz');
INSERT INTO provincia (idccaa,nombre) VALUES (11,'Cáceres');

-- Galicia (12)
INSERT INTO provincia (idccaa,nombre) VALUES (12,'A Coruña');
INSERT INTO provincia (idccaa,nombre) VALUES (12,'Pontevedra');
INSERT INTO provincia (idccaa,nombre) VALUES (12,'Lugo');
INSERT INTO provincia (idccaa,nombre) VALUES (12,'Ourense');

-- Madrid (13)
INSERT INTO provincia (idccaa,nombre) VALUES (13,'Madrid');

-- Murcia (14)
INSERT INTO provincia (idccaa,nombre) VALUES (14,'Murcia');

-- Navarra (15)
INSERT INTO provincia (idccaa,nombre) VALUES (15,'Navarra');

-- País Vasco (16)
INSERT INTO provincia (idccaa,nombre) VALUES (16,'Álava');
INSERT INTO provincia (idccaa,nombre) VALUES (16,'Guipúzcoa');
INSERT INTO provincia (idccaa,nombre) VALUES (16,'Vizcaya');

-- La Rioja (17)
INSERT INTO provincia (idccaa,nombre) VALUES (17,'La Rioja');


--Municipios
INSERT INTO municipio (idprovincia, nombre)
VALUES (40, 'Santiago de Compostela');

INSERT INTO municipio (idprovincia, nombre)
VALUES (31, 'Barcelona');

INSERT INTO municipio (idprovincia, nombre)
VALUES (4, 'Motril');

INSERT INTO municipio (idprovincia, nombre)
VALUES (8, 'Dos Hermanas');

INSERT INTO municipio (idprovincia, nombre)
VALUES (11, 'Calatayud');

INSERT INTO municipio (idprovincia, nombre)
VALUES (12, 'Gijón');

INSERT INTO municipio (idprovincia, nombre)
VALUES (31, 'Badalona');

INSERT INTO municipio (idprovincia, nombre)
VALUES (40, 'Ferrol');


--Etiquetas ambientales
INSERT INTO EtiquetaAmbiental (codigo)
VALUES ('0');

INSERT INTO EtiquetaAmbiental (codigo)
VALUES ('ECO');

INSERT INTO EtiquetaAmbiental (codigo)
VALUES ('C');

INSERT INTO EtiquetaAmbiental (codigo)
VALUES ('B');

INSERT INTO EtiquetaAmbiental (codigo)
VALUES ('SIN ETIQUETA');

-- VEHÍCULOS



--COMMIT
COMMIT;