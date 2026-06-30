-- =============================================================================
-- Migración 06 — Cambios en tabla Socio (BD4 → BD5)
-- Base de datos: COSPABIRL1
-- =============================================================================
USE [COSPABIRL1]
GO

-- ─────────────────────────────────────────────
-- PASO 3: socio.medidor_id_medidor → nullable
-- Motivo: Un socio puede ser registrado sin medidor inicialmente.
-- ─────────────────────────────────────────────
ALTER TABLE [dbo].[socio]
    ALTER COLUMN [medidor_id_medidor] INT NULL;
GO

PRINT '✔ Paso 3.1 completado: socio.medidor_id_medidor ahora es nullable.';
GO

-- ─────────────────────────────────────────────
-- PASO 3: socio.estado → Agregar columna BIT NOT NULL DEFAULT 1
-- Motivo: Permitir la baja lógica de socios.
-- ─────────────────────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('[dbo].[socio]') AND name = 'estado'
)
BEGIN
    ALTER TABLE [dbo].[socio]
        ADD [estado] BIT NOT NULL CONSTRAINT [DF_socio_estado] DEFAULT 1;
    PRINT '✔ Paso 3.2 completado: Columna socio.estado agregada con valor default 1.';
END
ELSE
BEGIN
    PRINT '✔ Paso 3.2 omitido: La columna socio.estado ya existe.';
END
GO
