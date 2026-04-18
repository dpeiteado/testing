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

-- PROCEDIMIENTO PARA INSERTAR EN LA TABLA DE AUDITORÍA
CREATE OR REPLACE PROCEDURE sp_log_auditoria (
    p_nombre_procedimiento IN VARCHAR2,
    p_parametro_in         IN CLOB,
    p_rsp                  IN CLOB
) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO log_auditoria (
        nombre_procedimiento,
        parametro_in,
        rsp
    ) VALUES (
        p_nombre_procedimiento,
        p_parametro_in,
        p_rsp
    );

    COMMIT;
END sp_log_auditoria;
/



CREATE OR REPLACE PROCEDURE sp_registrar_persona (
    p_numero_documento  IN VARCHAR2,
    p_id_tipo_documento IN NUMBER,
    p_id_municipio      IN NUMBER DEFAULT NULL,
    p_direccion         IN VARCHAR2,
    p_telefono          IN VARCHAR2,
    p_email             IN VARCHAR2,
    p_es_juridica       IN NUMBER,
    p_nombre            IN VARCHAR2 DEFAULT NULL,
    p_apellido1         IN VARCHAR2 DEFAULT NULL,
    p_apellido2         IN VARCHAR2 DEFAULT NULL,
    p_razon_social      IN VARCHAR2 DEFAULT NULL,
    p_out_id_persona    OUT NUMBER
) AS
    v_sqlerrm VARCHAR2(4000);
    -- Variable para no repetir la cadena de parámetros en el log
    v_log_params VARCHAR2(4000);
