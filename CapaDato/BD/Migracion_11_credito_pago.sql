USE [COSPABIRL1]
GO

-- =====================================================================
-- Migración 11: vincular la cuota inicial de inscripción con su pago
-- Agrega credito_inscripcion.pago_id_pago (NULL) para poder recuperar
-- el recibo del primer pago desde la pantalla de Créditos.
-- Idempotente: se puede re-ejecutar sin problema.
-- =====================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.credito_inscripcion') AND name = 'pago_id_pago'
)
BEGIN
    ALTER TABLE dbo.credito_inscripcion
        ADD pago_id_pago INT NULL;
END
GO

-- FK opcional hacia pago (solo si aún no existe)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_credito_inscripcion_pago'
)
BEGIN
    ALTER TABLE dbo.credito_inscripcion
        ADD CONSTRAINT FK_credito_inscripcion_pago
        FOREIGN KEY (pago_id_pago) REFERENCES dbo.pago(id_pago);
END
GO
