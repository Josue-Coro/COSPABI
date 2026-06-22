-- =============================================================================
-- Migracion 02 : Soporte para Credito de Inscripcion (Fase B)
-- Sitio  : SQL Server 2012
-- Fecha  : 2026-06-14
--
-- OBJETIVO:
--   1) periodo.costo_inscripcion : costo de inscripcion CONFIGURABLE por periodo
--      (hoy 1700 Bs). Se lee al registrar un socio nuevo.
--   2) pago.aviso_id_aviso -> NULLABLE : permite registrar el pago inicial de
--      inscripcion, que NO tiene aviso asociado (opcion C).
--
-- Re-ejecutable (guardas IF [NOT] EXISTS).
-- =============================================================================

-- USE COSPABIRL1;
-- GO

-- -----------------------------------------------------------------------------
-- PASO 1: costo de inscripcion configurable, almacenado en periodo
-- -----------------------------------------------------------------------------

-- 1.a  Nueva columna
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('periodo') AND name = 'costo_inscripcion')
    ALTER TABLE periodo ADD costo_inscripcion DECIMAL(10,2) NULL;
GO

-- 1.b  Sembrar el valor actual (1700) en los periodos existentes que no lo tengan.
--      Ajusta el monto si historicamente fue distinto.
UPDATE periodo SET costo_inscripcion = 1700 WHERE costo_inscripcion IS NULL;
GO

-- -----------------------------------------------------------------------------
-- PASO 2: pago.aviso_id_aviso pasa a NULLABLE (pago inicial sin aviso)
-- -----------------------------------------------------------------------------
-- Cambiar NOT NULL -> NULL NO requiere quitar el FK pago_aviso_FK
-- (un FK con valor NULL simplemente no se valida en esa fila).
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('pago') AND name = 'aviso_id_aviso'
             AND is_nullable = 0)
    ALTER TABLE pago ALTER COLUMN aviso_id_aviso INT NULL;
GO

-- -----------------------------------------------------------------------------
-- Verificacion (descomenta para revisar)
-- -----------------------------------------------------------------------------
-- SELECT name, is_nullable
--   FROM sys.columns
--  WHERE object_id = OBJECT_ID('pago') AND name = 'aviso_id_aviso';   -- is_nullable debe ser 1

-- SELECT id_periodo, periodo, costo_inscripcion FROM periodo;          -- todos con 1700