BEGIN
    -- Cadena de parámetros para usarla en los logs
    v_log_params := 'doc=' || p_numero_documento || ', tipo_doc=' || p_id_tipo_documento ||
                    ', mun=' || p_id_municipio || ', dir=' || p_direccion || ', tel=' || p_telefono ||
                    ', email=' || p_email || ', jur=' || p_es_juridica ||
                    ', nom=' || p_nombre || ', ap1=' || p_apellido1 ||
                    ', ap2=' || p_apellido2 || ', rs=' || p_razon_social;

    -- Intenta localizar a la persona mediante la función modular
    p_out_id_persona := buscar_persona(p_numero_documento, p_id_tipo_documento);

    -- La persona ya existe
    IF p_out_id_persona IS NOT NULL THEN
        sp_log_auditoria(
            'sp_registrar_persona',
            v_log_params,
            'OK: Persona ya en el sistema, id=' || p_out_id_persona
        );
        RETURN;
    END IF;

    -- Inserción en tabla base
    BEGIN
        INSERT INTO persona (numero_documento, id_tipo_documento, id_municipio, direccion, telefono, email)
        VALUES (p_numero_documento, p_id_tipo_documento, p_id_municipio, p_direccion, p_telefono, p_email)
        RETURNING id_persona INTO p_out_id_persona;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            -- CONDICION DE CARRERA: Otra transacción ha insertado a la persona justo antes
            p_out_id_persona := buscar_persona(p_numero_documento, p_id_tipo_documento);
            sp_log_auditoria(
                'sp_registrar_persona',
                v_log_params,
                'WARN_RACE: Persona insertada concurrentemente, recuperado id=' || p_out_id_persona
            );
            RETURN;
    END;

    -- SElecion del tipo de persona para insertar en la tabla correspondiente (juridica o fisica)
    IF p_es_juridica = 1 THEN
        IF p_razon_social IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'La razón social es obligatoria para personas jurídicas.');
        END IF;

        INSERT INTO persona_juridica (id_persona, razon_social)
        VALUES (p_out_id_persona, p_razon_social);

    ELSIF p_es_juridica = 0 THEN
        IF p_nombre IS NULL OR p_apellido1 IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'Nombre y primer apellido obligatorios para personas físicas.');
        END IF;

        INSERT INTO persona_fisica (id_persona, nombre, apellido1, apellido2)
        VALUES (p_out_id_persona, p_nombre, p_apellido1, p_apellido2);
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Valor no válido para p_es_juridica (0 o 1).');
    END IF;

    -- ESCENARIO IDEAL: Registro exitoso
    sp_log_auditoria(
        'sp_registrar_persona',
        v_log_params,
        'OK: Persona creada con id=' || p_out_id_persona
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        -- Registro de errores
        sp_log_auditoria(
            'sp_registrar_persona',
            v_log_params,
            'ERROR: ' || v_sqlerrm
        );
        ROLLBACK;
        RAISE;
END sp_registrar_persona;
/

GRANT EXECUTE ON dgt_admin.sp_registrar_persona TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_registrar_persona FOR dgt_admin.sp_registrar_persona;


------------------ PROCEDIMIENTO PARA CREAR UN TITULAR (ROL ADMINISTRATIVO) A PARTIR DE UNA PERSONA EXISTENTE
CREATE OR REPLACE PROCEDURE sp_crear_titular (
    p_id_persona          IN  NUMBER,
    p_id_tipo_titularidad IN  NUMBER,
    p_out_id_titular      OUT NUMBER
) AS
    v_sqlerrm VARCHAR2(4000);
    v_existe  NUMBER;
BEGIN
     -- CHECK si la persona existe
    BEGIN
        SELECT id_titular INTO p_out_id_titular
        FROM titular
        WHERE id_persona = p_id_persona;

        sp_log_auditoria(
            'sp_crear_titular',
            'id_persona=' || p_id_persona,
            'OK: titular ya existente, id=' || p_out_id_titular
        );
        RETURN; 
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Continuamos con la creación
    END;

    -- CHECK si tipo de titularidad existe 
    BEGIN
        SELECT 1 INTO v_existe FROM tipo_titularidad 
        WHERE id_tipo_titularidad = p_id_tipo_titularidad;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-21002, 'El tipo de titularidad indicado no existe.');
    END;

    -- Vincula la identidad (persona) con TITULAR DEL VEHICULO 
    BEGIN
        INSERT INTO titular (id_persona, id_tipo_titularidad)
        VALUES (p_id_persona, p_id_tipo_titularidad)
        RETURNING id_titular INTO p_out_id_titular;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            -- CONDICION DE CARRERA: Otra transaccion ha creado el titular simultáneamente
            SELECT id_titular INTO p_out_id_titular
            FROM titular
            WHERE id_persona = p_id_persona;

            sp_log_auditoria(
                'sp_crear_titular',
                'id_pers=' || p_id_persona || ', tipo=' || p_id_tipo_titularidad,
                'WARN_RACE: Titular creado concurrentemente, recuperado id=' || p_out_id_titular
            );
            RETURN;
    END;

    -- Registro en el repositorio de auditoría -> TODO BIEN
    sp_log_auditoria(
        'sp_crear_titular',
        'id_pers=' || p_id_persona || ', tipo=' || p_id_tipo_titularidad,
        'OK: titular creado, id=' || p_out_id_titular
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        -- Registro en el repositorio de auditoría -> HAY ERROR
        sp_log_auditoria(
            'sp_crear_titular',
            'id_persona=' || p_id_persona,
            'ERROR: ' || v_sqlerrm
        );
        ROLLBACK;
        RAISE;
END sp_crear_titular;
/

GRANT EXECUTE ON dgt_admin.sp_crear_titular TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_crear_titular FOR dgt_admin.sp_crear_titular;



CREATE OR REPLACE PROCEDURE sp_crear_vehiculo (
    p_marca                       IN VARCHAR2,
    p_modelo                      IN VARCHAR2,
    p_color                       IN VARCHAR2,
    p_es_importado                IN NUMBER,
    p_fecha_importacion           IN DATE DEFAULT NULL,
    p_supero_primera_inspeccion   IN NUMBER,
    p_fecha_primera_matriculacion IN DATE,
    p_out_id_vehiculo             OUT NUMBER
) AS
    v_sqlerrm    VARCHAR2(4000);
    v_log_params VARCHAR2(4000);
BEGIN
    -- Concatenación de parámetros para el registro de auditoría
    v_log_params := 'marca=' || p_marca
        || ', modelo=' || p_modelo
        || ', color=' || p_color
        || ', es_importado=' || p_es_importado
        || ', fecha_importacion=' || NVL(TO_CHAR(p_fecha_importacion,'YYYY-MM-DD'),'NULL')
        || ', supero_primera_inspeccion=' || p_supero_primera_inspeccion
        || ', fecha_primera_matriculacion=' || TO_CHAR(p_fecha_primera_matriculacion,'YYYY-MM-DD');

    -- Inserción de los datos en la tabla vehiculo
    INSERT INTO vehiculo (
        marca,
        modelo,
        color,
        es_importado,
        fecha_importacion,
        supero_primera_inspeccion,
        fecha_primera_matriculacion
    ) VALUES (
        p_marca,
        p_modelo,
        p_color,
        p_es_importado,
        p_fecha_importacion,
        p_supero_primera_inspeccion,
        p_fecha_primera_matriculacion
    )
    RETURNING id_vehiculo INTO p_out_id_vehiculo;

    -- Registro de éxito en el log autónomo
    sp_log_auditoria(
        'sp_crear_vehiculo',
        v_log_params,
        'OK: Vehículo creado, id=' || p_out_id_vehiculo
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        -- Registro del error antes de realizar el rollback
        sp_log_auditoria(
            'sp_crear_vehiculo',
            v_log_params,
            'ERROR: ' || v_sqlerrm
        );
        ROLLBACK;
        RAISE;
END sp_crear_vehiculo;
/


GRANT EXECUTE ON dgt_admin.sp_crear_vehiculo TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_crear_vehiculo FOR dgt_admin.sp_crear_vehiculo;



CREATE OR REPLACE PROCEDURE sp_registrar_ficha_tecnica (
    p_vin               IN VARCHAR2,
    p_cilindrada        IN NUMBER,
    p_potencia_cv       IN NUMBER,
    p_potencia_kw       IN NUMBER,
    p_numero_plazas     IN NUMBER,
    p_mma               IN NUMBER,
    p_dimensiones       IN VARCHAR2,
    p_fecha_fabricacion IN DATE,
    p_id_tipo_vehiculo  IN NUMBER,
    p_id_vehiculo       IN NUMBER,
    p_id_combustible    IN NUMBER,
    p_id_normativa      IN NUMBER,
    p_out_id_ficha      OUT NUMBER
) AS
    v_sqlerrm    VARCHAR2(4000);
    v_log_params CLOB;
    v_dummy      NUMBER;
BEGIN
    v_log_params :=
           'vin=' || p_vin
        || ', cilindrada=' || p_cilindrada
        || ', potencia_cv=' || p_potencia_cv
        || ', potencia_kw=' || p_potencia_kw
        || ', plazas=' || p_numero_plazas
        || ', mma=' || p_mma
        || ', dimensiones=' || p_dimensiones
        || ', fecha_fabricacion=' || TO_CHAR(p_fecha_fabricacion,'YYYY-MM-DD')
        || ', id_tipo_vehiculo=' || p_id_tipo_vehiculo
        || ', id_vehiculo=' || p_id_vehiculo
        || ', id_combustible=' || p_id_combustible
        || ', id_normativa=' || p_id_normativa;

    SELECT 1 INTO v_dummy FROM vehiculo WHERE id_vehiculo = p_id_vehiculo;

    SELECT 1 INTO v_dummy FROM tipo_vehiculo WHERE id_tipo_vehiculo = p_id_tipo_vehiculo;

    SELECT 1 INTO v_dummy FROM tipo_combustible WHERE id_combustible = p_id_combustible;

    INSERT INTO ficha_tecnica (
        vin,
        cilindrada,
        potencia_cv,
        potencia_kw,
        numero_plazas,
        mma,
        dimensiones,
        fecha_fabricacion,
        id_tipo_vehiculo,
        id_vehiculo,
        id_combustible,
        id_normativa
    ) VALUES (
        p_vin,
        p_cilindrada,
        p_potencia_cv,
        p_potencia_kw,
        p_numero_plazas,
        p_mma,
        p_dimensiones,
        p_fecha_fabricacion,
        p_id_tipo_vehiculo,
        p_id_vehiculo,
        p_id_combustible,
        p_id_normativa
    )
    RETURNING id_ficha INTO p_out_id_ficha;

    sp_log_auditoria(
        'sp_registrar_ficha_tecnica',
        v_log_params,
        'OK: ficha registrada, id_ficha=' || p_out_id_ficha
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_sqlerrm := 'Ficha técnica duplicada: VIN o id_vehiculo ya existen.';
        sp_log_auditoria('sp_registrar_ficha_tecnica', v_log_params, 'ERROR: ' || v_sqlerrm);
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-24001, v_sqlerrm);

    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        sp_log_auditoria('sp_registrar_ficha_tecnica', v_log_params, 'ERROR: ' || v_sqlerrm);
        ROLLBACK;
        RAISE;
END sp_registrar_ficha_tecnica;
/

GRANT EXECUTE ON dgt_admin.sp_registrar_ficha_tecnica TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_registrar_ficha_tecnica FOR dgt_admin.sp_registrar_ficha_tecnica;


CREATE OR REPLACE PROCEDURE sp_registrar_homologacion (
    p_contrasena_homologacion IN VARCHAR2,
    p_autoridad_homologacion  IN VARCHAR2,
    p_fabricante              IN VARCHAR2,
    p_fecha_homologacion      IN DATE,
    p_id_vehiculo             IN NUMBER,
    p_out_id_homologacion     OUT NUMBER
) AS
    v_sqlerrm    VARCHAR2(4000);
    v_log_params CLOB;
    v_dummy      NUMBER;
BEGIN
    v_log_params :=
           'contrasena=' || p_contrasena_homologacion
        || ', autoridad=' || p_autoridad_homologacion
        || ', fabricante=' || p_fabricante
        || ', fecha=' || TO_CHAR(p_fecha_homologacion,'YYYY-MM-DD')
        || ', id_vehiculo=' || p_id_vehiculo;

    SELECT 1 INTO v_dummy
    FROM vehiculo
    WHERE id_vehiculo = p_id_vehiculo;

    INSERT INTO homologacion (
        contrasena_homologacion,
        autoridad_homologacion,
        fabricante,
        fecha_homologacion,
        id_vehiculo
    ) VALUES (
        p_contrasena_homologacion,
        p_autoridad_homologacion,
        p_fabricante,
        p_fecha_homologacion,
        p_id_vehiculo
    )
    RETURNING id INTO p_out_id_homologacion;

    sp_log_auditoria(
        'sp_registrar_homologacion',
        v_log_params,
        'OK: homologación registrada, id=' || p_out_id_homologacion
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_sqlerrm := 'El vehículo ' || p_id_vehiculo || ' ya tiene homologación registrada.';
        sp_log_auditoria('sp_registrar_homologacion', v_log_params, 'ERROR: ' || v_sqlerrm);
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-25001, v_sqlerrm);

    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        sp_log_auditoria('sp_registrar_homologacion', v_log_params, 'ERROR: ' || v_sqlerrm);
        ROLLBACK;
        RAISE;
END sp_registrar_homologacion;
/


GRANT EXECUTE ON dgt_admin.sp_registrar_homologacion TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_registrar_homologacion FOR dgt_admin.sp_registrar_homologacion;



CREATE OR REPLACE PROCEDURE sp_registrar_emisiones (
    p_emisiones_co2       IN NUMBER,
    p_id_vehiculo         IN NUMBER,
    p_id_factor_emisiones IN NUMBER,
    p_out_id_emisiones    OUT NUMBER
) AS
    v_sqlerrm    VARCHAR2(4000);
    v_log_params CLOB;
    v_dummy      NUMBER;
BEGIN
    v_log_params :=
           'co2=' || p_emisiones_co2
        || ', id_vehiculo=' || p_id_vehiculo
        || ', id_factor_emisiones=' || p_id_factor_emisiones;

    SELECT 1 INTO v_dummy
    FROM vehiculo
    WHERE id_vehiculo = p_id_vehiculo;

    SELECT 1 INTO v_dummy
    FROM factor_emisiones
    WHERE id = p_id_factor_emisiones;

    INSERT INTO emisiones (
        emisiones_co2,
        id_vehiculo,
        id_factor_emisiones
    ) VALUES (
        p_emisiones_co2,
        p_id_vehiculo,
        p_id_factor_emisiones
    )
    RETURNING id INTO p_out_id_emisiones;

    sp_log_auditoria(
        'sp_registrar_emisiones',
        v_log_params,
        'OK: emisiones registradas, id=' || p_out_id_emisiones
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        v_sqlerrm := 'El vehículo ' || p_id_vehiculo || ' ya tiene emisiones registradas.';
        sp_log_auditoria('sp_registrar_emisiones', v_log_params, 'ERROR: ' || v_sqlerrm);
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-26001, v_sqlerrm);

    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        sp_log_auditoria('sp_registrar_emisiones', v_log_params, 'ERROR: ' || v_sqlerrm);
        ROLLBACK;
        RAISE;
END sp_registrar_emisiones;
/


GRANT EXECUTE ON dgt_admin.sp_registrar_emisiones TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_registrar_emisiones FOR dgt_admin.sp_registrar_emisiones;




CREATE OR REPLACE PROCEDURE sp_crear_expediente_matriculacion (
    p_id_vehiculo             IN NUMBER,
    p_id_jefatura_provincial  IN NUMBER,
    p_fecha_inicio            IN DATE DEFAULT SYSDATE,
    p_out_id_expediente       OUT NUMBER
) AS
    v_sqlerrm    VARCHAR2(4000);
    v_log_params CLOB;
    v_dummy      NUMBER;
BEGIN
    v_log_params :=
           'id_vehiculo=' || p_id_vehiculo
        || ', id_jefatura=' || p_id_jefatura_provincial
        || ', fecha_inicio=' || TO_CHAR(p_fecha_inicio,'YYYY-MM-DD');

    SELECT 1 INTO v_dummy
    FROM vehiculo
    WHERE id_vehiculo = p_id_vehiculo;

    SELECT 1 INTO v_dummy
    FROM jefatura_provincial
    WHERE id_jefatura_provincial = p_id_jefatura_provincial;

    BEGIN
        SELECT 1 INTO v_dummy
        FROM expediente
        WHERE id_vehiculo = p_id_vehiculo
          AND fecha_finalizacion IS NULL;
        RAISE_APPLICATION_ERROR(-27001, 'El vehículo ya tiene un expediente activo.');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    INSERT INTO expediente (
        fecha_inicio,
        fecha_finalizacion,
        id_vehiculo,
        id_estado_exp,
        id_jefatura_provincial
    ) VALUES (
        p_fecha_inicio,
        NULL,
        p_id_vehiculo,
        1,
        p_id_jefatura_provincial
    )
    RETURNING id_expediente INTO p_out_id_expediente;

    sp_log_auditoria(
        'sp_crear_expediente_matriculacion',
        v_log_params,
        'OK: expediente creado, id=' || p_out_id_expediente
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        sp_log_auditoria(
            'sp_crear_expediente_matriculacion',
            v_log_params,
            'ERROR: ' || v_sqlerrm
        );
        ROLLBACK;
        RAISE;
END sp_crear_expediente_matriculacion;
/


GRANT EXECUTE ON dgt_admin.sp_crear_expediente_matriculacion TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_crear_expediente_matriculacion FOR dgt_admin.sp_crear_expediente_matriculacion;



CREATE OR REPLACE PROCEDURE sp_crear_registro_titularidad (
    p_id_titular            IN NUMBER,
    p_id_vehiculo           IN NUMBER,
    p_id_tipo_transaccion   IN NUMBER,
    p_fecha_inicio          IN DATE DEFAULT SYSDATE,
    p_out_id_registro       OUT NUMBER
) AS
    v_sqlerrm    VARCHAR2(4000);
    v_log_params CLOB;
    v_dummy      NUMBER;
BEGIN
    v_log_params :=
           'id_titular=' || p_id_titular
        || ', id_vehiculo=' || p_id_vehiculo
        || ', id_tipo_transaccion=' || p_id_tipo_transaccion
        || ', fecha_inicio=' || TO_CHAR(p_fecha_inicio,'YYYY-MM-DD');

    SELECT 1 INTO v_dummy
    FROM vehiculo
    WHERE id_vehiculo = p_id_vehiculo;

    SELECT 1 INTO v_dummy
    FROM titular
    WHERE id_titular = p_id_titular;

    SELECT 1 INTO v_dummy
    FROM tipo_transaccion
    WHERE id_tipo_transaccion = p_id_tipo_transaccion;

    UPDATE registro_titularidad
    SET fecha_fin = p_fecha_inicio
    WHERE id_vehiculo = p_id_vehiculo
      AND fecha_fin IS NULL;

    INSERT INTO registro_titularidad (
        fecha_inicio,
        fecha_fin,
        id_vehiculo,
        id_titular,
        id_tipo_transaccion
    ) VALUES (
        p_fecha_inicio,
        NULL,
        p_id_vehiculo,
        p_id_titular,
        p_id_tipo_transaccion
    )
    RETURNING id_registro_titularidad INTO p_out_id_registro;

    sp_log_auditoria(
        'sp_crear_registro_titularidad',
        v_log_params,
        'OK: titularidad registrada, id=' || p_out_id_registro
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        sp_log_auditoria(
            'sp_crear_registro_titularidad',
            v_log_params,
            'ERROR: ' || v_sqlerrm
        );
        ROLLBACK;
        RAISE;
END sp_crear_registro_titularidad;
/


GRANT EXECUTE ON dgt_admin.sp_crear_registro_titularidad TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_crear_registro_titularidad FOR dgt_admin.sp_crear_registro_titularidad;

CREATE OR REPLACE PROCEDURE sp_calcular_tasa_expediente (
    p_id_expediente IN NUMBER,
    p_id_tasa       OUT NUMBER
) AS
    v_id_vehiculo NUMBER;
    v_importe     NUMBER;
    v_id_ccaa     NUMBER;
    v_id_config   NUMBER;
    v_log_params  VARCHAR2(4000);
    v_sqlerrm     VARCHAR2(4000);
    v_existe      NUMBER;
BEGIN
    -- BLOQUEO Y VERIFICACIÓN (Protección contra condiciones de carrera)    
    SELECT e.id_vehiculo, p.id_ccaa
    INTO v_id_vehiculo, v_id_ccaa
    FROM expediente e
    JOIN jefatura_provincial jp ON e.id_jefatura_provincial = jp.id_jefatura_provincial
    JOIN municipio m           ON jp.id_municipio = m.id_municipio
    JOIN provincia p           ON m.id_provincia = p.id_provincia
    WHERE e.id_expediente = p_id_expediente
    FOR UPDATE; 

    -- COMPROBACIÓN DE TASA EXISTENTE    
    SELECT COUNT(*) INTO v_existe FROM tasa WHERE id_expediente = p_id_expediente;
    
    IF v_existe > 0 THEN
        SELECT id_tasa INTO p_id_tasa FROM tasa WHERE id_expediente = p_id_expediente;
        sp_log_auditoria('sp_calcular_tasa_expediente', 'ID='||p_id_expediente, 'WARN: Tasa ya existente recuperada ID='||p_id_tasa);
        RETURN;
    END IF;

    -- CÁLCULO DE IMPORTE
    v_importe := fn_calcular_tasa(v_id_vehiculo);

    IF v_importe IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Datos técnicos insuficientes para la tasa.');
    END IF;

    -- CONFIGURACIÓN VIGENTE
    SELECT id_configuracion_tasa
    INTO v_id_config
    FROM configuracion_tasa
    WHERE fecha_vigencia <= SYSDATE
      AND (fecha_fin IS NULL OR fecha_fin > SYSDATE)
    ORDER BY fecha_vigencia DESC
    FETCH FIRST 1 ROWS ONLY;

    -- REGISTRO DE LA LIQUIDACIÓN (PENDIENTE)
    INSERT INTO tasa (
        total, fecha_pago, id_configuracion_tasa,
        id_estado_pago_actual, id_expediente, id_ccaa
    ) VALUES (
        v_importe, NULL, v_id_config, 1, p_id_expediente, v_id_ccaa
    )
    RETURNING id_tasa INTO p_id_tasa;

    -- HISTÓRICO DE ESTADO
    INSERT INTO historico_pago (id_tasa, id_estado_pago, fecha_cambio)
    VALUES (p_id_tasa, 1, SYSDATE);

    -- AUDITORÍA
    v_log_params := 'exp=' || p_id_expediente || ', veh=' || v_id_vehiculo || ', imp=' || v_importe;
    sp_log_auditoria('sp_calcular_tasa_expediente', v_log_params, 'OK: Liquidación generada');

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        sp_log_auditoria('sp_calcular_tasa_expediente', 'ID='||p_id_expediente, 'ERROR: Datos no encontrados');
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN
        v_sqlerrm := SQLERRM;
        sp_log_auditoria('sp_calcular_tasa_expediente', 'ID='||p_id_expediente, 'ERROR: ' || v_sqlerrm);
        ROLLBACK;
        RAISE;
END sp_calcular_tasa_expediente;
/



GRANT EXECUTE ON dgt_admin.sp_calcular_tasa_expediente TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_calcular_tasa_expediente FOR dgt_admin.sp_calcular_tasa_expediente;


CREATE OR REPLACE PROCEDURE sp_registrar_pago_tasa (
    p_id_tasa IN NUMBER
) AS
    v_estado_actual NUMBER;
BEGIN    
    -- Bloquear la tasa para evitar condiciones de carrera    
    SELECT id_estado_pago_actual
    INTO v_estado_actual
    FROM tasa
    WHERE id_tasa = p_id_tasa
    FOR UPDATE;

    -- Check pendiente?
    IF v_estado_actual <> 1 THEN   -- 1 = PENDIENTE
        sp_log_auditoria(
            'sp_registrar_pago_tasa',
            'id_tasa=' || p_id_tasa,
            'ERROR: La tasa no está en estado PENDIENTE'
        );
        RAISE_APPLICATION_ERROR(-20002, 'La tasa no está pendiente de pago');
    END IF;

    -- Actualizar estado a PAGADA (2) y registrar fecha de pago
    UPDATE tasa
    SET id_estado_pago_actual = 2,   -- 2 = PAGADA
        fecha_pago = SYSDATE
    WHERE id_tasa = p_id_tasa;

    
    -- Insertar histórico
    INSERT INTO historico_pago (
        id_tasa,
        id_estado_pago,
        fecha_cambio
    ) VALUES (
        p_id_tasa,
        2,            -- PAGADA
        SYSDATE
    );

    -- Log OK
    sp_log_auditoria(
        'sp_registrar_pago_tasa',
        'id_tasa=' || p_id_tasa,
        'OK: Pago registrado correctamente'
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        sp_log_auditoria(
            'sp_registrar_pago_tasa',
            'id_tasa=' || p_id_tasa,
            'ERROR: No existe la tasa'
        );
        RAISE_APPLICATION_ERROR(-20001, 'No existe la tasa');

    WHEN OTHERS THEN
        sp_log_auditoria(
            'sp_registrar_pago_tasa',
            'id_tasa=' || p_id_tasa,
            'ERROR: ' || SQLERRM
        );
        RAISE;
END sp_registrar_pago_tasa;
/


GRANT EXECUTE ON dgt_admin.sp_registrar_pago_tasa TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_registrar_pago_tasa FOR dgt_admin.sp_registrar_pago_tasa;



CREATE OR REPLACE PROCEDURE sp_cambiar_estado_expediente (
    p_id_expediente   IN NUMBER,
    p_id_estado_nuevo IN NUMBER
) AS
    v_estado_actual NUMBER;
    v_count_estado  NUMBER;
BEGIN
    -- Bloqueo del expediente
    SELECT id_estado_exp
    INTO v_estado_actual
    FROM expediente
    WHERE id_expediente = p_id_expediente
    FOR UPDATE;

    -- Si el estado es el mismo, no hacemos nada para no duplicar historiales
    IF v_estado_actual = p_id_estado_nuevo THEN
        sp_log_auditoria(
            'sp_cambiar_estado_expediente',
            'id_expediente=' || p_id_expediente ||
            ', id_estado_nuevo=' || p_id_estado_nuevo,
            'OK: El expediente ya se encontraba en el estado indicado'
        );
        RETURN;
    END IF;

    -- Validación del estado nuevo
    SELECT COUNT(*)
    INTO v_count_estado
    FROM estado_expediente
    WHERE id_estado_exp = p_id_estado_nuevo;

    IF v_count_estado = 0 THEN
        sp_log_auditoria(
            'sp_cambiar_estado_expediente',
            'id_expediente=' || p_id_expediente ||
            ', id_estado_nuevo=' || p_id_estado_nuevo,
            'ERROR: Estado no válido'
        );
        RAISE_APPLICATION_ERROR(-20010, 'El estado indicado no existe');
    END IF;

    -- Actualización del expediente
    UPDATE expediente
    SET id_estado_exp = p_id_estado_nuevo
    WHERE id_expediente = p_id_expediente;

    -- Inserción en histórico
    INSERT INTO historico_estado_expediente (
        id_expediente,
        fecha_cambio,
        id_estado_exp
    ) VALUES (
        p_id_expediente,
        SYSDATE,
        p_id_estado_nuevo
    );

    -- Log OK
    sp_log_auditoria(
        'sp_cambiar_estado_expediente',
        'id_expediente=' || p_id_expediente ||
        ', id_estado_nuevo=' || p_id_estado_nuevo,
        'OK: Estado actualizado'
    );

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        sp_log_auditoria(
            'sp_cambiar_estado_expediente',
            'id_expediente=' || p_id_expediente ||
            ', id_estado_nuevo=' || p_id_estado_nuevo,
            'ERROR: Expediente no encontrado'
        );
        RAISE_APPLICATION_ERROR(-20011, 'El expediente no existe');

    WHEN OTHERS THEN
        sp_log_auditoria(
            'sp_cambiar_estado_expediente',
            'id_expediente=' || p_id_expediente ||
            ', id_estado_nuevo=' || p_id_estado_nuevo,
            'ERROR: ' || SQLERRM
        );
        RAISE;
END sp_cambiar_estado_expediente;
/

GRANT EXECUTE ON dgt_admin.sp_cambiar_estado_expediente TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_cambiar_estado_expediente FOR dgt_admin.sp_cambiar_estado_expediente;

CREATE OR REPLACE PROCEDURE sp_generar_matricula_expediente (
    p_id_expediente IN NUMBER
) AS
    v_id_vehiculo      NUMBER;
    v_estado           NUMBER;
    v_id_matricula     NUMBER;
    v_id_tipo          NUMBER;
    v_id_etiqueta      NUMBER;
    v_anio             NUMBER := EXTRACT(YEAR FROM SYSDATE);
    v_count            NUMBER;
BEGIN
    -- Bloqueo del expediente
    SELECT id_vehiculo, id_estado_exp
    INTO v_id_vehiculo, v_estado
    FROM expediente
    WHERE id_expediente = p_id_expediente
    FOR UPDATE;

    -- Validación de estado COMPLETADO
    IF v_estado <> 2 THEN
        sp_log_auditoria(
            'sp_generar_matricula_expediente',
            'id_expediente=' || p_id_expediente,
            'ERROR: El expediente no está COMPLETADO'
        );
        RAISE_APPLICATION_ERROR(-20020, 'El expediente no está en estado COMPLETADO');
    END IF;

    -- Obtener tipo de vehículo y etiqueta ambiental
    SELECT f.id_tipo_vehiculo, v.id_etiqueta
    INTO v_id_tipo, v_id_etiqueta
    FROM vehiculo v
    JOIN ficha_tecnica f ON v.id_vehiculo = f.id_vehiculo
    WHERE v.id_vehiculo = v_id_vehiculo;

    -- Inserción en matricula (el trigger genera la matrícula)
    INSERT INTO matricula (
        id_vehiculo,
        fecha_asignacion
    ) VALUES (
        v_id_vehiculo,
        SYSDATE
    )
    RETURNING id_matricula INTO v_id_matricula;

    -- Actualizar re_matriculaciones_tipo_anual
    SELECT COUNT(*)
    INTO v_count
    FROM re_matriculaciones_tipo_anual
    WHERE id_tipo_vehiculo = v_id_tipo
      AND anio = v_anio;

    IF v_count = 0 THEN
        INSERT INTO re_matriculaciones_tipo_anual (
            id_tipo_vehiculo, anio, total_matriculaciones
        ) VALUES (
            v_id_tipo, v_anio, 1
        );
    ELSE
        UPDATE re_matriculaciones_tipo_anual
        SET total_matriculaciones = total_matriculaciones + 1
        WHERE id_tipo_vehiculo = v_id_tipo
          AND anio = v_anio;
    END IF;

    -- Actualizar re_distribucion_etiqueta_ambiental
    UPDATE re_distribucion_etiqueta_ambiental
    SET total_vehiculos = total_vehiculos + 1
    WHERE id_etiqueta = v_id_etiqueta;

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO re_distribucion_etiqueta_ambiental (id_etiqueta, total_vehiculos)
        VALUES (v_id_etiqueta, 1);
    END IF;

    -- Log OK
    sp_log_auditoria(
        'sp_generar_matricula_expediente',
        'id_expediente=' || p_id_expediente ||
        ', id_vehiculo=' || v_id_vehiculo ||
        ', id_matricula=' || v_id_matricula,
        'OK: Matrícula generada y estadísticas actualizadas'
    );

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        sp_log_auditoria(
            'sp_generar_matricula_expediente',
            'id_expediente=' || p_id_expediente,
            'ERROR: Expediente o vehículo no encontrado'
        );
        RAISE_APPLICATION_ERROR(-20021, 'El expediente o vehículo no existe');

    WHEN OTHERS THEN
        sp_log_auditoria(
            'sp_generar_matricula_expediente',
            'id_expediente=' || p_id_expediente,
            'ERROR: ' || SQLERRM
        );
        RAISE;
END sp_generar_matricula_expediente;
/




GRANT EXECUTE ON dgt_admin.sp_generar_matricula_expediente TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_generar_matricula_expediente FOR dgt_admin.sp_generar_matricula_expediente;




-- GENERACIÓN DE DOCUMENTACIÓN
CREATE OR REPLACE PROCEDURE sp_generar_documentacion (
    p_id_expediente IN NUMBER
) AS
    v_id_vehiculo NUMBER;
    v_matricula   VARCHAR2(10);
    v_etiqueta    VARCHAR2(5);
    v_permiso     CLOB;
    v_ficha       CLOB;
    v_cert        CLOB;
BEGIN
    -- Verificar expediente en estado COMPLETADO (2) y recuperar vehiculo
    SELECT id_vehiculo INTO v_id_vehiculo
    FROM expediente
    WHERE id_expediente = p_id_expediente 
      AND id_estado_exp = 2;

    -- Obtener matrícula asignada
    SELECT matricula INTO v_matricula
    FROM matricula
    WHERE id_vehiculo = v_id_vehiculo 
      AND fecha_fin IS NULL;
    
    -- Obtener etiqueta (codigo)
    SELECT e.codigo INTO v_etiqueta
    FROM vehiculo v
    LEFT JOIN etiqueta_ambiental e ON v.id_etiqueta = e.id_etiqueta
    WHERE v.id_vehiculo = v_id_vehiculo;

    -- Generar JSON o texto básico simulando los documentos
    v_permiso := '{"documento": "PERMISO DE CIRCULACION", "matricula": "' || v_matricula || '", "estado": "VIGENTE"}';
    v_ficha   := '{"documento": "FICHA TECNICA VEHICULO", "vehiculo_id": ' || v_id_vehiculo || '}';
    v_cert    := '{"documento": "CERTIFICADO CARACTERISTICAS TECNICAS", "valido": true}';

    -- Insertar en la tabla documentacion
    INSERT INTO documentacion (
        id_expediente, 
        fecha_generacion, 
        permiso_circulacion, 
        ficha_tecnica, 
        etiqueta_ambiental, 
        certificado_tecnico, 
        fecha_fin
    ) VALUES (
        p_id_expediente, 
        SYSDATE, 
        v_permiso, 
        v_ficha, 
        v_etiqueta, 
        v_cert, 
        NULL
    );

    sp_log_auditoria(
        'sp_generar_documentacion',
        'id_expediente=' || p_id_expediente,
        'OK: Documentación administrativa generada y archivada'
    );
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        sp_log_auditoria(
            'sp_generar_documentacion', 
            'id_exp=' || p_id_expediente, 
            'ERROR: Expediente no válido o sin matrícula'
        );
        RAISE_APPLICATION_ERROR(-20040, 'El expediente no está completado o no tiene matrícula asignada');
    WHEN OTHERS THEN
        sp_log_auditoria(
            'sp_generar_documentacion', 
            'id_exp=' || p_id_expediente, 
            'ERROR: ' || SQLERRM
        );
        ROLLBACK;
        RAISE;
END sp_generar_documentacion;
/

GRANT EXECUTE ON dgt_admin.sp_generar_documentacion TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_generar_documentacion FOR dgt_admin.sp_generar_documentacion;


CREATE OR REPLACE PROCEDURE sp_transferir_titularidad (
    p_id_vehiculo       IN NUMBER,
    p_id_titular_nuevo  IN NUMBER
) AS
    v_id_registro_actual   NUMBER;
    v_id_titular_actual    NUMBER;
    v_id_provincia         NUMBER;
    v_anio                 NUMBER := EXTRACT(YEAR FROM SYSDATE);
    v_count                NUMBER;
BEGIN
    -- Obtener y bloquear la titularidad activa
    SELECT id_registro_titularidad, id_titular
    INTO v_id_registro_actual, v_id_titular_actual
    FROM registro_titularidad
    WHERE id_vehiculo = p_id_vehiculo
      AND fecha_fin IS NULL
    FOR UPDATE;

    -- Cerrar titularidad actual
    UPDATE registro_titularidad
    SET fecha_fin = SYSDATE
    WHERE id_registro_titularidad = v_id_registro_actual;

    -- Insertar nueva titularidad (TRANSFERENCIA = 5)
    INSERT INTO registro_titularidad (
        fecha_inicio,
        fecha_fin,
        id_vehiculo,
        id_titular,
        id_tipo_transaccion
    ) VALUES (
        SYSDATE,
        NULL,
        p_id_vehiculo,
        p_id_titular_nuevo,
        5
    );

    -- Obtener provincia del nuevo titular
    SELECT m.id_provincia
    INTO v_id_provincia
    FROM titular t
    JOIN persona p ON t.id_persona = p.id_persona
    JOIN municipio m ON p.id_municipio = m.id_municipio
    WHERE t.id_titular = p_id_titular_nuevo;

    -- Actualizar estadística de transferencias
    SELECT COUNT(*)
    INTO v_count
    FROM re_transferencias_provincia_anual
    WHERE id_provincia = v_id_provincia
      AND anio = v_anio;

    IF v_count = 0 THEN
        INSERT INTO re_transferencias_provincia_anual (
            id_provincia, anio, total_transferencias
        ) VALUES (
            v_id_provincia, v_anio, 1
        );
    ELSE
        UPDATE re_transferencias_provincia_anual
        SET total_transferencias = total_transferencias + 1
        WHERE id_provincia = v_id_provincia
          AND anio = v_anio;
    END IF;

    -- Log OK
    sp_log_auditoria(
        'sp_transferir_titularidad',
        'id_vehiculo=' || p_id_vehiculo ||
        ', id_titular_nuevo=' || p_id_titular_nuevo,
        'OK: Transferencia realizada'
    );

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        sp_log_auditoria(
            'sp_transferir_titularidad',
            'id_vehiculo=' || p_id_vehiculo ||
            ', id_titular_nuevo=' || p_id_titular_nuevo,
            'ERROR: No existe titularidad activa o titular inválido'
        );
        RAISE_APPLICATION_ERROR(-20030, 'No existe titularidad activa o titular no válido');

    WHEN OTHERS THEN
        sp_log_auditoria(
            'sp_transferir_titularidad',
            'id_vehiculo=' || p_id_vehiculo ||
            ', id_titular_nuevo=' || p_id_titular_nuevo,
            'ERROR: ' || SQLERRM
        );
        RAISE;
END sp_transferir_titularidad;
/



GRANT EXECUTE ON dgt_admin.sp_transferir_titularidad TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_transferir_titularidad FOR dgt_admin.sp_transferir_titularidad;



-- PROCEDIMIENTO DE ANULACIÓN DE EXPEDIENTES POR CADUCIDAD
CREATE OR REPLACE PROCEDURE sp_anular_expedientes_caducados AS
BEGIN
    -- Insertamos en el histórico SÓLO los que van a cambiar a estado 3    
    INSERT INTO historico_estado_expediente (
        id_expediente,
        fecha_cambio,
        id_estado_exp
    )
    SELECT id_expediente, SYSDATE, 3
    FROM expediente
    WHERE fecha_limite_pago < SYSDATE
      AND id_estado_exp NOT IN (2, 3);

    -- Actualizamos el estado a 3
    UPDATE expediente
    SET id_estado_exp = 3
    WHERE fecha_limite_pago < SYSDATE
      AND id_estado_exp NOT IN (2, 3);

    sp_log_auditoria(
        'sp_anular_expedientes_caducados',
        'auto',
        'OK: Expedientes anulados por caducidad'
    );

    COMMIT;
END;
/


CREATE OR REPLACE PROCEDURE sp_verificar_requisitos_matriculacion (
    p_id_vehiculo IN NUMBER
) AS
    v_count NUMBER;
    v_importado NUMBER;
    v_revision NUMBER;
BEGIN
    -- HOMOLOGACIÓN (Certificado de conformidad europea)
    SELECT COUNT(*)
    INTO v_count
    FROM homologacion
    WHERE id_vehiculo = p_id_vehiculo
      AND contrasena_homologacion IS NOT NULL;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20100,
            'El vehículo no dispone de certificado de homologación europea'
        );
    END IF;

    --  Validación usando factor_emisiones (co2_min, co2_max)
    SELECT COUNT(*)
    INTO v_count
    FROM emisiones e
    JOIN factor_emisiones f
      ON e.emisiones_co2 BETWEEN f.co2_min AND f.co2_max
    WHERE e.id_vehiculo = p_id_vehiculo;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20101,
            'Las emisiones del vehículo no cumplen los límites establecidos por la normativa Euro'
        );
    END IF;

    -- FICHA TÉCNICA EXISTENTE
    SELECT COUNT(*)
    INTO v_count
    FROM ficha_tecnica
    WHERE id_vehiculo = p_id_vehiculo;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20102,
            'El vehículo no dispone de ficha técnica registrada'
        );
    END IF;

    -- ITV INICIAL OBLIGATORIA SI ES IMPORTADO
    SELECT es_importado, supero_primera_inspeccion
    INTO v_importado, v_revision
    FROM vehiculo
    WHERE id_vehiculo = p_id_vehiculo;

    IF v_importado = 1 AND v_revision = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20103,
            'El vehículo importado no ha superado la inspección técnica inicial obligatoria'
        );
    END IF;

    -- NO DEBE ESTAR YA MATRICULADO
    SELECT COUNT(*)
    INTO v_count
    FROM matricula
    WHERE id_vehiculo = p_id_vehiculo;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20104,
            'El vehículo ya está matriculado'
        );
    END IF;

    -- NO DEBE TENER EXPEDIENTE ACTIVO
    SELECT COUNT(*)
    INTO v_count
    FROM expediente
    WHERE id_vehiculo = p_id_vehiculo
      AND id_estado_exp <> 3;  -- 3 = ANULADO

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20105,
            'El vehículo ya tiene un expediente activo'
        );
    END IF;
    
    -- AUDITORÍA
    
    sp_log_auditoria(
        'sp_verificar_requisitos_matriculacion',
        'id_vehiculo=' || p_id_vehiculo,
        'OK: Requisitos de matriculación verificados correctamente'
    );

END;
/

GRANT EXECUTE ON dgt_admin.sp_verificar_requisitos_matriculacion TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_verificar_requisitos_matriculacion FOR dgt_admin.sp_verificar_requisitos_matriculacion;



CREATE OR REPLACE PROCEDURE sp_tramitar_matriculacion (
    p_id_vehiculo       IN NUMBER,
    p_id_titular        IN NUMBER,
    p_id_jefatura       IN NUMBER,
    p_out_id_expediente OUT NUMBER,
    p_out_id_tasa       OUT NUMBER,
    p_rsp               OUT VARCHAR2
) AS
    v_id_registro   NUMBER;
BEGIN
    --  Verificar requisitos técnicos y medioambientales
    sp_verificar_requisitos_matriculacion(p_id_vehiculo);

    -- Crear expediente de matriculación
    sp_crear_expediente_matriculacion(
        p_id_vehiculo             => p_id_vehiculo,
        p_id_jefatura_provincial  => p_id_jefatura,
        p_out_id_expediente       => p_out_id_expediente
    );

    -- Crear titularidad inicial del vehículo
    sp_crear_registro_titularidad(
        p_id_vehiculo         => p_id_vehiculo,
        p_id_titular          => p_id_titular,
        p_id_tipo_transaccion => 1,   -- 1 = Alta inicial
        p_out_id_registro     => v_id_registro
    );

    -- Calcular tasas asociadas al expediente
    sp_calcular_tasa_expediente(
        p_id_expediente => p_out_id_expediente,
        p_id_tasa       => p_out_id_tasa
    );

    -- Auditoría global del proceso
    sp_log_auditoria(
        'sp_tramitar_matriculacion',
        'vehiculo=' || p_id_vehiculo || ', titular=' || p_id_titular,
        'OK: Tramitación completada hasta fase de pago'
    );

    p_rsp := 'OK';

