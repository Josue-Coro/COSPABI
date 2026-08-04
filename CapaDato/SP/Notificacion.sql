
USE [COSPABIRL1]
GO

-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_listar_notificaciones
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT COUNT(*) AS TotalRegistros
    FROM notificacion
    WHERE (@Busqueda = ''
           OR titulo LIKE '%' + @Busqueda + '%'
           OR tipo LIKE '%' + @Busqueda + '%');

    SELECT
        id_notificacion,
        titulo,
        mensaje,
        tipo,
        fecha_publicacion,
        estado
    FROM notificacion
    WHERE (@Busqueda = ''
           OR titulo LIKE '%' + @Busqueda + '%'
           OR tipo LIKE '%' + @Busqueda + '%')
    ORDER BY id_notificacion DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_obtener_notificacion
(
    @IdNotificacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_notificacion,
        titulo,
        mensaje,
        tipo,
        fecha_publicacion,
        estado
    FROM notificacion
    WHERE id_notificacion = @IdNotificacion;
END
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_registrar_notificacion
(
    @Titulo       VARCHAR(255),
    @Mensaje      VARCHAR(1000),
    @Tipo         VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- No permitir una notificación duplicada (mismo título y mensaje)
    IF EXISTS (SELECT 1 FROM notificacion
               WHERE LTRIM(RTRIM(titulo))  = LTRIM(RTRIM(@Titulo))
                 AND LTRIM(RTRIM(mensaje)) = LTRIM(RTRIM(@Mensaje)))
    BEGIN
        SELECT 0 AS IdGenerado, 0 AS Resultado, 'Ya existe una notificación con el mismo título y mensaje.' AS Mensaje;
        RETURN;
    END

    INSERT INTO notificacion (
        titulo,
        mensaje,
        tipo,
        fecha_publicacion,
        estado
    )
    VALUES (
        @Titulo,
        @Mensaje,
        @Tipo,
        CAST(GETDATE() AS DATE),
        1
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS IdGenerado, 1 AS Resultado, 'Notificacion registrada correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_editar_notificacion
(
    @IdNotificacion INT,
    @Titulo         VARCHAR(255),
    @Mensaje        VARCHAR(1000),
    @Tipo           VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM notificacion WHERE id_notificacion = @IdNotificacion)
    BEGIN
        SELECT 0 AS Resultado, 'La notificación no existe.' AS Mensaje;
        RETURN;
    END

    -- No permitir duplicar OTRA notificación (mismo título y mensaje)
    IF EXISTS (SELECT 1 FROM notificacion
               WHERE LTRIM(RTRIM(titulo))  = LTRIM(RTRIM(@Titulo))
                 AND LTRIM(RTRIM(mensaje)) = LTRIM(RTRIM(@Mensaje))
                 AND id_notificacion <> @IdNotificacion)
    BEGIN
        SELECT 0 AS Resultado, 'Ya existe otra notificación con el mismo título y mensaje.' AS Mensaje;
        RETURN;
    END

    UPDATE notificacion SET
        titulo  = @Titulo,
        mensaje = @Mensaje,
        tipo    = @Tipo
    WHERE id_notificacion = @IdNotificacion;

    SELECT 1 AS Resultado, 'Notificacion actualizada correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- ELIMINAR (Fisico con validacion)
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_eliminar_notificacion
(
    @IdNotificacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM notificacion_socio WHERE notificacion_id_notificacion = @IdNotificacion)
    BEGIN
        SELECT 0 AS Resultado, 'La notificacion ya esta en uso (asignada a uno o mas socios).' AS Mensaje;
        RETURN;
    END

    DELETE FROM notificacion
    WHERE id_notificacion = @IdNotificacion;

    SELECT 1 AS Resultado, 'Notificacion eliminada correctamente.' AS Mensaje;
END
GO












-- ══════════════════════════════════════════
-- ASIGNAR SOCIOS a una notificacion
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_asignar_notificacion_socios
(
    @IdNotificacion INT,
    @EnviarATodos   BIT          = 0,
    @IdsSocios      VARCHAR(MAX) = ''
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar asignaciones previas
    DELETE FROM notificacion_socio
    WHERE notificacion_id_notificacion = @IdNotificacion;

    IF @EnviarATodos = 1
    BEGIN
        INSERT INTO notificacion_socio (fecha_lectura, leido, notificacion_id_notificacion, socio_id_socio)
        SELECT CAST(GETDATE() AS DATE), 0, @IdNotificacion, id_socio
        FROM socio;
    END
    ELSE
    BEGIN
        INSERT INTO notificacion_socio (fecha_lectura, leido, notificacion_id_notificacion, socio_id_socio)
        SELECT CAST(GETDATE() AS DATE), 0, @IdNotificacion, CAST(value AS INT)
        FROM STRING_SPLIT(@IdsSocios, ',')
        WHERE RTRIM(LTRIM(value)) <> '';
    END

    SELECT 1 AS Resultado, 'Socios asignados correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- LISTAR SOCIOS asignados a una notificacion
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_listar_notificacion_socios
(
    @IdNotificacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ns.id_notificacion_socio,
        ns.socio_id_socio,
        s.nombre_socio,
        s.codigo_fijo
    FROM notificacion_socio ns
    INNER JOIN socio s ON s.id_socio = ns.socio_id_socio
    WHERE ns.notificacion_id_notificacion = @IdNotificacion;
END
GO



-- ══════════════════════════════════════════════════════════════════
-- RF-27: Notificaciones AUTOMATICAS al portal del socio
-- ══════════════════════════════════════════════════════════════════

-- Confirmacion de pago: se invoca desde sp_registrar_pago_aviso y
-- sp_confirmar_pago_qr (despues del COMMIT; si falla no afecta el cobro).
CREATE OR ALTER PROCEDURE dbo.sp_notificar_pago_confirmado
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @id_socio INT, @monto DECIMAL(30,2), @periodo VARCHAR(50), @id_aviso INT;
        SELECT @id_socio = a.socio_id_socio, @monto = p.monto_pagado,
               @periodo = per.periodo, @id_aviso = a.id_aviso
        FROM pago p
        INNER JOIN aviso a     ON a.id_aviso    = p.aviso_id_aviso
        INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
        WHERE p.id_pago = @id_pago;

        IF @id_socio IS NULL RETURN;   -- pago sin aviso (inscripcion): sin notificacion

        DECLARE @id_notif INT;
        INSERT INTO notificacion (titulo, mensaje, tipo, fecha_publicacion, estado)
        VALUES ('Pago confirmado',
                'Tu pago de Bs. ' + CONVERT(VARCHAR, @monto) +
                ' del aviso del periodo ' + @periodo +
                ' fue registrado correctamente. [Aviso #' + CAST(@id_aviso AS VARCHAR) + ']',
                'Pago', CAST(GETDATE() AS DATE), 1);
        SET @id_notif = CAST(SCOPE_IDENTITY() AS INT);

        INSERT INTO notificacion_socio (fecha_lectura, leido, notificacion_id_notificacion, socio_id_socio)
        VALUES (CAST(GETDATE() AS DATE), 0, @id_notif, @id_socio);
    END TRY
    BEGIN CATCH
        -- best-effort: una notificacion fallida nunca debe romper un cobro
    END CATCH
END
GO

-- Recordatorios de vencimiento: un aviso no pagado que vence dentro de
-- @DiasAntes dias genera UNA notificacion al socio (no se repite: se
-- detecta por la marca [Aviso #id] con tipo 'Vencimiento').
CREATE OR ALTER PROCEDURE dbo.sp_generar_notificaciones_vencimiento
    @DiasAntes INT           = 3,
    @Resultado INT           OUTPUT,   -- cantidad de recordatorios generados
    @Mensaje   NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

        DECLARE @porVencer TABLE (id_aviso INT, id_socio INT, periodo VARCHAR(50),
                                  vence DATE, deuda DECIMAL(30,2));
        INSERT INTO @porVencer
        SELECT a.id_aviso, a.socio_id_socio, per.periodo, a.fecha_vencimiento, a.deuda_actual
        FROM aviso a
        INNER JOIN estado  e   ON e.id_estado    = a.estado_id_estado
        INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
        WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
          AND a.fecha_vencimiento BETWEEN @hoy AND DATEADD(DAY, @DiasAntes, @hoy)
          AND NOT EXISTS (SELECT 1 FROM notificacion n
                          WHERE n.tipo = 'Vencimiento'
                            AND n.mensaje LIKE '%[[]Aviso #' + CAST(a.id_aviso AS VARCHAR) + ']%');

        DECLARE @id_aviso INT, @id_socio INT, @periodo VARCHAR(50),
                @vence DATE, @deuda DECIMAL(30,2), @id_notif INT;
        DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT id_aviso, id_socio, periodo, vence, deuda FROM @porVencer;
        OPEN cur;
        FETCH NEXT FROM cur INTO @id_aviso, @id_socio, @periodo, @vence, @deuda;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO notificacion (titulo, mensaje, tipo, fecha_publicacion, estado)
            VALUES ('Aviso proximo a vencer',
                    'Tu aviso del periodo ' + @periodo + ' vence el ' +
                    CONVERT(VARCHAR, @vence, 103) + '. Deuda: Bs. ' +
                    CONVERT(VARCHAR, @deuda) + '. [Aviso #' + CAST(@id_aviso AS VARCHAR) + ']',
                    'Vencimiento', @hoy, 1);
            SET @id_notif = CAST(SCOPE_IDENTITY() AS INT);

            INSERT INTO notificacion_socio (fecha_lectura, leido, notificacion_id_notificacion, socio_id_socio)
            VALUES (@hoy, 0, @id_notif, @id_socio);

            SET @Resultado = @Resultado + 1;
            FETCH NEXT FROM cur INTO @id_aviso, @id_socio, @periodo, @vence, @deuda;
        END
        CLOSE cur; DEALLOCATE cur;

        SET @Mensaje = CAST(@Resultado AS VARCHAR) + ' recordatorio(s) de vencimiento generado(s).';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
