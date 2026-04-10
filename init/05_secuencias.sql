ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;

CREATE SEQUENCE seq_num_matricula
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 9999
    CYCLE
    NOCACHE;

-- Permisos y Sinónimos inmediatos
GRANT SELECT ON seq_num_matricula TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM seq_num_matricula FOR dgt_admin.seq_num_matricula;