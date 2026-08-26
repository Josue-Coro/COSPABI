USE [COSPABIRL1]
GO

-- =============================================================================
-- MIGRACION 14 - Endurecimiento de seguridad
--
--   1. Bloqueo por intentos fallidos en el portal del socio (cuenta_socio),
--      espejo del que ya tenia usuario_admin desde la Migracion 10. Sin esto
--      el portal se puede forzar por fuerza bruta sin ningun limite.
--
-- Los cambios de propiedad (IDOR) de caja y el nuevo sp_login_socio viajan en
-- sus propios archivos de SP: CapaDato/SP/Caja.sql y CapaDato/SP/LoginSocio.sql.
-- =============================================================================

-- 1. Contador de intentos fallidos y ventana de bloqueo del socio -------------
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.cuenta_socio')
                 AND name = 'intentos_fallidos')
BEGIN
    ALTER TABLE cuenta_socio ADD intentos_fallidos INT NOT NULL
        CONSTRAINT DF_cuenta_socio_intentos DEFAULT (0);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.cuenta_socio')
                 AND name = 'bloqueado_hasta')
BEGIN
    ALTER TABLE cuenta_socio ADD bloqueado_hasta DATETIME NULL;
END
GO

PRINT 'Migracion 14 aplicada: bloqueo por intentos fallidos en cuenta_socio.';
GO
