-- =====================================================================
-- Perfil del usuario administrativo ("Mi perfil" en el header del admin)
-- Todo opera SOLO sobre el usuario de la sesión (@id_usuario_admin viene
-- del Session["Usuario"], nunca del navegador). Sin permiso propio: cualquier
-- usuario autenticado puede ver y editar su propio perfil.
-- =====================================================================

-- 1. Datos del perfil + resumen de actividad
CREATE OR ALTER PROCEDURE dbo.sp_obtener_perfil_admin
    @id_usuario_admin INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.id_usuario_admin,
        U.nombre,
        U.apellido,
        U.usuario,
        U.estado,
        U.fecha_creacion,
        R.nombre      AS nombre_rol,
        R.descripcion AS descripcion_rol,
        (SELECT COUNT(*) FROM rol_permiso RP WHERE RP.rol_id_rol = R.id_rol) AS cantidad_permisos,
        (SELECT COUNT(*) FROM bitacora B WHERE B.usuario_admin_id_usuario_admin = U.id_usuario_admin) AS acciones_bitacora,
        (SELECT MAX(B.fecha_hora) FROM bitacora B
          WHERE B.usuario_admin_id_usuario_admin = U.id_usuario_admin
            AND B.accion LIKE 'Inicio de sesi%') AS ultimo_acceso,
        (SELECT COUNT(*) FROM caja C WHERE C.usuario_admin_id_usuario_admin = U.id_usuario_admin) AS cajas_abiertas_total
    FROM usuario_admin U
    INNER JOIN rol R ON R.id_rol = U.rol_id_rol
    WHERE U.id_usuario_admin = @id_usuario_admin;
END
GO

-- 2. Últimas acciones del propio usuario (para la tarjeta "Actividad reciente")
CREATE OR ALTER PROCEDURE dbo.sp_actividad_reciente_admin
    @id_usuario_admin INT,
    @top              INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@top)
        B.id_bitacora,
        B.accion,
        B.fecha_hora,
        B.usuario_admin_id_usuario_admin,
        U.nombre + ' ' + U.apellido AS nombre_completo,
        U.usuario
    FROM bitacora B
    INNER JOIN usuario_admin U ON U.id_usuario_admin = B.usuario_admin_id_usuario_admin
    WHERE B.usuario_admin_id_usuario_admin = @id_usuario_admin
    ORDER BY B.fecha_hora DESC;
END
GO

-- 3. Editar datos personales (solo nombre y apellido: el usuario de login y el
--    rol los administra Gestionar Usuarios, no el propio usuario)
CREATE OR ALTER PROCEDURE dbo.sp_editar_perfil_admin
    @id_usuario_admin INT,
    @nombre           VARCHAR(255),
    @apellido         VARCHAR(255),
    @Resultado        INT          OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    SET @nombre   = LTRIM(RTRIM(@nombre));
    SET @apellido = LTRIM(RTRIM(@apellido));

    IF NOT EXISTS (SELECT 1 FROM usuario_admin WHERE id_usuario_admin = @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'No existe el usuario de la sesión.';
        RETURN;
    END

    IF @nombre = '' OR @apellido = ''
    BEGIN
        SET @Mensaje = 'El nombre y el apellido son obligatorios.';
        RETURN;
    END

    -- Misma regla de unicidad que sp_editar_usuario
    IF EXISTS (SELECT 1 FROM usuario_admin
               WHERE LTRIM(RTRIM(nombre))   = @nombre
                 AND LTRIM(RTRIM(apellido)) = @apellido
                 AND id_usuario_admin <> @id_usuario_admin)
    BEGIN
        SET @Mensaje = 'Ya existe otro usuario registrado con ese nombre y apellido.';
        RETURN;
    END

    UPDATE usuario_admin
    SET nombre = @nombre, apellido = @apellido
    WHERE id_usuario_admin = @id_usuario_admin;

    SET @Resultado = 1;
    SET @Mensaje   = 'Perfil actualizado correctamente.';
END
GO

-- 4. Cambiar la propia contraseña: exige la actual. Ambos hashes SHA-256
--    (CN_Recursos.ConvertirSha256), así que se comparan como texto.
CREATE OR ALTER PROCEDURE dbo.sp_cambiar_contrasena_admin
    @id_usuario_admin INT,
    @contrasena_actual VARCHAR(550),
    @contrasena_nueva  VARCHAR(550),
    @Resultado        INT          OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    DECLARE @hash VARCHAR(550);
    SELECT @hash = contraseña FROM usuario_admin WHERE id_usuario_admin = @id_usuario_admin;

    IF @hash IS NULL
    BEGIN
        SET @Mensaje = 'No existe el usuario de la sesión.';
        RETURN;
    END

    IF @hash <> @contrasena_actual
    BEGIN
        SET @Mensaje = 'La contraseña actual no es correcta.';
        RETURN;
    END

    IF @hash = @contrasena_nueva
    BEGIN
        SET @Mensaje = 'La nueva contraseña debe ser distinta a la actual.';
        RETURN;
    END

    UPDATE usuario_admin
    SET contraseña = @contrasena_nueva
    WHERE id_usuario_admin = @id_usuario_admin;

    SET @Resultado = 1;
    SET @Mensaje   = 'Contraseña actualizada correctamente.';
END
GO
