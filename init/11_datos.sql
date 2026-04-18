-- TESTEO
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;

--INSERTAR COMUNIDADES AUTONOMAS
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('ANDALUCIA', 1.03);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('ARAGON', 1.9);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('ASTURIAS', 1.02);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('ISLAS BALEARES', 1.07);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('CANARIAS', 1.03);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('CANTABRIA', 1.03);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('CASTILLA-LA MANCHA', 1.04);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('CASTILLA Y LEON', 1.04);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('CATALUÑA', 1.05);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('COMUNIDAD VALENCIANA', 1.07);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('EXTREMADURA', 1.06);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('GALICIA', 1.03);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('COMUNIDAD DE MADRID', 1.23);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('REGION DE MURCIA', 1.06);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('NAVARRA', 1.09);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('PAIS VASCO', 1.08);
INSERT INTO comunidad_autonoma (nombre, f_ccaa) VALUES ('LA RIOJA', 1.07);

-- INSERTAR PARA PROVINCIAS

-- Andalucía (1)
INSERT INTO provincia (id_ccaa, nombre) VALUES (1,'ALMERIA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (1,'CADIZ');
INSERT INTO provincia (id_ccaa, nombre) VALUES (1,'CORDOBA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (1,'GRANADA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (1,'HUELVA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (1,'JAEN');
INSERT INTO provincia (id_ccaa, nombre) VALUES (1,'MALAGA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (1,'SEVILLA');

-- Aragón (2)
INSERT INTO provincia (id_ccaa, nombre) VALUES (2,'HUESCA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (2,'TERUEL');
INSERT INTO provincia (id_ccaa, nombre) VALUES (2,'ZARAGOZA');

-- Asturias (3)
INSERT INTO provincia (id_ccaa, nombre) VALUES (3,'ASTURIAS');

-- Baleares (4)
INSERT INTO provincia (id_ccaa, nombre) VALUES (4,'ISLAS BALEARES');

-- Canarias (5)
INSERT INTO provincia (id_ccaa, nombre) VALUES (5,'LAS PALMAS');
INSERT INTO provincia (id_ccaa, nombre) VALUES (5,'SANTA CRUZ DE TENERIFE');

-- Cantabria (6)
INSERT INTO provincia (id_ccaa, nombre) VALUES (6,'CANTABRIA');

-- Castilla-La Mancha (7)
INSERT INTO provincia (id_ccaa, nombre) VALUES (7,'ALBACETE');
INSERT INTO provincia (id_ccaa, nombre) VALUES (7,'CIUDAD REAL');
INSERT INTO provincia (id_ccaa, nombre) VALUES (7,'CUENCA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (7,'GUADALAJARA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (7,'TOLEDO');

-- Castilla y León (8)
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'AVILA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'BURGOS');
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'LEON');
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'PALENCIA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'SALAMANCA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'SEGOVIA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'SORIA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'VALLADOLID');
INSERT INTO provincia (id_ccaa, nombre) VALUES (8,'ZAMORA');

-- Cataluña (9)
INSERT INTO provincia (id_ccaa, nombre) VALUES (9,'BARCELONA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (9,'GIRONA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (9,'LLEIDA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (9,'TARRAGONA');

-- Comunidad Valenciana (10)
INSERT INTO provincia (id_ccaa, nombre) VALUES (10,'ALICANTE');
INSERT INTO provincia (id_ccaa, nombre) VALUES (10,'CASTELLON');
INSERT INTO provincia (id_ccaa, nombre) VALUES (10,'VALENCIA');

-- Extremadura (11)
INSERT INTO provincia (id_ccaa, nombre) VALUES (11,'BADAJOZ');
INSERT INTO provincia (id_ccaa, nombre) VALUES (11,'CACERES');

-- Galicia (12)
INSERT INTO provincia (id_ccaa, nombre) VALUES (12,'A CORUÑA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (12,'PONTEVEDRA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (12,'LUGO');
INSERT INTO provincia (id_ccaa, nombre) VALUES (12,'OURENSE');

-- Madrid (13)
INSERT INTO provincia (id_ccaa, nombre) VALUES (13,'MADRID');

-- Murcia (14)
INSERT INTO provincia (id_ccaa, nombre) VALUES (14,'MURCIA');

-- Navarra (15)
INSERT INTO provincia (id_ccaa, nombre) VALUES (15,'NAVARRA');

-- País Vasco (16)
INSERT INTO provincia (id_ccaa, nombre) VALUES (16,'ALAVA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (16,'GUIPUZCOA');
INSERT INTO provincia (id_ccaa, nombre) VALUES (16,'VIZCAYA');

-- La Rioja (17)
INSERT INTO provincia (id_ccaa,nombre) VALUES (17,'LA RIOJA');


-- INSERTAR MUNICIPIOS
INSERT INTO municipio (id_provincia, nombre)
VALUES (40, 'SANTIAGO DE COMPOSTELA');

INSERT INTO municipio (id_provincia, nombre)
VALUES (31, 'BARCELONA');

INSERT INTO municipio (id_provincia, nombre)
VALUES (4, 'MOTRIL');

INSERT INTO municipio (id_provincia, nombre)
VALUES (8, 'DOS HERMANAS');

INSERT INTO municipio (id_provincia, nombre)
VALUES (11, 'CALATAYUD');

INSERT INTO municipio (id_provincia, nombre)
VALUES (12, 'GIJON');

INSERT INTO municipio (id_provincia, nombre)
VALUES (13, 'MANACOR');

INSERT INTO municipio (id_provincia, nombre)
VALUES (29, 'MEDINA DEL CAMPO');

INSERT INTO municipio (id_provincia, nombre)
VALUES (31, 'BADALONA');

INSERT INTO municipio (id_provincia, nombre)
VALUES (40, 'FERROL');


-- ETIQUETA AMBIENTAL
INSERT INTO etiqueta_ambiental (codigo)
VALUES ('0');

INSERT INTO etiqueta_ambiental (codigo)
VALUES ('ECO');

INSERT INTO etiqueta_ambiental (codigo)
VALUES ('C');

INSERT INTO etiqueta_ambiental (codigo)
VALUES ('B');

INSERT INTO etiqueta_ambiental (codigo)
VALUES ('SIN ETIQUETA');


-- NORMATIVA EURO
INSERT INTO normativa_euro (descripcion) VALUES ('EURO 1');
INSERT INTO normativa_euro (descripcion) VALUES ('EURO 2');
INSERT INTO normativa_euro (descripcion) VALUES ('EURO 3');
INSERT INTO normativa_euro (descripcion) VALUES ('EURO 4');
INSERT INTO normativa_euro (descripcion) VALUES ('EURO 5');
INSERT INTO normativa_euro (descripcion) VALUES ('EURO 6');
INSERT INTO normativa_euro (descripcion) VALUES ('N/A');


-- INSERTAR LETRAS INICIALES DE MATRICULAS
INSERT INTO matricula_letras (id, letras) VALUES (1, 'AAA');


-- TIPOS D COMBUSTIBLE
INSERT INTO tipo_combustible (descripcion_combustible, f_comb) VALUES ('ELECTRICO', 0.80);
INSERT INTO tipo_combustible (descripcion_combustible, f_comb) VALUES ('HIDROGRANO', 0.8);
INSERT INTO tipo_combustible (descripcion_combustible, f_comb) VALUES ('HIBRIDO', 0.90);
INSERT INTO tipo_combustible (descripcion_combustible, f_comb) VALUES ('GLP', 0.95);
INSERT INTO tipo_combustible (descripcion_combustible, f_comb) VALUES ('DIESEL', 1.00);
INSERT INTO tipo_combustible (descripcion_combustible, f_comb) VALUES ('GASOLINA', 1.00);


INSERT INTO tipo_vehiculo (id_tipo_vehiculo, descripcion_vehiculo, itv_especial, f_tipo)
VALUES (1, 'MOTOCICLETA', 0, 0.70);

INSERT INTO tipo_vehiculo (id_tipo_vehiculo, descripcion_vehiculo, itv_especial, f_tipo)
VALUES (2, 'TURISMO', 0, 1.00);

INSERT INTO tipo_vehiculo (id_tipo_vehiculo, descripcion_vehiculo, itv_especial, f_tipo)
VALUES (3, 'FURGONETA', 0, 1.15);

INSERT INTO tipo_vehiculo (id_tipo_vehiculo, descripcion_vehiculo, itv_especial, f_tipo)
VALUES (4, 'CAMION', 0, 1.30);

INSERT INTO tipo_vehiculo (id_tipo_vehiculo, descripcion_vehiculo, itv_especial, f_tipo)
VALUES (5, 'AUTOBUS', 0, 1.30);


-- FACTOR DE EMISIONES
INSERT INTO factor_emisiones (co2_min, co2_max, f_emis)
VALUES (0, 119, 0.90);

INSERT INTO factor_emisiones (co2_min, co2_max, f_emis)
VALUES (120, 160, 1.00);

INSERT INTO factor_emisiones (co2_min, co2_max, f_emis)
VALUES (161, 200, 1.15);

INSERT INTO factor_emisiones (co2_min, co2_max, f_emis)
VALUES (201, 999, 1.30);


-- ESTADOS DE EXPEDIENTE
INSERT INTO estado_expediente (descripcion) VALUES ('PENDIENTE');
INSERT INTO estado_expediente (descripcion) VALUES ('COMPLETADO');
INSERT INTO estado_expediente (descripcion) VALUES ('ANULADO');
INSERT INTO estado_expediente (descripcion) VALUES ('BAJA DEFINITIVA');


-- Documentacion del vehículo
/*
INSERT INTO tipo_documento (descripcion) VALUES ('PERMISO DE CIRCULACION');
INSERT INTO tipo_documento (descripcion) VALUES ('FICHA TECNICA VEHICULO');
INSERT INTO tipo_documento (descripcion) VALUES ('ETIQUETA MEDIOAMBIENTAL');
INSERT INTO tipo_documento (descripcion) VALUES ('CERTIFICADO CARACTERISTICAS TECNICAS');
*/

INSERT INTO tipo_documento (descripcion) VALUES ('DNI');
INSERT INTO tipo_documento (descripcion) VALUES ('NIF');


-- Potencia fiscal
INSERT INTO factor_potencia (cv_min, cv_max, f_pot)
VALUES (0, 7, 0.90);

INSERT INTO factor_potencia (cv_min, cv_max, f_pot)
VALUES (8, 12, 1.00);

INSERT INTO factor_potencia (cv_min, cv_max, f_pot)
VALUES (13, 16, 1.10);

INSERT INTO factor_potencia (cv_min, cv_max, f_pot)
VALUES (16, NULL, 1.20);

-- Configuración de la tasa para el calculo interno
INSERT INTO configuracion_tasa (t_base, iva, fecha_vigencia)
VALUES (120, 21, DATE '2024-01-01');



INSERT INTO tipo_titularidad (descripcion) VALUES ('PARTICULAR');
INSERT INTO tipo_titularidad (descripcion) VALUES ('EMPRESA');
INSERT INTO tipo_titularidad (descripcion) VALUES ('ADMINISTRACION_PUBLICA');
INSERT INTO tipo_titularidad (descripcion) VALUES ('AUTOESCUELA');
INSERT INTO tipo_titularidad (descripcion) VALUES ('VEHICULO_OFICIAL');



INSERT INTO tipo_transaccion (descripcion_transaccion) VALUES ('COMPRA-VENTA');
INSERT INTO tipo_transaccion (descripcion_transaccion) VALUES ('SUCESION');
INSERT INTO tipo_transaccion (descripcion_transaccion) VALUES ('BAJA TEMPORAL');
INSERT INTO tipo_transaccion (descripcion_transaccion) VALUES ('LEASING/RENTING');
INSERT INTO tipo_transaccion (descripcion_transaccion) VALUES ('TRANSFERENCIA');


--INSERTAR DATOS EN EL REPOSITORIO ESTADISTICO INICIADOS A 0 y del año 2026
INSERT INTO re_matriculaciones_tipo_anual (id_tipo_vehiculo, anio)
SELECT id_tipo_vehiculo, 2026
FROM tipo_vehiculo;

INSERT INTO re_distribucion_etiqueta_ambiental (id_etiqueta)
SELECT id_etiqueta
FROM etiqueta_ambiental;

INSERT INTO re_transferencias_provincia_anual (id_provincia, anio)
SELECT id_provincia, 2026
FROM provincia;



INSERT INTO jefatura_provincial (nombre, codigo, id_municipio)
VALUES ('JJefatura Provincial de A Coruña', 'JP-COR', 1);

INSERT INTO jefatura_provincial (nombre, codigo, id_municipio)
VALUES ('JJefatura Provincial de Barcelona', 'JP-BCN', 2);

-- ESTADOS DE PAGO (1: PENDIENTE, 2: PAGADO, 3: ANULADO)
INSERT INTO estado_pago (descripcion) VALUES ('PENDIENTE');
INSERT INTO estado_pago (descripcion) VALUES ('PAGADO');
INSERT INTO estado_pago (descripcion) VALUES ('ANULADO');



COMMIT;