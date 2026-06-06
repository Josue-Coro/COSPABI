USE [COSPABI]
GO

SELECT [id_rol]
      ,[nombre]
      ,[descripcion]
      ,[estado]
  FROM [dbo].[rol]

GO
CREATE TABLE rol 
    (
     id_rol INTEGER NOT NULL IDENTITY(1,1), 
     nombre VARCHAR (150) NOT NULL , 
     descripcion VARCHAR (250) , 
     estado BIT NOT NULL 
    )
GO

ALTER TABLE rol ADD CONSTRAINT rol_PK PRIMARY KEY CLUSTERED (id_rol)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

--listar roles sp
create procedure [dbo].[sp_listar_roles]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT [id_rol]
          ,[nombre]
          ,[descripcion]
          ,[estado]
      FROM [dbo].[rol]
END
go

--crear rol sp 
create procedure [dbo].[sp_crear_rol]
    @nombre nvarchar(100),
    @descripcion nvarchar(255),
    @estado bit,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
as
begin
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';

    -- Validar que el nombre no esté duplicado
    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE nombre = @nombre)
    BEGIN
        INSERT INTO [dbo].[rol] (nombre, descripcion, estado)
        VALUES (@nombre, @descripcion, @estado);
        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje = 'Rol registrado correctamente.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un rol con este nombre.';
    
end
go
--editar rol sp
create procedure [dbo].[sp_editar_rol]
    @id_rol int,
    @nombre nvarchar(100),
    @descripcion nvarchar(255),
    @estado bit,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';
    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE nombre = @nombre and id_rol <> @id_rol)
    BEGIN
          UPDATE [dbo].[rol]
          SET nombre = @nombre, descripcion = @descripcion, estado = @estado
          WHERE id_rol = @id_rol;

          SET @Resultado = 1;
          SET @Mensaje = 'Rol actualizado correctamente.';
     END
     ELSE
          SET @Mensaje = 'Ya existe un rol con este nombre.';
END

go
--eliminar rol sp, solo poner estado en 0
create procedure [dbo].[sp_eliminar_rol]
    @id_rol int,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje = '';
    IF EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @id_rol)
    BEGIN
        UPDATE [dbo].[rol]
        SET estado = 0
        WHERE id_rol = @id_rol;

        SET @Resultado = 1;
        SET @Mensaje = 'Rol eliminado correctamente.';
    END
    ELSE
        SET @Mensaje = 'No existe un rol con este ID.';
END
