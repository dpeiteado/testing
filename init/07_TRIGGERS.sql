ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;



-- Trigger
CREATE OR REPLACE TRIGGER trg_matricula
BEFORE INSERT ON matricula
FOR EACH ROW
DECLARE
    v_num NUMBER;
    v_letras VARCHAR2(3);
BEGIN
    v_num := dgt_admin.seq_num_matricula.NEXTVAL;

    -- Bloquea la fila para evitar que dos procesos lean las mismas letras a la vez
    SELECT letras INTO v_letras
    FROM dgt_admin.matricula_letras
    WHERE id = 1
    FOR UPDATE;

    :NEW.matricula := LPAD(v_num, 4, '0') || v_letras;

    -- Si el número llega a 9999, se calcula la siguiente serie
    IF v_num = 9999 THEN
        v_letras := dgt_admin.siguiente_letras(v_letras);
        
        UPDATE dgt_admin.matricula_letras
        SET letras = v_letras
        WHERE id = 1;
    END IF;
END;
/



-- Trigger para establecer fecha límite de pago en expediente FASE matriculación
CREATE OR REPLACE TRIGGER trg_exp_fecha_limite_pago
BEFORE INSERT ON expediente
FOR EACH ROW
BEGIN
    IF :NEW.fecha_limite_pago IS NULL THEN
        --:NEW.fecha_limite_pago := :NEW.fecha_inicio + 15; -- Si se quiere que el plazo de pago sea de 15 días a partir de la fecha de inicio
        :NEW.fecha_limite_pago := :NEW.fecha_inicio -1; -- Si se quiere que el plazo de pago sea el día anterior a la fecha de inicio
    END IF;
END;
/


-- Trigger para calcular y asignar la etiqueta ambiental al vehiculo
CREATE OR REPLACE TRIGGER trg_asignar_etiqueta_vehiculo
AFTER INSERT OR UPDATE ON ficha_tecnica
FOR EACH ROW
DECLARE
    v_id_etiqueta NUMBER;
BEGIN
    -- Se calcula la etiqueta mediante la funcion
    v_id_etiqueta := fn_calcular_etiqueta(:NEW.id_combustible, :NEW.id_normativa);
    
    -- Se actualiza el vehiculo correspondiente
    UPDATE vehiculo
    SET id_etiqueta = v_id_etiqueta
    WHERE id_vehiculo = :NEW.id_vehiculo;
END;
/
