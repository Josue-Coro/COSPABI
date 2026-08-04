USE [COSPABIRL1]
GO

-- =============================================================================
-- Modulo PAGO QR (pasarela Libelula).
-- Flujo: sp_datos_deuda_qr (lee datos para registrar la deuda en Libelula)
--   -> la app llama a Libelula (POST /rest/deuda/registrar)
--   -> sp_registrar_pago_qr_pendiente (inserta pago PENDIENTE con qr_url)
--   -> Libelula confirma via callback -> sp_confirmar_pago_qr (APROBADO +
--      cierra el ciclo: aviso->PAGADO, cargos->PAGADO, cuotas->CANCELADO).
-- Un pago QR PENDIENTE no cuenta en el arqueo (sp_cerrar_caja filtra APROBADO).
-- Desplegar con sqlcmd -I (pago tiene indice filtrado pago_id_transaccion_UX).
-- =============================================================================

-- 0. Metodo de pago para cobros QR --------------------------------------------
INSERT INTO metodo_pago (metodo, referencia)
SELECT 'QR LIBELULA', 'Pago con codigo QR via pasarela Libelula'
WHERE NOT EXISTS (SELECT 1 FROM metodo_pago WHERE metodo = 'QR LIBELULA');
GO

-- 1. Datos del aviso para registrar la deuda en Libelula ----------------------
--    Resultset 1: cabecera (incluye email del cliente y QR pendiente si existe).
--    Resultset 2: detalle de la deuda (concepto, subtotal), igual que el recibo.
CREATE OR ALTER PROCEDURE dbo.sp_datos_deuda_qr
    @id_aviso INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.id_aviso,
        a.total_aviso,
        e.estado,
        s.nombre_socio,
        s.codigo_fijo,
        per.periodo AS nombre_periodo,
        c.email,
        pqr.id_pago         AS pendiente_id_pago,
        pqr.id_transaccion  AS pendiente_id_transaccion,
        pqr.url_pasarela    AS pendiente_url_pasarela,
        pqr.qr_url          AS pendiente_qr_url
    FROM aviso a
    INNER JOIN estado  e   ON e.id_estado    = a.estado_id_estado
    INNER JOIN socio   s   ON s.id_socio     = a.socio_id_socio
    INNER JOIN cliente c   ON c.id_cliente   = s.cliente_id_cliente
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    OUTER APPLY (
        SELECT TOP 1 p.id_pago, p.id_transaccion, p.url_pasarela, p.qr_url
        FROM pago p
        WHERE p.aviso_id_aviso = a.id_aviso
          AND p.estado_pago    = 'PENDIENTE'
          AND p.id_transaccion IS NOT NULL
          -- Solo el QR generado HOY es reutilizable: la deuda se registra en
          -- Libelula con vencimiento al final del dia, asi que uno de un dia
          -- anterior ya no puede pagarse en la pasarela.
          AND CAST(p.fecha_pago AS DATE) = CAST(GETDATE() AS DATE)
        ORDER BY p.id_pago DESC
    ) pqr
    WHERE a.id_aviso = @id_aviso;

    -- Detalle para lineas_detalle_deuda de Libelula
    DECLARE @socio_id INT, @periodo_id INT, @total_consumo DECIMAL(30,2);
    SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo,
           @total_consumo = total_consumo
    FROM aviso WHERE id_aviso = @id_aviso;

    SELECT concepto, subtotal FROM (
        SELECT 'Consumo Agua' AS concepto, @total_consumo AS subtotal, 0 AS orden
        WHERE @total_consumo > 0
        UNION ALL
        SELECT descripcion, monto, 1
        FROM cargo_extra
        WHERE socio_id_socio = @socio_id AND periodo_id_periodo = @periodo_id
          AND estado = 'PENDIENTE'
        UNION ALL
        SELECT 'Cuota de Inscripcion (' + CAST(num_cuota AS VARCHAR) + ')', monto_pago, 2
        FROM credito_inscripcion
        WHERE socio_id_socio = @socio_id AND periodo_id_periodo = @periodo_id
          AND estado = 'PENDIENTE'
    ) d
    ORDER BY d.orden;
END
GO

