USE [COSPABIRL1]
GO

-- =============================================
-- LISTAR TODOS LOS PERMISOS (agrupados por módulo)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_permisos]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_permiso, accion, descripcion, modulo
    FROM [dbo].[permiso]
    ORDER BY
        CASE modulo
            WHEN 'Administración'      THEN 1
            WHEN 'Atención al Cliente' THEN 2
            WHEN 'Operaciones'         THEN 3
            WHEN 'Caja y Pagos'        THEN 4
            WHEN 'Configuración'       THEN 5
            WHEN 'Portal de Socios'    THEN 6
            WHEN 'Reportes'            THEN 7
            ELSE 99
        END,
        accion
END
GO

-- =============================================
-- LISTAR PERMISOS DE UN ROL ESPECÍFICO
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_permisos_por_rol]
    @id_rol INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.id_permiso, p.accion, p.descripcion
    FROM [dbo].[permiso] p
    INNER JOIN [dbo].[rol_permiso] rp ON rp.permiso_id_permiso = p.id_permiso
    WHERE rp.rol_id_rol = @id_rol
END
GO

-- =============================================
-- GUARDAR PERMISOS DE UN ROL (SYNC COMPLETO)
-- Usa un TVP para recibir la lista de permisos seleccionados
-- =============================================

-- Primero crear el tipo de tabla (solo si no existe)
IF TYPE_ID('dbo.TVP_IdsPermisos') IS NULL
    CREATE TYPE [dbo].[TVP_IdsPermisos] AS TABLE
    (
        id_permiso INT NOT NULL
    )
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_guardar_permisos_rol]
    @id_rol         INT,
    @TVP_Permisos   [dbo].[TVP_IdsPermisos] READONLY,
    @Resultado      INT OUTPUT,
    @Mensaje        VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    -- 1. Validación
    IF @id_rol IS NULL OR @id_rol = 0
    BEGIN
        SET @Mensaje   = 'ID de Rol no especificado.';
        SET @Resultado = 0;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @id_rol)
    BEGIN
        SET @Mensaje   = 'El rol especificado no existe.';
        SET @Resultado = 0;
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY

        -- 2. REVOCAR: eliminar permisos que el rol tiene pero que NO vienen en el TVP
        DELETE RP
        FROM [dbo].[rol_permiso] RP
        LEFT JOIN @TVP_Permisos TVP ON RP.permiso_id_permiso = TVP.id_permiso
        WHERE RP.rol_id_rol = @id_rol
          AND TVP.id_permiso IS NULL;

        -- 3. ASIGNAR: insertar permisos del TVP que el rol aún NO tiene
        INSERT INTO [dbo].[rol_permiso] (rol_id_rol, permiso_id_permiso)
        SELECT @id_rol, TVP.id_permiso
        FROM @TVP_Permisos TVP
        LEFT JOIN [dbo].[rol_permiso] RP 
            ON RP.permiso_id_permiso = TVP.id_permiso 
           AND RP.rol_id_rol = @id_rol
        WHERE RP.rol_id_rol IS NULL;

        COMMIT TRANSACTION;
        SET @Resultado = 1;
        SET @Mensaje   = 'Permisos actualizados correctamente.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO