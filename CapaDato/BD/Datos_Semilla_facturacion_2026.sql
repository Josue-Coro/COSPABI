USE [COSPABIRL1]
GO
-- =============================================================================
-- Datos de prueba: facturacion enero-agosto 2026 para los 200 socios
-- (requiere Datos_Semilla_50_personas.sql aplicado antes).
--
-- Calendario mensual que simula:
--   * Lecturacion del 19 al 23: ruta 1 el 19, ruta 2 el 20, ... ruta 5 el 23
--     (plomero Freddy Gonzales, sp_registrar_lectura). Enero parte de 0 m3.
--   * Generacion de avisos el mismo dia de la lectura de cada ruta
--     (sp_generar_avisos_periodo por ruta); vencimiento dos meses despues
--     (el aviso de 08/2026 vence en 10/2026). El generador
--     estampa TASA AFCOOP (tipo_cargo.automatico = 1) en TODOS los avisos.
--     Los avisos quedan IMPRESO (ya fueron entregados al socio).
--   * Cargos manuales registrados antes de la emision (sp_registrar_cargo_extra):
--     febrero  Materiales               (Bs.  55) a 5 socios
--     marzo    Multa de falta de Reunion (Bs.  50) a 22 socios
--     junio    Multa de Corte            (Bs. 100) a los 3 morosos mas antiguos
--   * Cobro en efectivo del aviso del mes M en la caja de la cajera (Delia) del
--     mes M+1 (sp_registrar_pago_aviso). Para los avisos de agosto se crea la
--     caja del 2026-09-01; la caja abierta de hoy no se toca.
--   * Septiembre no se lectura: la lecturacion es del 19 al 23.
--
-- Grupos (200 socios):
--   150 al dia               -> 8 avisos PAGADO
--    40 deben agosto         -> id_socio multiplo de 5
--    10 morosos (> 2 meses)  -> id_socio % 20 = 7:
--        7, 27, 47, 67  deben jun-ago (3 meses)
--        87, 107, 127   deben may-ago (4 meses)
--        147, 167, 187  deben mar-ago (6 meses)
--
-- Correccion de datos base: tipo_cargo 'Materiales' estaba con automatico = 1
-- (se habria cobrado Bs. 55 en los 1600 avisos); pasa a 0. Solo AFCOOP es
-- automatica.
--
-- Los SPs usan GETDATE(); el script corrige despues las fechas (emision,
-- vencimiento, cargos, pagos, notificaciones) al calendario simulado.
-- Si algo falla: ROLLBACK completo.
-- =============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @HOY        DATE = CAST(GETDATE() AS DATE);
DECLARE @PLOMERO    INT  = (SELECT id_usuario_admin FROM usuario_admin WHERE usuario = 'plomero');
DECLARE @CAJERA_ID  INT  = (SELECT id_usuario_admin FROM usuario_admin WHERE usuario = 'delia');
DECLARE @CAJERA_NOM VARCHAR(150) = (SELECT nombre + ' ' + apellido FROM usuario_admin WHERE usuario = 'delia');
DECLARE @EFECTIVO   INT  = (SELECT id_metodo_pago FROM metodo_pago WHERE metodo = 'Efectivo');
DECLARE @IMPRESO    INT  = (SELECT id_estado FROM estado WHERE estado = 'IMPRESO');
DECLARE @TC_AFCOOP  INT  = (SELECT id_tipo FROM tipo_cargo WHERE nombre = 'TASA AFCOOP');
DECLARE @TC_MATER   INT  = (SELECT id_tipo FROM tipo_cargo WHERE nombre = 'Materiales');
DECLARE @TC_REUNION INT  = (SELECT id_tipo FROM tipo_cargo WHERE nombre LIKE 'Multa de falta de Reuni%');
DECLARE @TC_CORTE   INT  = (SELECT id_tipo FROM tipo_cargo WHERE nombre = 'Multa de Corte');

