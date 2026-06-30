USE [COSPABIRL1]
GO

-- =============================================
-- 1. sp_registrar_cargo_extra
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_registrar_cargo_extra
    @id_periodo    INT,
    @id_socio      INT,
    @id_tipo_cargo INT,
    @monto         DECIMAL(30,2),
    @descripcion   VARCHAR(150),
    @Resultado     INT          OUTPUT,
    @Mensaje       VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM socio WHERE id_socio = @id_socio)
        BEGIN
            SET @Mensaje = 'El socio no existe.';
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM cargo_extra
            WHERE socio_id_socio      = @id_socio
              AND periodo_id_periodo  = @id_periodo
              AND tipo_cargo_id_tipo  = @id_tipo_cargo
              AND estado              = 'PENDIENTE'
        )
        BEGIN
            SET @Mensaje = 'Ya existe un cargo pendiente de este tipo para el socio en el periodo seleccionado.';
            RETURN;
        END

        INSERT INTO cargo_extra
            (monto, descripcion, fecha_registro, estado, tipo_cargo_id_tipo, socio_id_socio, periodo_id_periodo)
        VALUES
            (@monto, @descripcion, CAST(GETDATE() AS DATE), 'PENDIENTE', @id_tipo_cargo, @id_socio, @id_periodo);

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje   = 'Cargo extra registrado correctamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- 2. sp_listar_cargos_extra
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_listar_cargos_extra
    @id_periodo   INT           = NULL,
    @id_ruta      INT           = NULL,
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        ce.id_cargo_extra,
        ce.monto,
        ce.descripcion,
        ce.fecha_registro,
        ce.estado,
        ce.tipo_cargo_id_tipo,
        ce.socio_id_socio,
        ce.periodo_id_periodo,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo                                                                    AS nombre_periodo,
        t.nombre                                                                     AS nombre_tipo_cargo,
        r.ruta                                                                       AS nombre_ruta,
        CASE WHEN EXISTS (
            SELECT 1 FROM aviso a
            WHERE a.socio_id_socio = ce.socio_id_socio
              AND a.periodo_id_periodo = ce.periodo_id_periodo
              AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
        ) THEN 1 ELSE 0 END                                                          AS aplicado
    FROM cargo_extra ce
    INNER JOIN socio    s ON s.id_socio   = ce.socio_id_socio
    INNER JOIN periodo  p ON p.id_periodo = ce.periodo_id_periodo
    INNER JOIN tipo_cargo t ON t.id_tipo  = ce.tipo_cargo_id_tipo
    INNER JOIN ruta     r ON r.id_ruta    = s.ruta_id_ruta
    WHERE
        (@id_periodo IS NULL OR ce.periodo_id_periodo = @id_periodo)
        AND (@id_ruta   IS NULL OR s.ruta_id_ruta     = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        )
    ORDER BY ce.id_cargo_extra DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- Total para paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM cargo_extra ce
    INNER JOIN socio s ON s.id_socio = ce.socio_id_socio
    WHERE
        (@id_periodo IS NULL OR ce.periodo_id_periodo = @id_periodo)
        AND (@id_ruta   IS NULL OR s.ruta_id_ruta     = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        );
END
GO

-- =============================================
-- 3. sp_anular_cargo_extra
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_anular_cargo_extra
    @id_cargo_extra INT,
    @Resultado      INT          OUTPUT,
    @Mensaje        VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM cargo_extra WHERE id_cargo_extra = @id_cargo_extra)
        BEGIN
            SET @Mensaje = 'El cargo no existe.';
            RETURN;
        END

        -- El cargo está aplicado si existe un aviso no anulado para el mismo socio y periodo
        IF EXISTS (
            SELECT 1 FROM aviso a
            INNER JOIN cargo_extra ce ON ce.socio_id_socio = a.socio_id_socio AND ce.periodo_id_periodo = a.periodo_id_periodo
            WHERE ce.id_cargo_extra = @id_cargo_extra
              AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
        )
        BEGIN
            SET @Mensaje = 'El cargo ya fue aplicado a un aviso y no puede anularse.';
            RETURN;
        END

        DECLARE @estadoActual VARCHAR(150);
        SELECT @estadoActual = estado FROM cargo_extra WHERE id_cargo_extra = @id_cargo_extra;

        IF @estadoActual != 'PENDIENTE'
        BEGIN
            SET @Mensaje = 'Solo se pueden anular cargos en estado PENDIENTE.';
            RETURN;
        END

        UPDATE cargo_extra SET estado = 'ANULADO' WHERE id_cargo_extra = @id_cargo_extra;

        SET @Resultado = 1;
        SET @Mensaje   = 'Cargo anulado correctamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO
