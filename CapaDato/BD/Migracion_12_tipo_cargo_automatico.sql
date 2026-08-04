USE [COSPABIRL1]
GO

-- =====================================================================
-- Migración 12: cargos extra automáticos
-- ---------------------------------------------------------------------
-- Agrega tipo_cargo.automatico (BIT). Un tipo marcado con automatico = 1
-- y estado = 1 se estampa por si solo en cada aviso al generarlo:
-- sp_generar_avisos_periodo inserta el cargo_extra correspondiente ANTES
-- de crear el aviso, para que entre en total_aviso.
--
-- Caso real de COSPABI: la TASA AFCOOP (Bs. 0.50) que se cobra a todos
-- los socios en cada periodo.
--
-- Idempotente: se puede re-ejecutar sin problema.
-- =====================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.tipo_cargo') AND name = 'automatico'
)
BEGIN
    ALTER TABLE dbo.tipo_cargo
        ADD automatico BIT NOT NULL CONSTRAINT DF_tipo_cargo_automatico DEFAULT (0);
END
GO

-- La TASA AFCOOP pasa a ser automática y se corrige su monto a 0.50.
-- Solo afecta a los cargos que se registren de aquí en adelante: los ya
-- estampados en avisos existentes conservan el monto con que se emitieron.
UPDATE dbo.tipo_cargo
SET automatico = 1,
    monto      = 0.50
WHERE nombre = 'TASA AFCOOP';
GO
