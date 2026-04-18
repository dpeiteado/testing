-- JOBS
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = dgt_admin;

/*
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_ANULAR_EXPEDIENTES_TEST',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'sp_anular_expedientes_caducados',
        start_date      => SYSTIMESTAMP,
        -- Esto hará que se ejecute cada 1 minuto exactamente:
        repeat_interval => 'FREQ=MINUTELY;INTERVAL=1', 
        enabled         => TRUE
    );
END;
/
*/

-- A LAS 12
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_ANULAR_EXPEDIENTES',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'sp_anular_expedientes_caducados',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY;BYHOUR=0;BYMINUTE=0;BYSECOND=0',
        enabled         => TRUE
    );
END;
/

