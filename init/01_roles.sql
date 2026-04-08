ALTER SESSION SET CONTAINER = FREEPDB1;
-- ROLES
CREATE ROLE rol_agente;
CREATE ROLE rol_funcionario;
CREATE ROLE rol_analista;


GRANT CREATE SESSION TO rol_agente, rol_funcionario, rol_analista;