EXCEPTION
    WHEN OTHERS THEN
        sp_log_auditoria(
            'sp_tramitar_matriculacion',
            'vehiculo=' || p_id_vehiculo,
            'ERROR: ' || SQLERRM
        );
        p_rsp := 'ERROR: ' || SQLERRM;
        -- Revertir explícitamente en caso de error por buena práctica
        ROLLBACK;
        RAISE;
END sp_tramitar_matriculacion;
/


GRANT EXECUTE ON dgt_admin.sp_tramitar_matriculacion TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_tramitar_matriculacion FOR dgt_admin.sp_tramitar_matriculacion;


-- PROCEDIMIENTOS ORQUESTADORES (FACHADA)

CREATE OR REPLACE PROCEDURE sp_procesar_matriculacion (
    p_marca                       IN VARCHAR2,
    p_modelo                      IN VARCHAR2,
    p_color                       IN VARCHAR2,
    p_es_importado                IN NUMBER,
    p_vin                         IN VARCHAR2,
    p_cilindrada                  IN NUMBER,
    p_potencia_cv                 IN NUMBER,
    p_potencia_kw                 IN NUMBER,
    p_numero_plazas               IN NUMBER,
    p_mma                         IN NUMBER,
    p_dimensiones                 IN VARCHAR2,
    p_id_tipo_vehiculo            IN NUMBER,
    p_id_combustible              IN NUMBER,
    p_id_normativa                IN NUMBER,
    p_contrasena_homologacion     IN VARCHAR2,
    p_autoridad_homologacion      IN VARCHAR2,
    p_fabricante                  IN VARCHAR2,
    p_emisiones_co2               IN NUMBER,
    p_id_factor_emisiones         IN NUMBER,
    p_dni                         IN VARCHAR2,
    p_id_tipo_documento           IN NUMBER,
    p_id_municipio                IN NUMBER,
    p_direccion                   IN VARCHAR2,
    p_telefono                    IN VARCHAR2,
    p_email                       IN VARCHAR2,
    p_es_juridica                 IN NUMBER,
    p_nombre                      IN VARCHAR2,
    p_apellido1                   IN VARCHAR2,
    p_apellido2                   IN VARCHAR2,
    p_id_jefatura                 IN NUMBER,
    p_out_id_expediente           OUT NUMBER,
    p_out_matricula               OUT VARCHAR2
) AS
    v_id_vehiculo     NUMBER;
    v_id_ficha        NUMBER;
    v_id_homologacion NUMBER;
    v_id_emisiones    NUMBER;
    v_id_persona      NUMBER;
    v_id_titular      NUMBER;
    v_id_tasa         NUMBER;
    v_rsp             VARCHAR2(4000);
