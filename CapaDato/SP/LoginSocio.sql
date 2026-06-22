USE [COSPABIRL1]
GO

-- ══════════════════════════════════════════
-- SP LOGIN SOCIO (Panel Cliente)
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_login_socio
(
    @Usuario    VARCHAR(150),
    @Contrasena VARCHAR(500)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM cuenta_socio cs
        WHERE cs.usuario    = @Usuario
          AND cs.contraseña = @Contrasena
          AND cs.estado     = 1
    )
    BEGIN
        -- Actualizar ultimo acceso
        UPDATE cuenta_socio
        SET ultimo_acceso = GETDATE()
        WHERE usuario = @Usuario;

        -- Retornar datos del socio con su rol
        SELECT
            cs.id_cuenta_socio,
            cs.usuario,
            cs.estado           AS EstadoCuenta,
            cs.ultimo_acceso,
            s.id_socio,
            s.nombre_socio,
            rs.id_rol_socio,
            rs.rol_socio        AS NombreRolSocio
        FROM cuenta_socio cs
        INNER JOIN socio s      ON cs.socio_id_socio        = s.id_socio
        INNER JOIN rol_socio rs ON s.rol_socio_id_rol_socio = rs.id_rol_socio
        WHERE cs.usuario = @Usuario;
    END
    ELSE
    BEGIN
        SELECT
            NULL AS id_cuenta_socio,
            NULL AS usuario,
            NULL AS EstadoCuenta,
            NULL AS ultimo_acceso,
            NULL AS id_socio,
            NULL AS nombre_socio,
            NULL AS id_rol_socio,
            NULL AS NombreRolSocio
        WHERE 1 = 0;
    END
END
GO

--probar sp login socio
EXEC dbo.sp_login_socio @Usuario = 'josuecoro', @Contrasena = 'EF797C8118F02DFB649607DD5D3F8C7623048C9C063D532CC95C5ED7A898A64F';
