CREATE OR ALTER PROCEDURE dbo.sp_obtener_estadisticas_dashboard
    @periodo VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_periodo INT;
    SELECT @id_periodo = id_periodo FROM periodo WHERE periodo = @periodo;

    SELECT
        (SELECT COUNT(*) FROM socio)         AS TotalSocios,
        (SELECT COUNT(*) FROM cliente)       AS TotalClientes,
        (SELECT COUNT(*) FROM medidor)       AS TotalMedidores,
        (SELECT COUNT(*) FROM ruta)          AS TotalRutas,
        (SELECT COUNT(*) FROM usuario_admin) AS TotalUsuarios,
        (SELECT COUNT(*) FROM lectura WHERE periodo_id_periodo = ISNULL(@id_periodo, 0)) AS TotalLecturas,
        (SELECT COUNT(*) FROM aviso  WHERE periodo_id_periodo = ISNULL(@id_periodo, 0)) AS TotalAvisos;
END
