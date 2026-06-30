-- =============================================================================
-- Migración 05 — Cambios de nullabilidad simples (BD4 → BD5)
-- Base de datos: COSPABIRL1
-- Seguro: no afecta datos existentes ni lógica de SPs.
-- =============================================================================
USE [COSPABIRL1]
GO

-- ─────────────────────────────────────────────
-- PASO 1: metodo_pago.referencia → nullable
-- Motivo: "Efectivo" no tiene referencia.
-- ─────────────────────────────────────────────
ALTER TABLE [dbo].[metodo_pago]
    ALTER COLUMN [referencia] VARCHAR(255) NULL;
GO

PRINT '✔ Paso 1 completado: metodo_pago.referencia ahora es nullable.';
GO

-- ─────────────────────────────────────────────
-- PASO 2: caja.monto_cobrado → nullable
-- Motivo: se calcula al cerrar la caja;
--         al abrir no tiene sentido que sea NOT NULL con 0.
-- ─────────────────────────────────────────────
ALTER TABLE [dbo].[caja]
    ALTER COLUMN [monto_cobrado] DECIMAL(30,3) NULL;
GO

PRINT '✔ Paso 2 completado: caja.monto_cobrado ahora es nullable.';
GO