IF @PLOMERO IS NULL OR @CAJERA_ID IS NULL OR @EFECTIVO IS NULL OR @IMPRESO IS NULL
   OR @TC_AFCOOP IS NULL OR @TC_MATER IS NULL OR @TC_REUNION IS NULL OR @TC_CORTE IS NULL
BEGIN RAISERROR('Faltan datos base (plomero, delia, Efectivo, estado IMPRESO o tipos de cargo).', 16, 1); RETURN; END

IF (SELECT COUNT(*) FROM socio) <> 200 OR EXISTS (SELECT 1 FROM socio WHERE medidor_id_medidor IS NULL)
BEGIN RAISERROR('Se esperan 200 socios, todos con medidor (Datos_Semilla_50_personas.sql).', 16, 1); RETURN; END

IF EXISTS (SELECT 1 FROM lectura) OR EXISTS (SELECT 1 FROM aviso) OR EXISTS (SELECT 1 FROM cargo_extra)
BEGIN RAISERROR('lectura / aviso / cargo_extra deben estar vacias. Script ya aplicado?', 16, 1); RETURN; END

IF EXISTS (SELECT 1 FROM caja WHERE estado = 1 AND usuario_admin_id_usuario_admin = @CAJERA_ID)
BEGIN RAISERROR('La cajera ya tiene una caja abierta.', 16, 1); RETURN; END

BEGIN TRAN;

-- Solo TASA AFCOOP es automatica
UPDATE tipo_cargo SET automatico = 0 WHERE id_tipo = @TC_MATER AND automatico = 1;
IF @@ROWCOUNT = 1 PRINT 'OK  tipo_cargo Materiales: automatico 1 -> 0.';

-- ---------------------------------------------------------------------------
-- Grupos: pend_desde = primer mes (1..8) cuyo aviso queda sin pagar; 9 = al dia
-- ---------------------------------------------------------------------------
CREATE TABLE #grp (id_socio INT PRIMARY KEY, pend_desde INT NOT NULL);
INSERT INTO #grp
SELECT id_socio,
       CASE WHEN id_socio % 20 = 7 THEN CASE WHEN id_socio <= 67 THEN 6 WHEN id_socio <= 127 THEN 5 ELSE 3 END
            WHEN id_socio % 5  = 0 THEN 8
            ELSE 9 END
FROM socio;

