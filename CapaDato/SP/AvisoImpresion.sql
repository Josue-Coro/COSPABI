USE [COSPABIRL1]
GO

-- =============================================================================
-- sp_imprimir_aviso
-- -----------------------------------------------------------------------------
-- Devuelve TODOS los datos para imprimir un "Aviso de Cobranza" (media carta),
-- al estilo del recibo físico de COSPABI. Tres result sets:
--   1) Cabecera ampliada (socio + lectura + tarifa + totales + cuota crédito).
--   2) Cargos extra estampados en el aviso (incluye la "TASA AFCOOP" que hoy se
--      maneja como cargo extra). Alimentan "DATOS FACTURADOS".
--   3) Histórico: últimos 12 avisos del socio (mes, N° factura = id_aviso,
--      consumo m³, total, fecha de pago y estado Pag./Imp.).
--
-- NO modifica sp_detalle_aviso (ese sigue alimentando el modal "Ver detalle").
-- Re-ejecutable (CREATE OR ALTER).
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_imprimir_aviso
    @id_aviso INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_socio INT = (SELECT socio_id_socio FROM aviso WHERE id_aviso = @id_aviso);

    -- 1) CABECERA -------------------------------------------------------------
    SELECT
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_consumo,
        a.total_aviso,
        a.deuda_actual,
        e.estado        AS estado,
        e.estado        AS nombre_estado,
        -- Socio
        s.id_socio,
        s.codigo_fijo,
        s.nombre_socio,
        s.ubicacion,                 -- COD. UB
        s.num_casa,
        s.categoria,
        s.actividad,
        -- Ruta y Período
        r.ruta          AS nombre_ruta,
        p.periodo       AS nombre_periodo,
        -- Medidor y Lectura
        m.serie         AS serie_medidor,
        l.lectura_anterior,
        l.lectura_actual,
        l.consumo_m3,
        l.dias_lectura,
        l.fecha_lectura                                 AS fecha_lectura_actual,
        DATEADD(DAY, -l.dias_lectura, l.fecha_lectura)  AS fecha_lectura_anterior,
        -- Tarifa y Rol
        rs.rol_socio    AS nombre_rol,
        t.monto_minimo,
        t.consumo_minimo_m3,
        t.precio_m3,
        -- Suma de cargos extra del socio en el periodo (1:N)
        ISNULL((SELECT SUM(ce.monto) FROM cargo_extra ce
                WHERE ce.socio_id_socio = a.socio_id_socio
                  AND ce.periodo_id_periodo = a.periodo_id_periodo), 0) AS total_cargos,
        -- Cuota de crédito de inscripción (0..1)
        ci.monto_pago   AS monto_credito
    FROM aviso a
    INNER JOIN socio     s  ON s.id_socio               = a.socio_id_socio
    INNER JOIN ruta      r  ON r.id_ruta                = s.ruta_id_ruta
    INNER JOIN periodo   p  ON p.id_periodo             = a.periodo_id_periodo
    INNER JOIN estado    e  ON e.id_estado              = a.estado_id_estado
    INNER JOIN lectura   l  ON l.id_lectura             = a.lectura_id_lectura
    INNER JOIN medidor   m  ON m.id_medidor             = l.medidor_id_medidor
    INNER JOIN rol_socio rs ON rs.id_rol_socio          = s.rol_socio_id_rol_socio
    INNER JOIN tarifa    t  ON t.rol_socio_id_rol_socio = s.rol_socio_id_rol_socio
    LEFT  JOIN credito_inscripcion ci 
        ON ci.socio_id_socio = a.socio_id_socio
       AND ci.periodo_id_periodo = a.periodo_id_periodo
    WHERE a.id_aviso = @id_aviso;

    -- 2) CARGOS EXTRA (Datos Facturados) --------------------------------------
    DECLARE @socio_id INT, @periodo_id INT;
    SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo FROM aviso WHERE id_aviso = @id_aviso;

    SELECT
        ce.id_cargo_extra,
        ce.monto,
        ce.descripcion,
        tc.nombre AS nombre_tipo_cargo
    FROM cargo_extra ce
    INNER JOIN tipo_cargo tc ON tc.id_tipo = ce.tipo_cargo_id_tipo
    WHERE ce.socio_id_socio = @socio_id
      AND ce.periodo_id_periodo = @periodo_id
    ORDER BY ce.id_cargo_extra;

    -- 3) HISTÓRICO (últimos 12 avisos del socio) ------------------------------
    SELECT TOP (12)
        av.id_aviso,
        p2.periodo        AS nombre_periodo,
        l2.consumo_m3,
        av.total_aviso,
        pg.fecha_pago,
        CASE WHEN pg.id_pago IS NOT NULL THEN 'Pag.' ELSE 'Imp.' END AS estado_pago_label,
        e2.estado         AS estado
    FROM aviso av
    INNER JOIN periodo p2 ON p2.id_periodo = av.periodo_id_periodo
    INNER JOIN lectura l2 ON l2.id_lectura = av.lectura_id_lectura
    INNER JOIN estado  e2 ON e2.id_estado  = av.estado_id_estado
    OUTER APPLY (
        SELECT TOP (1) pa.id_pago, pa.fecha_pago
        FROM pago pa
        WHERE pa.aviso_id_aviso = av.id_aviso
          AND pa.estado_pago = 'APROBADO'
        ORDER BY pa.id_pago DESC
    ) pg
    WHERE av.socio_id_socio = @id_socio
      AND av.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
    ORDER BY av.fecha_emision DESC, av.id_aviso DESC;
