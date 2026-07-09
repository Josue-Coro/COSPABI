USE [COSPABIRL1]
GO

-- =============================================
-- 1. sp_existe_aviso_activo
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_existe_aviso_activo
    @idSocio INT,
    @idPeriodo INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 1 FROM aviso 
    WHERE socio_id_socio = @idSocio 
      AND periodo_id_periodo = @idPeriodo 
      AND estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO');
END
GO

-- =============================================
-- 2. sp_listar_estados
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_listar_estados
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT id_estado, estado 
    FROM estado 
    ORDER BY id_estado;
END
GO

-- =============================================
-- 3. sp_buscar_socios_cargo
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_buscar_socios_cargo
    @Busqueda NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 10 id_socio, nombre_socio, codigo_fijo
    FROM socio
    WHERE nombre_socio LIKE '%' + @Busqueda + '%'
       OR CAST(codigo_fijo AS VARCHAR) LIKE '%' + @Busqueda + '%'
    ORDER BY codigo_fijo;
END
GO

-- =============================================
-- 4. sp_obtener_costo_inscripcion_vigente
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_obtener_costo_inscripcion_vigente
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 1 costo_inscripcion 
    FROM periodo 
    WHERE costo_inscripcion IS NOT NULL 
    ORDER BY id_periodo DESC;
END
GO
