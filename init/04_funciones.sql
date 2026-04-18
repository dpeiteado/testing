ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;

-- FUNCION PARA OBTENER LAS SIGUIENTES LETRAS DE LA MATRÍCULA
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
                RAISE_APPLICATION_ERROR(-20001, 'Límite de matrículas alcanzado');
            END IF;
        END IF;
    END IF;

    RETURN l1 || l2 || l3;
END;
/






CREATE OR REPLACE FUNCTION buscar_persona (
    p_numero_documento  IN VARCHAR2,
    p_id_tipo_documento IN NUMBER
) RETURN NUMBER AS
    v_id_persona NUMBER;
BEGIN
    -- Busca el ID único basado en la combinación de tipo y número de documento
    SELECT id_persona INTO v_id_persona
    FROM persona
    WHERE numero_documento = p_numero_documento
      AND id_tipo_documento = p_id_tipo_documento;

    RETURN v_id_persona;
EXCEPTION
    -- Si no existe, devuelve NULL para que el procedimiento llamador decida qué hacer
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    -- Captura de errores inesperados
    WHEN OTHERS THEN
        RETURN NULL;
END buscar_persona;
/



--FUNCION CALCULO TASAS
CREATE OR REPLACE FUNCTION fn_calcular_tasa (
    p_id_vehiculo IN NUMBER
) RETURN NUMBER AS

    v_t_base    NUMBER;
    v_iva       NUMBER;
    v_f_emis    NUMBER;
    v_f_comb    NUMBER;
    v_f_pot     NUMBER;
    v_f_tipo    NUMBER;
    v_f_ccaa    NUMBER;
    v_co2       NUMBER;
    v_potencia  NUMBER;
    v_tasa      NUMBER;

BEGIN
    -- 1. Configuración vigente
    SELECT t_base, iva
    INTO v_t_base, v_iva
    FROM configuracion_tasa
    WHERE fecha_vigencia = (
        SELECT MAX(fecha_vigencia)
        FROM configuracion_tasa
        WHERE fecha_vigencia <= SYSDATE
    );

    -- 2. Emisiones CO₂ del vehículo
    SELECT emisiones_co2
    INTO v_co2
    FROM emisiones
    WHERE id_vehiculo = p_id_vehiculo;

    -- 3. Factor emisiones
    SELECT f_emis
    INTO v_f_emis
    FROM factor_emisiones
    WHERE v_co2 >= co2_min
      AND (co2_max IS NULL OR v_co2 <= co2_max);

    -- 4. Potencia, combustible y tipo
    SELECT ft.potencia_cv, tc.f_comb, tv.f_tipo
    INTO v_potencia, v_f_comb, v_f_tipo
    FROM ficha_tecnica ft
    JOIN tipo_combustible tc ON tc.id_combustible = ft.id_combustible
    JOIN tipo_vehiculo   tv ON tv.id_tipo_vehiculo = ft.id_tipo_vehiculo
    WHERE ft.id_vehiculo = p_id_vehiculo;

    -- 5. Factor potencia
    SELECT f_pot
    INTO v_f_pot
    FROM factor_potencia
    WHERE v_potencia >= cv_min
      AND (cv_max IS NULL OR v_potencia <= cv_max);

    -- 6. Factor CCAA
    SELECT ca.f_ccaa
    INTO v_f_ccaa
    FROM expediente e
    JOIN jefatura_provincial jp ON jp.id_jefatura_provincial = e.id_jefatura_provincial
    JOIN municipio m ON m.id_municipio = jp.id_municipio
    JOIN provincia p ON p.id_provincia = m.id_provincia
    JOIN comunidad_autonoma ca ON ca.id_ccaa = p.id_ccaa
    WHERE e.id_vehiculo = p_id_vehiculo
      AND e.fecha_finalizacion IS NULL;

    -- 7. Fórmula final
    v_tasa := ROUND(
        (v_t_base * v_f_emis * v_f_comb * v_f_pot * v_f_tipo * v_f_ccaa) * (1 + (v_iva / 100)),
        2
    );

    RETURN v_tasa;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;

END fn_calcular_tasa;
/


-- FUNCION CALCULO ETIQUETA AMBIENTAL
CREATE OR REPLACE FUNCTION fn_calcular_etiqueta (
    p_id_combustible IN NUMBER,
    p_id_normativa   IN NUMBER
) RETURN NUMBER AS
    v_etiqueta NUMBER;
BEGIN
    -- 1: 0, 2: ECO, 3: C, 4: B, 5: SIN ETIQUETA    
    v_etiqueta := CASE
        -- Eléctrico e Hidrógeno siempre son 0 Emisiones
        WHEN p_id_combustible IN (1, 2) THEN 1        
        -- Híbridos y Gas (GLP/GNC) suelen ser ECO
        WHEN p_id_combustible IN (3, 4) THEN 2        
        -- Lógica para DIESEL (ID 5)
        WHEN p_id_combustible = 5 THEN
            CASE 
                WHEN p_id_normativa >= 6 THEN 3 -- Euro 6 o superior -> C
                WHEN p_id_normativa >= 4 THEN 4 -- Euro 4 y 5 -> B
                ELSE 5                          -- Inferior a Euro 4 -> SIN
            END            
        -- Lógica para GASOLINA (ID 6)
        WHEN p_id_combustible = 6 THEN
            CASE 
                WHEN p_id_normativa >= 4 THEN 3 -- Euro 4 o superior -> C
                WHEN p_id_normativa = 3  THEN 4 -- Euro 3 -> B
                ELSE 5                          -- Inferior a Euro 3 -> SIN
            END            
        -- Cualquier otro caso o combustible no contemplado
        ELSE 5
    END;
    RETURN v_etiqueta;
END fn_calcular_etiqueta;
/
