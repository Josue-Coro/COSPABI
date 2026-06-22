IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'GENERADO')
    INSERT INTO estado (estado) VALUES ('GENERADO');   -- id 1
IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'LECTURADO')
    INSERT INTO estado (estado) VALUES ('LECTURADO');  -- id 2
IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'IMPRESO')
    INSERT INTO estado (estado) VALUES ('IMPRESO');    -- id 3
IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'PAGADO')
    INSERT INTO estado (estado) VALUES ('PAGADO');     -- id 4

    select * from estado