USE [COSPABIRL1]
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

CREATE TABLE usuario_admin 
    (
     id_usuario_admin INTEGER NOT NULL IDENTITY(1,1), 
     nombre VARCHAR (255) NOT NULL , 
     apellido VARCHAR (255) NOT NULL , 
     usuario VARCHAR (255) NOT NULL , 
     contraseña VARCHAR (550) NOT NULL , 
     estado BIT NOT NULL , 
     fecha_creacion DATE NOT NULL , 
     rol_id_rol INTEGER NOT NULL 
    )
GO

ALTER TABLE usuario_admin ADD CONSTRAINT usuario_admin_PK PRIMARY KEY CLUSTERED (id_usuario_admin)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO


-- =============================================
-- LISTAR USUARIOS
-- =============================================
CREATE PROCEDURE [dbo].[sp_listar_usuarios]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.id_usuario_admin,
        u.nombre,
        u.apellido,
        u.usuario,
        u.estado,
        u.fecha_creacion,
        u.rol_id_rol,
        r.nombre AS nombre_rol
    FROM [dbo].[usuario_admin] u
    INNER JOIN [dbo].[rol] r ON r.id_rol = u.rol_id_rol
END
GO

-- =============================================
-- CREAR USUARIO
-- =============================================
CREATE PROCEDURE [dbo].[sp_crear_usuario]
    @nombre      VARCHAR(255),
    @apellido    VARCHAR(255),
    @usuario     VARCHAR(255),
    @contrasena  VARCHAR(550),
    @estado      BIT,
    @rol_id_rol  INT,
    @Resultado   INT OUTPUT,
    @Mensaje     VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF EXISTS (SELECT 1 FROM [dbo].[usuario_admin] WHERE usuario = @usuario)
    BEGIN
        SET @Mensaje = 'Ya existe un usuario con ese nombre de usuario.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @rol_id_rol AND estado = 1)
    BEGIN
        SET @Mensaje = 'El rol seleccionado no existe o está inactivo.';
        RETURN;
    END

    INSERT INTO [dbo].[usuario_admin] 
        (nombre, apellido, usuario, contraseña, estado, fecha_creacion, rol_id_rol)
    VALUES 
        (@nombre, @apellido, @usuario, @contrasena, @estado, GETDATE(), @rol_id_rol);

    SET @Resultado = SCOPE_IDENTITY();
    SET @Mensaje   = 'Usuario registrado correctamente.';
END
GO

-- =============================================
-- EDITAR USUARIO
-- =============================================
CREATE PROCEDURE [dbo].[sp_editar_usuario]
    @id_usuario_admin INT,
    @nombre           VARCHAR(255),
    @apellido         VARCHAR(255),
    @usuario          VARCHAR(255),
    @contrasena       VARCHAR(550),
    @estado           BIT,
    @rol_id_rol       INT,
    @Resultado        INT OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[usuario_admin] WHERE id_usuario_admin = @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'No existe un usuario con este ID.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].[usuario_admin] 
               WHERE usuario = @usuario AND id_usuario_admin <> @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'Ya existe otro usuario con ese nombre de usuario.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @rol_id_rol AND estado = 1)
    BEGIN
        SET @Mensaje = 'El rol seleccionado no existe o está inactivo.';
        RETURN;
    END

    UPDATE [dbo].[usuario_admin]
    SET 
        nombre       = @nombre,
        apellido     = @apellido,
        usuario      = @usuario,
        contraseña   = CASE 
                           WHEN @contrasena IS NOT NULL AND @contrasena != '' 
                           THEN @contrasena 
                           ELSE contraseña 
                       END,
        estado       = @estado,
        rol_id_rol   = @rol_id_rol
    WHERE id_usuario_admin = @id_usuario_admin;

    SET @Resultado = 1;
    SET @Mensaje   = 'Usuario actualizado correctamente.';
END
GO

-- =============================================
-- ELIMINAR (DESACTIVAR) USUARIO
-- =============================================
CREATE PROCEDURE [dbo].[sp_eliminar_usuario]
    @id_usuario_admin INT,
    @Resultado        INT OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[usuario_admin] WHERE id_usuario_admin = @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'No existe un usuario con este ID.';
        RETURN;
    END

    UPDATE [dbo].[usuario_admin]
    SET estado = 0
    WHERE id_usuario_admin = @id_usuario_admin;

    SET @Resultado = 1;
    SET @Mensaje   = 'Usuario desactivado correctamente.';
END
GO