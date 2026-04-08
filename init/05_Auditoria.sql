ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;

/* 
CREACIÓN DE TABLAS PARA AUDITORÍA (TABLESPACE: dgt_log)
*/

CREATE TABLE LOG_Procedimientos (
    idLog               NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fechaHora           TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    usuario             VARCHAR2(100) NOT NULL,
    nombreProcedimiento VARCHAR2(200) NOT NULL,
    parametrosIN        CLOB,
    parametrosOUT       CLOB,
    RSP                 CLOB
) TABLESPACE dgt_log;


