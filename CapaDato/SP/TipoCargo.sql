USE [COSPABIRL1]
GO

-- Listar
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_tipo_cargo]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [id_tipo], [nombre], [monto], [estado], [automatico]
    FROM [dbo].[tipo_cargo]
END
GO

-- Crear
CREATE OR ALTER PROCEDURE [dbo].[sp_crear_tipo_cargo]
    @nombre VARCHAR(150),
    @monto DECIMAL(30,3),
    @estado BIT,
    @automatico BIT = 0,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_cargo] WHERE nombre = @nombre)
    BEGIN
        INSERT INTO [dbo].[tipo_cargo] (nombre, monto, estado, automatico)
        VALUES (@nombre, @monto, @estado, @automatico);
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Tipo de cargo registrado correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un tipo de cargo con este nombre.';
END
GO

-- Editar
CREATE OR ALTER PROCEDURE [dbo].[sp_editar_tipo_cargo]
    @id_tipo INT,
    @nombre VARCHAR(150),
    @monto DECIMAL(30,3),
    @estado BIT,
    @automatico BIT = 0,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tipo_cargo] WHERE nombre = @nombre AND id_tipo <> @id_tipo)
    BEGIN
        UPDATE [dbo].[tipo_cargo]
        SET nombre = @nombre, monto = @monto, estado = @estado, automatico = @automatico
        WHERE id_tipo = @id_tipo;
        SET @Resultado = 1;
        SET @Mensaje = 'Tipo de cargo actualizado correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un tipo de cargo con este nombre.';
END
GO

-- Eliminar (soft delete)
CREATE OR ALTER PROCEDURE [dbo].[sp_eliminar_tipo_cargo]
    @id_tipo INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF EXISTS (SELECT 1 FROM [dbo].[tipo_cargo] WHERE id_tipo = @id_tipo)
    BEGIN
        UPDATE [dbo].[tipo_cargo]
        SET estado = 0
        WHERE id_tipo = @id_tipo;
        SET @Resultado = 1;
        SET @Mensaje = 'Tipo de cargo desactivado correctamente.';
    END
    ELSE
        SET @Mensaje = 'No existe un tipo de cargo con este ID.';
END
GO