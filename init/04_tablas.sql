ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;



-- TABLA COMUNIDAD AUTONOMA
CREATE TABLE comunidadautonoma (
    idccaa NUMBER
        GENERATED ALWAYS AS IDENTITY
        CONSTRAINT pk_ccaa PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL
        CONSTRAINT uq_ccaa_nombre UNIQUE,
    f_ccaa NUMBER(4, 2) NOT NULL
)TABLESPACE dgt_data;


-- PROVINCIA

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


--MUNICIPIO
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



--VEHICULO
CREATE TABLE vehiculo (
    idvehiculo               NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_vehiculo PRIMARY KEY,
    matricula                VARCHAR2(10) NOT NULL CONSTRAINT uq_matricula UNIQUE,
    marca                    VARCHAR2(50) NOT NULL,
    modelo                   VARCHAR2(50) NOT NULL,
    color                    VARCHAR2(30) NOT NULL,
    esimportado              NUMBER(1) NOT NULL,
    fechaimportacion         DATE,
    superoprimerainspeccion  NUMBER(1) NOT NULL,
    idetiqueta               NUMBER NOT NULL,
    fechaultimaitv           DATE,
    CONSTRAINT fk_vehiculo_etiqueta FOREIGN KEY (idetiqueta) REFERENCES etiquetaambiental (idetiqueta),
    CONSTRAINT chk_esimportado_bool CHECK (esimportado IN (0, 1)),
    CONSTRAINT chk_supero_itv_bool CHECK (superoprimerainspeccion IN (0, 1)),
    CONSTRAINT chk_importacion CHECK ((esimportado = 1 AND fechaimportacion IS NOT NULL) OR (esimportado = 0 AND fechaimportacion IS NULL))
)TABLESPACE dgt_data;


CREATE TABLE matricula_letras (
    id NUMBER PRIMARY KEY CHECK (id = 1),
    letras VARCHAR2(3) NOT NULL
)TABLESPACE dgt_data;



-- Permisos y Sinónimos inmediatos
GRANT SELECT, UPDATE, INSERT ON matricula_letras TO PUBLIC;
GRANT SELECT, UPDATE, INSERT ON vehiculo TO PUBLIC;

CREATE OR REPLACE PUBLIC SYNONYM matricula_letras FOR dgt_admin.matricula_letras;
CREATE OR REPLACE PUBLIC SYNONYM vehiculo FOR dgt_admin.vehiculo;
