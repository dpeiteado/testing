ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;

-- Función para incrementar letras
CREATE OR REPLACE FUNCTION siguiente_letras(p_letras VARCHAR2)
RETURN VARCHAR2
IS
    l1 CHAR(1);
    l2 CHAR(1);
    l3 CHAR(1);
BEGIN
    l1 := SUBSTR(p_letras, 1, 1);
    l2 := SUBSTR(p_letras, 2, 1);
    l3 := SUBSTR(p_letras, 3, 1);

    IF l3 < 'Z' THEN
        l3 := CHR(ASCII(l3) + 1);
    ELSE
        l3 := 'A';
        IF l2 < 'Z' THEN
            l2 := CHR(ASCII(l2) + 1);
        ELSE
            l2 := 'A';
            IF l1 < 'Z' THEN
                l1 := CHR(ASCII(l1) + 1);
            ELSE
                -- opcional: límite máximo alcanzado
                RAISE_APPLICATION_ERROR(-20001, 'Límite de matrículas alcanzado (ZZZ)');
            END IF;
        END IF;
    END IF;

    RETURN l1 || l2 || l3;
END;
/
-- Permisos y Sinónimos inmediatos
GRANT EXECUTE ON siguiente_letras TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM siguiente_letras FOR dgt_admin.siguiente_letras;