USE [COSPABIRL1]
GO

-- =============================================================================
-- sp_registrar_socio_con_inscripcion  (Fase B)
-- Registra un socio nuevo y, en la MISMA transaccion, su credito de inscripcion:
--   * Cuota 1 = pago inicial (entero, min 500), estado CANCELADO, periodo de registro.
--   * Registra ese pago en 'pago' (sin aviso).
--   * Divide el saldo (costo - inicial) en (num_cuotas - 1) cuotas PENDIENTE,
--     enteras, resto a la ultima, en los periodos consecutivos siguientes
--     (creando los periodos que falten).
-- Reglas: total de cuotas 1..4 (1 = pago total). Costo = periodo.costo_inscripcion.
-- @Resultado = id_socio nuevo (>0) | 0 validacion | -1 excepcion.
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_registrar_socio_con_inscripcion
    -- datos del socio
    @nombre_socio            VARCHAR(255),
    @cliente_id_cliente      INT,
    @rol_socio_id_rol_socio  INT,
    @ubicacion               INT           = NULL,
    @medidor_id_medidor      INT           = NULL,
    @num_casa                INT           = NULL,
    @num_ocupantes           INT           = NULL,
    @tipo_instalacion        VARCHAR(255)  = NULL,
    @dim_instalacion         VARCHAR(255)  = NULL,
    @actividad               VARCHAR(255),
    @categoria               VARCHAR(255),
    @fecha_registro          DATE,
    @ruta_id_ruta            INT,
    @codigo_fijo             INT,
    -- datos de la inscripcion
    @monto_inicial           DECIMAL(10,2),
    @num_cuotas              INT,            -- total de cuotas (1 a 4). 1 = pago total.
    @id_metodo_pago          INT,
    @id_caja                 INT,
    @cajero                  VARCHAR(150),
    -- salida
    @Resultado               INT           OUTPUT,
    @Mensaje                 NVARCHAR(500) OUTPUT,
    @IdPago                  INT           = NULL OUTPUT   -- id del pago inicial (para el recibo)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    SET @IdPago    = 0;

    DECLARE @MAX_CUOTAS  INT           = 4;
    DECLARE @MIN_INICIAL DECIMAL(10,2) = 500;

    BEGIN TRY
        -- ===== Validaciones del socio =====
        IF NOT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = @cliente_id_cliente)
        BEGIN SET @Mensaje = 'El cliente seleccionado no existe.'; RETURN; END

        -- Regla institucional: una persona puede tener como máximo 4 socios (4 medidores)
        IF (SELECT COUNT(*) FROM socio WHERE cliente_id_cliente = @cliente_id_cliente) >= 4
        BEGIN SET @Mensaje = 'Esta persona ya alcanzó el máximo de 4 socios (medidores) permitidos.'; RETURN; END

        IF @medidor_id_medidor IS NOT NULL AND EXISTS (SELECT 1 FROM socio WHERE medidor_id_medidor = @medidor_id_medidor)
        BEGIN SET @Mensaje = 'El medidor seleccionado ya está asignado a otro socio.'; RETURN; END

        IF EXISTS (SELECT 1 FROM socio WHERE codigo_fijo = @codigo_fijo)
        BEGIN SET @Mensaje = 'El código fijo ingresado ya existe.'; RETURN; END

        IF EXISTS (SELECT 1 FROM socio WHERE LTRIM(RTRIM(nombre_socio)) = LTRIM(RTRIM(@nombre_socio)))
        BEGIN SET @Mensaje = 'Ya existe un socio registrado con ese nombre.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM metodo_pago WHERE id_metodo_pago = @id_metodo_pago)
        BEGIN SET @Mensaje = 'El método de pago seleccionado no existe.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'Debe tener una caja abierta para registrar la inscripción.'; RETURN; END

        -- ===== Periodo de registro y costo de inscripcion vigente =====
        DECLARE @baseDate   DATE        = DATEFROMPARTS(YEAR(@fecha_registro), MONTH(@fecha_registro), 1);
        DECLARE @periodoReg VARCHAR(50) = FORMAT(@baseDate, 'MM/yyyy');

        DECLARE @id_periodo_reg INT;
        EXEC dbo.sp_obtener_o_crear_periodo @periodoReg, @id_periodo_reg OUTPUT;

        DECLARE @costo DECIMAL(10,2);
        SELECT @costo = costo_inscripcion FROM periodo WHERE id_periodo = @id_periodo_reg;
        IF @costo IS NULL   -- fallback: ultimo costo configurado
            SELECT TOP 1 @costo = costo_inscripcion FROM periodo
            WHERE costo_inscripcion IS NOT NULL ORDER BY id_periodo DESC;

        IF @costo IS NULL
        BEGIN SET @Mensaje = 'No hay un costo de inscripción configurado en periodo.costo_inscripcion.'; RETURN; END

        -- ===== Validaciones de la inscripcion =====
        IF @monto_inicial <> FLOOR(@monto_inicial)
        BEGIN SET @Mensaje = 'El monto inicial debe ser un número entero (sin decimales).'; RETURN; END

        IF @monto_inicial < @MIN_INICIAL
        BEGIN SET @Mensaje = 'El pago inicial mínimo es Bs. ' + CAST(CAST(@MIN_INICIAL AS INT) AS VARCHAR) + '.'; RETURN; END

        IF @monto_inicial > @costo
        BEGIN SET @Mensaje = 'El pago inicial no puede superar el costo de inscripción (Bs. ' + CAST(CAST(@costo AS INT) AS VARCHAR) + ').'; RETURN; END

        IF @num_cuotas < 1 OR @num_cuotas > @MAX_CUOTAS
        BEGIN SET @Mensaje = 'El número de cuotas debe estar entre 1 y ' + CAST(@MAX_CUOTAS AS VARCHAR) + '.'; RETURN; END

        DECLARE @saldo DECIMAL(10,2) = @costo - @monto_inicial;

        IF @saldo = 0 AND @num_cuotas <> 1
        BEGIN SET @Mensaje = 'Si paga el total, debe registrarse como 1 sola cuota.'; RETURN; END

        IF @saldo > 0 AND @num_cuotas < 2
        BEGIN SET @Mensaje = 'Hay saldo a financiar: elija entre 2 y ' + CAST(@MAX_CUOTAS AS VARCHAR) + ' cuotas.'; RETURN; END

        -- ===== Transaccion =====
        BEGIN TRAN;

        -- 1) Socio
        INSERT INTO socio (
            nombre_socio, cliente_id_cliente, rol_socio_id_rol_socio,
            ubicacion, medidor_id_medidor, num_casa, num_ocupantes,
            tipo_instalacion, dim_instalacion, actividad, categoria,
            fecha_registro, ruta_id_ruta, codigo_fijo, estado
        )
        VALUES (
            @nombre_socio, @cliente_id_cliente, @rol_socio_id_rol_socio,
            @ubicacion, @medidor_id_medidor, @num_casa, @num_ocupantes,
            @tipo_instalacion, @dim_instalacion, @actividad, @categoria,
            @fecha_registro, @ruta_id_ruta, @codigo_fijo, 1
        );
        DECLARE @id_socio INT = SCOPE_IDENTITY();

        -- 2) Registrar el pago inicial (sin aviso, en la caja abierta). Efectivo -> APROBADO.
        INSERT INTO pago (fecha_pago, monto_pagado, cajero, estado_pago, aviso_id_aviso, metodo_pago_id_metodo_pago, vuelto, caja_id_caja)
        VALUES (@fecha_registro, @monto_inicial, @cajero, 'APROBADO', NULL, @id_metodo_pago, NULL, @id_caja);
        SET @IdPago = CAST(SCOPE_IDENTITY() AS INT);

        -- 3) Cuota inicial: CANCELADO, en el periodo de registro, ligada a su pago
        INSERT INTO credito_inscripcion (monto_pago, estado, num_cuota, socio_id_socio, periodo_id_periodo, pago_id_pago)
        VALUES (@monto_inicial, 'CANCELADO', 1, @id_socio, @id_periodo_reg, @IdPago);

        -- 4) Cuotas financiadas: PENDIENTE, en los periodos siguientes
        IF @saldo > 0
        BEGIN
            DECLARE @financiadas INT = @num_cuotas - 1;
            DECLARE @base INT = CAST(FLOOR(@saldo / @financiadas) AS INT);
            DECLARE @resto INT = CAST(@saldo AS INT) - (@base * @financiadas);

            DECLARE @i          INT = 2;
            DECLARE @perNombre  VARCHAR(50);
            DECLARE @idPer      INT;
            DECLARE @montoCuota INT;

            WHILE @i <= @num_cuotas
            BEGIN
                SET @perNombre = FORMAT(DATEADD(MONTH, @i - 1, @baseDate), 'MM/yyyy');
                SET @idPer     = NULL;   -- evitar id stale entre iteraciones
                EXEC dbo.sp_obtener_o_crear_periodo @perNombre, @idPer OUTPUT;

                SET @montoCuota = @base;
                IF @i = @num_cuotas SET @montoCuota = @base + @resto;   -- la ultima absorbe el resto

                INSERT INTO credito_inscripcion (monto_pago, estado, num_cuota, socio_id_socio, periodo_id_periodo)
                VALUES (@montoCuota, 'PENDIENTE', @i, @id_socio, @idPer);

                SET @i = @i + 1;
            END
        END

        COMMIT;

        SET @Resultado = @id_socio;
        SET @Mensaje   = 'Socio registrado con inscripción en ' + CAST(@num_cuotas AS VARCHAR) + ' cuota(s).';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = -1;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================================================
