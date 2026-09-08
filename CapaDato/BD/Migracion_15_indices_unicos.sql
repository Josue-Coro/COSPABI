-- =============================================================================
-- Migracion 15 : Indices UNICOS de negocio
-- Sitio  : SQL Server
-- Fecha  : 2026-08-28
--
-- OBJETIVO:
--   Llevar al MOTOR las reglas de unicidad que hoy solo viven dentro de los
--   stored procedures como "IF NOT EXISTS". Esa validacion protege una puerta
--   (el SP), pero no las demas: un script, un INSERT desde SSMS o dos sesiones
--   concurrentes la esquivan sin enterarse.
--
--   Caso concreto ya ocurrido: sp_crear_medidor rechaza series repetidas y aun
--   asi la tabla llego a tener 7 medidores con serie duplicada; no entraron por
--   ese SP. Un indice unico lo habria impedido viniera de donde viniera.
--
--   El riesgo economico esta en tres de ellos:
--     * aviso   -> dos avisos activos del mismo socio/periodo = cobro duplicado.
--     * tarifa  -> dos tarifas del mismo rol_socio hacen que el INNER JOIN de
--                  sp_generar_avisos_periodo multiplique filas y duplique TODA
--                  una corrida de facturacion.
--     * lectura -> dos lecturas del mismo medidor/periodo = consumo duplicado.
--
-- NO modifica tablas ni datos: solo agrega indices.
-- Re-ejecutable (guardas IF NOT EXISTS sobre sys.indexes).
--
-- Verificado antes de aplicar: 0 filas en conflicto para los 20 indices. Si
-- alguno falla, es que aparecieron datos que lo violan; el error nombra cual.
-- =============================================================================
USE [COSPABIRL1]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================
-- 1. AVISO  (el que cuesta plata: cobro duplicado)
-- ===========================================================================
-- Un socio no puede tener dos avisos VIVOS en el mismo periodo. Los ANULADOS
-- quedan fuera del indice a proposito: anular y regenerar es el flujo normal
-- (lo dice el propio mensaje de sp_anular_aviso), asi que un socio SI puede
-- acumular varios anulados mas el vigente.
--
-- El 5 va escrito a mano porque un indice filtrado de SQL Server no admite
-- subconsultas: no se puede poner (SELECT id_estado FROM estado WHERE ...).
-- Hoy ANULADO = 5 en la tabla estado, que es una tabla semilla. Si algun dia
-- se renumera, hay que rehacer este indice.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'aviso_socio_periodo_UX')
BEGIN
    CREATE UNIQUE INDEX aviso_socio_periodo_UX
        ON dbo.aviso (socio_id_socio, periodo_id_periodo)
        WHERE estado_id_estado <> 5;   -- 5 = ANULADO
    PRINT 'OK  aviso_socio_periodo_UX creado.';
END
ELSE PRINT '--  aviso_socio_periodo_UX ya existia.';
GO

-- ===========================================================================
-- 2. TARIFA  (el que duplica una corrida entera de facturacion)
-- ===========================================================================
-- sp_generar_avisos_periodo hace INNER JOIN tarifa ON rol_socio: con dos
-- tarifas para el mismo rol, cada socio de esa categoria genera DOS avisos.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'tarifa_rol_socio_UX')
BEGIN
    CREATE UNIQUE INDEX tarifa_rol_socio_UX ON dbo.tarifa (rol_socio_id_rol_socio);
    PRINT 'OK  tarifa_rol_socio_UX creado.';
END
ELSE PRINT '--  tarifa_rol_socio_UX ya existia.';
GO

-- ===========================================================================
-- 3. LECTURA  (consumo duplicado)
-- ===========================================================================
-- Ya lo valida sp_registrar_lectura, pero dos peticiones simultaneas pasan las
-- dos por el IF EXISTS antes de que cualquiera llegue a insertar.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'lectura_medidor_periodo_UX')
BEGIN
    CREATE UNIQUE INDEX lectura_medidor_periodo_UX
        ON dbo.lectura (medidor_id_medidor, periodo_id_periodo);
    PRINT 'OK  lectura_medidor_periodo_UX creado.';
END
ELSE PRINT '--  lectura_medidor_periodo_UX ya existia.';
GO

-- ===========================================================================
-- 4. SOCIO
-- ===========================================================================
-- codigo_fijo es el numero que el cajero teclea en todas las pantallas.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'socio_codigo_fijo_UX')
BEGIN
    CREATE UNIQUE INDEX socio_codigo_fijo_UX ON dbo.socio (codigo_fijo);
    PRINT 'OK  socio_codigo_fijo_UX creado.';
END
ELSE PRINT '--  socio_codigo_fijo_UX ya existia.';
GO

-- Un medidor pertenece a un solo socio. La columna es NULLABLE (un socio puede
-- existir sin medidor), asi que el indice va filtrado: sin el filtro SQL Server
-- trataria todos los NULL como un mismo valor y solo admitiria UN socio sin
-- medidor en toda la tabla.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'socio_medidor_UX')
BEGIN
    CREATE UNIQUE INDEX socio_medidor_UX ON dbo.socio (medidor_id_medidor)
        WHERE medidor_id_medidor IS NOT NULL;
    PRINT 'OK  socio_medidor_UX creado.';
END
ELSE PRINT '--  socio_medidor_UX ya existia.';
GO

-- ===========================================================================
-- 5. MEDIDOR
-- ===========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'medidor_serie_UX')
BEGIN
    CREATE UNIQUE INDEX medidor_serie_UX ON dbo.medidor (serie);
    PRINT 'OK  medidor_serie_UX creado.';
END
ELSE PRINT '--  medidor_serie_UX ya existia.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'medidor_numero_UX')
BEGIN
    CREATE UNIQUE INDEX medidor_numero_UX ON dbo.medidor (numero);
    PRINT 'OK  medidor_numero_UX creado.';
END
ELSE PRINT '--  medidor_numero_UX ya existia.';
GO

-- ===========================================================================
-- 6. PERIODO
-- ===========================================================================
-- sp_obtener_o_crear_periodo busca por nombre (MM/yyyy) y crea si no existe:
-- dos llamadas simultaneas crearian dos periodos con el mismo nombre, y desde
-- ahi las lecturas y avisos de un mismo mes quedarian repartidos entre dos ids.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'periodo_periodo_UX')
BEGIN
    CREATE UNIQUE INDEX periodo_periodo_UX ON dbo.periodo (periodo);
    PRINT 'OK  periodo_periodo_UX creado.';
END
ELSE PRINT '--  periodo_periodo_UX ya existia.';
GO

-- ===========================================================================
-- 7. CLIENTE
-- ===========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'cliente_ci_UX')
BEGIN
    CREATE UNIQUE INDEX cliente_ci_UX ON dbo.cliente (ci);
    PRINT 'OK  cliente_ci_UX creado.';
END
ELSE PRINT '--  cliente_ci_UX ya existia.';
GO

-- El email viaja a Libelula como identificador del pagador y los SPs ya lo
-- exigen unico. La columna sigue siendo NULLABLE por filas heredadas, asi que
-- el indice va filtrado.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'cliente_email_UX')
BEGIN
    CREATE UNIQUE INDEX cliente_email_UX ON dbo.cliente (email)
        WHERE email IS NOT NULL;
    PRINT 'OK  cliente_email_UX creado.';
END
ELSE PRINT '--  cliente_email_UX ya existia.';
GO

-- ===========================================================================
-- 8. USUARIOS Y CUENTAS  (dos usuarios iguales = login ambiguo)
-- ===========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'usuario_admin_usuario_UX')
BEGIN
    CREATE UNIQUE INDEX usuario_admin_usuario_UX ON dbo.usuario_admin (usuario);
    PRINT 'OK  usuario_admin_usuario_UX creado.';