BEGIN
    -- VEHÍCULO
    sp_crear_vehiculo(
        p_marca                       => p_marca,
        p_modelo                      => p_modelo,
        p_color                       => p_color,
        p_es_importado                => p_es_importado,
        p_supero_primera_inspeccion   => 0,
        p_fecha_primera_matriculacion => SYSDATE,
        p_out_id_vehiculo             => v_id_vehiculo
    );

    sp_registrar_ficha_tecnica(
        p_vin               => p_vin,
        p_cilindrada        => p_cilindrada,
        p_potencia_cv       => p_potencia_cv,
        p_potencia_kw       => p_potencia_kw,
        p_numero_plazas     => p_numero_plazas,
        p_mma               => p_mma,
        p_dimensiones       => p_dimensiones,
        p_fecha_fabricacion => ADD_MONTHS(SYSDATE, -2),
        p_id_tipo_vehiculo  => p_id_tipo_vehiculo,
        p_id_vehiculo       => v_id_vehiculo,
        p_id_combustible    => p_id_combustible,
        p_id_normativa      => p_id_normativa,
        p_out_id_ficha      => v_id_ficha
    );

    sp_registrar_homologacion(
        p_contrasena_homologacion => p_contrasena_homologacion,
        p_autoridad_homologacion  => p_autoridad_homologacion,
        p_fabricante              => p_fabricante,
        p_fecha_homologacion      => ADD_MONTHS(SYSDATE, -6),
        p_id_vehiculo             => v_id_vehiculo,
        p_out_id_homologacion     => v_id_homologacion
    );

    sp_registrar_emisiones(
        p_emisiones_co2       => p_emisiones_co2,
        p_id_vehiculo         => v_id_vehiculo,
        p_id_factor_emisiones => p_id_factor_emisiones, 
        p_out_id_emisiones    => v_id_emisiones
    );

    -- VERIFICACIÓN TÉCNICA
    sp_verificar_requisitos_matriculacion(p_id_vehiculo => v_id_vehiculo);

    -- TITULAR
    -- Buscar si la persona ya existe, si no, crearla.
    BEGIN
        SELECT id_persona INTO v_id_persona 
        FROM persona 
        WHERE numero_documento = p_dni AND id_tipo_documento = p_id_tipo_documento;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            sp_registrar_persona(
                p_numero_documento  => p_dni,
                p_id_tipo_documento => p_id_tipo_documento, 
                p_id_municipio      => p_id_municipio, 
                p_direccion         => p_direccion,
                p_telefono          => p_telefono,
                p_email             => p_email,
                p_es_juridica       => p_es_juridica, 
                p_nombre            => p_nombre,
                p_apellido1         => p_apellido1,
                p_apellido2         => p_apellido2,
                p_out_id_persona    => v_id_persona
            );
    END;

    -- Buscar o crear titular
    BEGIN
        SELECT id_titular INTO v_id_titular
        FROM titular
        WHERE id_persona = v_id_persona;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            sp_crear_titular(
                p_id_persona          => v_id_persona,
                p_id_tipo_titularidad => 1, 
                p_out_id_titular      => v_id_titular
            );
    END;

    -- TRAMITACIÓN DGT
    sp_tramitar_matriculacion(
        p_id_vehiculo       => v_id_vehiculo,
        p_id_titular        => v_id_titular,
        p_id_jefatura       => p_id_jefatura,
        p_out_id_expediente => p_out_id_expediente,
        p_out_id_tasa       => v_id_tasa,
        p_rsp               => v_rsp
    );

    IF v_rsp = 'OK' THEN
        sp_registrar_pago_tasa(p_id_tasa => v_id_tasa);
        sp_cambiar_estado_expediente(p_id_expediente => p_out_id_expediente, p_id_estado_nuevo => 2);
        sp_generar_matricula_expediente(p_id_expediente => p_out_id_expediente);
        sp_generar_documentacion(p_id_expediente => p_out_id_expediente);
        
        -- Obtener la matricula final para devolverla
        SELECT matricula INTO p_out_matricula
        FROM matricula
        WHERE id_vehiculo = v_id_vehiculo AND fecha_fin IS NULL;
    ELSE
        p_out_matricula := 'ERROR';
        RAISE_APPLICATION_ERROR(-20050, 'Error en tramitación: ' || v_rsp);
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        sp_log_auditoria('sp_procesar_matriculacion', 'vin='||p_vin, 'ERROR FATAL: ' || SQLERRM);
        RAISE;