-- sp_listar_creditos_pendientes : socios con cuotas de inscripcion PENDIENTES
--   Una fila por socio: total, pagado, saldo, nro de cuotas pend. y proxima cuota.
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_listar_creditos_pendientes
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    ;WITH socios_pend AS (
        SELECT s.id_socio, s.codigo_fijo, s.nombre_socio
        FROM socio s
        WHERE EXISTS (SELECT 1 FROM credito_inscripcion ci
                      WHERE ci.socio_id_socio = s.id_socio AND ci.estado = 'PENDIENTE')
          AND ( @Busqueda = ''
                OR s.nombre_socio LIKE '%' + @Busqueda + '%'
                OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%' )
    )
    SELECT
        sp.id_socio,
        sp.codigo_fijo,
        sp.nombre_socio,
        SUM(ci.monto_pago)                                                   AS total_inscripcion,
        SUM(CASE WHEN ci.estado = 'CANCELADO' THEN ci.monto_pago ELSE 0 END) AS pagado,
        SUM(CASE WHEN ci.estado = 'PENDIENTE' THEN ci.monto_pago ELSE 0 END) AS saldo,
        SUM(CASE WHEN ci.estado = 'PENDIENTE' THEN 1 ELSE 0 END)             AS cuotas_pendientes,
        prox.periodo                                                        AS proximo_periodo,
        ISNULL(prox.monto_pago, 0)                                          AS proximo_monto
    FROM socios_pend sp
    INNER JOIN credito_inscripcion ci ON ci.socio_id_socio = sp.id_socio
    OUTER APPLY (
        SELECT TOP 1 p.periodo, c.monto_pago
        FROM credito_inscripcion c
        INNER JOIN periodo p ON p.id_periodo = c.periodo_id_periodo
        WHERE c.socio_id_socio = sp.id_socio AND c.estado = 'PENDIENTE'
        ORDER BY c.num_cuota
    ) prox
    GROUP BY sp.id_socio, sp.codigo_fijo, sp.nombre_socio, prox.periodo, prox.monto_pago
    ORDER BY sp.nombre_socio
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- total para paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM socio s
    WHERE EXISTS (SELECT 1 FROM credito_inscripcion ci
                  WHERE ci.socio_id_socio = s.id_socio AND ci.estado = 'PENDIENTE')
      AND ( @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%' );
END
GO

-- =============================================================================
-- sp_detalle_credito_socio : todas las cuotas de inscripcion de un socio
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_detalle_credito_socio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ci.id_credito,
        ci.num_cuota,
        p.periodo                                                AS nombre_periodo,
        ci.monto_pago,
        ci.estado,
        CASE WHEN av.id_aviso IS NOT NULL THEN 1 ELSE 0 END      AS en_aviso,
        av.id_aviso                                              AS aviso_id_aviso,
        ci.pago_id_pago                                          AS pago_id_pago
    FROM credito_inscripcion ci
    INNER JOIN periodo p ON p.id_periodo = ci.periodo_id_periodo
    OUTER APPLY (
        SELECT TOP 1 a.id_aviso
        FROM aviso a
        WHERE a.socio_id_socio = ci.socio_id_socio
          AND a.periodo_id_periodo = ci.periodo_id_periodo
          AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
    ) av
    WHERE ci.socio_id_socio = @id_socio
    ORDER BY ci.num_cuota;
END
GO

-- Permiso para la pantalla de seguimiento de credito
INSERT INTO permiso (accion, descripcion)
SELECT 'Gestionar Credito Inscripcion', 'Ver y dar seguimiento a las cuotas de inscripcion'
WHERE NOT EXISTS (SELECT 1 FROM permiso WHERE accion = 'Gestionar Credito Inscripcion');
GO

-- =============================================================================
-- sp_recibo_pago_inscripcion : recibo del pago inicial de inscripcion.
-- El pago de inscripcion NO tiene aviso (aviso_id_aviso = NULL); se ubica por
-- la cuota de credito_inscripcion que lo referencia (pago_id_pago).
-- Devuelve la MISMA forma (cabecera + detalle) que sp_recibo_pago_aviso para
-- reutilizar la vista ImprimirRecibo y el modelo CM_ReciboPago.
-- =============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_recibo_pago_inscripcion
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cuota de inscripcion ligada a este pago (normalmente la cuota inicial)
    DECLARE @id_credito INT, @socio_id INT, @periodo_id INT, @monto_cuota DECIMAL(30,2), @num_cuota INT;
    SELECT TOP 1
        @id_credito  = ci.id_credito,
        @socio_id    = ci.socio_id_socio,
        @periodo_id  = ci.periodo_id_periodo,
        @monto_cuota = ci.monto_pago,
        @num_cuota   = ci.num_cuota
    FROM credito_inscripcion ci
    WHERE ci.pago_id_pago = @id_pago;

    -- 1. Cabecera del recibo
    SELECT
        p.id_pago,
        p.fecha_pago,
        s.nombre_socio,
        s.codigo_fijo,
        per.periodo               AS nombre_periodo,
        CAST(NULL AS DECIMAL(30,2)) AS consumo,
        CAST(0 AS DECIMAL(30,2))    AS total_consumo,
        p.monto_pagado            AS total_pagado,
        p.vuelto,
        p.cajero,
        mp.metodo                 AS metodo_pago,
        s.categoria,
        r.ruta                    AS nombre_ruta,
        s.ubicacion
    FROM pago p
    INNER JOIN credito_inscripcion ci ON ci.pago_id_pago = p.id_pago
    INNER JOIN socio s   ON s.id_socio   = ci.socio_id_socio
    INNER JOIN periodo per ON per.id_periodo = ci.periodo_id_periodo
    LEFT  JOIN ruta r    ON r.id_ruta     = s.ruta_id_ruta
    LEFT  JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.id_pago = @id_pago;

    -- 2. Detalle: la cuota de inscripcion pagada
    SELECT
        'Inscripción - Cuota ' + CAST(@num_cuota AS VARCHAR) + ' (pago inicial)' AS concepto,
        @monto_cuota AS subtotal;
END
GO
