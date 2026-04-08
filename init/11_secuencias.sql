--Secuencia para la parte numérica de la matricula VEHICULO
CREATE SEQUENCE seq_num_matricula
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 9999
    CYCLE;   -- vuelve a 1 cuando llegue a 9999