END sp_procesar_matriculacion;
/

GRANT EXECUTE ON dgt_admin.sp_procesar_matriculacion TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_procesar_matriculacion FOR dgt_admin.sp_procesar_matriculacion;


-- PROCEDIMIENTO ORQUESTADOR PARA TRANSFERENCIAS
CREATE OR REPLACE PROCEDURE sp_procesar_transferencia (
    p_vin                         IN VARCHAR2,
    p_dni_comprador               IN VARCHAR2,
    p_id_tipo_documento           IN NUMBER,
    p_id_municipio                IN NUMBER,
    p_direccion                   IN VARCHAR2,
    p_telefono                    IN VARCHAR2,
    p_email                       IN VARCHAR2,
    p_es_juridica                 IN NUMBER,
    p_nombre                      IN VARCHAR2,
    p_apellido1                   IN VARCHAR2,
    p_apellido2                   IN VARCHAR2
) AS
    v_id_vehiculo NUMBER;
    v_id_persona  NUMBER;
    v_id_titular  NUMBER;
BEGIN
    -- Buscar vehículo por bastidor
    BEGIN
        SELECT v.id_vehiculo INTO v_id_vehiculo
        FROM vehiculo v
        JOIN ficha_tecnica ft ON v.id_vehiculo = ft.id_vehiculo
        WHERE ft.vin = p_vin;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20051, 'No se ha encontrado ningún vehículo con bastidor: ' || p_vin);
    END;

    -- Buscar si la persona ya existe, si no, crearla.
    BEGIN
        SELECT id_persona INTO v_id_persona 
        FROM persona 
        WHERE numero_documento = p_dni_comprador AND id_tipo_documento = p_id_tipo_documento;
        
        sp_log_auditoria('sp_procesar_transferencia', 'dni='||p_dni_comprador, 'INFO: Persona ya existe, procediendo...');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            sp_registrar_persona(
                p_numero_documento  => p_dni_comprador,
                p_id_tipo_documento => p_id_tipo_documento, 
                p_id_municipio      => p_id_municipio, 
                p_direccion         => p_direccion,
                p_telefono          => p_telefono,
                p_email             => p_email,
                p_es_juridica       => p_es_juridica, 
                p_nombre            => p_nombre,
                p_apellido1         => p_apellido1,
                p_apellido2         => p_apellido2,
                p_out_id_persona    => v_id_persona
            );
            sp_log_auditoria('sp_procesar_transferencia', 'dni='||p_dni_comprador, 'INFO: Persona nueva registrada.');
    END;

    -- Buscar o crear titular
    BEGIN
        SELECT id_titular INTO v_id_titular
        FROM titular
        WHERE id_persona = v_id_persona;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            sp_crear_titular(
                p_id_persona          => v_id_persona,
                p_id_tipo_titularidad => 1, 
                p_out_id_titular      => v_id_titular
            );
    END;

    -- Ejecutar Transferencia (que se encarga de cerrar titularidad anterior e insertar nueva)
    sp_transferir_titularidad(
        p_id_vehiculo       => v_id_vehiculo,
        p_id_titular_nuevo  => v_id_titular
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        sp_log_auditoria('sp_procesar_transferencia', 'vin='||p_vin||', dni='||p_dni_comprador, 'ERROR: ' || SQLERRM);
        RAISE;
END sp_procesar_transferencia;
/

GRANT EXECUTE ON dgt_admin.sp_procesar_transferencia TO rol_funcionario;
CREATE PUBLIC SYNONYM sp_procesar_transferencia FOR dgt_admin.sp_procesar_transferencia;
