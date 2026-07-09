USE [COSPABIRL1]
GO
----------------------------
CREATE TABLE bitacora 
    (
     id_bitacora INTEGER NOT NULL IDENTITY(1,1), 
     accion VARCHAR (255) NOT NULL , 
     fecha DATE NOT NULL , 
     hora DATETIME NOT NULL , 
     usuario_admin_id_usuario_admin INTEGER NOT NULL 
    )
GO

ALTER TABLE bitacora ADD CONSTRAINT bitacora_PK PRIMARY KEY CLUSTERED (id_bitacora)
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

-----------------------------
CREATE TABLE permiso 
    (
     id_permiso INTEGER NOT NULL IDENTITY(1,1), 
     accion VARCHAR (150) NOT NULL , 
     descripcion VARCHAR (150) 
    )
GO

ALTER TABLE permiso ADD CONSTRAINT permiso_PK PRIMARY KEY CLUSTERED (id_permiso)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

INSERT INTO [dbo].[permiso]
           ([accion]
           ,[descripcion])
     VALUES
           ('Gestionar Usuarios','Gestion de Usuarios')
GO


INSERT INTO permiso (accion, [descripcion]) VALUES
('Gestionar Cliente', 'Gestion de cliente'),
('Gestionar Avisos', 'Gestion de avisos'),
('Gestionar Caja', 'Gestion de caja'),
('Gestionar Lecturas', 'Gestion de lecturas'),
('Gestionar Notificaciones', 'Gestion de notificaciones'),
('Gestionar Rol', 'Gestion de rol'),
('Gestionar Tarifa', 'Gestion de tarifa');
-------------------

INSERT INTO permiso (accion, [descripcion]) VALUES
('Crear Rol', 'Registrar nuevos roles'),
('Editar Rol', 'Modificar roles existentes'),
('Desactivar Rol', 'Desactivar roles');
go
-------------------
INSERT INTO permiso (accion, [descripcion]) VALUES
('Crear Usuario', 'Registrar nuevos usuarios'),
('Editar Usuario', 'Modificar usuarios'),
('Desactivar Usuario', 'Desactivar usuarios');
go


-------------------
INSERT INTO permiso (accion, [descripcion]) VALUES
('Gestionar Permiso', 'Editar los permisos de un rol'),
('Visualizar Bitacora', 'Ver la bitácora de acciones');
go
---------------
INSERT INTO permiso (accion, [descripcion]) VALUES
('Gestionar TipoCargo', 'Gestion de Tipo de Cargo'),
('Gestionar Socio', 'Gestion de Socio'),
('Gestionar Credito Inscripcion', 'Gestion de Credito Inscripcion'),
('Gestionar Pago', 'Gestion de Pago');
go
----------------
-----------------
INSERT INTO permiso (accion, [descripcion]) VALUES
('Registrar Cliente', 'Crear nuevos clientes'),
('Editar Cliente', 'Modificar clientes existentes'),
('Eliminar Cliente', 'Eliminar clientes existentes'),
('Editar Tarifa', 'Modificar tarifas existentes'),
('Editar Tipo Cargo', 'Modificar tipos de cargo existentes'),
('Registrar Socio', 'Crear nuevos socios'),
('Editar Socio', 'Modificar socios existentes'),
('Eliminar Socio', 'Eliminar socios existentes');

go

INSERT INTO permiso (accion, [descripcion]) VALUES
('Gestionar Ruta', 'Gestion de Rutas');

go
INSERT INTO permiso (accion, [descripcion]) VALUES
('Editar Tarifa', 'Modificar Tarifas');

go
INSERT INTO permiso (accion, [descripcion]) VALUES
('Gestionar Medidor', 'Gestion de Medidores');

go
INSERT INTO permiso (accion, [descripcion]) VALUES
('Anular Avisos', 'Anular Avisos con errores');

go

----------------------
INSERT INTO permiso (accion, [descripcion]) VALUES
('Generar Reporte Caja', 'Generar de Reporte de Cajas'),
('Generar Reporte Morosidad', 'Generar de Reporte de Morosidad'),
('Gestionar Cuenta Socio', 'Gestionar Cuenta de Socios'),
('Gestionar Metodo Pago', 'Gestionar Metodo de Pago'),
('Gestionar Cargo Extra', 'Gestionar Cargo Extra');
go


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

