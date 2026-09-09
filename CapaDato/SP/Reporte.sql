USE [COSPABIRL1]
GO

-- =============================================================================
-- Modulo REPORTE (HU21 Reporte de Caja, HU22 Reporte de Morosidad).
-- Los permisos 'Generar Reporte Caja' y 'Generar Reporte Morosidad' ya estan
-- sembrados (Login.sql) y asignados al modulo 'Reportes' (Migracion 09).
-- =============================================================================

-- 1. HU21: Reporte de caja por rango de fechas y cajero opcional --------------
--    RS1: detalle de cobros (aviso o inscripcion) APROBADOS del periodo.
--    RS2: totales por metodo de pago.
--    RS3: resumen (cantidad de pagos y total recaudado).
--    Cubre UNICAMENTE el dinero que entro por una caja. Un pago del portal
--    del socio se aprueba sin caja (caja_id_caja NULL) y, al no filtrar por
--    cajero, se colaba aqui mezclado con el efectivo de ventanilla; ahora
--    tiene su propio reporte en sp_reporte_pagos_sistema.
CREATE OR ALTER PROCEDURE dbo.sp_reporte_caja
    @FechaInicio DATE,
    @FechaFin    DATE,
    @IdCajero    INT = NULL   -- usuario_admin de la caja; NULL = todos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.id_pago,
        p.fecha_pago,
        p.aviso_id_aviso,
        CASE WHEN p.aviso_id_aviso IS NULL THEN 'Inscripcion' ELSE 'Aviso' END AS tipo_cobro,
        ISNULL(s.nombre_socio, si.nombre_socio) AS nombre_socio,
        ISNULL(s.codigo_fijo,  si.codigo_fijo)  AS codigo_fijo,
        mp.metodo AS nombre_metodo,
        p.cajero,
        p.monto_pagado
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN caja  c  ON c.id_caja  = p.caja_id_caja
    LEFT  JOIN aviso a  ON a.id_aviso = p.aviso_id_aviso
    LEFT  JOIN socio s  ON s.id_socio = a.socio_id_socio
    -- pago de inscripcion (sin aviso): el socio via su credito
    OUTER APPLY (
        SELECT TOP 1 s2.nombre_socio, s2.codigo_fijo
        FROM credito_inscripcion ci
        INNER JOIN socio s2 ON s2.id_socio = ci.socio_id_socio
        WHERE ci.pago_id_pago = p.id_pago
    ) si
    WHERE p.estado_pago = 'APROBADO'
      AND p.caja_id_caja IS NOT NULL          -- excluye los pagos del portal
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero)
    ORDER BY p.fecha_pago;

    SELECT
        mp.metodo AS nombre_metodo,
        COUNT(*)  AS cantidad,
        SUM(p.monto_pagado) AS total
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN caja c ON c.id_caja = p.caja_id_caja
    WHERE p.estado_pago = 'APROBADO'
      AND p.caja_id_caja IS NOT NULL          -- excluye los pagos del portal
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero)
    GROUP BY mp.metodo
    ORDER BY total DESC;

    SELECT
        COUNT(*)                     AS cantidad_pagos,
        ISNULL(SUM(p.monto_pagado),0) AS total_recaudado
    FROM pago p
    LEFT JOIN caja c ON c.id_caja = p.caja_id_caja
    WHERE p.estado_pago = 'APROBADO'
      AND p.caja_id_caja IS NOT NULL          -- excluye los pagos del portal
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero);
END
GO

