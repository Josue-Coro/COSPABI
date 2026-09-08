USE [COSPABIRL1]
GO
-- =============================================================================
-- Migracion 18 - permisos del modulo Personas (antes "Cliente")
-- Cambio de datos, no de esquema. Completa la Migracion 17: la tabla ya se
-- llama persona y el codigo ya dice Persona, pero los nombres de permiso son
-- filas de 'permiso' que los atributos [ValidarPermisos] deben calzar letra
-- por letra. Los ids y las asignaciones en rol_permiso no cambian.
-- Idempotente: cada UPDATE filtra por el nombre viejo.
-- =============================================================================
UPDATE permiso SET accion = 'Gestionar Persona', descripcion = 'Gestion de personas'          WHERE accion = 'Gestionar Cliente';
UPDATE permiso SET accion = 'Registrar Persona', descripcion = 'Crear nuevas personas'        WHERE accion = 'Registrar Cliente';
UPDATE permiso SET accion = 'Editar Persona',    descripcion = 'Modificar personas existentes' WHERE accion = 'Editar Cliente';
UPDATE permiso SET accion = 'Eliminar Persona',  descripcion = 'Eliminar personas existentes'  WHERE accion = 'Eliminar Cliente';

-- El modulo agrupa Personas + Socios (Migracion 09): el nombre viejo repetia
-- la palabra observada en la defensa.
UPDATE permiso SET modulo = 'Personas y Socios' WHERE modulo = N'Atención al Cliente';
GO
SELECT id_permiso, accion, descripcion, modulo FROM permiso WHERE modulo = 'Personas y Socios' ORDER BY id_permiso;
GO