INSERT INTO rol (nombre, descripcion, estado) VALUES
('Super Admin', 'Acceso total al sistema',1),
('Admin', 'Acceso limitado al sistema',1),
('Cajero', 'Acceso solo a caja, cliente y avisos',1);



CREATE TABLE rol_permiso 
    (
     id_rol_permiso INTEGER NOT NULL IDENTITY(1,1), 
     permiso_id_permiso INTEGER NOT NULL , 
     rol_id_rol INTEGER NOT NULL 
    )
GO

ALTER TABLE rol_permiso ADD CONSTRAINT rol_permiso_PK PRIMARY KEY CLUSTERED (id_rol_permiso)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

INSERT INTO rol_permiso (permiso_id_permiso, rol_id_rol) VALUES
-- Super Admin (ID 1)
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1), (8, 1),

-- Admin (ID 2) 
(2, 2), (3, 2), (4, 2), (5, 2), (6, 2), 

-- Cajero (ID 3) 
(2, 3), (3, 3), (4, 3);

--insertar los nuevos permisos al rol de super admin
INSERT INTO rol_permiso (permiso_id_permiso, rol_id_rol) VALUES
-- Super Admin (ID 1)
(9, 1), (10, 1), (11, 1)
-------------
--insertar los nuevos permisos al rol de super admin
INSERT INTO rol_permiso (permiso_id_permiso, rol_id_rol) VALUES
-- Super Admin (ID 1)
(12, 1), (13, 1), (14, 1)
-------------
--insertar los nuevos permisos al rol de super admin
INSERT INTO rol_permiso (permiso_id_permiso, rol_id_rol) VALUES
-- Super Admin (ID 1)
(15, 1), (16, 1)

-- Insertar Usuario Super Admin
INSERT INTO usuario_admin(
    nombre,
    apellido,
    usuario,
    contraseña,
    estado,
    fecha_creacion,
    rol_id_rol
)
VALUES (
    'Admin', 
    'Principal',     
    'admin',      
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '12345678'), 2),
    1, 
    GETDATE(),
    1
);

INSERT INTO usuario_admin(
    nombre,
    apellido,
    usuario,
    contraseña,
    estado,
    fecha_creacion,
    rol_id_rol
)
VALUES (
    'Cajero', 
    'Principal',     
    'cajero',      
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '12345678'), 2),
    1, 
    GETDATE(),
    3
);