-- Caja donde se cobra el aviso del mes M: la del mes M+1 (Delia). Agosto -> 01/09.
CREATE TABLE #cajaMes (mes INT PRIMARY KEY, id_caja INT NOT NULL, fecha DATE NOT NULL);
INSERT INTO caja (fecha, hora_apertura, hora_cierre, monto_apertura, monto_cobrado, usuario_admin_id_usuario_admin, estado)
VALUES ('2026-09-01', '2026-09-01 08:00', '2026-09-01 18:00', 0, 0, @CAJERA_ID, 0);
INSERT INTO #cajaMes
SELECT MONTH(fecha) - 1, id_caja, fecha
FROM caja
WHERE usuario_admin_id_usuario_admin = @CAJERA_ID AND fecha BETWEEN '2026-02-01' AND '2026-09-30';
IF (SELECT COUNT(*) FROM #cajaMes WHERE mes BETWEEN 1 AND 8) <> 8
BEGIN ROLLBACK; RAISERROR('Faltan cajas mensuales de la cajera (feb-sep).', 16, 1); RETURN; END

-- ---------------------------------------------------------------------------
-- Bucle mensual
-- ---------------------------------------------------------------------------
DECLARE @mes INT = 1, @idPeriodo INT, @ruta INT, @fecha DATE;
DECLARE @idSocio INT, @idMedidor INT, @serie VARCHAR(150), @ant INT, @act INT, @consumo INT;
DECLARE @res INT, @msg VARCHAR(500), @msgN NVARCHAR(500), @gen INT, @esperados INT;
DECLARE @idCaja INT, @fechaCaja DATE, @idAviso INT, @idPago INT;
DECLARE @lecturas INT = 0, @avisos INT = 0, @pagos INT = 0, @cargosManuales INT = 0, @cargoDesde INT;
DECLARE @tipoC INT, @montoC DECIMAL(30,2), @descC VARCHAR(150), @idCargo INT;
DECLARE @NOTIF_BEFORE INT = ISNULL((SELECT MAX(id_notificacion) FROM notificacion), 0);

WHILE @mes <= 8
BEGIN
    SELECT @idPeriodo = id_periodo FROM periodo WHERE periodo = RIGHT('0' + CAST(@mes AS VARCHAR), 2) + '/2026';
    IF @idPeriodo IS NULL BEGIN ROLLBACK; RAISERROR('Falta el periodo del mes %d.', 16, 1, @mes); RETURN; END

    -- 1) Cargos manuales del mes (antes de la emision, como exige sp_registrar_cargo_extra)
    SET @cargoDesde = ISNULL((SELECT MAX(id_cargo_extra) FROM cargo_extra), 0);
    DECLARE curC CURSOR LOCAL FAST_FORWARD FOR
        SELECT s.id_socio, x.tipo, x.monto, x.descripcion
        FROM socio s
        JOIN #grp g ON g.id_socio = s.id_socio
        CROSS APPLY (
            SELECT @TC_MATER   AS tipo, CAST(55  AS DECIMAL(30,2)) AS monto, 'Reposicion de llave de paso'      AS descripcion WHERE @mes = 2 AND s.id_socio % 37 = 0
            UNION ALL
            SELECT @TC_REUNION,         CAST(50  AS DECIMAL(30,2)),          'Inasistencia a asamblea general'  WHERE @mes = 3 AND s.id_socio % 9 = 0
            UNION ALL
            SELECT @TC_CORTE,           CAST(100 AS DECIMAL(30,2)),          'Corte por mora de 3 meses'        WHERE @mes = 6 AND g.pend_desde = 3
        ) x;
    OPEN curC;
    FETCH NEXT FROM curC INTO @idSocio, @tipoC, @montoC, @descC;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_registrar_cargo_extra @idPeriodo, @idSocio, @tipoC, @montoC, @descC, @idCargo OUTPUT, @msg OUTPUT;
        IF ISNULL(@idCargo, 0) <= 0
        BEGIN CLOSE curC; DEALLOCATE curC; IF @@TRANCOUNT > 0 ROLLBACK; RAISERROR('Cargo socio %d mes %d: %s', 16, 1, @idSocio, @mes, @msg); RETURN; END
        SET @cargosManuales = @cargosManuales + 1;
        FETCH NEXT FROM curC INTO @idSocio, @tipoC, @montoC, @descC;
    END
    CLOSE curC; DEALLOCATE curC;
    -- registrados a mitad de mes, antes de la lecturacion
    UPDATE cargo_extra SET fecha_registro = DATEFROMPARTS(2026, @mes, 12) WHERE id_cargo_extra > @cargoDesde;

    -- 2) Lecturas + avisos, ruta por ruta (ruta r se lee el dia 18 + r)
    SET @ruta = 1;
    WHILE @ruta <= 5
    BEGIN
        SET @fecha = DATEFROMPARTS(2026, @mes, 18 + @ruta);

        DECLARE curL CURSOR LOCAL FAST_FORWARD FOR
            SELECT s.id_socio, s.medidor_id_medidor, m.serie
            FROM socio s JOIN medidor m ON m.id_medidor = s.medidor_id_medidor
            WHERE s.ruta_id_ruta = @ruta ORDER BY s.codigo_fijo;
        OPEN curL;
        FETCH NEXT FROM curL INTO @idSocio, @idMedidor, @serie;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @ant = ISNULL((SELECT TOP 1 lectura_actual FROM lectura
                               WHERE medidor_id_medidor = @idMedidor ORDER BY fecha_lectura DESC), 0);
            SET @consumo = 4 + ((@idSocio * 7 + @mes * 13) % 22);   -- 4..25 m3, determinista
            SET @act = @ant + @consumo;

            EXEC dbo.sp_registrar_lectura @fecha, @ant, @act, NULL, @PLOMERO, @idMedidor, @idPeriodo, @ruta, @res OUTPUT, @msg OUTPUT;
            IF ISNULL(@res, 0) <= 0
            BEGIN CLOSE curL; DEALLOCATE curL; IF @@TRANCOUNT > 0 ROLLBACK; RAISERROR('Lectura %s mes %d: %s', 16, 1, @serie, @mes, @msg); RETURN; END
            SET @lecturas = @lecturas + 1;
            FETCH NEXT FROM curL INTO @idSocio, @idMedidor, @serie;
        END
        CLOSE curL; DEALLOCATE curL;

        -- Generar los avisos de la ruta (estampa TASA AFCOOP a todos)
        SET @esperados = (SELECT COUNT(*) FROM socio WHERE ruta_id_ruta = @ruta);
        EXEC dbo.sp_generar_avisos_periodo @idPeriodo, @ruta, @gen OUTPUT, @msg OUTPUT;
        IF ISNULL(@gen, 0) <> @esperados
        BEGIN IF @@TRANCOUNT > 0 ROLLBACK; RAISERROR('Avisos mes %d ruta %d: %d de %d. %s', 16, 1, @mes, @ruta, @gen, @esperados, @msg); RETURN; END
        SET @avisos = @avisos + @gen;

        -- Fechas al calendario simulado (el SP usa GETDATE)
        UPDATE a SET fecha_emision = @fecha, fecha_vencimiento = DATEADD(MONTH, 2, @fecha), estado_id_estado = @IMPRESO
        FROM aviso a JOIN socio s ON s.id_socio = a.socio_id_socio
        WHERE a.periodo_id_periodo = @idPeriodo AND s.ruta_id_ruta = @ruta AND a.fecha_emision = @HOY;

        UPDATE ce SET fecha_registro = @fecha
        FROM cargo_extra ce JOIN socio s ON s.id_socio = ce.socio_id_socio
        WHERE ce.periodo_id_periodo = @idPeriodo AND s.ruta_id_ruta = @ruta AND ce.fecha_registro = @HOY;

        SET @ruta = @ruta + 1;
    END

    IF EXISTS (SELECT 1 FROM aviso a WHERE a.periodo_id_periodo = @idPeriodo
               AND NOT EXISTS (SELECT 1 FROM cargo_extra ce WHERE ce.socio_id_socio = a.socio_id_socio
                               AND ce.periodo_id_periodo = @idPeriodo AND ce.tipo_cargo_id_tipo = @TC_AFCOOP))
    BEGIN ROLLBACK; RAISERROR('Mes %d: hay avisos sin TASA AFCOOP.', 16, 1, @mes); RETURN; END

    -- 3) Cobros del mes en la caja del mes siguiente (se reabre solo para registrar)
    SELECT @idCaja = id_caja, @fechaCaja = fecha FROM #cajaMes WHERE mes = @mes;
    UPDATE caja SET estado = 1 WHERE id_caja = @idCaja;

    DECLARE curP CURSOR LOCAL FAST_FORWARD FOR
        SELECT a.id_aviso
        FROM aviso a JOIN #grp g ON g.id_socio = a.socio_id_socio
        WHERE a.periodo_id_periodo = @idPeriodo AND g.pend_desde > @mes
        ORDER BY a.id_aviso;
    OPEN curP;
    FETCH NEXT FROM curP INTO @idAviso;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_registrar_pago_aviso @idAviso, @idCaja, @EFECTIVO, NULL, @CAJERA_NOM, @idPago OUTPUT, @msgN OUTPUT;
        IF ISNULL(@idPago, 0) <= 0
        BEGIN CLOSE curP; DEALLOCATE curP; IF @@TRANCOUNT > 0 ROLLBACK; RAISERROR('Pago aviso %d: %s', 16, 1, @idAviso, @msgN); RETURN; END
        SET @pagos = @pagos + 1;
        FETCH NEXT FROM curP INTO @idAviso;
    END
    CLOSE curP; DEALLOCATE curP;

    UPDATE pago SET fecha_pago = @fechaCaja
    WHERE caja_id_caja = @idCaja AND CAST(fecha_pago AS DATE) = @HOY AND aviso_id_aviso IS NOT NULL;

    UPDATE caja
    SET estado = 0,
        monto_cobrado = (SELECT ISNULL(SUM(monto_pagado), 0) FROM pago WHERE caja_id_caja = @idCaja AND estado_pago = 'APROBADO')
    WHERE id_caja = @idCaja;

    PRINT 'OK  mes ' + CAST(@mes AS VARCHAR) + ': avisos generados y cobrados.';
    SET @mes = @mes + 1;
