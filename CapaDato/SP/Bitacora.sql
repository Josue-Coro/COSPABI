USE [COSPABIRL1]
GO

SELECT [id_bitacora]
      ,[accion]
      ,[fecha]
      ,[hora]
      ,[usuario_admin_id_usuario_admin]
  FROM [dbo].[bitacora]

GO

CREATE PROCEDURE dbo.sp_registrar_bitacora
(
    @Accion VARCHAR(255),
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO bitacora (accion, fecha, hora, usuario_admin_id_usuario_admin)
    VALUES (
        @Accion,
        CAST(GETDATE() AS DATE),
        GETDATE(),
        @IdUsuario
    );
END
GO


CREATE PROCEDURE [dbo].[sp_listar_bitacora]
    @fecha_inicio DATE     = NULL,
    @fecha_fin    DATE     = NULL,
    @id_usuario   INT      = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        b.id_bitacora,
        b.accion,
        b.fecha,
        b.hora,
        b.usuario_admin_id_usuario_admin,
        u.nombre + ' ' + u.apellido AS nombre_completo,
        u.usuario
    FROM [dbo].[bitacora] b
    INNER JOIN [dbo].[usuario_admin] u 
        ON u.id_usuario_admin = b.usuario_admin_id_usuario_admin
    WHERE
        (@fecha_inicio IS NULL OR b.fecha >= @fecha_inicio)
        AND (@fecha_fin    IS NULL OR b.fecha <= @fecha_fin)
        AND (@id_usuario   IS NULL OR b.usuario_admin_id_usuario_admin = @id_usuario)
    ORDER BY b.hora DESC
END
GO