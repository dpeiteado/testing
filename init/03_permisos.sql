ALTER SESSION SET CONTAINER = FREEPDB1;

-- Permisos de construcción para el admin
GRANT CONNECT, RESOURCE TO dgt_admin;
GRANT CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER, CREATE TABLE TO dgt_admin;

-- Asignación de roles
GRANT rol_agente TO agente_gc01;
GRANT rol_funcionario TO funcionario01;
GRANT rol_analista TO analista01;


/*
ALTER SESSION SET CONTAINER = FREEPDB1;

-- Permisos al ADMIN 
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO dgt_admin;

-- Cuotas al ADMIN en sus tablespaces
ALTER USER dgt_admin QUOTA UNLIMITED ON dgt_data;
ALTER USER dgt_admin QUOTA UNLIMITED ON dgt_index;
ALTER USER dgt_admin QUOTA UNLIMITED ON dgt_log;
ALTER USER dgt_admin QUOTA UNLIMITED ON dgt_dw;

-- Asignación de Roles a Usuarios/trabajadores de la DGT
GRANT rol_agente TO agente_gc01;
GRANT rol_funcionario TO funcionario01;
GRANT rol_analista TO analista01;



*/