END

-- ---------------------------------------------------------------------------
-- Notificaciones de pago (sp_notificar_pago_confirmado las fecha con GETDATE)
-- ---------------------------------------------------------------------------
UPDATE n SET fecha_publicacion = CAST(p.fecha_pago AS DATE)
FROM notificacion n
JOIN notificacion_socio ns ON ns.notificacion_id_notificacion = n.id_notificacion
JOIN aviso a  ON a.socio_id_socio = ns.socio_id_socio
JOIN pago  p  ON p.aviso_id_aviso = a.id_aviso
WHERE n.tipo = 'Pago' AND n.id_notificacion > @NOTIF_BEFORE
  AND n.mensaje LIKE '%[[]Aviso #' + CAST(a.id_aviso AS VARCHAR) + ']%';

-- Las anteriores a septiembre ya fueron leidas en el portal; las de septiembre quedan sin leer
UPDATE ns SET leido = CASE WHEN n.fecha_publicacion < '2026-09-01' THEN 1 ELSE 0 END,
              fecha_lectura = CASE WHEN n.fecha_publicacion < '2026-09-01' THEN DATEADD(DAY, 1, n.fecha_publicacion) ELSE n.fecha_publicacion END
FROM notificacion_socio ns JOIN notificacion n ON n.id_notificacion = ns.notificacion_id_notificacion
WHERE n.tipo = 'Pago' AND n.id_notificacion > @NOTIF_BEFORE;

