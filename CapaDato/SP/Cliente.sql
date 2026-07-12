USE [COSPABIRL1]
GO

-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_listar_clientes
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
        email,
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
-- LISTAR PERSONAS DISPONIBLES PARA SOCIO
-- Regla institucional: una persona puede tener como máximo 4 socios
-- (4 medidores). Excluye a quienes ya alcanzaron ese tope.
-- Mismo shape que sp_listar_clientes (total + datos) para reusar el mapeo.
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_listar_personas_disponibles_socio
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset    INT = (@Pagina - 1) * @TamanoPagina;
    DECLARE @MaxSocios INT = 4;

    SELECT COUNT(*) AS TotalRegistros
    FROM cliente c
    WHERE (@Busqueda = ''
           OR c.nombre_completo LIKE '%' + @Busqueda + '%'
           OR c.ci              LIKE '%' + @Busqueda + '%')
      AND (SELECT COUNT(*) FROM socio s WHERE s.cliente_id_cliente = c.id_cliente) < @MaxSocios;

    SELECT
        c.id_cliente,
        c.nombre_completo,
        c.ci,
        c.genero,
        c.telefono,
        c.email,
        c.fecha_nacimiento,
        c.fecha_registro,
        c.estado
    FROM cliente c
    WHERE (@Busqueda = ''
           OR c.nombre_completo LIKE '%' + @Busqueda + '%'
           OR c.ci              LIKE '%' + @Busqueda + '%')
      AND (SELECT COUNT(*) FROM socio s WHERE s.cliente_id_cliente = c.id_cliente) < @MaxSocios
    ORDER BY c.id_cliente DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_obtener_cliente
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
        email,
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
CREATE OR ALTER PROCEDURE dbo.sp_registrar_cliente
(
    @NombreCompleto  VARCHAR(250),
    @CI              VARCHAR(50),
    @Genero          VARCHAR(255),
    @Telefono        INTEGER,
    @Email           VARCHAR(150),
    @FechaNacimiento DATE,
    @Resultado       INT          OUTPUT,
    @Mensaje         VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cliente WHERE ci = @CI)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El CI ya está registrado.';
        RETURN;
    END

    -- Email único (se usa como referencia para pagos QR)
    IF EXISTS (SELECT 1 FROM cliente WHERE LTRIM(RTRIM(email)) = LTRIM(RTRIM(@Email)))
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El email ya está registrado en otro cliente.';
        RETURN;
    END

    INSERT INTO cliente (
        nombre_completo,
        ci,
        genero,
        telefono,
        email,
        fecha_nacimiento,
        fecha_registro,
        estado
    )
    VALUES (
        @NombreCompleto,
        @CI,
        @Genero,
        @Telefono,
        @Email,
        @FechaNacimiento,
        CAST(GETDATE() AS DATE),
        1
    );

    SET @Resultado = 1;
    SET @Mensaje   = 'Cliente registrado correctamente.';
END
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_editar_cliente
(
    @IdCliente       INT,
    @NombreCompleto  VARCHAR(250),
    @CI              VARCHAR(50),
    @Genero          VARCHAR(255),
    @Telefono        INTEGER,
    @Email           VARCHAR(150),
    @FechaNacimiento DATE,
    @Resultado       INT          OUTPUT,
    @Mensaje         VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cliente WHERE ci = @CI AND id_cliente <> @IdCliente)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El CI ya está registrado en otro cliente.';
        RETURN;
    END

    -- Email único en OTRO cliente (se usa como referencia para pagos QR)
    IF EXISTS (SELECT 1 FROM cliente
               WHERE LTRIM(RTRIM(email)) = LTRIM(RTRIM(@Email))
                 AND id_cliente <> @IdCliente)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El email ya está registrado en otro cliente.';
        RETURN;
    END

    UPDATE cliente SET
        nombre_completo  = @NombreCompleto,
        ci               = @CI,
        genero           = @Genero,
        telefono         = @Telefono,
        email            = @Email,
        fecha_nacimiento = @FechaNacimiento
    WHERE id_cliente = @IdCliente;

    SET @Resultado = 1;
    SET @Mensaje   = 'Cliente actualizado correctamente.';
END
GO

-- ══════════════════════════════════════════
-- CAMBIAR ESTADO
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_cambiar_estado_cliente
(
    @IdCliente INT,
    @Resultado INT          OUTPUT,
    @Mensaje   VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = @IdCliente)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El cliente no existe.';
        RETURN;
    END

    UPDATE cliente
    SET estado = CASE WHEN estado = 1 THEN 0 ELSE 1 END
    WHERE id_cliente = @IdCliente;

    SET @Resultado = 1;
    SET @Mensaje   = 'Estado actualizado correctamente.';
END
GO