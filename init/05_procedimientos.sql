ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;



--TABLA TESTEO PARA EL SISTEMA DE AUDITORÍA
CREATE OR REPLACE PROCEDURE consultar_auditoria (p_cursor OUT SYS_REFCURSOR) AS
BEGIN
    OPEN p_cursor FOR
        SELECT * FROM log_auditoria ORDER BY fecha_registro DESC;
END;
/

-- PERMISO PARA ANALISTAS
GRANT EXECUTE ON dgt_admin.consultar_auditoria TO rol_analista;
CREATE PUBLIC SYNONYM consultar_auditoria FOR dgt_admin.consultar_auditoria;
-- ------------------------------------------------

