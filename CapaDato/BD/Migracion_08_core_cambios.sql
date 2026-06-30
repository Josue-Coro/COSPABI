-- =============================================================================
-- Migración 08 — Cambios Críticos: Aviso, Cargo Extra y Crédito (BD4 → BD5)
-- Base de datos: COSPABIRL1
-- =============================================================================
USE [COSPABIRL1]
GO

-- ─────────────────────────────────────────────
-- PASO 5: aviso.estado → Eliminar columna VARCHAR
-- Motivo: Redundancia eliminada. Solo queda estado_id_estado (FK).
-- ─────────────────────────────────────────────
IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('[dbo].[aviso]') AND name = 'estado'
)
BEGIN
    ALTER TABLE [dbo].[aviso] DROP COLUMN [estado];
    PRINT '✔ Paso 5 completado: Columna aviso.estado eliminada.';
END
ELSE
BEGIN
    PRINT '✔ Paso 5 omitido: La columna aviso.estado ya no existe.';
END
GO

-- ─────────────────────────────────────────────
-- PASO 6: cargo_extra → Eliminar aviso_id_aviso + Renombrar PK
-- Motivo: Eliminar relación circular y corregir typo de id_carga_extra.
-- ─────────────────────────────────────────────

-- 6.1 Eliminar FK si existe
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'cargo_extra_aviso_FK' AND parent_object_id = OBJECT_ID('[dbo].[cargo_extra]')
)
BEGIN
    ALTER TABLE [dbo].[cargo_extra] DROP CONSTRAINT [cargo_extra_aviso_FK];
    PRINT '✔ Paso 6.1 completado: FK cargo_extra_aviso_FK eliminada.';
END
GO

-- 6.2 Eliminar columna aviso_id_aviso
IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('[dbo].[cargo_extra]') AND name = 'aviso_id_aviso'
)
BEGIN
    ALTER TABLE [dbo].[cargo_extra] DROP COLUMN [aviso_id_aviso];
    PRINT '✔ Paso 6.2 completado: Columna cargo_extra.aviso_id_aviso eliminada.';
END
ELSE
BEGIN
    PRINT '✔ Paso 6.2 omitido: La columna cargo_extra.aviso_id_aviso ya no existe.';
END
GO

-- 6.3 Renombrar PK id_carga_extra → id_cargo_extra
IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('[dbo].[cargo_extra]') AND name = 'id_carga_extra'
)
BEGIN
    EXEC sp_rename 'dbo.cargo_extra.id_carga_extra', 'id_cargo_extra', 'COLUMN';
    PRINT '✔ Paso 6.3 completado: Columna id_carga_extra renombrada a id_cargo_extra.';
END
ELSE
BEGIN
    PRINT '✔ Paso 6.3 omitido o ya renombrado.';
END
GO

-- ─────────────────────────────────────────────
-- PASO 7: credito_inscripcion → Eliminar aviso_id_aviso
-- Motivo: Eliminar relación circular.
-- ─────────────────────────────────────────────

-- 7.1 Eliminar FK si existe
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys 
    WHERE name = 'credito_inscripcion_aviso_FK' AND parent_object_id = OBJECT_ID('[dbo].[credito_inscripcion]')
)
BEGIN
    ALTER TABLE [dbo].[credito_inscripcion] DROP CONSTRAINT [credito_inscripcion_aviso_FK];
    PRINT '✔ Paso 7.1 completado: FK credito_inscripcion_aviso_FK eliminada.';
END
GO

-- 7.1.5 Eliminar índice dependiente si existe
IF EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'credito_inscripcion_aviso_UX' AND object_id = OBJECT_ID('[dbo].[credito_inscripcion]')
)
BEGIN
    DROP INDEX [credito_inscripcion_aviso_UX] ON [dbo].[credito_inscripcion];
    PRINT '✔ Paso 7.1.5 completado: Índice credito_inscripcion_aviso_UX eliminado.';
END
GO

-- 7.2 Eliminar columna aviso_id_aviso
IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('[dbo].[credito_inscripcion]') AND name = 'aviso_id_aviso'
)
BEGIN
    ALTER TABLE [dbo].[credito_inscripcion] DROP COLUMN [aviso_id_aviso];
    PRINT '✔ Paso 7.2 completado: Columna credito_inscripcion.aviso_id_aviso eliminada.';
END
ELSE
BEGIN
    PRINT '✔ Paso 7.2 omitido: La columna credito_inscripcion.aviso_id_aviso ya no existe.';
END
GO
