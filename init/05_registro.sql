ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;

-- REGISTRO VEHÍCULOS

/*
Tabla para las Comunidades Autónomas
	nombre: denominación oficial de la Comunidad Autónoma
	f_ccaa: tasa autonómica aplicado a la tasa de matriculación
*/
CREATE TABLE comunidadautonoma (
    idccaa NUMBER
        GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_ccaa PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL
        CONSTRAINT uq_ccaa_nombre UNIQUE,
    f_ccaa NUMBER(4, 2) NOT NULL
)TABLESPACE dgt_data;



CREATE TABLE provincia (
    idprovincia NUMBER
        GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_provincia PRIMARY KEY,
    idccaa      NUMBER NOT NULL,
    nombre      VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_provincia_ccaa FOREIGN KEY ( idccaa )
        REFERENCES comunidadautonoma ( idccaa ),
    CONSTRAINT uq_provincia UNIQUE ( idccaa,
                                     nombre )
)
TABLESPACE dgt_data;


CREATE TABLE municipio (
    idmunicipio NUMBER
        GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_municipio PRIMARY KEY,
    idprovincia NUMBER NOT NULL,
    nombre      VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_municipio_provincia FOREIGN KEY ( idprovincia )
        REFERENCES provincia ( idprovincia ),
    CONSTRAINT uq_municipio UNIQUE ( idprovincia,
                                     nombre )
)
TABLESPACE dgt_data; 


CREATE TABLE etiquetaambiental (
    idetiqueta NUMBER
        GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_etiqueta PRIMARY KEY,
    codigo     VARCHAR2(20) NOT NULL
        CONSTRAINT uq_etiqueta UNIQUE
)
TABLESPACE dgt_data;


-- 2. TABLA DE ESTADO
CREATE TABLE matricula_estado (
    id NUMBER PRIMARY KEY CHECK (id = 1),
    letras VARCHAR2(3) NOT NULL,
    inicializado NUMBER(1) DEFAULT 0 NOT NULL
)
TABLESPACE dgt_data;

INSERT INTO matricula_estado (id, letras, inicializado)
VALUES (1, 'AAA', 0);




CREATE TABLE vehiculo (
    idvehiculo              NUMBER
        GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_vehiculo PRIMARY KEY,
    vin                     VARCHAR2(17) NOT NULL
        CONSTRAINT uq_vin UNIQUE,
    matricula               VARCHAR2(10) NOT NULL
        CONSTRAINT uq_matricula UNIQUE,
    marca                   VARCHAR2(50) NOT NULL,
    modelo                  VARCHAR2(50) NOT NULL,
    color                   VARCHAR2(30) NOT NULL,
    fechafabricacion        DATE NOT NULL,
    esimportado             boolean DEFAULT FALSE NOT NULL,
    fechaimportacion        DATE,
    superoprimerainspeccion boolean DEFAULT FALSE NOT NULL,
    idetiqueta              NUMBER NOT NULL,
    CONSTRAINT fk_vehiculo_etiqueta FOREIGN KEY ( idetiqueta )
        REFERENCES etiquetaambiental ( idetiqueta ),
    CONSTRAINT chk_importacion
        CHECK ( esimportado = FALSE
                OR fechaimportacion IS NOT NULL )
)
TABLESPACE dgt_data;


COMMIT;