-- ============================================================================
-- Migración 05 — Normalizar tipo_instalacion y dim_instalacion en socio
-- ----------------------------------------------------------------------------
-- Alinea los datos existentes (que antes eran texto libre) con las opciones
-- de los nuevos <select> de CrearSocio.cshtml / EditarSocio.cshtml.
--
--   tipo_instalacion  ->  PVC | CPVC | Polipropileno | Tubería negra
--   dim_instalacion   ->  1/2 pulgada | 3/4 pulgada | 1 pulgada
--
-- Decisión del usuario: los valores 'Domiciliaria' (no son un material) se
-- convierten a 'PVC'.
--
-- Re-ejecutable (idempotente): vuelve a fijar los valores canónicos.
-- Nota: la collation por defecto es Case-Insensitive, así que 'pvc' = 'PVC'
-- en las comparaciones; los UPDATE simplemente reescriben la forma canónica.
-- ============================================================================

-- 1) Diagnóstico ANTES -------------------------------------------------------
SELECT 'ANTES - tipo' AS info, tipo_instalacion AS valor, COUNT(*) AS cantidad
FROM socio GROUP BY tipo_instalacion;

SELECT 'ANTES - dim'  AS info, dim_instalacion  AS valor, COUNT(*) AS cantidad
FROM socio GROUP BY dim_instalacion;
GO

-- 2) Normalizar TIPO DE INSTALACIÓN (material de cañería) ---------------------
UPDATE socio SET tipo_instalacion = 'PVC'
WHERE tipo_instalacion IN ('pvc', 'Domiciliaria');     -- 'Domiciliaria' -> PVC

UPDATE socio SET tipo_instalacion = 'CPVC'
WHERE tipo_instalacion = 'cpvc';

UPDATE socio SET tipo_instalacion = 'Polipropileno'
WHERE tipo_instalacion = 'polipropileno';

UPDATE socio SET tipo_instalacion = N'Tubería negra'
WHERE tipo_instalacion IN ('tuberia negra', N'tubería negra', 'tuveria negra');
GO

-- 3) Normalizar DIMENSIÓN DE INSTALACIÓN -------------------------------------
UPDATE socio SET dim_instalacion = '1/2 pulgada'
WHERE dim_instalacion IN ('1/2', '1/2"', '1/2 pulg');

UPDATE socio SET dim_instalacion = '3/4 pulgada'
WHERE dim_instalacion IN ('3/4', '3/4"', '3/4 pulg');

UPDATE socio SET dim_instalacion = '1 pulgada'
WHERE dim_instalacion IN ('1', '1"', '1 pulg');
GO

-- 4) Verificación DESPUÉS — deberían quedar solo los valores canónicos -------
SELECT 'DESPUES - tipo' AS info, tipo_instalacion AS valor, COUNT(*) AS cantidad
FROM socio GROUP BY tipo_instalacion;

SELECT 'DESPUES - dim'  AS info, dim_instalacion  AS valor, COUNT(*) AS cantidad
FROM socio GROUP BY dim_instalacion;
GO
