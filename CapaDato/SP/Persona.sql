USE [COSPABIRL1]
GO

-- =============================================================================
-- PERSONA: datos de identidad (CI, nombre, nacimiento, genero, telefono).
-- 'socio' es la afiliacion construida sobre una persona (hasta 4 por persona).
-- El correo NO vive aqui: es del socio (quien usa el medidor, paga por QR y
-- entra al portal), ver Migracion 17.
-- Reemplaza a Cliente.sql (sp_*_cliente), eliminados en la Migracion 17.
-- =============================================================================

-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_listar_personas
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
    FROM persona
    WHERE (@Busqueda = ''
           OR nombre_completo LIKE '%' + @Busqueda + '%'
           OR ci              LIKE '%' + @Busqueda + '%');

    SELECT
        id_persona,
        nombre_completo,
        ci,
        genero,
        telefono,
        fecha_nacimiento,
        fecha_registro,
        estado
    FROM persona
    WHERE (@Busqueda = ''
           OR nombre_completo LIKE '%' + @Busqueda + '%'
           OR ci              LIKE '%' + @Busqueda + '%')
    ORDER BY id_persona DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO

-- ══════════════════════════════════════════
-- LISTAR PERSONAS DISPONIBLES PARA SOCIO
-- Regla institucional: una persona puede tener como máximo 4 socios
-- (4 medidores). Excluye a quienes ya alcanzaron ese tope.
-- Mismo shape que sp_listar_personas (total + datos) para reusar el mapeo.
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
    FROM persona p
    WHERE (@Busqueda = ''
           OR p.nombre_completo LIKE '%' + @Busqueda + '%'
           OR p.ci              LIKE '%' + @Busqueda + '%')
      AND (SELECT COUNT(*) FROM socio s WHERE s.persona_id_persona = p.id_persona) < @MaxSocios;

    SELECT
        p.id_persona,
        p.nombre_completo,
        p.ci,
        p.genero,
        p.telefono,
        p.fecha_nacimiento,
        p.fecha_registro,
        p.estado
    FROM persona p
    WHERE (@Busqueda = ''
           OR p.nombre_completo LIKE '%' + @Busqueda + '%'
           OR p.ci              LIKE '%' + @Busqueda + '%')
      AND (SELECT COUNT(*) FROM socio s WHERE s.persona_id_persona = p.id_persona) < @MaxSocios
    ORDER BY p.id_persona DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_obtener_persona
(
    @IdPersona INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_persona,
        nombre_completo,
        ci,
        genero,
        telefono,
        fecha_nacimiento,
        fecha_registro,
        estado
    FROM persona
    WHERE id_persona = @IdPersona;
END
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_registrar_persona
(
    @NombreCompleto  VARCHAR(250),
    @CI              VARCHAR(50),
    @Genero          VARCHAR(255),
    @Telefono        INTEGER,
    @FechaNacimiento DATE,
    @Resultado       INT          OUTPUT,
    @Mensaje         VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM persona WHERE ci = @CI)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El CI ya está registrado.';
        RETURN;
    END

    INSERT INTO persona (
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

    SET @Resultado = 1;
    SET @Mensaje   = 'Persona registrada correctamente.';
END
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_editar_persona
(
    @IdPersona       INT,
    @NombreCompleto  VARCHAR(250),
    @CI              VARCHAR(50),
    @Genero          VARCHAR(255),
    @Telefono        INTEGER,
    @FechaNacimiento DATE,
    @Resultado       INT          OUTPUT,
    @Mensaje         VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM persona WHERE id_persona = @IdPersona)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'La persona no existe.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM persona WHERE ci = @CI AND id_persona <> @IdPersona)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'El CI ya está registrado en otra persona.';
        RETURN;
    END

    UPDATE persona SET
        nombre_completo  = @NombreCompleto,
        ci               = @CI,
        genero           = @Genero,
        telefono         = @Telefono,
        fecha_nacimiento = @FechaNacimiento
    WHERE id_persona = @IdPersona;

    SET @Resultado = 1;
    SET @Mensaje   = 'Persona actualizada correctamente.';
END
GO

-- ══════════════════════════════════════════
-- CAMBIAR ESTADO
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_cambiar_estado_persona
(
    @IdPersona INT,
    @Resultado INT          OUTPUT,
    @Mensaje   VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM persona WHERE id_persona = @IdPersona)
    BEGIN
        SET @Resultado = 0;
        SET @Mensaje   = 'La persona no existe.';
        RETURN;
    END

    UPDATE persona
    SET estado = CASE WHEN estado = 1 THEN 0 ELSE 1 END
    WHERE id_persona = @IdPersona;

    SET @Resultado = 1;
    SET @Mensaje   = 'Estado actualizado correctamente.';
END
GO
