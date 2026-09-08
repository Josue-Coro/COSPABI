USE [COSPABIRL1]
GO

-- =============================================================================
-- BITACORA (registro de auditoria).
-- bitacora.usuario_admin_id_usuario_admin es NOT NULL con FK a usuario_admin,
-- asi que toda accion auditada necesita un usuario. Las acciones que nacen en
-- el portal del socio no tienen usuario humano: para esos casos la capa de
-- negocio manda @IdUsuario = 0 y aqui se resuelve al usuario SISTEMA
-- (Migracion 13), en vez de perder el registro por una FK invalida.
-- =============================================================================

CREATE OR ALTER PROCEDURE dbo.sp_registrar_bitacora
(
    @Accion    VARCHAR(255),
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Sin usuario humano (portal del socio, procesos automaticos) -> SISTEMA
    IF @IdUsuario IS NULL OR @IdUsuario <= 0
       OR NOT EXISTS (SELECT 1 FROM usuario_admin WHERE id_usuario_admin = @IdUsuario)
        SELECT @IdUsuario = (SELECT TOP 1 id_usuario_admin
                             FROM usuario_admin WHERE usuario = 'SISTEMA');

    -- Si ni siquiera existe SISTEMA no se inserta: la auditoria se pierde,
    -- pero jamas se rompe la operacion que la origino.
    IF @IdUsuario IS NULL RETURN;

    INSERT INTO bitacora (accion, fecha_hora, usuario_admin_id_usuario_admin)
    VALUES (
        @Accion,
        GETDATE(),
        @IdUsuario
    );
END
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_listar_bitacora]
    @fecha_inicio DATE     = NULL,
    @fecha_fin    DATE     = NULL,
    @id_usuario   INT      = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        b.id_bitacora,
        b.accion,
        b.fecha_hora,
        b.usuario_admin_id_usuario_admin,
        u.nombre + ' ' + u.apellido AS nombre_completo,
        u.usuario
    FROM [dbo].[bitacora] b
    INNER JOIN [dbo].[usuario_admin] u 
        ON u.id_usuario_admin = b.usuario_admin_id_usuario_admin
    WHERE
        (@fecha_inicio IS NULL OR b.fecha_hora >= @fecha_inicio)
        AND (@fecha_fin    IS NULL OR b.fecha_hora <  DATEADD(DAY, 1, @fecha_fin))
        AND (@id_usuario   IS NULL OR b.usuario_admin_id_usuario_admin = @id_usuario)
    ORDER BY b.fecha_hora DESC
END
GO
