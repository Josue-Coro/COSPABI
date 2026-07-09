USE [COSPABIRL1]
GO

-- =====================================================================
-- Migración 09: columna "modulo" en la tabla permiso
-- Agrupa los permisos por módulo del sistema para la UI de Permisos.
-- Idempotente: se puede re-ejecutar sin problema.
-- =====================================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.permiso') AND name = 'modulo'
)
BEGIN
    ALTER TABLE dbo.permiso ADD modulo VARCHAR(100) NULL;
END
GO

-- ===== Clasificación por módulo (alineada al menú del sistema) =====

-- Administración: usuarios, roles, permisos, bitácora
UPDATE dbo.permiso SET modulo = 'Administración'
WHERE accion IN ('Gestionar Usuarios','Crear Usuario','Editar Usuario','Desactivar Usuario',
                 'Gestionar Rol','Crear Rol','Editar Rol','Desactivar Rol',
                 'Gestionar Permiso','Visualizar Bitacora');

-- Atención al Cliente: clientes y socios
UPDATE dbo.permiso SET modulo = 'Atención al Cliente'
WHERE accion IN ('Gestionar Cliente','Registrar Cliente','Editar Cliente','Eliminar Cliente',
                 'Gestionar Socio','Registrar Socio','Editar Socio','Eliminar Socio');

-- Operaciones: lecturas, avisos, cargos extra, rutas
UPDATE dbo.permiso SET modulo = 'Operaciones'
WHERE accion IN ('Gestionar Lecturas','Registrar Lecturas',
                 'Gestionar Avisos','Anular Avisos',
                 'Gestionar Cargo Extra','Gestionar Ruta');

-- Caja y Pagos: caja, pagos, crédito de inscripción
UPDATE dbo.permiso SET modulo = 'Caja y Pagos'
WHERE accion IN ('Gestionar Caja','Gestionar Pago','Gestionar Credito Inscripcion');

-- Configuración: tarifas, tipos de cargo, medidores
UPDATE dbo.permiso SET modulo = 'Configuración'
WHERE accion IN ('Gestionar Tarifa','Editar Tarifa',
                 'Gestionar TipoCargo','Editar Tipo Cargo',
                 'Gestionar Medidor');

-- Portal de Socios: cuentas, notificaciones, métodos de pago
UPDATE dbo.permiso SET modulo = 'Portal de Socios'
WHERE accion IN ('Gestionar Cuenta Socio','Gestionar Notificaciones','Gestionar Metodo Pago');

-- Reportes
UPDATE dbo.permiso SET modulo = 'Reportes'
WHERE accion IN ('Generar Reporte Caja','Generar Reporte Morosidad');

-- Fallback: cualquier permiso futuro sin clasificar
UPDATE dbo.permiso SET modulo = 'Otros' WHERE modulo IS NULL;
GO
