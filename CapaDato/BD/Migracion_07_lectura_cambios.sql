-- =============================================================================
-- Migración 07 — Cambios en tabla Lectura (BD4 → BD5)
-- Base de datos: COSPABIRL1
-- =============================================================================
USE [COSPABIRL1]
GO

-- ─────────────────────────────────────────────
-- PASO 4: Eliminar FK y columna ruta_id_ruta en lectura
-- Motivo: Redundancia eliminada, la ruta se obtiene de socio -> medidor -> ruta.
-- ─────────────────────────────────────────────
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'lectura_ruta_FK' AND parent_object_id = OBJECT_ID('[dbo].[lectura]')
)
BEGIN
    ALTER TABLE [dbo].[lectura] DROP CONSTRAINT [lectura_ruta_FK];
    PRINT '✔ Paso 4.1 completado: FK lectura_ruta_FK eliminada.';
END
GO

IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('[dbo].[lectura]') AND name = 'ruta_id_ruta'
)
BEGIN
    ALTER TABLE [dbo].[lectura] DROP COLUMN [ruta_id_ruta];
    PRINT '✔ Paso 4.2 completado: Columna lectura.ruta_id_ruta eliminada.';
END
ELSE
BEGIN
    PRINT '✔ Paso 4.2 omitido: La columna lectura.ruta_id_ruta ya no existe.';
END
GO

-- ─────────────────────────────────────────────
-- PASO 4.3: lectura.observacion → VARCHAR(255) NULL
-- Motivo: Las observaciones no deberían ser obligatorias.
-- ─────────────────────────────────────────────
ALTER TABLE [dbo].[lectura]
    ALTER COLUMN [observacion] VARCHAR(255) NULL;
GO

PRINT '✔ Paso 4.3 completado: lectura.observacion ahora es nullable.';
GO
