USE [COSPABIRL1]
GO

-- =============================================================================
-- Modulo PAGO (cobro manual de avisos; SIN pasarela/QR por ahora).
-- Pago COMPLETO: un pago salda el aviso. estado_pago = 'APROBADO' al instante.
-- Requiere una caja ABIERTA. Cierra el ciclo: aviso->PAGADO, cargos->PAGADO,
-- cuotas de credito->CANCELADO.
-- =============================================================================

-- 1. Avisos por cobrar (no PAGADO ni ANULADO) --------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_listar_avisos_por_cobrar
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        a.id_aviso,
        a.total_aviso,
        a.deuda_actual,
        e.estado AS estado,
        a.fecha_emision,
        a.fecha_vencimiento,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo AS nombre_periodo
    FROM aviso a
    INNER JOIN socio   s ON s.id_socio   = a.socio_id_socio
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND (@Busqueda = ''
           OR s.nombre_socio LIKE '%' + @Busqueda + '%'
           OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%')
    ORDER BY a.id_aviso DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    SELECT COUNT(*) AS TotalRegistros
    FROM aviso a
    INNER JOIN socio s ON s.id_socio = a.socio_id_socio
    INNER JOIN estado e ON e.id_estado = a.estado_id_estado
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND (@Busqueda = ''
           OR s.nombre_socio LIKE '%' + @Busqueda + '%'
           OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%');
END
GO

-- 2. Registrar pago de un aviso (manual, completo) ---------------------------
CREATE OR ALTER PROCEDURE dbo.sp_registrar_pago_aviso
    @id_aviso       INT,
    @id_caja        INT,
    @id_metodo_pago INT,
    @monto_recibido DECIMAL(30,2) = NULL,   -- efectivo entregado (para vuelto). NULL = exacto
    @cajero         VARCHAR(150),
    @Resultado      INT           OUTPUT,    -- id_pago generado (>0) | 0 error
    @Mensaje        NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'No hay una caja abierta valida. Abra su caja primero.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM metodo_pago WHERE id_metodo_pago = @id_metodo_pago)
        BEGIN SET @Mensaje = 'Metodo de pago invalido.'; RETURN; END

        DECLARE @total DECIMAL(30,2), @estado VARCHAR(50);
        SELECT @total = a.total_aviso, @estado = e.estado 
        FROM aviso a
        INNER JOIN estado e ON e.id_estado = a.estado_id_estado
        WHERE a.id_aviso = @id_aviso;

        IF @total IS NULL BEGIN SET @Mensaje = 'Aviso no encontrado.'; RETURN; END
        IF @estado = 'PAGADO'  BEGIN SET @Mensaje = 'El aviso ya esta pagado.'; RETURN; END
        IF @estado = 'ANULADO' BEGIN SET @Mensaje = 'El aviso esta anulado.'; RETURN; END

        DECLARE @recibido DECIMAL(30,2) = ISNULL(@monto_recibido, @total);
        IF @recibido < @total
        BEGIN SET @Mensaje = 'El monto recibido es menor al total del aviso (el pago es completo).'; RETURN; END
        DECLARE @vuelto DECIMAL(30,3) = @recibido - @total;

        DECLARE @id_pagado INT = (SELECT id_estado FROM estado WHERE estado = 'PAGADO');

        BEGIN TRAN;

        -- Si habia un QR pendiente para este aviso, caduca (se cobro en efectivo)
        UPDATE pago SET estado_pago = 'EXPIRADO'
        WHERE aviso_id_aviso = @id_aviso
          AND estado_pago    = 'PENDIENTE'
          AND id_transaccion IS NOT NULL;

        INSERT INTO pago (fecha_pago, monto_pagado, cajero, estado_pago, aviso_id_aviso,
                          metodo_pago_id_metodo_pago, vuelto, caja_id_caja)
        VALUES (GETDATE(), @total, @cajero, 'APROBADO', @id_aviso,
                @id_metodo_pago, @vuelto, @id_caja);

        DECLARE @id_pago INT = CAST(SCOPE_IDENTITY() AS INT);

        UPDATE aviso
        SET estado_id_estado = @id_pagado
        WHERE id_aviso = @id_aviso;

        -- obtener socio y periodo para cerrar ciclo
        DECLARE @socio_id INT, @periodo_id INT;
        SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo 
        FROM aviso 
        WHERE id_aviso = @id_aviso;

        -- cerrar el ciclo
        UPDATE cargo_extra
        SET estado = 'PAGADO'
        WHERE socio_id_socio = @socio_id 
          AND periodo_id_periodo = @periodo_id 
          AND estado = 'PENDIENTE';

        UPDATE credito_inscripcion
        SET estado = 'CANCELADO'
        WHERE socio_id_socio = @socio_id 
          AND periodo_id_periodo = @periodo_id 
          AND estado = 'PENDIENTE';

        COMMIT;

        -- RF-27: notificacion automatica al portal del socio (best-effort)
        EXEC dbo.sp_notificar_pago_confirmado @id_pago;

        SET @Resultado = @id_pago;
        SET @Mensaje   = 'Pago registrado correctamente. Vuelto: Bs. ' + CONVERT(VARCHAR, CAST(@vuelto AS DECIMAL(30,2)));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- 3. Pagos registrados en una caja (para la sesion del cajero) ---------------
CREATE OR ALTER PROCEDURE dbo.sp_listar_pagos_caja
    @id_caja INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.id_pago,
        p.fecha_pago,
        p.monto_pagado,
        p.vuelto,
        p.estado_pago,
        mp.metodo        AS nombre_metodo,
        p.aviso_id_aviso,
        s.nombre_socio,
        s.codigo_fijo
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN aviso a ON a.id_aviso = p.aviso_id_aviso
    LEFT  JOIN socio s ON s.id_socio = a.socio_id_socio
    WHERE p.caja_id_caja = @id_caja
    ORDER BY p.id_pago DESC;
END
GO

-- 4. Permiso ------------------------------------------------------------------
INSERT INTO permiso (accion, descripcion)
SELECT 'Gestionar Pago', 'Cobrar avisos y registrar pagos en caja'
WHERE NOT EXISTS (SELECT 1 FROM permiso WHERE accion = 'Gestionar Pago');
GO

-- 5. Obtener recibo de pago ----------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_recibo_pago_aviso
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Cabecera del recibo
    SELECT 
        p.id_pago,
        p.fecha_pago,
        s.nombre_socio,
        s.codigo_fijo,
        per.periodo AS nombre_periodo,
        l.consumo_m3 AS consumo,
        a.total_consumo,
        p.monto_pagado AS total_pagado,
        p.vuelto,
        p.cajero,
        mp.metodo AS metodo_pago,
        s.categoria,
        r.ruta AS nombre_ruta,
        s.ubicacion
    FROM pago p
    INNER JOIN aviso a ON a.id_aviso = p.aviso_id_aviso
    INNER JOIN socio s ON s.id_socio = a.socio_id_socio
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT JOIN lectura l ON l.id_lectura = a.lectura_id_lectura
    LEFT JOIN ruta r ON r.id_ruta = s.ruta_id_ruta
    LEFT JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.id_pago = @id_pago;

    -- 2. Detalles del recibo (Concepto, Subtotal)
    DECLARE @id_aviso INT = (SELECT aviso_id_aviso FROM pago WHERE id_pago = @id_pago);
    DECLARE @total_consumo DECIMAL(30,2) = (SELECT total_consumo FROM aviso WHERE id_aviso = @id_aviso);

    CREATE TABLE #Detalle (
        concepto VARCHAR(255),
        subtotal DECIMAL(30,2)
    );

    IF @total_consumo > 0
    BEGIN
        INSERT INTO #Detalle (concepto, subtotal) VALUES ('Consumo Agua', @total_consumo);
    END

    DECLARE @socio_id_rec INT, @periodo_id_rec INT;
    SELECT @socio_id_rec = socio_id_socio, @periodo_id_rec = periodo_id_periodo 
    FROM aviso 
    WHERE id_aviso = @id_aviso;

    INSERT INTO #Detalle (concepto, subtotal)
    SELECT descripcion AS concepto, monto 
    FROM cargo_extra 
    WHERE socio_id_socio = @socio_id_rec 
      AND periodo_id_periodo = @periodo_id_rec;

    INSERT INTO #Detalle (concepto, subtotal)
    SELECT 'Cuota de Inscripción (' + CAST(num_cuota AS VARCHAR) + ')', monto_pago
    FROM credito_inscripcion 
    WHERE socio_id_socio = @socio_id_rec 
      AND periodo_id_periodo = @periodo_id_rec;

    SELECT concepto, subtotal FROM #Detalle;
    DROP TABLE #Detalle;
END
GO
