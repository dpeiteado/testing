
--Trigger generador de matrículas
CREATE OR REPLACE TRIGGER trg_matricula
BEFORE INSERT ON vehiculo
FOR EACH ROW
DECLARE
    v_num NUMBER;
    v_letras VARCHAR2(3);
BEGIN
    -- 1. Obtenemos el número de la secuencia
    v_num := seq_num_matricula.NEXTVAL;

    -- 2. Obtenemos las letras actuales ANTES de cualquier cambio
    SELECT letras INTO v_letras FROM matricula_letras;

    -- 3. Si el número es 1 Y NO es la primera vez que se usa la secuencia, 
    -- o si prefieres una lógica más robusta:
    -- Solo incrementamos si el número ACTUAL es 1 pero ya existían registros.
    -- Pero hay un truco más fácil: Incrementar cuando el v_num sea 1 
    -- y ACTUALIZAR la tabla para la PRÓXIMA vez.
    
    :NEW.matricula := LPAD(v_num, 4, '0') || v_letras;

    -- 4. Si el número que acabamos de usar es 9999, preparamos las letras para el siguiente
    IF v_num = 9999 THEN
        UPDATE matricula_letras SET letras = siguiente_letras(v_letras);
    END IF;
END;
/

COMMIT;