-- 1b. Reporte de PAGOS DEL SISTEMA -------------------------------------------
--     Cobros aprobados que no pasaron por ninguna caja: el socio los pago solo
--     desde el portal con QR. Misma forma que sp_reporte_caja (3 resultsets)
--     para que la vista pueda leerse igual.
--     RS1: detalle.  RS2: totales por metodo.  RS3: resumen + QR sin cobrar.
CREATE OR ALTER PROCEDURE dbo.sp_reporte_pagos_sistema
    @FechaInicio DATE,
    @FechaFin    DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.id_pago,
        p.fecha_pago,
        p.aviso_id_aviso,
        CASE WHEN p.aviso_id_aviso IS NULL THEN 'Inscripcion' ELSE 'Aviso' END AS tipo_cobro,
        ISNULL(s.nombre_socio, si.nombre_socio) AS nombre_socio,
        ISNULL(s.codigo_fijo,  si.codigo_fijo)  AS codigo_fijo,
        per.periodo        AS nombre_periodo,
        mp.metodo          AS nombre_metodo,
        p.id_transaccion,
        p.codigo_recaudacion,
        p.forma_pago,
        p.monto_pagado
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN aviso   a   ON a.id_aviso    = p.aviso_id_aviso
    LEFT  JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT  JOIN socio   s   ON s.id_socio    = a.socio_id_socio
    OUTER APPLY (
        SELECT TOP 1 s2.nombre_socio, s2.codigo_fijo
        FROM credito_inscripcion ci
        INNER JOIN socio s2 ON s2.id_socio = ci.socio_id_socio
        WHERE ci.pago_id_pago = p.id_pago
    ) si
    WHERE p.estado_pago  = 'APROBADO'
      AND p.caja_id_caja IS NULL
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
    ORDER BY p.fecha_pago;

    SELECT
        mp.metodo AS nombre_metodo,
        COUNT(*)  AS cantidad,
        SUM(p.monto_pagado) AS total
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.estado_pago  = 'APROBADO'
      AND p.caja_id_caja IS NULL
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY mp.metodo
    ORDER BY total DESC;

    -- Resumen. 'qr_sin_cobrar' son los QR generados en el periodo que nadie
    -- llego a pagar (siguen PENDIENTE o ya vencieron): no son plata, pero
    -- dicen cuanta gente abandono el pago a medio camino.
    SELECT
        COUNT(*)                      AS cantidad_pagos,
        ISNULL(SUM(p.monto_pagado),0) AS total_recaudado,
        (SELECT COUNT(*)
         FROM pago q
         WHERE q.caja_id_caja IS NULL
           AND q.id_transaccion IS NOT NULL
           AND q.estado_pago IN ('PENDIENTE', 'EXPIRADO')
           AND CAST(q.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin)
                                      AS qr_sin_cobrar
    FROM pago p
    WHERE p.estado_pago  = 'APROBADO'
      AND p.caja_id_caja IS NULL
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin;
END
GO

-- 2. HU22: Reporte de morosidad -----------------------------------------------
--    Avisos VENCIDOS (fecha_vencimiento pasada, ni PAGADO ni ANULADO),
--    agrupados por socio, con dias de mora. Filtros: rango del vencimiento
--    y ruta, ambos opcionales.
--    RS1: detalle por aviso. RS2: resumen (socios, avisos, total adeudado).
CREATE OR ALTER PROCEDURE dbo.sp_reporte_morosidad
    @FechaInicio DATE = NULL,
    @FechaFin    DATE = NULL,
    @IdRuta      INT  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.id_socio,
        s.nombre_socio,
        s.codigo_fijo,
        r.ruta AS nombre_ruta,
        per.periodo AS nombre_periodo,
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_aviso AS monto_adeudado,
        DATEDIFF(DAY, a.fecha_vencimiento, GETDATE()) AS dias_mora
    FROM aviso a
    INNER JOIN estado  e   ON e.id_estado    = a.estado_id_estado
    INNER JOIN socio   s   ON s.id_socio     = a.socio_id_socio
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT  JOIN ruta    r   ON r.id_ruta      = s.ruta_id_ruta
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND a.fecha_vencimiento < CAST(GETDATE() AS DATE)
      AND (@FechaInicio IS NULL OR a.fecha_vencimiento >= @FechaInicio)
      AND (@FechaFin    IS NULL OR a.fecha_vencimiento <= @FechaFin)
      AND (@IdRuta      IS NULL OR s.ruta_id_ruta = @IdRuta)
    ORDER BY s.nombre_socio, a.fecha_vencimiento;

    SELECT
        COUNT(DISTINCT s.id_socio)     AS cantidad_socios,
        COUNT(*)                       AS cantidad_avisos,
        ISNULL(SUM(a.total_aviso),0)   AS total_adeudado
    FROM aviso a
    INNER JOIN estado e ON e.id_estado = a.estado_id_estado
    INNER JOIN socio  s ON s.id_socio  = a.socio_id_socio
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND a.fecha_vencimiento < CAST(GETDATE() AS DATE)
      AND (@FechaInicio IS NULL OR a.fecha_vencimiento >= @FechaInicio)
      AND (@FechaFin    IS NULL OR a.fecha_vencimiento <= @FechaFin)
      AND (@IdRuta      IS NULL OR s.ruta_id_ruta = @IdRuta);
END
GO

-- 3. Cajeros que registraron cajas (para el filtro del reporte de caja) -------
CREATE OR ALTER PROCEDURE dbo.sp_listar_cajeros_con_caja
    @SolicitanteEsSuperadmin BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DISTINCT
        u.id_usuario_admin,
        u.nombre + ' ' + u.apellido AS nombre_completo
    FROM caja c
    INNER JOIN usuario_admin u ON u.id_usuario_admin = c.usuario_admin_id_usuario_admin
    INNER JOIN rol ro ON ro.id_rol = u.rol_id_rol
    WHERE (@SolicitanteEsSuperadmin = 1 OR ro.nombre <> 'SUPERADMIN')
    ORDER BY nombre_completo;
END
GO

-- 4. Facturas cobradas (detalle de cobros del periodo) -----------------------
--    Replica el reporte "Facturas Cobradas" que la cooperativa ya usaba:
--    una fila por pago APROBADO con codigo, socio, periodo cobrado, boleta
--    (id_pago), fecha/hora, N° de aviso y monto.
--    @Origen: 'CAJA'  = solo pagos que pasaron por una caja (@IdCajero opcional)
--             'PORTAL'= solo pagos del portal del socio (sin caja)
--             'TODOS' = ambos
--    RS1: detalle. RS2: subtotales por tipo de cobro (Aviso / Inscripcion).
--    RS3: resumen (cantidad, total).
CREATE OR ALTER PROCEDURE dbo.sp_reporte_cobros
    @FechaInicio DATE,
    @FechaFin    DATE,
    @IdCajero    INT         = NULL,
    @Origen      VARCHAR(10) = 'CAJA'
AS
BEGIN
    SET NOCOUNT ON;
    SET @Origen = UPPER(ISNULL(@Origen, 'CAJA'));

    SELECT
        p.id_pago,
        p.fecha_pago,
        p.aviso_id_aviso,
        CASE WHEN p.aviso_id_aviso IS NULL THEN 'Inscripcion' ELSE 'Aviso' END AS tipo_cobro,
        ISNULL(s.codigo_fijo,  si.codigo_fijo)  AS codigo_fijo,
        ISNULL(s.nombre_socio, si.nombre_socio) AS nombre_socio,
        ISNULL(per.periodo,    si.periodo)      AS nombre_periodo,
        mp.metodo AS nombre_metodo,
        p.cajero,
        p.caja_id_caja,
        p.monto_pagado
    INTO #cobros
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN caja    c   ON c.id_caja     = p.caja_id_caja
    LEFT  JOIN aviso   a   ON a.id_aviso    = p.aviso_id_aviso
    LEFT  JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT  JOIN socio   s   ON s.id_socio    = a.socio_id_socio
    OUTER APPLY (
        SELECT TOP 1 s2.nombre_socio, s2.codigo_fijo, per2.periodo
        FROM credito_inscripcion ci
        INNER JOIN socio   s2   ON s2.id_socio     = ci.socio_id_socio
        INNER JOIN periodo per2 ON per2.id_periodo = ci.periodo_id_periodo
        WHERE ci.pago_id_pago = p.id_pago
    ) si
    WHERE p.estado_pago = 'APROBADO'
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND (   (@Origen = 'CAJA'   AND p.caja_id_caja IS NOT NULL)
           OR (@Origen = 'PORTAL' AND p.caja_id_caja IS NULL)
           OR (@Origen = 'TODOS'))
      AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero);

    SELECT * FROM #cobros ORDER BY fecha_pago, id_pago;

    SELECT tipo_cobro, COUNT(*) AS cantidad, SUM(monto_pagado) AS total
    FROM #cobros
    GROUP BY tipo_cobro
    ORDER BY tipo_cobro;

    SELECT COUNT(*) AS cantidad_pagos, ISNULL(SUM(monto_pagado), 0) AS total_recaudado
    FROM #cobros;

    DROP TABLE #cobros;
