ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;


CREATE TABLE re_matriculaciones_tipo_anual (
    id_tipo_vehiculo NUMBER NOT NULL CONSTRAINT fk_re_tipo_vehiculo REFERENCES tipo_vehiculo(id_tipo_vehiculo),
    anio NUMBER(4) NOT NULL,
    total_matriculaciones NUMBER DEFAULT 0  NOT NULL,
    CONSTRAINT pk_re_matriculaciones_tipo_anual
        PRIMARY KEY (id_tipo_vehiculo, anio)
)
TABLESPACE dgt_re;


CREATE TABLE re_distribucion_etiqueta_ambiental (
    id_etiqueta NUMBER NOT NULL CONSTRAINT fk_re_etiqueta REFERENCES etiqueta_ambiental(id_etiqueta),
    total_vehiculos NUMBER DEFAULT 0 NOT NULL,
    CONSTRAINT pk_re_distribucion_etiqueta PRIMARY KEY (id_etiqueta)
)
TABLESPACE dgt_re;


CREATE TABLE re_transferencias_provincia_anual (
    id_provincia         NUMBER NOT NULL
        CONSTRAINT fk_re_transferencias_provincia
            REFERENCES provincia ( id_provincia ),
    anio                 NUMBER(4) NOT NULL,
    total_transferencias NUMBER DEFAULT 0 NOT NULL,
    CONSTRAINT pk_re_transferencias_provincia_anual PRIMARY KEY ( id_provincia, anio )
)
TABLESPACE dgt_re;