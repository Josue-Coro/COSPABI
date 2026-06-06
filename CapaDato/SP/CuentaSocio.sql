
-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_listar_cuenta_socio
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
    FROM cuenta_socio cs
    INNER JOIN socio s ON cs.socio_id_socio = s.id_socio
    WHERE (@Busqueda = ''
           OR cs.usuario LIKE '%' + @Busqueda + '%'
           OR s.nombre_socio LIKE '%' + @Busqueda + '%');

    SELECT
        cs.id_cuenta_socio,
        cs.usuario,
        cs.ultimo_acceso,
        cs.estado,
        cs.socio_id_socio,
        s.nombre_socio as nombre_socio
    FROM cuenta_socio cs
    INNER JOIN socio s ON cs.socio_id_socio = s.id_socio
    WHERE (@Busqueda = ''
           OR cs.usuario LIKE '%' + @Busqueda + '%'
           OR s.nombre_socio LIKE '%' + @Busqueda + '%')
    ORDER BY cs.id_cuenta_socio DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_obtener_cuenta_socio
(
    @IdCuentaSocio INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_cuenta_socio,
        usuario,
        ultimo_acceso,
        estado,
        socio_id_socio
    FROM cuenta_socio
    WHERE id_cuenta_socio = @IdCuentaSocio;
END
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_registrar_cuenta_socio
(
    @Usuario        VARCHAR(150),
    @Contrasena     VARCHAR(500),
    @IdSocio        INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cuenta_socio WHERE usuario = @Usuario)
    BEGIN
        SELECT 0 AS Resultado, 'El nombre de usuario ya está registrado.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM cuenta_socio WHERE socio_id_socio = @IdSocio)
    BEGIN
        SELECT 0 AS Resultado, 'El socio ya tiene una cuenta asignada.' AS Mensaje;
        RETURN;
    END

    INSERT INTO cuenta_socio (
        usuario,
        contraseña,
        ultimo_acceso,
        estado,
        socio_id_socio
    )
    VALUES (
        @Usuario,
        CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Contrasena), 2),
        GETDATE(),
        1,
        @IdSocio
    );

    SELECT 1 AS Resultado, 'Cuenta de socio registrada correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_editar_cuenta_socio
(
    @IdCuentaSocio  INT,
    @Usuario        VARCHAR(150),
    @Contrasena     VARCHAR(500) = '', -- Si viene vacio no se actualiza
    @IdSocio        INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cuenta_socio WHERE usuario = @Usuario AND id_cuenta_socio <> @IdCuentaSocio)
    BEGIN
        SELECT 0 AS Resultado, 'El nombre de usuario ya está en uso por otra cuenta.' AS Mensaje;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM cuenta_socio WHERE socio_id_socio = @IdSocio AND id_cuenta_socio <> @IdCuentaSocio)
    BEGIN
        SELECT 0 AS Resultado, 'El socio ya tiene una cuenta asignada diferente.' AS Mensaje;
        RETURN;
    END

    IF (@Contrasena <> '')
    BEGIN
        UPDATE cuenta_socio SET
            usuario        = @Usuario,
            contraseña     = CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Contrasena), 2),
            socio_id_socio = @IdSocio
        WHERE id_cuenta_socio = @IdCuentaSocio;
    END
    ELSE
    BEGIN
        UPDATE cuenta_socio SET
            usuario        = @Usuario,
            socio_id_socio = @IdSocio
        WHERE id_cuenta_socio = @IdCuentaSocio;
    END

    SELECT 1 AS Resultado, 'Cuenta actualizada correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- CAMBIAR ESTADO
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_cambiar_estado_cuenta_socio
(
    @IdCuentaSocio INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE cuenta_socio
    SET estado = CASE WHEN estado = 1 THEN 0 ELSE 1 END
    WHERE id_cuenta_socio = @IdCuentaSocio;

    SELECT estado AS NuevoEstado FROM cuenta_socio WHERE id_cuenta_socio = @IdCuentaSocio;
END
GO