END
GO

-- 5. Arqueo general (recaudacion por concepto) --------------------------------
--    Replica el "Arqueo General" de la cooperativa: cuanto entro por cada
--    servicio (consumo de agua, cada tipo de cargo extra, cuotas de
--    inscripcion) en un rango de fechas. Un pago de aviso se descompone
--    en los conceptos que su total_aviso agrupaba:
--      consumo  = aviso.total_consumo
--      cargos   = cargo_extra PAGADO del mismo socio/periodo, por tipo
--      cuotas   = credito_inscripcion selladas con ese pago_id_pago
--    y un pago sin aviso es la cuota inicial de una inscripcion.
--    Si el desglose no cuadra con lo cobrado (cargo nacido despues de la
--    emision, ver CLAUDE.md) la diferencia sale como fila propia para que
--    el total del arqueo siempre sea el dinero real.
--    @IdCaja: arqueo de UNA caja (ignora fechas/origen/cajero). El llamador
--    debe haber validado antes la propiedad de esa caja (sp_arqueo_caja).
--    RS1: conceptos (nro, servicio, cantidad, cobrado).
--    RS2: totales por metodo de pago.  RS3: resumen.
CREATE OR ALTER PROCEDURE dbo.sp_reporte_arqueo_general
    @FechaInicio DATE        = NULL,
    @FechaFin    DATE        = NULL,
    @IdCajero    INT         = NULL,
    @Origen      VARCHAR(10) = 'CAJA',
    @IdCaja      INT         = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @Origen = UPPER(ISNULL(@Origen, 'CAJA'));

    -- Universo de pagos del arqueo
    SELECT p.id_pago, p.monto_pagado, p.metodo_pago_id_metodo_pago,
           a.id_aviso, a.total_consumo, a.socio_id_socio, a.periodo_id_periodo
    INTO #p
    FROM pago p
    LEFT JOIN caja  c ON c.id_caja  = p.caja_id_caja
    LEFT JOIN aviso a ON a.id_aviso = p.aviso_id_aviso
    WHERE p.estado_pago = 'APROBADO'
      AND (
            (@IdCaja IS NOT NULL AND p.caja_id_caja = @IdCaja)
         OR (@IdCaja IS NULL
             AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
             AND (   (@Origen = 'CAJA'   AND p.caja_id_caja IS NOT NULL)
                  OR (@Origen = 'PORTAL' AND p.caja_id_caja IS NULL)
                  OR (@Origen = 'TODOS'))
             AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero))
          );

    CREATE TABLE #c (orden INT, servicio VARCHAR(160), cantidad INT, cobrado DECIMAL(30,2));

    -- 1. Consumo de agua
    INSERT INTO #c
    SELECT 1, 'Consumo de agua', COUNT(*), ISNULL(SUM(total_consumo), 0)
    FROM #p WHERE id_aviso IS NOT NULL;

    -- 2. Cargos extra, uno por tipo (solo los que tuvieron cobro)
    INSERT INTO #c
    SELECT 10 + tc.id_tipo, tc.nombre, COUNT(*), SUM(ce.monto)
    FROM #p
    INNER JOIN cargo_extra ce ON ce.socio_id_socio    = #p.socio_id_socio
                              AND ce.periodo_id_periodo = #p.periodo_id_periodo
                              AND ce.estado = 'PAGADO'
    INNER JOIN tipo_cargo tc  ON tc.id_tipo = ce.tipo_cargo_id_tipo
    WHERE #p.id_aviso IS NOT NULL
    GROUP BY tc.id_tipo, tc.nombre;

    -- 3. Inscripcion (cuota inicial pagada en caja + cuotas cobradas en avisos)
    INSERT INTO #c
    SELECT 900, 'Inscripcion (cuotas)', COUNT(*), SUM(ci.monto_pago)
    FROM #p
    INNER JOIN credito_inscripcion ci ON ci.pago_id_pago = #p.id_pago
    HAVING COUNT(*) > 0;

    -- 4. Diferencia entre lo cobrado y el desglose (normalmente 0)
    DECLARE @cobrado DECIMAL(30,2) = ISNULL((SELECT SUM(monto_pagado) FROM #p), 0);
    DECLARE @desglose DECIMAL(30,2) = ISNULL((SELECT SUM(cobrado) FROM #c), 0);
    IF ABS(@cobrado - @desglose) >= 0.01
        INSERT INTO #c VALUES (999, 'Otros / ajuste de desglose', 0, @cobrado - @desglose);

    -- Sin pagos: igual devolvemos la fila de consumo en 0 para que el reporte no salga vacio
    SELECT ROW_NUMBER() OVER (ORDER BY orden) AS nro, servicio, cantidad, cobrado
    FROM #c
    WHERE cobrado <> 0 OR orden = 1
    ORDER BY orden;

    SELECT mp.metodo AS nombre_metodo, COUNT(*) AS cantidad, SUM(#p.monto_pagado) AS total
    FROM #p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = #p.metodo_pago_id_metodo_pago
    GROUP BY mp.metodo
    ORDER BY total DESC;

    SELECT COUNT(*) AS cantidad_pagos, @cobrado AS total_recaudado,
           (SELECT COUNT(*) FROM #c WHERE cobrado <> 0) AS cantidad_conceptos
    FROM #p;

    DROP TABLE #p; DROP TABLE #c;
END
GO

-- 6. HU24: Reporte de pagos de inscripcion ------------------------------------
--    Que cuotas del credito de inscripcion se cobraron en el rango (por fecha
--    del pago que las sello: credito_inscripcion.pago_id_pago) y que socios
--    siguen con cuotas pendientes. El monto reportado es SOLO la cuota
--    (credito_inscripcion.monto_pago), no el total del aviso que la incluyo.
--    RS1: cuotas cobradas en el rango.
--    RS2: socios con saldo pendiente hoy (todos, no depende del rango).
--    RS3: resumen.
CREATE OR ALTER PROCEDURE dbo.sp_reporte_pagos_inscripcion
    @FechaInicio DATE,
    @FechaFin    DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Totales por socio (foto de hoy)
    SELECT socio_id_socio                                                  AS id_socio,
           SUM(monto_pago)                                                 AS total_credito,
           SUM(CASE WHEN estado = 'CANCELADO' THEN monto_pago ELSE 0 END)  AS pagado,
           SUM(CASE WHEN estado = 'PENDIENTE' THEN monto_pago ELSE 0 END)  AS saldo,
           COUNT(*)                                                        AS total_cuotas,
           SUM(CASE WHEN estado = 'PENDIENTE' THEN 1 ELSE 0 END)           AS cuotas_pendientes
    INTO #tot
    FROM credito_inscripcion
    GROUP BY socio_id_socio;

    -- RS1: cuotas cobradas en el rango
    SELECT
        s.codigo_fijo,
        s.nombre_socio,
        t.total_credito,
        ci.num_cuota,
        t.total_cuotas,
        ci.monto_pago                                   AS monto_cuota,
        t.saldo                                         AS saldo_pendiente,
        p.fecha_pago,
        p.id_pago,
        p.aviso_id_aviso,
        per.periodo                                     AS nombre_periodo,
        mp.metodo                                       AS nombre_metodo,
        CASE WHEN t.saldo = 0 THEN 'CANCELADO' ELSE 'PENDIENTE' END AS estado_credito
    FROM credito_inscripcion ci
    INNER JOIN pago        p   ON p.id_pago      = ci.pago_id_pago
    INNER JOIN socio       s   ON s.id_socio     = ci.socio_id_socio
    INNER JOIN #tot        t   ON t.id_socio     = ci.socio_id_socio
    INNER JOIN periodo     per ON per.id_periodo = ci.periodo_id_periodo
    INNER JOIN metodo_pago mp  ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE ci.estado = 'CANCELADO'
      AND p.estado_pago = 'APROBADO'
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
    ORDER BY p.fecha_pago, s.nombre_socio, ci.num_cuota;

    -- RS2: socios con cuotas pendientes hoy
    SELECT
        s.codigo_fijo,
        s.nombre_socio,
        t.total_credito,
        t.pagado,
        t.saldo,
        t.cuotas_pendientes,
        t.total_cuotas,
        prox.periodo    AS proximo_periodo,
        prox.monto_pago AS proximo_monto
    FROM #tot t
    INNER JOIN socio s ON s.id_socio = t.id_socio
    OUTER APPLY (
        SELECT TOP 1 per.periodo, c.monto_pago
        FROM credito_inscripcion c
        INNER JOIN periodo per ON per.id_periodo = c.periodo_id_periodo
        WHERE c.socio_id_socio = t.id_socio AND c.estado = 'PENDIENTE'
        ORDER BY c.num_cuota
    ) prox
    WHERE t.saldo > 0
    ORDER BY s.nombre_socio;

    -- RS3: resumen
    SELECT
        COUNT(*)                                     AS cantidad_cuotas,
        ISNULL(SUM(ci.monto_pago), 0)                AS monto_cobrado,
        COUNT(DISTINCT ci.socio_id_socio)            AS socios_cobrados,
        COUNT(DISTINCT CASE WHEN t.saldo = 0 THEN ci.socio_id_socio END) AS socios_cancelaron_total,
        (SELECT COUNT(*) FROM #tot WHERE saldo > 0)  AS socios_con_pendientes,
        (SELECT ISNULL(SUM(saldo), 0) FROM #tot)     AS saldo_total_pendiente
    FROM credito_inscripcion ci
    INNER JOIN pago p ON p.id_pago = ci.pago_id_pago
    INNER JOIN #tot t ON t.id_socio = ci.socio_id_socio
    WHERE ci.estado = 'CANCELADO'
      AND p.estado_pago = 'APROBADO'
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin;

    DROP TABLE #tot;
END
GO
