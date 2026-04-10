ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;



-- Trigger
CREATE OR REPLACE TRIGGER trg_matricula
BEFORE INSERT ON vehiculo
FOR EACH ROW
DECLARE
    v_num NUMBER;
    v_letras VARCHAR2(3);
BEGIN
    -- 1. Obtener número
    v_num := dgt_admin.seq_num_matricula.NEXTVAL;

    -- 2. Bloquear y leer letras actuales
    SELECT letras
    INTO v_letras
    FROM matricula_letras
    WHERE id = 1
    FOR UPDATE;

    -- 3. Si la secuencia ha ciclado → cambiar letras
    IF v_num = 1 THEN
        v_letras := siguiente_letras(v_letras);

        UPDATE matricula_letras
        SET letras = v_letras
        WHERE id = 1;
    END IF;

    -- 4. Generar matrícula
    :NEW.matricula := LPAD(v_num, 4, '0') || v_letras;
END;
/



-- Verificación de errores automática en el log de Docker
SHOW ERRORS TRIGGER dgt_admin.trg_matricula;
