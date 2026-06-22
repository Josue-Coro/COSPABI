USE [COSPABIRL1]
GO

-- =============================================================================
-- Modulo CAJA  (estado: 1 = ABIERTA, 0 = CERRADA)
-- Una caja ABIERTA por cajero (respaldado por indice caja_cajero_abierta_UX).
-- monto_cobrado se calcula al cerrar = SUM(pagos APROBADO de la caja).
-- =============================================================================

-- 1. Abrir caja --------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_abrir_caja
    @id_usuario     INT,
    @monto_apertura DECIMAL(30,2),
    @Resultado      INT           OUTPUT,   -- id_caja nuevo (>0) | 0 error
    @Mensaje        NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM caja
                   WHERE usuario_admin_id_usuario_admin = @id_usuario AND estado = 1)
        BEGIN
            SET @Mensaje = 'Ya tiene una caja abierta. Ciérrela antes de abrir otra.';
            RETURN;
        END
        IF @monto_apertura < 0
        BEGIN
            SET @Mensaje = 'El monto de apertura no puede ser negativo.';
            RETURN;
        END

        INSERT INTO caja (fecha, hora_apertura, hora_cierre, monto_apertura,
                          monto_cobrado, usuario_admin_id_usuario_admin, estado)
        VALUES (CAST(GETDATE() AS DATE), GETDATE(), NULL, @monto_apertura,
                0, @id_usuario, 1);

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje   = 'Caja abierta correctamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- 2. Caja abierta del cajero (con total cobrado en vivo) ----------------------
CREATE OR ALTER PROCEDURE dbo.sp_caja_abierta
    @id_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1
        c.id_caja,
        c.fecha,
        c.hora_apertura,
        c.monto_apertura,
        c.estado,
        ISNULL((SELECT SUM(p.monto_pagado) FROM pago p
                WHERE p.caja_id_caja = c.id_caja AND p.estado_pago = 'APROBADO'), 0) AS total_cobrado,
        (SELECT COUNT(*) FROM pago p
                WHERE p.caja_id_caja = c.id_caja AND p.estado_pago = 'APROBADO')     AS num_pagos
    FROM caja c
    WHERE c.usuario_admin_id_usuario_admin = @id_usuario AND c.estado = 1;
END
GO

-- 3. Cerrar caja --------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_cerrar_caja
    @id_caja   INT,
    @Resultado INT           OUTPUT,   -- 1 ok | 0 error
    @Mensaje   NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja)
        BEGIN SET @Mensaje = 'Caja no encontrada.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'La caja ya está cerrada.'; RETURN; END

        DECLARE @total DECIMAL(30,2) =
            ISNULL((SELECT SUM(p.monto_pagado) FROM pago p
                    WHERE p.caja_id_caja = @id_caja AND p.estado_pago = 'APROBADO'), 0);

        UPDATE caja
        SET monto_cobrado = @total,
            hora_cierre   = GETDATE(),
            estado        = 0
        WHERE id_caja = @id_caja;

        SET @Resultado = 1;
        SET @Mensaje   = 'Caja cerrada correctamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- 4. Arqueo de una caja -------------------------------------------------------
--    Result set 1: cabecera (fondo, total, efectivo cobrado)
--    Result set 2: total por metodo de pago
CREATE OR ALTER PROCEDURE dbo.sp_arqueo_caja
    @id_caja INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id_caja, c.fecha, c.hora_apertura, c.hora_cierre, c.estado,
        c.monto_apertura,
        ISNULL((SELECT SUM(p.monto_pagado) FROM pago p
                WHERE p.caja_id_caja = c.id_caja AND p.estado_pago = 'APROBADO'), 0) AS total_cobrado,
        ISNULL((SELECT SUM(p.monto_pagado) FROM pago p
                INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
                WHERE p.caja_id_caja = c.id_caja AND p.estado_pago = 'APROBADO'
                  AND mp.metodo = 'Efectivo'), 0)                                    AS efectivo_cobrado
    FROM caja c
    WHERE c.id_caja = @id_caja;

    SELECT
        mp.metodo,
        SUM(p.monto_pagado) AS total,
        COUNT(*)            AS cantidad
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.caja_id_caja = @id_caja AND p.estado_pago = 'APROBADO'
    GROUP BY mp.metodo
    ORDER BY mp.metodo;
END
GO

-- 5. Historial de cajas del cajero (solo las suyas) ---------------------------
CREATE OR ALTER PROCEDURE dbo.sp_listar_cajas
    @id_usuario   INT,
    @Pagina       INT = 1,
    @TamanoPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        c.id_caja, c.fecha, c.hora_apertura, c.hora_cierre,
        c.monto_apertura, c.monto_cobrado, c.estado
    FROM caja c
    WHERE c.usuario_admin_id_usuario_admin = @id_usuario
    ORDER BY c.id_caja DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    SELECT COUNT(*) AS TotalRegistros
    FROM caja c
    WHERE c.usuario_admin_id_usuario_admin = @id_usuario;
END
GO

-- 6. Permiso ------------------------------------------------------------------
INSERT INTO permiso (accion, descripcion)
SELECT 'Gestionar Caja', 'Abrir, cerrar y consultar la caja del cajero'
WHERE NOT EXISTS (SELECT 1 FROM permiso WHERE accion = 'Gestionar Caja');
GO
