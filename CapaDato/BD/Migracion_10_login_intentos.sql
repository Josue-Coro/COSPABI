USE [COSPABIRL1]
GO

-- =====================================================================
-- Migración 10: bloqueo de cuenta por intentos fallidos de login
-- Agrega a usuario_admin el contador de intentos y la fecha de bloqueo.
-- Idempotente: se puede re-ejecutar sin problema.
-- =====================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.usuario_admin') AND name = 'intentos_fallidos'
)
BEGIN
    ALTER TABLE dbo.usuario_admin
        ADD intentos_fallidos INT NOT NULL CONSTRAINT DF_usuario_admin_intentos DEFAULT 0;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.usuario_admin') AND name = 'bloqueado_hasta'
)
BEGIN
    ALTER TABLE dbo.usuario_admin
        ADD bloqueado_hasta DATETIME NULL;
END
GO
