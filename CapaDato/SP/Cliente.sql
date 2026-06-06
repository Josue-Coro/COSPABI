

-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_listar_clientes
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
    FROM cliente
    WHERE (@Busqueda = ''
           OR nombre_completo LIKE '%' + @Busqueda + '%'
           OR ci              LIKE '%' + @Busqueda + '%');

    SELECT
        id_cliente,
        nombre_completo,
        ci,
        genero,
        telefono,
        fecha_nacimiento,
        fecha_registro,
        estado
    FROM cliente
    WHERE (@Busqueda = ''
           OR nombre_completo LIKE '%' + @Busqueda + '%'
           OR ci              LIKE '%' + @Busqueda + '%')
    ORDER BY id_cliente DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_obtener_cliente
(
    @IdCliente INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_cliente,
        nombre_completo,
        ci,
        genero,
        telefono,
        fecha_nacimiento,
        fecha_registro,
        estado
    FROM cliente
    WHERE id_cliente = @IdCliente;
END
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_registrar_cliente
(
    @NombreCompleto  VARCHAR(250),
    @CI              VARCHAR(50),
    @Genero          VARCHAR(255),
    @Telefono        INTEGER,
    @FechaNacimiento DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cliente WHERE ci = @CI)
    BEGIN
        SELECT 0 AS Resultado, 'El CI ya está registrado.' AS Mensaje;
        RETURN;
    END

    INSERT INTO cliente (
        nombre_completo,
        ci,
        genero,
        telefono,
        fecha_nacimiento,
        fecha_registro,
        estado
    )
    VALUES (
        @NombreCompleto,
        @CI,
        @Genero,
        @Telefono,
        @FechaNacimiento,
        CAST(GETDATE() AS DATE),
        1
    );

    SELECT 1 AS Resultado, 'Cliente registrado correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_editar_cliente
(
    @IdCliente       INT,
    @NombreCompleto  VARCHAR(250),
    @CI              VARCHAR(50),
    @Genero          VARCHAR(255),
    @Telefono        INTEGER,
    @FechaNacimiento DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cliente WHERE ci = @CI AND id_cliente <> @IdCliente)
    BEGIN
        SELECT 0 AS Resultado, 'El CI ya está registrado en otro cliente.' AS Mensaje;
        RETURN;
    END

    UPDATE cliente SET
        nombre_completo  = @NombreCompleto,
        ci               = @CI,
        genero           = @Genero,
        telefono         = @Telefono,
        fecha_nacimiento = @FechaNacimiento
    WHERE id_cliente = @IdCliente;

    SELECT 1 AS Resultado, 'Cliente actualizado correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- CAMBIAR ESTADO
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_cambiar_estado_cliente
(
    @IdCliente INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE cliente
    SET estado = CASE WHEN estado = 1 THEN 0 ELSE 1 END
    WHERE id_cliente = @IdCliente;

    SELECT estado AS NuevoEstado FROM cliente WHERE id_cliente = @IdCliente;
END
GO