USE [COSPABIRL1]
GO

-- =============================================================================
-- TARIFA  (una tarifa por rol_socio: consumo_minimo_m3 / monto_minimo / precio_m3)
--
-- Las tarifas NO se siembran desde aqui: las filas ya existen en la base. Este
-- archivo solo define procedimientos y es re-ejecutable (CREATE OR ALTER).
-- =============================================================================

-- =============================================
-- LISTAR TARIFAS
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_listar_tarifa]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        u.id_tarifa,
        u.consumo_minimo_m3,
        u.monto_minimo,
        u.precio_m3,
        u.rol_socio_id_rol_socio,
        r.rol_socio AS nombre_rol
    FROM [dbo].[tarifa] u
    -- El JOIN unia rol_socio.id_rol_socio contra tarifa.id_tarifa (la PK de la
    -- tarifa, no su FK). Coincidia por casualidad mientras id_tarifa y
    -- rol_socio_id_rol_socio llevaban el mismo valor; con una tarifa mas, el
    -- listado mostraba el rol equivocado o perdia la fila.
    INNER JOIN [dbo].[rol_socio] r ON r.id_rol_socio = u.rol_socio_id_rol_socio
END
GO

-- =============================================
-- EDITAR TARIFA
-- =============================================
-- consumo_minimo_m3 y precio_m3 son INT en la tabla: los parametros son INT.
-- monto_minimo es DECIMAL(30,3) en la tabla y si admite decimales.
CREATE OR ALTER PROCEDURE [dbo].[sp_editar_tarifa]
    @id_tarifa INT,
    @consumo_minimo_m3 INT,
    @monto_minimo DECIMAL(18,3),
    @precio_m3 INT,
    @rol_socio_id_rol_socio INT,
    @Resultado INT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[tarifa] WHERE id_tarifa = @id_tarifa)
    BEGIN
        SET @Mensaje = 'No existe una tarifa con este ID.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM [dbo].tarifa
               WHERE rol_socio_id_rol_socio = @rol_socio_id_rol_socio AND id_tarifa <> @id_tarifa)
    BEGIN
        SET @Mensaje = 'Ya existe otra tarifa con ese rol de socio.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[rol_socio] WHERE id_rol_socio = @rol_socio_id_rol_socio)
    BEGIN
        SET @Mensaje = 'El rol seleccionado no existe.';
        RETURN;
    END

    UPDATE [dbo].[tarifa]
    SET
        consumo_minimo_m3      = @consumo_minimo_m3,
        monto_minimo           = @monto_minimo,
        precio_m3              = @precio_m3,
        rol_socio_id_rol_socio = @rol_socio_id_rol_socio
    WHERE id_tarifa = @id_tarifa;

    SET @Resultado = 1;
    SET @Mensaje   = 'Tarifa actualizada correctamente.';
END
GO
