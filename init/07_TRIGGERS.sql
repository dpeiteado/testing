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
    -- 1. Obtener número de la secuencia
    v_num := dgt_admin.seq_num_matricula.NEXTVAL;

    -- 2. Leer letras actuales (SIN modificarlas aún)
    SELECT letras INTO v_letras
    FROM dgt_admin.matricula_letras
    WHERE id = 1
    FOR UPDATE;

    -- 3. Generar la matrícula con las letras actuales
    :NEW.matricula := LPAD(v_num, 4, '0') || v_letras;

    -- 4. SI EL NÚMERO ES EL MÁXIMO (9999), preparamos las letras para el PRÓXIMO insert
    IF v_num = 9999 THEN
        v_letras := dgt_admin.siguiente_letras(v_letras);
        
        UPDATE dgt_admin.matricula_letras
        SET letras = v_letras
        WHERE id = 1;
    END IF;
END;
/



-- ERRORES
--SHOW ERRORS TRIGGER dgt_admin.trg_matricula;
