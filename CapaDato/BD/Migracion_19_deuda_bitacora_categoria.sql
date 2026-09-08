USE [COSPABIRL1]
GO
-- =============================================================================
-- Migracion 19 - limpieza de normalizacion
--
-- 1) aviso.deuda_actual se elimina. Se escribia una sola vez (igual a
--    total_aviso) y ningun SP la actualizaba jamas: un aviso PAGADO seguia
--    "debiendo" el total. Como no existen pagos parciales, la deuda es
--    derivable del estado: total_aviso si el aviso no esta PAGADO/ANULADO,
--    cero si lo esta. Los SPs la devuelven calculada con el mismo alias
--    deuda_actual, asi que la capa C# y las vistas no cambian.
--
-- 2) bitacora.fecha se elimina y bitacora.hora pasa a llamarse fecha_hora:
--    hora era DATETIME y ya contenia la fecha (dependencia derivable).
--
-- 3) socio.categoria queda como dato descriptivo con dominio cerrado (CHECK):
--    Domestico, Comercial, Industrial, Social. La tarifa la decide rol_socio.
--
-- Idempotente.
-- =============================================================================

-- 1. aviso.deuda_actual ------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.aviso') AND name = 'deuda_actual')
BEGIN
    ALTER TABLE dbo.aviso DROP COLUMN deuda_actual;
    PRINT 'OK  aviso.deuda_actual eliminada.';
END
ELSE PRINT '--  aviso.deuda_actual ya no existia.';
GO

-- 2. bitacora ----------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.bitacora') AND name = 'fecha')
BEGIN
    ALTER TABLE dbo.bitacora DROP COLUMN fecha;
    PRINT 'OK  bitacora.fecha eliminada.';
END
ELSE PRINT '--  bitacora.fecha ya no existia.';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.bitacora') AND name = 'hora')
BEGIN
    EXEC sp_rename 'dbo.bitacora.hora', 'fecha_hora', 'COLUMN';
    PRINT 'OK  bitacora.hora -> fecha_hora.';
END
ELSE PRINT '--  bitacora.fecha_hora ya existia.';
GO

-- 3. socio.categoria ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'socio_categoria_CK')
BEGIN
    ALTER TABLE dbo.socio ADD CONSTRAINT socio_categoria_CK
        CHECK (categoria IN ('Doméstico', 'Comercial', 'Industrial', 'Social'));
    PRINT 'OK  socio_categoria_CK creado.';
END
ELSE PRINT '--  socio_categoria_CK ya existia.';
GO
