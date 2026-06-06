
-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_listar_notificaciones
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
CREATE PROCEDURE dbo.sp_obtener_notificacion
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
CREATE PROCEDURE dbo.sp_registrar_notificacion
(
    @Titulo       VARCHAR(255),
    @Mensaje      VARCHAR(1000),
    @Tipo         VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

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
CREATE PROCEDURE dbo.sp_editar_notificacion
(
    @IdNotificacion INT,
    @Titulo         VARCHAR(255),
    @Mensaje        VARCHAR(1000),
    @Tipo           VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

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
CREATE PROCEDURE dbo.sp_eliminar_notificacion
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
CREATE PROCEDURE dbo.sp_asignar_notificacion_socios
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
CREATE PROCEDURE dbo.sp_listar_notificacion_socios
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