END
ELSE PRINT '--  usuario_admin_usuario_UX ya existia.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'cuenta_socio_usuario_UX')
BEGIN
    CREATE UNIQUE INDEX cuenta_socio_usuario_UX ON dbo.cuenta_socio (usuario);
    PRINT 'OK  cuenta_socio_usuario_UX creado.';
END
ELSE PRINT '--  cuenta_socio_usuario_UX ya existia.';
GO

-- Relacion 1:1 con socio.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'cuenta_socio_socio_UX')
BEGIN
    CREATE UNIQUE INDEX cuenta_socio_socio_UX ON dbo.cuenta_socio (socio_id_socio);
    PRINT 'OK  cuenta_socio_socio_UX creado.';
END
ELSE PRINT '--  cuenta_socio_socio_UX ya existia.';
GO

-- ===========================================================================
-- 9. CATALOGOS
-- ===========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ruta_ruta_UX')
BEGIN
    CREATE UNIQUE INDEX ruta_ruta_UX ON dbo.ruta (ruta);
    PRINT 'OK  ruta_ruta_UX creado.';
END
ELSE PRINT '--  ruta_ruta_UX ya existia.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'rol_nombre_UX')
BEGIN
    CREATE UNIQUE INDEX rol_nombre_UX ON dbo.rol (nombre);
    PRINT 'OK  rol_nombre_UX creado.';
END
ELSE PRINT '--  rol_nombre_UX ya existia.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'tipo_cargo_nombre_UX')
BEGIN
    CREATE UNIQUE INDEX tipo_cargo_nombre_UX ON dbo.tipo_cargo (nombre);
    PRINT 'OK  tipo_cargo_nombre_UX creado.';
END
ELSE PRINT '--  tipo_cargo_nombre_UX ya existia.';
GO

-- sp_registrar_pago_qr_pendiente busca el metodo por nombre (QR LIBELULA) y
-- sp_arqueo_caja hace lo mismo con Efectivo: dos filas con el mismo nombre
-- dejarian el metodo elegido al azar.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'metodo_pago_metodo_UX')
BEGIN
    CREATE UNIQUE INDEX metodo_pago_metodo_UX ON dbo.metodo_pago (metodo);
    PRINT 'OK  metodo_pago_metodo_UX creado.';
END
ELSE PRINT '--  metodo_pago_metodo_UX ya existia.';
GO

-- ===========================================================================
-- 10. CREDITO Y TABLAS PUENTE
-- ===========================================================================
-- Un socio no puede tener dos veces la misma cuota.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'credito_socio_cuota_UX')
BEGIN
    CREATE UNIQUE INDEX credito_socio_cuota_UX
        ON dbo.credito_inscripcion (socio_id_socio, num_cuota);
    PRINT 'OK  credito_socio_cuota_UX creado.';
END
ELSE PRINT '--  credito_socio_cuota_UX ya existia.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'rol_permiso_UX')
BEGIN
    CREATE UNIQUE INDEX rol_permiso_UX ON dbo.rol_permiso (rol_id_rol, permiso_id_permiso);
    PRINT 'OK  rol_permiso_UX creado.';
END
ELSE PRINT '--  rol_permiso_UX ya existia.';
GO

-- Una notificacion se asigna una sola vez a cada socio; si no, el socio la ve
-- repetida y el contador de "sin leer" del portal la cuenta dos veces.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'notificacion_socio_UX')
BEGIN
    CREATE UNIQUE INDEX notificacion_socio_UX
        ON dbo.notificacion_socio (notificacion_id_notificacion, socio_id_socio);
    PRINT 'OK  notificacion_socio_UX creado.';
END
ELSE PRINT '--  notificacion_socio_UX ya existia.';
GO

PRINT '';
PRINT '=== Migracion 15 aplicada. Indices unicos de negocio activos. ===';
GO
