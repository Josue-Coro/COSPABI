USE [COSPABIRL1]
GO
-- =============================================================================
-- Datos de prueba: 50 personas x 4 socios = 200 socios con inscripcion pagada
--
-- Estado de partida esperado (BD de desarrollo, 2026-09-08):
--   persona : 2   (Segundino Coro Rodriguez, Santiago Arequipa Espinoza)
--   socio   : 3   (ids 2, 3, 4)
--   medidor : 3   (M123, M321, M231)
--   caja    : 1   (abierta, Josue, 2026-09-08)
--
-- Lo que hace, en UNA transaccion:
--   1) Inserta 48 personas nuevas (ids 3..50).
--   2) Abre la caja de ENERO/2026 a nombre de la cajera (Delia Barrionuevo).
--   3) Completa a 4 socios por persona con el SP real del sistema
--      (sp_registrar_socio_con_inscripcion): pago total Bs. 1700 en efectivo,
--      1 cuota CANCELADO en 01/2026, pago APROBADO en la caja de enero.
--      Cada socio recibe su propio medidor (sp_crear_medidor).
--      Nombres: "Nombre", "Nombre 2" (rol SOCIO), "Nombre 3", "Nombre 4" (rol USUARIO).
--   4) Mueve la inscripcion de los 3 socios que ya existian a enero (fecha,
--      periodo, caja y cajera) para que los 200 queden iguales, y corrige el
--      rol de "Santiago Arequipa Espinoza 2" a SOCIO segun la regla anterior.
--   5) Cierra la caja de enero (monto_cobrado = 200 x 1700 = 340.000) y crea
--      las cajas cerradas de febrero a agosto (sin cobros). La de septiembre es
--      la que ya existe; octubre-diciembre no se crean (fechas futuras).
--
-- Si cualquier registro falla el script hace ROLLBACK completo.
-- =============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @FECHA      DATE = '2026-01-05';          -- lunes, primer dia habil de enero
DECLARE @CAJERA_ID  INT  = (SELECT id_usuario_admin FROM usuario_admin WHERE usuario = 'delia');
DECLARE @CAJERA_NOM VARCHAR(150) = (SELECT nombre + ' ' + apellido FROM usuario_admin WHERE usuario = 'delia');
DECLARE @EFECTIVO   INT  = (SELECT id_metodo_pago FROM metodo_pago WHERE metodo = 'Efectivo');
DECLARE @ROL_SOCIO  INT  = (SELECT id_rol_socio FROM rol_socio WHERE rol_socio = 'SOCIO');
DECLARE @ROL_USUARIO INT = (SELECT id_rol_socio FROM rol_socio WHERE rol_socio = 'USUARIO');

IF @CAJERA_ID IS NULL OR @EFECTIVO IS NULL OR @ROL_SOCIO IS NULL OR @ROL_USUARIO IS NULL
BEGIN RAISERROR('Faltan datos base (cajera delia, metodo Efectivo, roles SOCIO/USUARIO).', 16, 1); RETURN; END

IF (SELECT COUNT(*) FROM persona) <> 2 OR (SELECT COUNT(*) FROM socio) <> 3
BEGIN RAISERROR('La BD no esta en el estado de partida esperado (2 personas / 3 socios). Script ya aplicado?', 16, 1); RETURN; END

IF NOT EXISTS (SELECT 1 FROM periodo WHERE periodo = '01/2026' AND costo_inscripcion = 1700)
BEGIN RAISERROR('Falta el periodo 01/2026 con costo_inscripcion 1700.', 16, 1); RETURN; END

BEGIN TRAN;

