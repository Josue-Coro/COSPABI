USE [COSPABIRL1]
GO

-- =============================================================================
-- Migracion 13 : soporte para los PAGOS DEL SISTEMA (QR pagado desde el portal
--                del socio, sin caja fisica).
--
--   1) permiso 'Generar Reporte Pagos Sistema' (modulo Reportes) + asignacion
--      al rol SUPERADMIN, que debe tener siempre la totalidad de los permisos.
--   2) usuario_admin 'SISTEMA' (rol CAJERO): dueno de la bitacora de las
--      acciones que nacen en el portal, donde no hay un usuario humano.
--      Se crea INACTIVO y con una contrasena imposible: sp_login_admin corta
--      por estado = 0 antes de comparar el hash, y el hash guardado no es un
--      SHA-256 valido, asi que ningun texto puede producirlo.
--   3) metodo_pago id 1 'QR': se renombra. Convivia con 'QR LIBELULA' y en el
--      combo de cobro el cajero veia dos opciones llamadas casi igual. Sus 5
--      pagos historicos NO tienen id_transaccion: son transferencias de banco
--      registradas a mano, no cobros de la pasarela. Por eso se renombra en
--      vez de fusionarse: reasignarlos a 'QR LIBELULA' falsearia el historico,
--      y borrar la fila es imposible (la referencian esos pagos).
--
-- Idempotente: se puede re-ejecutar sin efectos secundarios.
-- Desplegar con:  sqlcmd -f 65001 -I -i Migracion_13_pagos_sistema.sql
-- =============================================================================

-- PASO 1: permiso del reporte de pagos del sistema ----------------------------
IF NOT EXISTS (SELECT 1 FROM permiso WHERE accion = 'Generar Reporte Pagos Sistema')
BEGIN
    INSERT INTO permiso (accion, descripcion, modulo)
    VALUES ('Generar Reporte Pagos Sistema',
            'Ver el reporte de pagos cobrados por el sistema (portal del socio)',
            'Reportes');
    PRINT 'Permiso "Generar Reporte Pagos Sistema" creado.';
END
ELSE
    PRINT 'El permiso "Generar Reporte Pagos Sistema" ya existia.';
GO

-- SUPERADMIN conserva TODOS los permisos (incluye el recien creado)
INSERT INTO rol_permiso (rol_id_rol, permiso_id_permiso)
SELECT r.id_rol, p.id_permiso
FROM rol r
CROSS JOIN permiso p
WHERE r.nombre = 'SUPERADMIN'
  AND NOT EXISTS (SELECT 1 FROM rol_permiso rp
                  WHERE rp.rol_id_rol = r.id_rol
                    AND rp.permiso_id_permiso = p.id_permiso);
PRINT 'Permisos de SUPERADMIN sincronizados.';
GO

-- PASO 2: usuario SISTEMA (autor de la bitacora del portal) -------------------
IF NOT EXISTS (SELECT 1 FROM usuario_admin WHERE usuario = 'SISTEMA')
BEGIN
    DECLARE @id_rol_cajero INT = (SELECT TOP 1 id_rol FROM rol WHERE nombre = 'CAJERO');

    IF @id_rol_cajero IS NULL
        PRINT 'ERROR: no existe el rol CAJERO; no se creo el usuario SISTEMA.';
    ELSE
    BEGIN
        INSERT INTO usuario_admin
            (nombre, apellido, usuario, [contraseña], estado, fecha_creacion,
             rol_id_rol, intentos_fallidos, bloqueado_hasta)
        VALUES
            ('SISTEMA', 'COSPABI', 'SISTEMA',
             'NO-LOGIN',            -- no es un SHA-256: no hay clave que coincida
             0,                     -- inactivo: sp_login_admin corta aqui
             CAST(GETDATE() AS DATE),
             @id_rol_cajero, 0, NULL);
        PRINT 'Usuario SISTEMA creado (rol CAJERO, inactivo).';
    END
END
ELSE
    PRINT 'El usuario SISTEMA ya existia.';
GO

-- PASO 3: desambiguar el metodo de pago QR legado -----------------------------
UPDATE metodo_pago
SET metodo     = 'Transferencia QR (banco)',
    referencia = 'Transferencia bancaria por QR registrada manualmente en caja'
WHERE id_metodo_pago = 1
  AND metodo = 'QR';
GO

PRINT '--- Migracion 13 aplicada ---';
GO

-- Verificacion:
-- SELECT id_metodo_pago, metodo FROM metodo_pago;
-- SELECT usuario, estado FROM usuario_admin WHERE usuario = 'SISTEMA';
-- SELECT accion, modulo FROM permiso WHERE modulo = 'Reportes';
