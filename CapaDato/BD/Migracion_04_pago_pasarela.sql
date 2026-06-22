-- =============================================================================
-- Migracion 04 : 'pago' listo para pasarela QR (Libelula) + cliente.email
-- Sitio  : SQL Server 2012
-- Fecha  : 2026-06-15
--
-- Libelula abstrae la tarjeta/QR (tokeniza) -> NO guardamos datos de tarjeta
-- (cero PCI). Solo referencias de la transaccion.
--
-- CAMBIOS:
--   1) pago: + columnas de pasarela (identificador_deuda, id_transaccion,
--            forma_pago, codigo_recaudacion, url_pasarela, qr_url).
--   2) pago: estado (BIT) -> estado_pago VARCHAR(30)  [PENDIENTE/APROBADO/RECHAZADO/EXPIRADO]
--            porque el pago electronico es ASINCRONO (un BIT no alcanza).
--   3) pago: fecha_pago  DATE -> DATETIME  (el pago electronico necesita hora).
--   4) pago: indice unico filtrado sobre id_transaccion (idempotencia del callback).
--   5) cliente: + email  (Libelula lo EXIGE en REGISTRAR DEUDA).
--
-- OJO: el paso 2 elimina pago.estado; por eso tambien se ajusta el INSERT de
--      'pago' dentro de sp_registrar_socio_con_inscripcion (re-desplegar Credito.sql).
-- Re-ejecutable (guardas IF [NOT] EXISTS).
-- =============================================================================

-- USE COSPABIRL1;
-- GO

-- -----------------------------------------------------------------------------
-- PASO 1: columnas de pasarela en 'pago'
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('pago') AND name = 'id_transaccion')
    ALTER TABLE pago ADD
        identificador_deuda VARCHAR(100) NULL,   -- NUESTRO id enviado a Libelula
        id_transaccion      VARCHAR(100) NULL,   -- id que devuelve Libelula
        forma_pago          VARCHAR(60)  NULL,   -- canal real (TIGO MONEY, TARJETA..., QR SIMPLE)
        codigo_recaudacion  VARCHAR(50)  NULL,   -- codigo de Libelula (conciliacion)
        url_pasarela        VARCHAR(500) NULL,   -- url_pasarela_pagos (mientras PENDIENTE)
        qr_url              VARCHAR(500) NULL;    -- qr_simple_url (imagen del QR)
GO

-- -----------------------------------------------------------------------------
-- PASO 2: estado (BIT) -> estado_pago (VARCHAR)
-- -----------------------------------------------------------------------------

-- 2.a  Nueva columna (default APROBADO: las filas viejas eran cobros en efectivo)
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('pago') AND name = 'estado_pago')
    ALTER TABLE pago ADD estado_pago VARCHAR(30) NOT NULL
        CONSTRAINT DF_pago_estado_pago DEFAULT ('APROBADO');
GO

-- 2.b  Eliminar el BIT 'estado' (reemplazado por estado_pago)
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('pago') AND name = 'estado')
    ALTER TABLE pago DROP COLUMN estado;
GO

-- -----------------------------------------------------------------------------
-- PASO 3: fecha_pago  DATE -> DATETIME
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.columns c
           INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
           WHERE c.object_id = OBJECT_ID('pago') AND c.name = 'fecha_pago' AND t.name = 'date')
    ALTER TABLE pago ALTER COLUMN fecha_pago DATETIME NOT NULL;
GO

-- -----------------------------------------------------------------------------
-- PASO 4: idempotencia -> un id_transaccion no se registra dos veces
--         (filtrado: permite muchos NULL = pagos en efectivo sin pasarela)
-- -----------------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'pago_id_transaccion_UX' AND object_id = OBJECT_ID('pago'))
    CREATE UNIQUE INDEX pago_id_transaccion_UX
        ON pago (id_transaccion)
        WHERE id_transaccion IS NOT NULL;
GO

-- -----------------------------------------------------------------------------
-- PASO 5: cliente.email (requerido por Libelula). NULL por ahora; el CRUD de
--         cliente se actualizara capa por capa para capturarlo.
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('cliente') AND name = 'email')
    ALTER TABLE cliente ADD email VARCHAR(150) NULL;
GO

-- -----------------------------------------------------------------------------
-- Verificacion (descomenta)
-- -----------------------------------------------------------------------------
-- SELECT c.name, t.name AS tipo, c.max_length, c.is_nullable
--   FROM sys.columns c INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
--  WHERE c.object_id = OBJECT_ID('pago') ORDER BY c.column_id;
-- SELECT name, is_nullable FROM sys.columns WHERE object_id = OBJECT_ID('cliente') AND name='email';
