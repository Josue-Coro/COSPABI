USE [COSPABIRL1]
GO

SELECT [id_tarifa]
      ,[consumo_minimo_m3]
      ,[monto_minimo]
      ,[precio_m3]
      ,[rol_socio_id_rol_socio]
  FROM [dbo].[tarifa]

GO


-- =============================================
-- LISTAR TARIFAS
-- =============================================
CREATE PROCEDURE [dbo].[sp_listar_tarifa]
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
    INNER JOIN [dbo].[rol_socio] r ON r.id_rol_socio = u.id_tarifa
END
GO


--insertamos  tarifa para cada rol ya definido en la tabla rol_socio ("SOCIO", "USUARIO") solo esos 2 van a existir en la tabla rol_socio
insert into tarifa (consumo_minimo_m3, monto_minimo, precio_m3, rol_socio_id_rol_socio) values (10.00, 50.00, 5.00, 1)
insert into tarifa (consumo_minimo_m3, monto_minimo, precio_m3, rol_socio_id_rol_socio) values (15.00, 75.00, 7.00, 2)
go
-- =============================================
-- EDITAR TARIFA
-- =============================================

CREATE PROCEDURE [dbo].[sp_editar_tarifa]
    @id_tarifa INT,
    @consumo_minimo_m3 DECIMAL(18,2),
    @monto_minimo DECIMAL(18,2),
    @precio_m3 DECIMAL(18,2),
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
        consumo_minimo_m3 = @consumo_minimo_m3,
        monto_minimo      = @monto_minimo,
        precio_m3        = @precio_m3,
        rol_socio_id_rol_socio = @rol_socio_id_rol_socio
    WHERE id_tarifa = @id_tarifa;

    SET @Resultado = 1;
    SET @Mensaje   = 'Tarifa actualizada correctamente.';
END
GO
      
--probar el procedimiento almacenado de editar tarifa
DECLARE @Resultado INT, @Mensaje VARCHAR(500);

EXEC [dbo].[sp_editar_tarifa] 
    @id_tarifa = 1, 
    @consumo_minimo_m3 = 12.00, 
    @monto_minimo = 60.00, 
    @precio_m3 = 6.00, 
    @rol_socio_id_rol_socio = 1, 
    @Resultado = @Resultado OUTPUT, 
    @Mensaje = @Mensaje OUTPUT;