-- 2. Registrar pago QR PENDIENTE (despues de registrar la deuda en Libelula) --
CREATE OR ALTER PROCEDURE dbo.sp_registrar_pago_qr_pendiente
    @id_aviso            INT,
    @id_caja             INT           = NULL,   -- NULL = pago online sin caja
    @cajero              VARCHAR(150),
    @identificador_deuda VARCHAR(100),
    @id_transaccion      VARCHAR(100),
    @url_pasarela        VARCHAR(500)  = NULL,
    @qr_url              VARCHAR(500)  = NULL,
    @Resultado           INT           OUTPUT,   -- id_pago generado (>0) | 0 error
    @Mensaje             NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        DECLARE @total DECIMAL(30,2), @estado VARCHAR(50);
        SELECT @total = a.total_aviso, @estado = e.estado
        FROM aviso a
        INNER JOIN estado e ON e.id_estado = a.estado_id_estado
        WHERE a.id_aviso = @id_aviso;

        IF @total IS NULL BEGIN SET @Mensaje = 'Aviso no encontrado.'; RETURN; END
        IF @estado = 'PAGADO'  BEGIN SET @Mensaje = 'El aviso ya esta pagado.'; RETURN; END
        IF @estado = 'ANULADO' BEGIN SET @Mensaje = 'El aviso esta anulado.'; RETURN; END

        IF @id_caja IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'No hay una caja abierta valida. Abra su caja primero.'; RETURN; END

        IF EXISTS (SELECT 1 FROM pago WHERE id_transaccion = @id_transaccion)
        BEGIN SET @Mensaje = 'La transaccion ya fue registrada.'; RETURN; END

        DECLARE @id_metodo_qr INT =
            (SELECT TOP 1 id_metodo_pago FROM metodo_pago WHERE metodo = 'QR LIBELULA');
        IF @id_metodo_qr IS NULL
        BEGIN SET @Mensaje = 'Falta el metodo de pago QR LIBELULA.'; RETURN; END

        BEGIN TRAN;

        -- Un solo QR vigente por aviso: los intentos anteriores quedan EXPIRADO
        UPDATE pago SET estado_pago = 'EXPIRADO'
        WHERE aviso_id_aviso = @id_aviso
          AND estado_pago    = 'PENDIENTE'
          AND id_transaccion IS NOT NULL;

        INSERT INTO pago (fecha_pago, monto_pagado, cajero, estado_pago, aviso_id_aviso,
                          metodo_pago_id_metodo_pago, vuelto, caja_id_caja,
                          identificador_deuda, id_transaccion, url_pasarela, qr_url)
        VALUES (GETDATE(), @total, @cajero, 'PENDIENTE', @id_aviso,
                @id_metodo_qr, NULL, @id_caja,
                @identificador_deuda, @id_transaccion, @url_pasarela, @qr_url);

        SET @Resultado = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT;
        SET @Mensaje = 'QR generado. A la espera de la confirmacion del pago.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- 3. Obtener un pago QR por id_transaccion (para verificar el callback) -------
CREATE OR ALTER PROCEDURE dbo.sp_obtener_pago_qr
    @id_transaccion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.id_pago, p.identificador_deuda, p.id_transaccion, p.estado_pago,
           p.monto_pagado, p.aviso_id_aviso, p.caja_id_caja
    FROM pago p
    WHERE p.id_transaccion = @id_transaccion;
END
GO

