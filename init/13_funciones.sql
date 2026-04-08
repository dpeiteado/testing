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

    -- Incrementar la última letra
    IF l3 < 'Z' THEN
        l3 := CHR(ASCII(l3) + 1);
    ELSE
        l3 := 'A';
        IF l2 < 'Z' THEN
            l2 := CHR(ASCII(l2) + 1);
        ELSE
            l2 := 'A';
            l1 := CHR(ASCII(l1) + 1);
        END IF;
    END IF;

    RETURN l1 || l2 || l3;
END;
/