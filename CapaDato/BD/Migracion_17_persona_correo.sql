USE [COSPABIRL1]
GO
-- =============================================================================
-- Migracion 17 - cliente -> persona, email -> socio.correo
--
-- 1) La tabla 'cliente' pasa a llamarse 'persona'. Guarda datos de identidad
--    (CI, nombre, nacimiento, genero, telefono); 'socio' es la afiliacion que
--    se construye encima de una persona. Con el nombre viejo parecia que
--    cliente y socio eran la misma entidad (observacion de la defensa).
--
-- 2) El correo deja de ser un atributo de la persona y pasa al socio.
--    Regla de negocio: una persona (el dueno del terreno) puede tener hasta 4
--    socios (medidores) y cada medidor lo usa alguien distinto (hijos,
--    familiares, inquilinos) que evita pagar una nueva inscripcion. Quien paga
--    por QR y entra al portal es ese ocupante, no el dueno, asi que el correo
--    depende del socio: id_socio -> correo. No es unico: el dueno puede tener
--    dos medidores propios y usar el mismo correo en ambos.
--
-- Requiere que socio este vacia (la columna nace NOT NULL sin default).
-- Idempotente: cada paso verifica si ya se aplico.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Renombrar tabla, PK, columna id y FK desde socio
-- ---------------------------------------------------------------------------
IF OBJECT_ID('dbo.cliente', 'U') IS NOT NULL AND OBJECT_ID('dbo.persona', 'U') IS NULL
BEGIN
    EXEC sp_rename 'dbo.cliente', 'persona';
    PRINT 'OK  tabla cliente -> persona.';
END
ELSE PRINT '--  tabla persona ya existia.';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.persona') AND name = 'id_cliente')
BEGIN
    EXEC sp_rename 'dbo.persona.id_cliente', 'id_persona', 'COLUMN';
    PRINT 'OK  persona.id_cliente -> id_persona.';
END
ELSE PRINT '--  persona.id_persona ya existia.';
GO

IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'cliente_PK')
BEGIN
    EXEC sp_rename 'dbo.cliente_PK', 'persona_PK', 'OBJECT';
    PRINT 'OK  cliente_PK -> persona_PK.';
END
ELSE PRINT '--  persona_PK ya existia.';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.socio') AND name = 'cliente_id_cliente')
BEGIN
    EXEC sp_rename 'dbo.socio.cliente_id_cliente', 'persona_id_persona', 'COLUMN';
    PRINT 'OK  socio.cliente_id_cliente -> persona_id_persona.';
END
ELSE PRINT '--  socio.persona_id_persona ya existia.';
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'socio_cliente_FK')
BEGIN
    EXEC sp_rename 'dbo.socio_cliente_FK', 'socio_persona_FK', 'OBJECT';
    PRINT 'OK  socio_cliente_FK -> socio_persona_FK.';
END
ELSE PRINT '--  socio_persona_FK ya existia.';
GO

-- Indices unicos de Migracion 15 que llevaban el nombre viejo
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'cliente_ci_UX' AND object_id = OBJECT_ID('dbo.persona'))
BEGIN
    EXEC sp_rename 'dbo.persona.cliente_ci_UX', 'persona_ci_UX', 'INDEX';
    PRINT 'OK  cliente_ci_UX -> persona_ci_UX.';
END
ELSE PRINT '--  persona_ci_UX ya existia.';
GO

-- ---------------------------------------------------------------------------
-- 2. Quitar el correo de persona (indice filtrado + columna)
-- ---------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'cliente_email_UX' AND object_id = OBJECT_ID('dbo.persona'))
BEGIN
    DROP INDEX cliente_email_UX ON dbo.persona;
    PRINT 'OK  cliente_email_UX eliminado.';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.persona') AND name = 'email')
BEGIN
    ALTER TABLE dbo.persona DROP COLUMN email;
    PRINT 'OK  persona.email eliminada.';
END
ELSE PRINT '--  persona.email ya no existia.';
GO

-- ---------------------------------------------------------------------------
-- 3. Correo en socio. NOT NULL: sin correo no hay QR ni portal, y la regla
--    ya se exigia en los SPs; ahora la garantiza el motor.
-- ---------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.socio') AND name = 'correo')
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.socio)
        RAISERROR('socio tiene filas: no se puede agregar correo NOT NULL sin backfill.', 16, 1);
    ELSE
    BEGIN
        ALTER TABLE dbo.socio ADD correo VARCHAR(150) NOT NULL;
        PRINT 'OK  socio.correo agregada.';
    END
END
ELSE PRINT '--  socio.correo ya existia.';
GO

-- ---------------------------------------------------------------------------
-- 4. SPs con el nombre viejo: los reemplaza CapaDato/SP/Persona.sql
-- ---------------------------------------------------------------------------
IF OBJECT_ID('dbo.sp_listar_clientes',        'P') IS NOT NULL DROP PROCEDURE dbo.sp_listar_clientes;
IF OBJECT_ID('dbo.sp_obtener_cliente',        'P') IS NOT NULL DROP PROCEDURE dbo.sp_obtener_cliente;
IF OBJECT_ID('dbo.sp_registrar_cliente',      'P') IS NOT NULL DROP PROCEDURE dbo.sp_registrar_cliente;
IF OBJECT_ID('dbo.sp_editar_cliente',         'P') IS NOT NULL DROP PROCEDURE dbo.sp_editar_cliente;
IF OBJECT_ID('dbo.sp_cambiar_estado_cliente', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_cambiar_estado_cliente;
-- Huerfano detectado en el analisis: no lo llama ningun archivo del repo.
IF OBJECT_ID('dbo.sp_registrar_socio',        'P') IS NOT NULL DROP PROCEDURE dbo.sp_registrar_socio;
PRINT 'OK  SPs con nombre viejo eliminados (redesplegar Persona.sql, Socio.sql, Credito.sql, CuentaSocio.sql, PagoQr.sql, Estadistica.sql).';
GO