-- 4. Confirmar pago QR (callback PAGO EXITOSO / conciliacion). Idempotente. ---
CREATE OR ALTER PROCEDURE dbo.sp_confirmar_pago_qr
    @id_transaccion    VARCHAR(100),
    @forma_pago        VARCHAR(60)   = NULL,
    @codigo_recaudacion VARCHAR(50)  = NULL,
    @Resultado         INT           OUTPUT,   -- id_pago confirmado (>0) | 0 error
    @Mensaje           NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        DECLARE @id_pago INT, @estado_pago VARCHAR(30), @id_aviso INT;
        SELECT @id_pago = id_pago, @estado_pago = estado_pago, @id_aviso = aviso_id_aviso
        FROM pago WHERE id_transaccion = @id_transaccion;

        IF @id_pago IS NULL
        BEGIN SET @Mensaje = 'Transaccion no encontrada.'; RETURN; END

        -- Idempotencia: reconfirmar no es un error
        IF @estado_pago = 'APROBADO'
        BEGIN SET @Resultado = @id_pago; SET @Mensaje = 'El pago ya estaba confirmado.'; RETURN; END

        IF @estado_pago <> 'PENDIENTE'
        BEGIN SET @Mensaje = 'El pago esta en estado ' + @estado_pago + ' y no puede confirmarse.'; RETURN; END

        DECLARE @estado_aviso VARCHAR(50) =
            (SELECT e.estado FROM aviso a
             INNER JOIN estado e ON e.id_estado = a.estado_id_estado
             WHERE a.id_aviso = @id_aviso);

        IF @estado_aviso IN ('PAGADO', 'ANULADO')
        BEGIN
            -- El aviso ya se cobro por otra via o fue anulado: este QR caduca.
            -- Si ademas llego dinero a la pasarela, requiere devolucion manual.
            UPDATE pago SET estado_pago = 'EXPIRADO' WHERE id_pago = @id_pago;
            SET @Mensaje = 'El aviso esta ' + @estado_aviso +
                           '; el QR quedo expirado y no se registro el cobro.';
            RETURN;
        END

        DECLARE @id_pagado INT = (SELECT id_estado FROM estado WHERE estado = 'PAGADO');
        DECLARE @socio_id INT, @periodo_id INT;
        SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo
        FROM aviso WHERE id_aviso = @id_aviso;

        -- Si la caja del cajero ya cerro (pago confirmado tarde o en background),
        -- el pago pasa a ser "online" (sin caja): no distorsiona un arqueo ya hecho.
        DECLARE @id_caja INT = (SELECT caja_id_caja FROM pago WHERE id_pago = @id_pago);
        IF @id_caja IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
            SET @id_caja = NULL;

        BEGIN TRAN;

        UPDATE pago
        SET estado_pago        = 'APROBADO',
            fecha_pago         = GETDATE(),
            forma_pago         = ISNULL(@forma_pago, forma_pago),
            codigo_recaudacion = ISNULL(@codigo_recaudacion, codigo_recaudacion),
            caja_id_caja       = @id_caja
        WHERE id_pago = @id_pago;

        UPDATE aviso SET estado_id_estado = @id_pagado WHERE id_aviso = @id_aviso;

        UPDATE cargo_extra SET estado = 'PAGADO'
        WHERE socio_id_socio = @socio_id AND periodo_id_periodo = @periodo_id
          AND estado = 'PENDIENTE';

        UPDATE credito_inscripcion SET estado = 'CANCELADO'
        WHERE socio_id_socio = @socio_id AND periodo_id_periodo = @periodo_id
          AND estado = 'PENDIENTE';

        COMMIT;

        -- RF-27: notificacion automatica al portal del socio (best-effort)
        EXEC dbo.sp_notificar_pago_confirmado @id_pago;

        SET @Resultado = @id_pago;
        SET @Mensaje   = 'Pago QR confirmado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- 5. Estado actual de un pago (polling desde la pantalla de cobro) ------------
CREATE OR ALTER PROCEDURE dbo.sp_estado_pago_qr
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_pago, estado_pago FROM pago WHERE id_pago = @id_pago;
END
GO

-- 6. Pagos QR pendientes (para conciliacion con Libelula) ---------------------
CREATE OR ALTER PROCEDURE dbo.sp_listar_pagos_qr_pendientes
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpieza: los QR pendientes de dias anteriores ya vencieron en Libelula
    -- (fecha_vencimiento = mismo dia), asi que aqui quedan EXPIRADO y dejan
    -- de consultarse en cada conciliacion.
    UPDATE pago SET estado_pago = 'EXPIRADO'
    WHERE estado_pago = 'PENDIENTE'
      AND id_transaccion IS NOT NULL
      AND CAST(fecha_pago AS DATE) < CAST(GETDATE() AS DATE);

    SELECT p.id_pago, p.identificador_deuda, p.id_transaccion,
           p.monto_pagado, p.fecha_pago, p.aviso_id_aviso
    FROM pago p
    WHERE p.estado_pago = 'PENDIENTE'
      AND p.id_transaccion IS NOT NULL
    ORDER BY p.id_pago;
END
GO
