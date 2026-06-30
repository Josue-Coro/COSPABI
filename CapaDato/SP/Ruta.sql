USE [COSPABIRL1]
-- Listar rutas
CREATE PROCEDURE [dbo].[sp_listar_rutas]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [id_ruta], [ruta], [descripcion]
    FROM [dbo].[ruta]
END
GO

-- Crear ruta
CREATE PROCEDURE [dbo].[sp_crear_ruta]
    @ruta INT,
    @descripcion VARCHAR(150),
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[ruta] WHERE ruta = @ruta)
    BEGIN
        INSERT INTO [dbo].[ruta] (ruta, descripcion)
        VALUES (@ruta, @descripcion);
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Ruta registrada correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe una ruta con este número.';
END
GO

-- Editar ruta
CREATE PROCEDURE [dbo].[sp_editar_ruta]
    @id_ruta INT,
    @ruta INT,
    @descripcion VARCHAR(150),
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[ruta] WHERE ruta = @ruta AND id_ruta <> @id_ruta)
    BEGIN
        UPDATE [dbo].[ruta]
        SET ruta = @ruta, descripcion = @descripcion
        WHERE id_ruta = @id_ruta;
        SET @Resultado = 1;
        SET @Mensaje = 'Ruta actualizada correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe una ruta con este número.';
END
GO