-- ---------------------------------------------------------------------------
-- 1) 48 personas nuevas
-- ---------------------------------------------------------------------------
CREATE TABLE #per (orden INT, nombre VARCHAR(250), genero VARCHAR(20), ci VARCHAR(50), fnac DATE, tel INT);
INSERT INTO #per VALUES
 ( 1,'Maria Luisa Quispe Mamani',      'Femenino', '4512873','1968-03-14',71234501),
 ( 2,'Juan Carlos Choque Flores',      'Masculino','5231904','1975-08-22',72345612),
 ( 3,'Rosa Elena Condori Apaza',       'Femenino', '6108347','1982-11-05',73456723),
 ( 4,'Pedro Antonio Mamani Cruz',      'Masculino','4879215','1959-06-30',74567834),
 ( 5,'Ana Beatriz Rojas Villca',       'Femenino', '5364128','1990-01-17',75678945),
 ( 6,'Luis Fernando Vargas Ticona',    'Masculino','6725093','1971-09-09',76789056),
 ( 7,'Carmen Rosa Flores Huanca',      'Femenino', '4293581','1965-12-01',77890167),
 ( 8,'Jorge Luis Apaza Quispe',        'Masculino','5817246','1985-04-28',78901278),
 ( 9,'Silvia Patricia Mamani Poma',    'Femenino', '6432719','1978-07-19',79012389),
 (10,'Ricardo Alberto Ticona Cruz',    'Masculino','4956830','1962-02-11',60123490),
 (11,'Gladys Marina Huanca Callisaya', 'Femenino', '5648201','1988-10-23',61234501),
 (12,'Miguel Angel Callisaya Nina',    'Masculino','6275914','1973-05-06',62345612),
 (13,'Lidia Esther Poma Chambi',       'Femenino', '4738562','1969-08-15',63456723),
 (14,'Roberto Carlos Nina Aruquipa',   'Masculino','5093847','1980-03-03',64567834),
 (15,'Norma Beatriz Chambi Mamani',    'Femenino', '6581230','1992-06-27',65678945),
 (16,'Victor Hugo Aruquipa Quispe',    'Masculino','4167925','1957-11-20',66789056),
 (17,'Elizabeth Rocio Villca Choque',  'Femenino', '5920384','1983-09-12',67890167),
 (18,'Fernando Jose Cruz Condori',     'Masculino','6349571','1976-01-25',68901278),
 (19,'Martha Cecilia Limachi Apaza',   'Femenino', '4805216','1970-04-08',69012389),
 (20,'Daniel Eduardo Quispe Rojas',    'Masculino','5472903','1987-12-30',70123490),
 (21,'Patricia Alejandra Yujra Mamani','Femenino', '6014758','1994-02-14',71234512),
 (22,'Julio Cesar Colque Vargas',      'Masculino','4629381','1963-07-07',72345623),
 (23,'Teresa Isabel Mamani Limachi',   'Femenino', '5786042','1979-10-19',73456734),
 (24,'Oscar David Tarqui Flores',      'Masculino','6297135','1984-05-23',74567845),
 (25,'Sonia Lourdes Apaza Colque',     'Femenino', '4351807','1966-08-31',75678956),
 (26,'Marcelo Ivan Huanca Tarqui',     'Masculino','5908264','1991-03-16',76789067),
 (27,'Ruth Noemi Condori Yujra',       'Femenino', '6183459','1974-11-27',77890178),
 (28,'Gonzalo Rene Poma Quispe',       'Masculino','4742916','1958-06-04',78901289),
 (29,'Virginia Amparo Choque Ticona',  'Femenino', '5561378','1986-09-21',79012390),
 (30,'Hugo Alberto Flores Callisaya',  'Masculino','6839025','1972-12-13',60123401),
 (31,'Nancy Roxana Ticona Chambi',     'Femenino', '4487693','1989-01-29',61234512),
 (32,'Edwin Rolando Cruz Nina',        'Masculino','5215947','1967-04-17',62345623),
 (33,'Delia Marlene Nina Villca',      'Femenino', '6702318','1981-07-02',63456734),
 (34,'Freddy Marcelo Villca Aruquipa', 'Masculino','4093572','1977-10-10',64567845),
 (35,'Angelica Maria Chambi Huanca',   'Femenino', '5637184','1993-05-05',65678956),
 (36,'Wilson Eduardo Rojas Limachi',   'Masculino','6458720','1960-02-22',66789067),
 (37,'Yolanda Susana Aruquipa Poma',   'Femenino', '4961035','1985-08-08',67890178),
 (38,'Ramiro Ernesto Quispe Tarqui',   'Masculino','5384691','1970-11-15',68901289),
 (39,'Beatriz Elena Callisaya Colque', 'Femenino', '6120847','1988-03-26',69012390),
 (40,'Alfredo Juan Mamani Yujra',      'Masculino','4576219','1964-06-19',70123401),
 (41,'Claudia Veronica Colque Cruz',   'Femenino', '5843960','1995-09-03',71234523),
 (42,'Sergio Ramiro Yujra Flores',     'Masculino','6295381','1979-12-24',72345634),
 (43,'Ines Margarita Tarqui Choque',   'Femenino', '4318726','1968-05-11',73456745),
 (44,'Mario Alberto Limachi Condori',  'Masculino','5709153','1983-02-06',74567856),
 (45,'Erika Fabiola Apaza Mamani',     'Femenino', '6067492','1990-10-28',75678967),
 (46,'Rene Osvaldo Huanca Quispe',     'Masculino','4824609','1961-01-13',76789078),
 (47,'Lourdes Pilar Poma Ticona',      'Femenino', '5152837','1987-07-30',77890189),
 (48,'Javier Alejandro Condori Rojas', 'Masculino','6613074','1975-04-01',78901290);

