-- =============================================================================
-- Migracion 01 : Relacion aviso <-> cargo_extra / credito_inscripcion
-- Sitio  : SQL Server 2012
-- Fecha  : 2026-06-13
--
-- OBJETIVO (modelo "Caso 1" - ledger de obligaciones):
--   Un aviso puede recoger VARIOS cargos_extra (1:N) y a lo sumo UNA cuota de
--   credito_inscripcion (1:0..1). Tanto el cargo como la cuota nacen ANTES del
--   aviso (ligados a socio + periodo) y se "estampan" con aviso_id_aviso al
--   facturar (cierre de periodo).
--
-- CAMBIOS:
--   1) aviso  : se eliminan las columnas/FK invertidas
--               cargo_extra_id_carga_extra  y  credito_inscripcion_id_credito.
--   2) cargo_extra          : se agrega aviso_id_aviso (NULL) + FK.
--   3) credito_inscripcion  : se agrega aviso_id_aviso (NULL) + FK
--               + indice unico filtrado (garantiza 0..1 por aviso).
--
-- AVISO: el paso 1 elimina columnas; cualquier dato que tuvieran (del modelo
--        viejo, que era de prueba) se pierde. Las filas existentes de
--        cargo_extra / credito_inscripcion quedaran con aviso_id_aviso = NULL,
--        es decir "pendientes de facturar", que es lo correcto.
--
-- Ejecutar UNA vez sobre la base existente. Es re-ejecutable (guardas IF EXISTS).
-- =============================================================================

-- USE COSPABIRL1;
-- GO

-- -----------------------------------------------------------------------------
-- PASO 1: limpiar la relacion invertida en 'aviso'
-- -----------------------------------------------------------------------------

-- 1.a  Quitar FK aviso -> cargo_extra
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'aviso_cargo_extra_FK')
    ALTER TABLE aviso DROP CONSTRAINT aviso_cargo_extra_FK;
GO

-- 1.b  Quitar columna cargo_extra_id_carga_extra
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('aviso') AND name = 'cargo_extra_id_carga_extra')
    ALTER TABLE aviso DROP COLUMN cargo_extra_id_carga_extra;
GO

-- 1.c  Quitar FK aviso -> credito_inscripcion
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'aviso_credito_inscripcion_FK')
    ALTER TABLE aviso DROP CONSTRAINT aviso_credito_inscripcion_FK;
GO

-- 1.d  Quitar columna credito_inscripcion_id_credito
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('aviso') AND name = 'credito_inscripcion_id_credito')
    ALTER TABLE aviso DROP COLUMN credito_inscripcion_id_credito;
GO

-- -----------------------------------------------------------------------------
-- PASO 2: cargo_extra recibe el enlace al aviso (1 aviso : N cargos)
-- -----------------------------------------------------------------------------

-- 2.a  Nueva columna (NULL = cargo registrado pero aun no facturado)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('cargo_extra') AND name = 'aviso_id_aviso')
    ALTER TABLE cargo_extra ADD aviso_id_aviso INTEGER NULL;
GO

-- 2.b  FK cargo_extra -> aviso
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'cargo_extra_aviso_FK')
    ALTER TABLE cargo_extra
        ADD CONSTRAINT cargo_extra_aviso_FK FOREIGN KEY (aviso_id_aviso)
        REFERENCES aviso (id_aviso)
        ON DELETE NO ACTION ON UPDATE NO ACTION;
GO

-- -----------------------------------------------------------------------------
-- PASO 3: credito_inscripcion recibe el enlace al aviso (1 aviso : 0..1 cuota)
-- -----------------------------------------------------------------------------

-- 3.a  Nueva columna (NULL = cuota registrada pero aun no facturada)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('credito_inscripcion') AND name = 'aviso_id_aviso')
    ALTER TABLE credito_inscripcion ADD aviso_id_aviso INTEGER NULL;
GO

-- 3.b  FK credito_inscripcion -> aviso
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'credito_inscripcion_aviso_FK')
    ALTER TABLE credito_inscripcion
        ADD CONSTRAINT credito_inscripcion_aviso_FK FOREIGN KEY (aviso_id_aviso)
        REFERENCES aviso (id_aviso)
        ON DELETE NO ACTION ON UPDATE NO ACTION;
GO

-- 3.c  Indice unico filtrado: impide que dos cuotas caigan en el mismo aviso.
--      (Permite muchos NULL = muchas cuotas aun sin facturar.)
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'credito_inscripcion_aviso_UX'
                 AND object_id = OBJECT_ID('credito_inscripcion'))
    CREATE UNIQUE INDEX credito_inscripcion_aviso_UX
        ON credito_inscripcion (aviso_id_aviso)
        WHERE aviso_id_aviso IS NOT NULL;
GO

-- -----------------------------------------------------------------------------
-- PASO 4 (OPCIONAL - recomendado): un solo aviso por socio por periodo.
-- Descomenta SOLO si confirmas esa regla de negocio. Si ya tienes avisos
-- duplicados (socio, periodo) en datos de prueba, fallara hasta limpiarlos.
-- -----------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'aviso_socio_periodo_UX' AND object_id = OBJECT_ID('aviso'))
    CREATE UNIQUE INDEX aviso_socio_periodo_UX
        ON aviso (socio_id_socio, periodo_id_periodo);
GO



---------------------------------------------------------------------------------
SELECT  i.name AS indice,
        OBJECT_NAME(i.object_id) AS tabla,
        i.is_unique,
        i.has_filter,
        i.filter_definition
FROM    sys.indexes i
WHERE   i.name IN ('credito_inscripcion_aviso_UX', 'aviso_socio_periodo_UX');

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE UNIQUE INDEX credito_inscripcion_aviso_UX
    ON credito_inscripcion (aviso_id_aviso)
    WHERE aviso_id_aviso IS NOT NULL;
GO
------------------
DROP INDEX aviso_socio_periodo_UX ON aviso;