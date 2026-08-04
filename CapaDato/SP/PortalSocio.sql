USE [COSPABIRL1]
GO

-- =============================================================================
-- PORTAL DEL SOCIO (HU18 consulta autonoma / HU19 notificaciones visibles).
-- SPs de solo lectura sobre los datos del socio logueado, mas marcar leida.
-- =============================================================================

-- 1. Resumen del estado de cuenta del socio -----------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_portal_resumen_socio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT ISNULL(SUM(a.deuda_actual), 0)
         FROM aviso a
         INNER JOIN estado e ON e.id_estado = a.estado_id_estado
         WHERE a.socio_id_socio = @id_socio
           AND e.estado NOT IN ('PAGADO', 'ANULADO'))          AS deuda_total,
        (SELECT COUNT(*)
         FROM aviso a
         INNER JOIN estado e ON e.id_estado = a.estado_id_estado
         WHERE a.socio_id_socio = @id_socio
           AND e.estado NOT IN ('PAGADO', 'ANULADO'))          AS avisos_pendientes,
        (SELECT COUNT(*)
         FROM aviso a
         INNER JOIN estado e ON e.id_estado = a.estado_id_estado
         WHERE a.socio_id_socio = @id_socio
           AND e.estado NOT IN ('PAGADO', 'ANULADO')
           AND a.fecha_vencimiento < CAST(GETDATE() AS DATE))  AS avisos_vencidos,
        (SELECT COUNT(*)
         FROM notificacion_socio ns
         INNER JOIN notificacion n ON n.id_notificacion = ns.notificacion_id_notificacion
         WHERE ns.socio_id_socio = @id_socio
           AND ns.leido = 0 AND n.estado = 1)                  AS notificaciones_sin_leer;
END
GO

-- 2. Historial de avisos del socio --------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_portal_avisos_socio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        a.id_aviso,
        per.periodo AS nombre_periodo,
        a.fecha_emision,
        a.fecha_vencimiento,
        l.consumo_m3,                    -- RF-26: historial de consumo
        a.total_aviso,
        a.deuda_actual,
        e.estado,
        CASE WHEN e.estado NOT IN ('PAGADO', 'ANULADO')
                  AND a.fecha_vencimiento < CAST(GETDATE() AS DATE)
             THEN 1 ELSE 0 END AS vencido
    FROM aviso a
    INNER JOIN estado  e   ON e.id_estado    = a.estado_id_estado
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT  JOIN lectura l   ON l.id_lectura   = a.lectura_id_lectura
    WHERE a.socio_id_socio = @id_socio
    ORDER BY a.id_aviso DESC;
END
GO

-- 3. Historial de pagos del socio (avisos e inscripcion) ----------------------
CREATE OR ALTER PROCEDURE dbo.sp_portal_pagos_socio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.id_pago,
        p.fecha_pago,
        p.monto_pagado,
        mp.metodo AS nombre_metodo,
        p.aviso_id_aviso,
        CASE WHEN p.aviso_id_aviso IS NULL THEN 'Inscripcion'
             ELSE 'Aviso ' + ISNULL(per.periodo, '') END AS concepto
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN aviso   a   ON a.id_aviso    = p.aviso_id_aviso
    LEFT  JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    WHERE p.estado_pago = 'APROBADO'
      AND (a.socio_id_socio = @id_socio
           OR EXISTS (SELECT 1 FROM credito_inscripcion ci
                      WHERE ci.pago_id_pago = p.id_pago
                        AND ci.socio_id_socio = @id_socio))
    ORDER BY p.fecha_pago DESC;
END
GO

-- 4. Notificaciones del socio (HU19: visibles en el portal) -------------------
CREATE OR ALTER PROCEDURE dbo.sp_portal_notificaciones_socio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ns.id_notificacion_socio,
        n.titulo,
        n.mensaje,
        n.tipo,
        n.fecha_publicacion,
        ns.leido,
        ns.fecha_lectura
    FROM notificacion_socio ns
    INNER JOIN notificacion n ON n.id_notificacion = ns.notificacion_id_notificacion
    WHERE ns.socio_id_socio = @id_socio
      AND n.estado = 1
    ORDER BY n.fecha_publicacion DESC, ns.id_notificacion_socio DESC;
END
GO

-- 5. Marcar una notificacion como leida (registra la fecha de lectura) --------
CREATE OR ALTER PROCEDURE dbo.sp_portal_marcar_notificacion_leida
    @id_notificacion_socio INT,
    @id_socio              INT,            -- guarda: solo el dueno puede marcarla
    @Resultado             INT           OUTPUT,
    @Mensaje               NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        UPDATE notificacion_socio
        SET leido = 1, fecha_lectura = GETDATE()
        WHERE id_notificacion_socio = @id_notificacion_socio
          AND socio_id_socio = @id_socio
          AND leido = 0;

        SET @Resultado = 1;   -- idempotente: ya leida tambien es exito
        SET @Mensaje   = 'Notificacion marcada como leida.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