IF EXISTS (SELECT 1 FROM #per p JOIN persona x ON x.ci = p.ci)
BEGIN ROLLBACK; RAISERROR('CI repetido contra persona existente.', 16, 1); RETURN; END

INSERT INTO persona (genero, nombre_completo, ci, fecha_nacimiento, fecha_registro, estado, telefono)
SELECT genero, nombre, ci, fnac, @FECHA, 1, tel FROM #per ORDER BY orden;
PRINT 'OK  48 personas insertadas.';

-- ---------------------------------------------------------------------------
-- 2) Caja de enero (abierta mientras se registran las inscripciones)
-- ---------------------------------------------------------------------------
INSERT INTO caja (fecha, hora_apertura, hora_cierre, monto_apertura, monto_cobrado, usuario_admin_id_usuario_admin, estado)
VALUES (@FECHA, DATEADD(HOUR, 8, CAST(@FECHA AS DATETIME)), NULL, 0, 0, @CAJERA_ID, 1);
DECLARE @CAJA_ENE INT = SCOPE_IDENTITY();

-- ---------------------------------------------------------------------------
-- 3) Completar 4 socios por persona (con medidor propio) via los SPs reales
-- ---------------------------------------------------------------------------
DECLARE @idPersona INT, @nombre VARCHAR(250), @orden INT, @n INT;
DECLARE @nombreSocio VARCHAR(255), @correo VARCHAR(150), @rol INT, @ruta INT, @codigo INT;
DECLARE @serie VARCHAR(150), @numero INT, @idMedidor INT, @idSocio INT, @idPago INT;
DECLARE @res INT, @msg NVARCHAR(500);
DECLARE @tipoInst VARCHAR(50), @dimInst VARCHAR(50), @actividad VARCHAR(100), @categoria VARCHAR(50);
DECLARE @ubicacion INT, @numCasa INT, @ocupantes INT;

-- Correo: "nombre.apellido[N]@dominio" sin acentos ni espacios
DECLARE @p1 VARCHAR(100), @p2 VARCHAR(100);

DECLARE @numeroBase INT = (SELECT ISNULL(MAX(numero), 1000) FROM medidor);   -- 1012 -> nuevos desde 1013
DECLARE @codigoBase INT = 100;                                                 -- codigos fijos 101, 102, ...
DECLARE @creados INT = 0;

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT id_persona, nombre_completo, ROW_NUMBER() OVER (ORDER BY id_persona)
    FROM persona ORDER BY id_persona;
OPEN cur;
FETCH NEXT FROM cur INTO @idPersona, @nombre, @orden;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Datos del terreno: todos los medidores de una persona estan en el mismo lote
    SET @ruta      = ((@orden - 1) % 5) + 1;
    SET @ubicacion = 100 + @orden;
    SET @numCasa   = 1 + ((@orden * 7) % 40);
    SET @p1 = LOWER(TRANSLATE(PARSENAME(REPLACE(@nombre, ' ', '.'), 4), 'áéíóúñ', 'aeioun'));
    SET @p2 = LOWER(TRANSLATE(PARSENAME(REPLACE(@nombre, ' ', '.'), 2), 'áéíóúñ', 'aeioun'));   -- primer apellido
    IF @p1 IS NULL SET @p1 = LOWER(TRANSLATE(PARSENAME(REPLACE(@nombre, ' ', '.'), 3), 'áéíóúñ', 'aeioun'));

    SET @n = 1;
    WHILE @n <= 4
    BEGIN
        SET @nombreSocio = CASE WHEN @n = 1 THEN @nombre ELSE @nombre + ' ' + CAST(@n AS VARCHAR) END;

        IF NOT EXISTS (SELECT 1 FROM socio WHERE nombre_socio = @nombreSocio)
        BEGIN
            SET @rol       = CASE WHEN @n <= 2 THEN @ROL_SOCIO ELSE @ROL_USUARIO END;
            SET @correo    = @p1 + '.' + @p2 + CASE WHEN @n = 1 THEN '' ELSE CAST(@n AS VARCHAR) END
                           + CASE @n WHEN 1 THEN '@gmail.com' WHEN 2 THEN '@gmail.com' WHEN 3 THEN '@hotmail.com' ELSE '@outlook.com' END;
            SET @ocupantes = 2 + ((@orden + @n) % 5);
            SET @tipoInst  = CASE (@orden + @n) % 4 WHEN 0 THEN 'PVC' WHEN 1 THEN 'CPVC' WHEN 2 THEN 'Polipropileno' ELSE 'Tubería negra' END;
            SET @dimInst   = CASE (@orden + @n) % 3 WHEN 0 THEN '1/2 pulgada' WHEN 1 THEN '3/4 pulgada' ELSE '1 pulgada' END;
            -- Mayoria domestica; algunos comercios, talleres y sedes sociales
            SET @categoria = CASE
                                WHEN @orden % 10 = 0 AND @n = 2 THEN 'Comercial'
                                WHEN @orden % 15 = 0 AND @n = 3 THEN 'Industrial'
                                WHEN @orden % 12 = 0 AND @n = 4 THEN 'Social'
                                ELSE 'Doméstico' END;
            SET @actividad = CASE @categoria WHEN 'Comercial' THEN 'Tienda de barrio' WHEN 'Industrial' THEN 'Taller mecánico'
                                             WHEN 'Social' THEN 'Sede vecinal' ELSE 'Doméstica' END;

            -- Codigo fijo unico
            SET @codigoBase = @codigoBase + 1;
            WHILE EXISTS (SELECT 1 FROM socio WHERE codigo_fijo = @codigoBase) SET @codigoBase = @codigoBase + 1;
            SET @codigo = @codigoBase;

            -- Medidor propio
            SET @numeroBase = @numeroBase + 1;
            SET @numero = @numeroBase;
            SET @serie  = 'MD-' + RIGHT('0000' + CAST(@numero AS VARCHAR), 5);
            EXEC dbo.sp_crear_medidor @serie, @numero, @FECHA, @idMedidor OUTPUT, @msg OUTPUT;
            IF ISNULL(@idMedidor, 0) <= 0
            BEGIN CLOSE cur; DEALLOCATE cur; ROLLBACK; RAISERROR('Medidor %s: %s', 16, 1, @serie, @msg); RETURN; END

            -- Socio + inscripcion pagada al contado (1 cuota) en la caja de enero
            EXEC dbo.sp_registrar_socio_con_inscripcion
                @nombre_socio           = @nombreSocio,
                @persona_id_persona     = @idPersona,
                @correo                 = @correo,
                @rol_socio_id_rol_socio = @rol,
                @ubicacion              = @ubicacion,
                @medidor_id_medidor     = @idMedidor,
                @num_casa               = @numCasa,
                @num_ocupantes          = @ocupantes,
                @tipo_instalacion       = @tipoInst,
                @dim_instalacion        = @dimInst,
                @actividad              = @actividad,
                @categoria              = @categoria,
                @fecha_registro         = @FECHA,
                @ruta_id_ruta           = @ruta,
                @codigo_fijo            = @codigo,
                @monto_inicial          = 1700,
                @num_cuotas             = 1,
                @id_metodo_pago         = @EFECTIVO,
                @id_caja                = @CAJA_ENE,
                @cajero                 = @CAJERA_NOM,
                @Resultado              = @idSocio OUTPUT,
                @Mensaje                = @msg OUTPUT,
                @IdPago                 = @idPago OUTPUT;

            IF ISNULL(@idSocio, 0) <= 0
            BEGIN CLOSE cur; DEALLOCATE cur; IF @@TRANCOUNT > 0 ROLLBACK; RAISERROR('Socio "%s": %s', 16, 1, @nombreSocio, @msg); RETURN; END

            SET @creados = @creados + 1;
        END
        SET @n = @n + 1;
    END
    FETCH NEXT FROM cur INTO @idPersona, @nombre, @orden;