COMMIT;

PRINT 'OK  ' + CAST(@lecturas AS VARCHAR) + ' lecturas, ' + CAST(@avisos AS VARCHAR) + ' avisos, '
    + CAST(@cargosManuales AS VARCHAR) + ' cargos manuales, ' + CAST(@pagos AS VARCHAR) + ' pagos de aviso.';

-- ---------------------------------------------------------------------------
-- Resumen
-- ---------------------------------------------------------------------------
SELECT p.periodo, e.estado, COUNT(*) avisos, SUM(a.total_aviso) total
FROM aviso a JOIN periodo p ON p.id_periodo = a.periodo_id_periodo JOIN estado e ON e.id_estado = a.estado_id_estado
GROUP BY p.periodo, e.estado ORDER BY p.periodo, e.estado;

SELECT pendientes, COUNT(*) socios FROM (
    SELECT s.id_socio, SUM(CASE WHEN e.estado NOT IN ('PAGADO','ANULADO') THEN 1 ELSE 0 END) pendientes
    FROM socio s JOIN aviso a ON a.socio_id_socio = s.id_socio JOIN estado e ON e.id_estado = a.estado_id_estado
    GROUP BY s.id_socio) x GROUP BY pendientes ORDER BY pendientes;

SELECT id_caja, fecha, monto_cobrado, estado, usuario_admin_id_usuario_admin FROM caja ORDER BY fecha;
GO
