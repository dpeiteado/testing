-- TESTEO
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;

--INSERTAR COMUNIDADES AUTONOMAS
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('ANDALUCIA', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('ARAGON', 1.9);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('ASTURIAS', 1.02);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('ISLAS BALEARES', 1.07);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('CANARIAS', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('CANTABRIA', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('CASTILLA-LA MANCHA', 1.04);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('CASTILLA Y LEON', 1.04);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('CATALUÑA', 1.05);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('COMUNIDAD VALENCIANA', 1.07);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('EXTREMADURA', 1.06);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('GALICIA', 1.03);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('COMUNIDAD DE MADRID', 1.23);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('REGION DE MURCIA', 1.06);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('NAVARRA', 1.09);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('PAIS VASCO', 1.08);
INSERT INTO comunidadautonoma (nombre, f_ccaa) VALUES ('LA RIOJA', 1.07);

-- INSERTAR PARA PROVINCIAS

-- Andalucía (1)
INSERT INTO provincia (idccaa,nombre) VALUES (1,'ALMERIA');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'CADIZ');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'CORDOBA');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'GRANADA');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'HUELVA');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'JAEN');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'MALAGA');
INSERT INTO provincia (idccaa,nombre) VALUES (1,'SEVILLA');

-- Aragón (2)
INSERT INTO provincia (idccaa,nombre) VALUES (2,'HUESCA');
INSERT INTO provincia (idccaa,nombre) VALUES (2,'TERUEL');
INSERT INTO provincia (idccaa,nombre) VALUES (2,'ZARAGOZA');

-- Asturias (3)
INSERT INTO provincia (idccaa,nombre) VALUES (3,'ASTURIAS');

-- Baleares (4)
INSERT INTO provincia (idccaa,nombre) VALUES (4,'ISLAS BALEARES');

-- Canarias (5)
INSERT INTO provincia (idccaa,nombre) VALUES (5,'LAS PALMAS');
INSERT INTO provincia (idccaa,nombre) VALUES (5,'SANTA CRUZ DE TENERIFE');

-- Cantabria (6)
INSERT INTO provincia (idccaa,nombre) VALUES (6,'CANTABRIA');

-- Castilla-La Mancha (7)
INSERT INTO provincia (idccaa,nombre) VALUES (7,'ALBACETE');
INSERT INTO provincia (idccaa,nombre) VALUES (7,'CIUDAD REAL');
INSERT INTO provincia (idccaa,nombre) VALUES (7,'CUENCA');
INSERT INTO provincia (idccaa,nombre) VALUES (7,'GUADALAJARA');
INSERT INTO provincia (idccaa,nombre) VALUES (7,'TOLEDO');

-- Castilla y León (8)
INSERT INTO provincia (idccaa,nombre) VALUES (8,'AVILA');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'BURGOS');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'LEON');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'PALENCIA');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'SALAMANCA');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'SEGOVIA');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'SORIA');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'VALLADOLID');
INSERT INTO provincia (idccaa,nombre) VALUES (8,'ZAMORA');

-- Cataluña (9)
INSERT INTO provincia (idccaa,nombre) VALUES (9,'BARCELONA');
INSERT INTO provincia (idccaa,nombre) VALUES (9,'GIRONA');
INSERT INTO provincia (idccaa,nombre) VALUES (9,'LLEIDA');
INSERT INTO provincia (idccaa,nombre) VALUES (9,'TARRAGONA');

-- Comunidad Valenciana (10)
INSERT INTO provincia (idccaa,nombre) VALUES (10,'ALICANTE');
INSERT INTO provincia (idccaa,nombre) VALUES (10,'CASTELLON');
INSERT INTO provincia (idccaa,nombre) VALUES (10,'VALENCIA');

-- Extremadura (11)
INSERT INTO provincia (idccaa,nombre) VALUES (11,'BADAJOZ');
INSERT INTO provincia (idccaa,nombre) VALUES (11,'CACERES');

-- Galicia (12)
INSERT INTO provincia (idccaa,nombre) VALUES (12,'A CORUÑA');
INSERT INTO provincia (idccaa,nombre) VALUES (12,'PONTEVEDRA');
INSERT INTO provincia (idccaa,nombre) VALUES (12,'LUGO');
INSERT INTO provincia (idccaa,nombre) VALUES (12,'OURENSE');

