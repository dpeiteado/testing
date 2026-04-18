ALTER SESSION SET CONTAINER = freepdb1;

ALTER SESSION SET current_schema = dgt_admin;


-- Garantiza que un vehículo solo pueda tener un expediente activo a la vez
CREATE UNIQUE INDEX uq_expediente_activo 
ON expediente (CASE WHEN fecha_finalizacion IS NULL THEN id_vehiculo END);

-- Garantiza que un vehículo solo pueda tener una matrícula activa a la vez
CREATE UNIQUE INDEX uq_matricula_activa 
ON matricula (CASE WHEN fecha_fin IS NULL THEN id_vehiculo END);

-- Garantiza que un vehículo solo pueda tener un titular vigente a la vez
CREATE UNIQUE INDEX uq_titular_vigente 
ON registro_titularidad (CASE WHEN fecha_fin IS NULL THEN id_vehiculo END);