--sp login (con bloqueo por intentos fallidos)
USE [COSPABIRL1]
GO
CREATE OR ALTER PROCEDURE dbo.sp_login_admin
(
    @Usuario    VARCHAR(255),
    @Contrasena VARCHAR(550),
    @Resultado  INT          OUTPUT,   -- 1 = OK, 0 = credenciales inválidas, -1 = cuenta bloqueada
    @Mensaje    VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    DECLARE @MAX_INTENTOS INT = 5;    -- intentos permitidos antes de bloquear
    DECLARE @MIN_BLOQUEO  INT = 15;   -- minutos de bloqueo

    DECLARE @id        INT,
            @hash      VARCHAR(550),
            @intentos  INT,
            @bloqueado DATETIME,
            @estadoU   BIT,
            @estadoR   BIT,
            @idRol     INT;

    SELECT
        @id        = U.id_usuario_admin,
        @hash      = U.contraseña,
        @intentos  = U.intentos_fallidos,
        @bloqueado = U.bloqueado_hasta,
        @estadoU   = U.estado,
        @estadoR   = R.estado,
        @idRol     = R.id_rol
    FROM usuario_admin U
    INNER JOIN rol R ON U.rol_id_rol = R.id_rol
    WHERE U.usuario = @Usuario;

    -- Usuario inexistente o inactivo: mismo mensaje genérico (no revelar si la cuenta existe)
    IF @id IS NULL OR @estadoU = 0 OR @estadoR = 0
    BEGIN
        SET @Mensaje = 'Usuario o contraseña incorrectos, o el usuario/rol no está activo.';
        SELECT NULL AS id_usuario_admin, NULL AS nombre, NULL AS apellido,
               NULL AS usuario, NULL AS EstadoUsuario, NULL AS id_rol, NULL AS NombreRol
        WHERE 1 = 0;
        SELECT NULL AS id_permiso, NULL AS accion WHERE 1 = 0;
        RETURN;
    END

    -- Cuenta bloqueada por intentos fallidos
    IF @bloqueado IS NOT NULL AND @bloqueado > GETDATE()
    BEGIN
        SET @Resultado = -1;
        SET @Mensaje   = 'Cuenta bloqueada por intentos fallidos. Intenta nuevamente en '
                       + CAST(DATEDIFF(MINUTE, GETDATE(), @bloqueado) + 1 AS VARCHAR)
                       + ' minuto(s).';
        SELECT NULL AS id_usuario_admin, NULL AS nombre, NULL AS apellido,
               NULL AS usuario, NULL AS EstadoUsuario, NULL AS id_rol, NULL AS NombreRol
        WHERE 1 = 0;
        SELECT NULL AS id_permiso, NULL AS accion WHERE 1 = 0;
        RETURN;
    END

    -- Contraseña incorrecta: acumular intento y bloquear si llegó al límite
    IF @hash <> @Contrasena
    BEGIN
        SET @intentos = @intentos + 1;

        IF @intentos >= @MAX_INTENTOS
        BEGIN
            UPDATE usuario_admin
            SET intentos_fallidos = 0,
                bloqueado_hasta   = DATEADD(MINUTE, @MIN_BLOQUEO, GETDATE())
            WHERE id_usuario_admin = @id;

            DECLARE @accBloqueo VARCHAR(255) =
                'Cuenta bloqueada por ' + CAST(@MIN_BLOQUEO AS VARCHAR) + ' minutos tras '
                + CAST(@MAX_INTENTOS AS VARCHAR) + ' intentos fallidos de inicio de sesión';
            EXEC dbo.sp_registrar_bitacora @accBloqueo, @id;

            SET @Resultado = -1;
            SET @Mensaje   = 'Cuenta bloqueada por ' + CAST(@MIN_BLOQUEO AS VARCHAR)
                           + ' minutos tras ' + CAST(@MAX_INTENTOS AS VARCHAR)
                           + ' intentos fallidos.';
        END
        ELSE
        BEGIN
            UPDATE usuario_admin
            SET intentos_fallidos = @intentos
            WHERE id_usuario_admin = @id;

            DECLARE @accFallo VARCHAR(255) =
                'Intento de inicio de sesión fallido (' + CAST(@intentos AS VARCHAR)
                + ' de ' + CAST(@MAX_INTENTOS AS VARCHAR) + ')';
            EXEC dbo.sp_registrar_bitacora @accFallo, @id;

            SET @Mensaje = 'Usuario o contraseña incorrectos, o el usuario/rol no está activo.';
        END

        SELECT NULL AS id_usuario_admin, NULL AS nombre, NULL AS apellido,
               NULL AS usuario, NULL AS EstadoUsuario, NULL AS id_rol, NULL AS NombreRol
        WHERE 1 = 0;
        SELECT NULL AS id_permiso, NULL AS accion WHERE 1 = 0;
        RETURN;
    END

    -- Login exitoso: resetear contador y bloqueo
    UPDATE usuario_admin
    SET intentos_fallidos = 0,
        bloqueado_hasta   = NULL
    WHERE id_usuario_admin = @id;

    SET @Resultado = 1;
    SET @Mensaje   = 'Acceso concedido.';

    -- Primer ResultSet: datos del usuario
    SELECT
        U.id_usuario_admin,
        U.nombre,
        U.apellido,
        U.usuario,
        U.estado AS EstadoUsuario,
        R.id_rol,
        R.nombre AS NombreRol
    FROM usuario_admin U
    INNER JOIN rol R ON U.rol_id_rol = R.id_rol
    WHERE U.id_usuario_admin = @id;

    -- Segundo ResultSet: permisos del rol
    SELECT
        P.id_permiso,
        P.accion
    FROM rol_permiso RP
    INNER JOIN permiso P ON RP.permiso_id_permiso = P.id_permiso
    WHERE RP.rol_id_rol = @idRol;
END
GO