-- Madrid (13)
INSERT INTO provincia (idccaa,nombre) VALUES (13,'MADRID');

-- Murcia (14)
INSERT INTO provincia (idccaa,nombre) VALUES (14,'MURCIA');

-- Navarra (15)
INSERT INTO provincia (idccaa,nombre) VALUES (15,'NAVARRA');

-- País Vasco (16)
INSERT INTO provincia (idccaa,nombre) VALUES (16,'ALAVA');
INSERT INTO provincia (idccaa,nombre) VALUES (16,'GUIPUZCOA');
INSERT INTO provincia (idccaa,nombre) VALUES (16,'VIZCAYA');

-- La Rioja (17)
INSERT INTO provincia (idccaa,nombre) VALUES (17,'LA RIOJA');


-- INSERTAR MUNICIPIOS
INSERT INTO municipio (idprovincia, nombre)
VALUES (40, 'SANTIAGO DE COMPOSTELA');

INSERT INTO municipio (idprovincia, nombre)
VALUES (31, 'BARCELONA');

INSERT INTO municipio (idprovincia, nombre)
VALUES (4, 'MOTRIL');

INSERT INTO municipio (idprovincia, nombre)
VALUES (8, 'DOS HERMANAS');

INSERT INTO municipio (idprovincia, nombre)
VALUES (11, 'CALATAYUD');

INSERT INTO municipio (idprovincia, nombre)
VALUES (12, 'GIJON');

INSERT INTO municipio (idprovincia, nombre)
VALUES (13, 'MANACOR');

INSERT INTO municipio (idprovincia, nombre)
VALUES (29, 'MEDINA DEL CAMPO');

INSERT INTO municipio (idprovincia, nombre)
VALUES (31, 'BADALONA');

INSERT INTO municipio (idprovincia, nombre)
VALUES (40, 'FERROL');


-- ETIQUETA AMBIENTAL
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


-- INSERTAR LETRAS INICIALES DE MATRICULAS
INSERT INTO matricula_letras (id, letras) VALUES (1, 'AAA');


-- TIPOS D COMBUSTIBLE
INSERT INTO TipoCombustible (descripcionCombustible, f_comb) VALUES ('ELECTRICO', 0.80);
INSERT INTO TipoCombustible (descripcionCombustible, f_comb) VALUES ('HIDROGRANO', 0.8);
INSERT INTO TipoCombustible (descripcionCombustible, f_comb) VALUES ('HIBRIDO', 0.90);
INSERT INTO TipoCombustible (descripcionCombustible, f_comb) VALUES ('GLP', 0.95);
INSERT INTO TipoCombustible (descripcionCombustible, f_comb) VALUES ('DIESEL', 1.00);
INSERT INTO TipoCombustible (descripcionCombustible, f_comb) VALUES ('GASOLINA', 1.00);


INSERT INTO TipoVehiculo (idTipoVehiculo, descripcionVehiculo, itv_especial, F_tipo)
VALUES (1, 'MOTOCICLETA', 0, 0.70);

INSERT INTO TipoVehiculo (idTipoVehiculo, descripcionVehiculo, itv_especial, F_tipo)
VALUES (2, 'TURISMO', 0, 1.00);

INSERT INTO TipoVehiculo (idTipoVehiculo, descripcionVehiculo, itv_especial, F_tipo)
VALUES (3, 'FURGONETA', 0, 1.15);

INSERT INTO TipoVehiculo (idTipoVehiculo, descripcionVehiculo, itv_especial, F_tipo)
VALUES (4, 'CAMION', 0, 1.30);

INSERT INTO TipoVehiculo (idTipoVehiculo, descripcionVehiculo, itv_especial, F_tipo)
VALUES (5, 'AUTOBUS', 0, 1.30);


-- FACTOR DE EMISIONES
INSERT INTO FactorEmisiones (co2Min, co2Max, f_emis)
VALUES (0, 119, 0.90);

INSERT INTO FactorEmisiones (co2Min, co2Max, f_emis)
VALUES (120, 160, 1.00);

INSERT INTO FactorEmisiones (co2Min, co2Max, f_emis)
VALUES (161, 200, 1.15);

INSERT INTO FactorEmisiones (co2Min, co2Max, f_emis)
VALUES (201, 999, 1.30);





COMMIT;