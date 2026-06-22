-- =============================================================================
-- Migracion 03 : Soporte para Caja + Pagos
-- Sitio  : SQL Server 2012
-- Fecha  : 2026-06-15
--
-- DECISIONES (acordadas):
--   1) El vinculo con caja va en 'pago' (no en 'aviso')  -> se mueve.
--   2) Una caja ABIERTA por cajero (no global).
--   3) La caja tiene fondo inicial: monto_apertura.
--   4) Registrar un socio exige caja abierta (el pago inicial entra a caja).
--   5) Arqueo = total por metodo de pago.
--
-- CAMBIOS:
--   1) pago  : + caja_id_caja (FK)            -> en que caja se cobro el pago.
--   2) caja  : + monto_apertura               -> fondo inicial.
--   3) caja  : hors_cierre -> hora_cierre + NULLABLE (al abrir aun no hay cierre).
--   4) aviso : se ELIMINA caja_id_caja + FK   -> el vinculo se movio a 'pago'.
--   5) caja  : indice unico filtrado -> una sola caja ABIERTA por cajero.
--
-- Convencion de estado de caja:  1 = ABIERTA , 0 = CERRADA.
-- Re-ejecutable (guardas IF [NOT] EXISTS).
-- =============================================================================

-- USE COSPABIRL1;
-- GO

-- -----------------------------------------------------------------------------
-- PASO 1: pago recibe el vinculo a la caja
-- -----------------------------------------------------------------------------

-- 1.a  Nueva columna (NULL: las filas viejas no tenian caja; las nuevas SI la setean)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('pago') AND name = 'caja_id_caja')
    ALTER TABLE pago ADD caja_id_caja INT NULL;
GO

-- 1.b  FK pago -> caja
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'pago_caja_FK')
    ALTER TABLE pago
        ADD CONSTRAINT pago_caja_FK FOREIGN KEY (caja_id_caja)
        REFERENCES caja (id_caja)
        ON DELETE NO ACTION ON UPDATE NO ACTION;
GO

-- -----------------------------------------------------------------------------
-- PASO 2: caja recibe el fondo inicial
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('caja') AND name = 'monto_apertura')
    ALTER TABLE caja ADD monto_apertura DECIMAL(30,2) NOT NULL
        CONSTRAINT DF_caja_monto_apertura DEFAULT (0);
GO

-- -----------------------------------------------------------------------------
-- PASO 3: renombrar hors_cierre -> hora_cierre y hacerla NULLABLE
-- -----------------------------------------------------------------------------

-- 3.a  Renombrar (solo si aun se llama 'hors_cierre' y no existe 'hora_cierre')
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('caja') AND name = 'hors_cierre')
   AND NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID('caja') AND name = 'hora_cierre')
    EXEC sp_rename 'caja.hors_cierre', 'hora_cierre', 'COLUMN';
GO

-- 3.b  Hacerla NULLABLE (al abrir la caja todavia no hay cierre)
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('caja') AND name = 'hora_cierre' AND is_nullable = 0)
    ALTER TABLE caja ALTER COLUMN hora_cierre DATETIME NULL;
GO

-- -----------------------------------------------------------------------------
-- PASO 4: mover el vinculo -> eliminar caja_id_caja de 'aviso'
--         (estaba sin uso; el vinculo ahora vive en 'pago')
-- -----------------------------------------------------------------------------

-- 4.a  Quitar FK aviso -> caja
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'aviso_caja_FK')
    ALTER TABLE aviso DROP CONSTRAINT aviso_caja_FK;
GO

-- 4.b  Quitar columna caja_id_caja
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('aviso') AND name = 'caja_id_caja')
    ALTER TABLE aviso DROP COLUMN caja_id_caja;
GO

-- -----------------------------------------------------------------------------
-- PASO 5: una sola caja ABIERTA por cajero (decision 2)
--         Indice unico filtrado: permite muchas CERRADAS (estado=0) por cajero,
--         pero a lo sumo UNA ABIERTA (estado=1).
--         Requiere QUOTED_IDENTIFIER ON al crear indices filtrados.
-- -----------------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'caja_cajero_abierta_UX' AND object_id = OBJECT_ID('caja'))
    CREATE UNIQUE INDEX caja_cajero_abierta_UX
        ON caja (usuario_admin_id_usuario_admin)
        WHERE estado = 1;
GO

-- -----------------------------------------------------------------------------
-- Verificacion (descomenta para revisar)
-- -----------------------------------------------------------------------------
-- SELECT name, system_type_id, is_nullable FROM sys.columns WHERE object_id = OBJECT_ID('caja');
-- SELECT name, is_nullable FROM sys.columns WHERE object_id = OBJECT_ID('pago') AND name = 'caja_id_caja';
-- SELECT name, has_filter, filter_definition FROM sys.indexes WHERE name = 'caja_cajero_abierta_UX';