END
GO


--EXEC dbo.sp_imprimir_aviso 30;   -- usá un id_aviso que exista


-- =============================================================================
-- sp_marcar_aviso_impreso
-- -----------------------------------------------------------------------------
-- Avanza el aviso al estado IMPRESO de forma AUTOMATICA, al abrir la vista de
-- impresion. Reemplaza el cambio manual de estado que hacia el select de la
-- pantalla de Avisos (LECTURADO / IMPRESO).
--
-- Es idempotente y no lanza error: si el aviso ya esta IMPRESO, PAGADO o
-- ANULADO simplemente no hace nada y devuelve @Resultado = 0. Solo avanza desde
-- GENERADO o LECTURADO (LECTURADO queda por compatibilidad con avisos viejos;
-- los nuevos nacen GENERADO y ya implican lectura registrada).
--
-- @Resultado = 1 -> el estado cambio realmente (la capa CN registra bitacora).
-- @Resultado = 0 -> no habia nada que cambiar (o el aviso no existe).
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_marcar_aviso_impreso
    @id_aviso  INT,
    @Resultado INT          OUTPUT,
    @Mensaje   VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        DECLARE @estado_actual VARCHAR(150);
        SELECT @estado_actual = e.estado
        FROM aviso a
        INNER JOIN estado e ON e.id_estado = a.estado_id_estado
        WHERE a.id_aviso = @id_aviso;

        IF @estado_actual IS NULL
        BEGIN
            SET @Mensaje = 'Aviso no encontrado.';
            RETURN;
        END

        IF @estado_actual NOT IN ('GENERADO', 'LECTURADO')
        BEGIN
            SET @Mensaje = 'El aviso ya estaba en estado ' + @estado_actual + '.';
            RETURN;
        END

        DECLARE @id_impreso INT;
        SELECT @id_impreso = id_estado FROM estado WHERE estado = 'IMPRESO';

        IF @id_impreso IS NULL
        BEGIN
            SET @Mensaje = 'Tabla estado no inicializada (falta IMPRESO).';
            RETURN;
        END

        UPDATE aviso
        SET estado_id_estado = @id_impreso
        WHERE id_aviso = @id_aviso;

        SET @Resultado = 1;
        SET @Mensaje   = 'Aviso marcado como IMPRESO.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO