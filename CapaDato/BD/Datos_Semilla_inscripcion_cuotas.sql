USE [COSPABIRL1]
GO
-- =============================================================================
-- Datos de prueba: 10 personas nuevas con UN socio cada una e inscripcion
-- financiada en 4 cuotas (requiere los dos scripts de semilla anteriores).
--
-- Regla del sistema (sp_registrar_socio_con_inscripcion): cuota 1 = pago
-- inicial (CANCELADO, en el periodo de registro); cuotas 2..4 = saldo repartido
-- en los 3 periodos siguientes, PENDIENTE. Cada cuota pendiente se cobra
-- DENTRO del aviso de su periodo (sp_generar_avisos_periodo la suma al total y
-- sp_registrar_pago_aviso la cancela).
--
--   Grupo JUNIO (5): inscritos el 2026-06-01 (caja de Delia de ese dia),
--     inicial Bs. 500 + cuotas de Bs. 400 en 07, 08 y 09/2026.
--     Lecturas jun/jul/ago; avisos de jun (sin cuota), jul (cuota 2) y ago
--     (cuota 3), los tres PAGADOS. Queda pendiente la cuota 4 (09/2026).
--   Grupo AGOSTO (5): inscritos el 2026-08-03, inicial Bs. 500 + cuotas de
--     Bs. 400 en 09, 10 y 11/2026. Lectura y aviso de agosto (sin cuota),
--     PAGADO el 2026-09-01. Quedan 3 cuotas PENDIENTE.
--
-- Mismo calendario que la semilla de facturacion: ruta r se lee y factura el
-- dia 18 + r, vencimiento +2 meses, aviso del mes M cobrado en la caja de
-- Delia del mes M+1. Los SPs usan GETDATE(); se corrigen las fechas despues.
-- Si algo falla: ROLLBACK completo.
-- =============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @HOY        DATE = CAST(GETDATE() AS DATE);
DECLARE @PLOMERO    INT  = (SELECT id_usuario_admin FROM usuario_admin WHERE usuario = 'plomero');
DECLARE @CAJERA_ID  INT  = (SELECT id_usuario_admin FROM usuario_admin WHERE usuario = 'delia');
DECLARE @CAJERA_NOM VARCHAR(150) = (SELECT nombre + ' ' + apellido FROM usuario_admin WHERE usuario = 'delia');
DECLARE @EFECTIVO   INT  = (SELECT id_metodo_pago FROM metodo_pago WHERE metodo = 'Efectivo');
DECLARE @ROL_SOCIO  INT  = (SELECT id_rol_socio FROM rol_socio WHERE rol_socio = 'SOCIO');
DECLARE @IMPRESO    INT  = (SELECT id_estado FROM estado WHERE estado = 'IMPRESO');
DECLARE @NOTIF_BEFORE INT = ISNULL((SELECT MAX(id_notificacion) FROM notificacion), 0);

IF @PLOMERO IS NULL OR @CAJERA_ID IS NULL OR @EFECTIVO IS NULL OR @ROL_SOCIO IS NULL OR @IMPRESO IS NULL
BEGIN RAISERROR('Faltan datos base.', 16, 1); RETURN; END
IF (SELECT COUNT(*) FROM persona) <> 50 OR (SELECT COUNT(*) FROM socio) <> 200
BEGIN RAISERROR('Se esperan 50 personas / 200 socios. Script ya aplicado?', 16, 1); RETURN; END
IF EXISTS (SELECT 1 FROM caja WHERE estado = 1 AND usuario_admin_id_usuario_admin = @CAJERA_ID)
BEGIN RAISERROR('La cajera ya tiene una caja abierta.', 16, 1); RETURN; END

-- Cajas de Delia por mes (aviso del mes M se cobra en la del mes M+1)
CREATE TABLE #cajaMes (mes INT PRIMARY KEY, id_caja INT NOT NULL, fecha DATE NOT NULL);
INSERT INTO #cajaMes
SELECT MONTH(fecha), id_caja, fecha FROM caja
WHERE usuario_admin_id_usuario_admin = @CAJERA_ID AND fecha BETWEEN '2026-02-01' AND '2026-09-30';
IF (SELECT COUNT(*) FROM #cajaMes WHERE mes IN (6, 7, 8, 9)) <> 4
BEGIN RAISERROR('Faltan cajas de Delia de junio a septiembre.', 16, 1); RETURN; END

BEGIN TRAN;

-- ---------------------------------------------------------------------------
-- 1) Personas
-- ---------------------------------------------------------------------------
CREATE TABLE #nuevos (orden INT PRIMARY KEY, nombre VARCHAR(250), genero VARCHAR(20), ci VARCHAR(50), fnac DATE, tel INT,
                      mes_reg INT, ruta INT, correo VARCHAR(150), id_persona INT NULL, id_socio INT NULL);
INSERT INTO #nuevos (orden, nombre, genero, ci, fnac, tel, mes_reg, ruta, correo) VALUES
 ( 1,'Valeria Fernanda Mamani Quispe', 'Femenino', '7104582','1991-05-14',71450012, 6, 1,'valeria.mamani@gmail.com'),
 ( 2,'Cristian Rodrigo Apaza Nina',    'Masculino','7238915','1986-09-02',72561123, 6, 2,'cristian.apaza@gmail.com'),
 ( 3,'Daniela Alejandra Choque Poma',  'Femenino', '7351264','1994-12-21',73672234, 6, 3,'daniela.choque@hotmail.com'),
 ( 4,'Marco Antonio Flores Huanca',    'Masculino','7463829','1979-03-08',74783345, 6, 4,'marco.flores@gmail.com'),
 ( 5,'Jhoselin Karen Condori Villca',  'Femenino', '7590341','1998-07-27',75894456, 6, 5,'jhoselin.condori@outlook.com'),
 ( 6,'Alvaro Enrique Ticona Rojas',    'Masculino','7612708','1983-01-16',76905567, 8, 1,'alvaro.ticona@gmail.com'),
 ( 7,'Paola Andrea Quispe Callisaya',  'Femenino', '7725493','1989-10-05',77016678, 8, 2,'paola.quispe@gmail.com'),
 ( 8,'Nelson Fabricio Cruz Limachi',   'Masculino','7846137','1976-06-11',78127789, 8, 3,'nelson.cruz@hotmail.com'),
 ( 9,'Adriana Lucia Poma Tarqui',      'Femenino', '7958620','1996-02-29',79238890, 8, 4,'adriana.poma@gmail.com'),
 (10,'Israel David Huanca Colque',     'Masculino','7071355','1981-08-19',60349901, 8, 5,'israel.huanca@outlook.com');

IF EXISTS (SELECT 1 FROM #nuevos n JOIN persona x ON x.ci = n.ci)
BEGIN ROLLBACK; RAISERROR('CI repetido.', 16, 1); RETURN; END

DECLARE @orden INT, @nombre VARCHAR(250), @idPersona INT, @idSocio INT, @mesReg INT, @ruta INT, @correo VARCHAR(150);
DECLARE @fechaReg DATE, @idCajaReg INT, @codigo INT, @numero INT, @serie VARCHAR(150), @idMedidor INT, @idPago INT;
DECLARE @res INT, @msg VARCHAR(500), @msgN NVARCHAR(500), @ubic INT, @casa INT;
DECLARE @codigoBase INT = (SELECT MAX(codigo_fijo) FROM socio WHERE codigo_fijo < 400);   -- 297 -> 298..
DECLARE @numeroBase INT = (SELECT MAX(numero) FROM medidor);

-- ---------------------------------------------------------------------------
-- 2) Persona + medidor + socio con inscripcion en 4 cuotas (inicial 500)
-- ---------------------------------------------------------------------------
DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT orden FROM #nuevos ORDER BY orden;
OPEN cur; FETCH NEXT FROM cur INTO @orden;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @nombre = nombre, @mesReg = mes_reg, @ruta = ruta, @correo = correo FROM #nuevos WHERE orden = @orden;
    SELECT @idCajaReg = id_caja, @fechaReg = fecha FROM #cajaMes WHERE mes = @mesReg;
    SET @ubic = 150 + @orden; SET @casa = 40 + @orden;

    INSERT INTO persona (genero, nombre_completo, ci, fecha_nacimiento, fecha_registro, estado, telefono)
    SELECT genero, nombre, ci, fnac, @fechaReg, 1, tel FROM #nuevos WHERE orden = @orden;
    SET @idPersona = SCOPE_IDENTITY();

    SET @numeroBase = @numeroBase + 1; SET @numero = @numeroBase;
    SET @serie = 'MD-' + RIGHT('0000' + CAST(@numero AS VARCHAR), 5);
    EXEC dbo.sp_crear_medidor @serie, @numero, @fechaReg, @idMedidor OUTPUT, @msg OUTPUT;
    IF ISNULL(@idMedidor, 0) <= 0 BEGIN CLOSE cur; DEALLOCATE cur; ROLLBACK; RAISERROR('Medidor %s: %s', 16, 1, @serie, @msg); RETURN; END

    SET @codigoBase = @codigoBase + 1;
    WHILE EXISTS (SELECT 1 FROM socio WHERE codigo_fijo = @codigoBase) SET @codigoBase = @codigoBase + 1;
    SET @codigo = @codigoBase;

    UPDATE caja SET estado = 1 WHERE id_caja = @idCajaReg;   -- reabrir solo para registrar
    EXEC dbo.sp_registrar_socio_con_inscripcion
        @nombre_socio = @nombre, @persona_id_persona = @idPersona, @correo = @correo,
        @rol_socio_id_rol_socio = @ROL_SOCIO, @ubicacion = @ubic, @medidor_id_medidor = @idMedidor,
        @num_casa = @casa, @num_ocupantes = 3, @tipo_instalacion = 'PVC', @dim_instalacion = '1/2 pulgada',
        @actividad = 'Doméstica', @categoria = 'Doméstico', @fecha_registro = @fechaReg, @ruta_id_ruta = @ruta,
        @codigo_fijo = @codigo,
        @monto_inicial = 500, @num_cuotas = 4, @id_metodo_pago = @EFECTIVO, @id_caja = @idCajaReg, @cajero = @CAJERA_NOM,
        @Resultado = @idSocio OUTPUT, @Mensaje = @msgN OUTPUT, @IdPago = @idPago OUTPUT;
    IF ISNULL(@idSocio, 0) <= 0 BEGIN CLOSE cur; DEALLOCATE cur; IF @@TRANCOUNT > 0 ROLLBACK; RAISERROR('Socio "%s": %s', 16, 1, @nombre, @msgN); RETURN; END
    UPDATE caja SET estado = 0,
        monto_cobrado = (SELECT SUM(monto_pagado) FROM pago WHERE caja_id_caja = @idCajaReg AND estado_pago = 'APROBADO')
    WHERE id_caja = @idCajaReg;

    UPDATE #nuevos SET id_persona = @idPersona, id_socio = @idSocio WHERE orden = @orden;
    FETCH NEXT FROM cur INTO @orden;
END
CLOSE cur; DEALLOCATE cur;
PRINT 'OK  10 personas y 10 socios con inscripcion en 4 cuotas.';

-- ---------------------------------------------------------------------------
-- 3) Lecturas, avisos y cobros desde el mes de registro hasta agosto
-- ---------------------------------------------------------------------------
DECLARE @mes INT = 6, @idPeriodo INT, @fecha DATE, @ant INT, @act INT, @gen INT, @esperados INT;
DECLARE @idCaja INT, @fechaCaja DATE, @idAviso INT, @lecturas INT = 0, @avisos INT = 0, @pagos INT = 0;

WHILE @mes <= 8
BEGIN
    SELECT @idPeriodo = id_periodo FROM periodo WHERE periodo = RIGHT('0' + CAST(@mes AS VARCHAR), 2) + '/2026';

    SET @ruta = 1;
    WHILE @ruta <= 5
    BEGIN
        SET @fecha = DATEFROMPARTS(2026, @mes, 18 + @ruta);
        SET @esperados = 0;

        DECLARE curL CURSOR LOCAL FAST_FORWARD FOR
            SELECT n.id_socio, s.medidor_id_medidor FROM #nuevos n JOIN socio s ON s.id_socio = n.id_socio
            WHERE n.ruta = @ruta AND n.mes_reg <= @mes ORDER BY n.orden;
        OPEN curL; FETCH NEXT FROM curL INTO @idSocio, @idMedidor;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @ant = ISNULL((SELECT TOP 1 lectura_actual FROM lectura WHERE medidor_id_medidor = @idMedidor ORDER BY fecha_lectura DESC), 0);
            SET @act = @ant + 4 + ((@idSocio * 7 + @mes * 13) % 22);
            EXEC dbo.sp_registrar_lectura @fecha, @ant, @act, NULL, @PLOMERO, @idMedidor, @idPeriodo, @ruta, @res OUTPUT, @msg OUTPUT;
            IF ISNULL(@res, 0) <= 0 BEGIN CLOSE curL; DEALLOCATE curL; ROLLBACK; RAISERROR('Lectura socio %d mes %d: %s', 16, 1, @idSocio, @mes, @msg); RETURN; END
            SET @lecturas = @lecturas + 1; SET @esperados = @esperados + 1;
            FETCH NEXT FROM curL INTO @idSocio, @idMedidor;
        END
        CLOSE curL; DEALLOCATE curL;

        IF @esperados > 0
        BEGIN
            -- Solo genera para quienes aun no tienen aviso del periodo: los nuevos
            EXEC dbo.sp_generar_avisos_periodo @idPeriodo, @ruta, @gen OUTPUT, @msg OUTPUT;
            IF ISNULL(@gen, 0) <> @esperados BEGIN IF @@TRANCOUNT > 0 ROLLBACK; RAISERROR('Avisos mes %d ruta %d: %d de %d. %s', 16, 1, @mes, @ruta, @gen, @esperados, @msg); RETURN; END
            SET @avisos = @avisos + @gen;

            UPDATE a SET fecha_emision = @fecha, fecha_vencimiento = DATEADD(MONTH, 2, @fecha), estado_id_estado = @IMPRESO
            FROM aviso a JOIN #nuevos n ON n.id_socio = a.socio_id_socio
            WHERE a.periodo_id_periodo = @idPeriodo AND n.ruta = @ruta AND a.fecha_emision = @HOY;
            UPDATE ce SET fecha_registro = @fecha
            FROM cargo_extra ce JOIN #nuevos n ON n.id_socio = ce.socio_id_socio
            WHERE ce.periodo_id_periodo = @idPeriodo AND n.ruta = @ruta AND ce.fecha_registro = @HOY;
        END
        SET @ruta = @ruta + 1;
    END

    -- Cobro en la caja del mes siguiente (cancela la cuota del periodo si la hay)
    SELECT @idCaja = id_caja, @fechaCaja = fecha FROM #cajaMes WHERE mes = @mes + 1;
    UPDATE caja SET estado = 1 WHERE id_caja = @idCaja;
    DECLARE curP CURSOR LOCAL FAST_FORWARD FOR
        SELECT a.id_aviso FROM aviso a JOIN #nuevos n ON n.id_socio = a.socio_id_socio
        WHERE a.periodo_id_periodo = @idPeriodo ORDER BY a.id_aviso;
    OPEN curP; FETCH NEXT FROM curP INTO @idAviso;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_registrar_pago_aviso @idAviso, @idCaja, @EFECTIVO, NULL, @CAJERA_NOM, @idPago OUTPUT, @msgN OUTPUT;
        IF ISNULL(@idPago, 0) <= 0 BEGIN CLOSE curP; DEALLOCATE curP; IF @@TRANCOUNT > 0 ROLLBACK; RAISERROR('Pago aviso %d: %s', 16, 1, @idAviso, @msgN); RETURN; END
        SET @pagos = @pagos + 1;
        FETCH NEXT FROM curP INTO @idAviso;
    END
    CLOSE curP; DEALLOCATE curP;
    UPDATE pago SET fecha_pago = @fechaCaja WHERE caja_id_caja = @idCaja AND CAST(fecha_pago AS DATE) = @HOY AND aviso_id_aviso IS NOT NULL;
    UPDATE caja SET estado = 0,
        monto_cobrado = (SELECT SUM(monto_pagado) FROM pago WHERE caja_id_caja = @idCaja AND estado_pago = 'APROBADO')
    WHERE id_caja = @idCaja;

    SET @mes = @mes + 1;
END

-- Notificaciones de pago al calendario simulado
UPDATE n SET fecha_publicacion = CAST(p.fecha_pago AS DATE)
FROM notificacion n
JOIN notificacion_socio ns ON ns.notificacion_id_notificacion = n.id_notificacion
JOIN aviso a ON a.socio_id_socio = ns.socio_id_socio
JOIN pago  p ON p.aviso_id_aviso = a.id_aviso
WHERE n.tipo = 'Pago' AND n.id_notificacion > @NOTIF_BEFORE
  AND n.mensaje LIKE '%[[]Aviso #' + CAST(a.id_aviso AS VARCHAR) + ']%';
UPDATE ns SET leido = CASE WHEN n.fecha_publicacion < '2026-09-01' THEN 1 ELSE 0 END,
              fecha_lectura = CASE WHEN n.fecha_publicacion < '2026-09-01' THEN DATEADD(DAY, 1, n.fecha_publicacion) ELSE n.fecha_publicacion END
FROM notificacion_socio ns JOIN notificacion n ON n.id_notificacion = ns.notificacion_id_notificacion
WHERE n.tipo = 'Pago' AND n.id_notificacion > @NOTIF_BEFORE;

COMMIT;
PRINT 'OK  ' + CAST(@lecturas AS VARCHAR) + ' lecturas, ' + CAST(@avisos AS VARCHAR) + ' avisos, ' + CAST(@pagos AS VARCHAR) + ' pagos.';

-- Resumen: cuotas por socio nuevo
SELECT n.id_socio, s.nombre_socio, s.codigo_fijo, s.fecha_registro,
       ci.num_cuota, ci.monto_pago, ci.estado, p.periodo, ci.pago_id_pago
FROM #nuevos n JOIN socio s ON s.id_socio = n.id_socio
JOIN credito_inscripcion ci ON ci.socio_id_socio = s.id_socio
JOIN periodo p ON p.id_periodo = ci.periodo_id_periodo
ORDER BY n.orden, ci.num_cuota;
GO
