ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;


-- 4. TRIGGER
CREATE OR REPLACE TRIGGER trg_matricula
BEFORE INSERT ON vehiculo
FOR EACH ROW
DECLARE
    v_num NUMBER;
    v_letras VARCHAR2(3);
    v_inicializado NUMBER;
BEGIN
    -- 1. Obtener número de secuencia
    v_num := seq_num_matricula.NEXTVAL;

    -- 2. Leer estado con bloqueo (evita concurrencia)
    SELECT letras, inicializado
    INTO v_letras, v_inicializado
    FROM matricula_estado
    WHERE id = 1
    FOR UPDATE;

    -- 3. Detectar ciclo REAL (no primera ejecución)
    IF v_num = 1 AND v_inicializado = 1 THEN
        v_letras := siguiente_letras(v_letras);

        UPDATE matricula_estado
        SET letras = v_letras
        WHERE id = 1;
    END IF;

    -- 4. Generar matrícula
    :NEW.matricula := LPAD(v_num, 4, '0') || v_letras;

    -- 5. Marcar como inicializado tras la primera inserción
    IF v_inicializado = 0 THEN
        UPDATE matricula_estado
        SET inicializado = 1
        WHERE id = 1;
    END IF;

END;
/