END
CLOSE cur; DEALLOCATE cur;
PRINT 'OK  ' + CAST(@creados AS VARCHAR) + ' socios registrados con inscripcion pagada.';

-- ---------------------------------------------------------------------------
-- 4) Los 3 socios previos: misma fecha, periodo, caja y cajera que el resto
-- ---------------------------------------------------------------------------
DECLARE @PER_ENE INT = (SELECT id_periodo FROM periodo WHERE periodo = '01/2026');

UPDATE socio   SET fecha_registro = @FECHA WHERE id_socio IN (2, 3, 4);
UPDATE socio   SET rol_socio_id_rol_socio = @ROL_SOCIO WHERE nombre_socio = 'Santiago Arequipa Espinoza 2';   -- "2" es SOCIO
UPDATE medidor SET fecha_instalacion = @FECHA WHERE id_medidor IN (SELECT medidor_id_medidor FROM socio WHERE id_socio IN (2, 3, 4));
UPDATE p SET fecha_pago = @FECHA, caja_id_caja = @CAJA_ENE, cajero = @CAJERA_NOM
FROM pago p JOIN credito_inscripcion ci ON ci.pago_id_pago = p.id_pago
WHERE ci.socio_id_socio IN (2, 3, 4);
UPDATE credito_inscripcion SET periodo_id_periodo = @PER_ENE WHERE socio_id_socio IN (2, 3, 4);
PRINT 'OK  3 socios previos alineados a enero.';

-- ---------------------------------------------------------------------------
-- 5) Cierre de la caja de enero y cajas de febrero a agosto
-- ---------------------------------------------------------------------------
UPDATE caja
SET monto_cobrado = (SELECT SUM(monto_pagado) FROM pago WHERE caja_id_caja = @CAJA_ENE AND estado_pago = 'APROBADO'),
    hora_cierre   = DATEADD(HOUR, 18, CAST(@FECHA AS DATETIME)),
    estado        = 0
WHERE id_caja = @CAJA_ENE;

INSERT INTO caja (fecha, hora_apertura, hora_cierre, monto_apertura, monto_cobrado, usuario_admin_id_usuario_admin, estado)
SELECT d, DATEADD(HOUR, 8, CAST(d AS DATETIME)), DATEADD(HOUR, 18, CAST(d AS DATETIME)), 0, 0, @CAJERA_ID, 0
FROM (VALUES (CAST('2026-02-02' AS DATE)), ('2026-03-02'), ('2026-04-06'), ('2026-05-04'),
             ('2026-06-01'), ('2026-07-06'), ('2026-08-03')) v(d);
PRINT 'OK  caja de enero cerrada y cajas de febrero a agosto creadas.';

COMMIT;

-- ---------------------------------------------------------------------------
-- Resumen
-- ---------------------------------------------------------------------------
SELECT (SELECT COUNT(*) FROM persona) AS personas,
       (SELECT COUNT(*) FROM socio)   AS socios,
       (SELECT COUNT(*) FROM medidor) AS medidores,
       (SELECT COUNT(*) FROM socio WHERE medidor_id_medidor IS NULL) AS socios_sin_medidor,
       (SELECT COUNT(*) FROM credito_inscripcion WHERE estado = 'CANCELADO') AS cuotas_canceladas,
       (SELECT COUNT(*) FROM credito_inscripcion WHERE estado <> 'CANCELADO') AS cuotas_pendientes,
       (SELECT COUNT(*) FROM pago WHERE estado_pago = 'APROBADO') AS pagos,
       (SELECT SUM(monto_pagado) FROM pago) AS total_pagado;
SELECT persona_id_persona, COUNT(*) socios, MIN(id_socio) primer, MAX(id_socio) ultimo
FROM socio GROUP BY persona_id_persona HAVING COUNT(*) <> 4;
SELECT id_caja, fecha, monto_cobrado, estado, usuario_admin_id_usuario_admin FROM caja ORDER BY fecha;
GO
