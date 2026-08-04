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
      AND CAST(p.fecha_pago AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND (@IdCajero IS NULL OR c.usuario_admin_id_usuario_admin = @IdCajero);
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
        a.deuda_actual AS monto_adeudado,
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
        ISNULL(SUM(a.deuda_actual),0)  AS total_adeudado
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
