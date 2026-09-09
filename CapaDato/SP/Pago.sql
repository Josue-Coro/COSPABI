USE [COSPABIRL1]
GO

-- =============================================================================
-- Modulo PAGO (cobro manual de avisos; SIN pasarela/QR por ahora).
-- Pago COMPLETO: un pago salda el aviso. estado_pago = 'APROBADO' al instante.
-- Requiere una caja ABIERTA. Cierra el ciclo: aviso->PAGADO, cargos->PAGADO,
-- cuotas de credito->CANCELADO.
-- =============================================================================

-- 0. Aviso anterior sin pagar del mismo socio -------------------------------
--    Regla de cobro: los avisos se cobran del mas antiguo al mas reciente. No se
--    puede cobrar (ni generar QR de) un aviso mientras el socio tenga otro de un
--    periodo anterior sin pagar. Devuelve el periodo (MM/yyyy) mas antiguo que
--    bloquea, o NULL si el aviso se puede cobrar. La usan los SPs de cobro (que
--    rechazan) y los listados (para deshabilitar el boton antes de intentarlo).
CREATE OR ALTER FUNCTION dbo.fn_aviso_anterior_pendiente (@id_aviso INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @periodo VARCHAR(50);
    SELECT TOP 1 @periodo = pa.periodo
    FROM aviso a
    INNER JOIN periodo p  ON p.id_periodo      = a.periodo_id_periodo
    INNER JOIN aviso   an ON an.socio_id_socio = a.socio_id_socio AND an.id_aviso <> a.id_aviso
    INNER JOIN periodo pa ON pa.id_periodo     = an.periodo_id_periodo
    INNER JOIN estado  e  ON e.id_estado       = an.estado_id_estado
    WHERE a.id_aviso = @id_aviso
      AND e.estado NOT IN ('PAGADO', 'ANULADO')
      -- MM/yyyy -> yyyyMM para comparar periodos
      AND CAST(RIGHT(pa.periodo, 4) + LEFT(pa.periodo, 2) AS INT)
        < CAST(RIGHT(p.periodo, 4)  + LEFT(p.periodo, 2)  AS INT)
    ORDER BY CAST(RIGHT(pa.periodo, 4) + LEFT(pa.periodo, 2) AS INT);
    RETURN @periodo;
END
GO

-- 1. Avisos por cobrar (no PAGADO ni ANULADO) --------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_listar_avisos_por_cobrar
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        a.id_aviso,
        a.total_aviso,
        a.total_aviso AS deuda_actual,
        e.estado AS estado,
        a.fecha_emision,
        a.fecha_vencimiento,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo AS nombre_periodo,
        dbo.fn_aviso_anterior_pendiente(a.id_aviso) AS aviso_anterior_pendiente   -- NULL = cobrable
    FROM aviso a
    INNER JOIN socio   s ON s.id_socio   = a.socio_id_socio
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND (@Busqueda = ''
           OR s.nombre_socio LIKE '%' + @Busqueda + '%'
           OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%')
    ORDER BY a.id_aviso DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    SELECT COUNT(*) AS TotalRegistros
    FROM aviso a
    INNER JOIN socio s ON s.id_socio = a.socio_id_socio
    INNER JOIN estado e ON e.id_estado = a.estado_id_estado
    WHERE e.estado NOT IN ('PAGADO', 'ANULADO')
      AND (@Busqueda = ''
           OR s.nombre_socio LIKE '%' + @Busqueda + '%'
           OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%');
END
GO

-- 1b. Deuda total de un socio (tarjeta "Cobrar todo" de la pantalla de Pago) --
--     Result set 1: socio + cuantos avisos debe y cuanto suman.
--     Result set 2: esos avisos del mas antiguo al mas reciente (orden de cobro).
CREATE OR ALTER PROCEDURE dbo.sp_deuda_socio
    @codigo_fijo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.id_socio, s.nombre_socio, s.codigo_fijo,
           COUNT(a.id_aviso)             AS cantidad_avisos,
           ISNULL(SUM(a.total_aviso), 0) AS total_deuda
    FROM socio s
    LEFT JOIN aviso  a ON a.socio_id_socio = s.id_socio
                      AND a.estado_id_estado NOT IN (SELECT id_estado FROM estado WHERE estado IN ('PAGADO', 'ANULADO'))
    WHERE s.codigo_fijo = @codigo_fijo
    GROUP BY s.id_socio, s.nombre_socio, s.codigo_fijo;

    SELECT a.id_aviso,
           p.periodo AS nombre_periodo,
           a.fecha_emision,
           a.fecha_vencimiento,
           a.total_aviso,
           CASE WHEN a.fecha_vencimiento < CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END AS vencido
    FROM aviso a
    INNER JOIN socio   s ON s.id_socio   = a.socio_id_socio
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    WHERE s.codigo_fijo = @codigo_fijo
      AND e.estado NOT IN ('PAGADO', 'ANULADO')
    ORDER BY CAST(RIGHT(p.periodo, 4) + LEFT(p.periodo, 2) AS INT);   -- MM/yyyy -> yyyyMM
END
GO

-- 2. Registrar pago de un aviso (manual, completo) ---------------------------
CREATE OR ALTER PROCEDURE dbo.sp_registrar_pago_aviso
    @id_aviso       INT,
    @id_caja        INT,
    @id_metodo_pago INT,
    @monto_recibido DECIMAL(30,2) = NULL,   -- efectivo entregado (para vuelto). NULL = exacto
    @cajero         VARCHAR(150),
    @Resultado      INT           OUTPUT,    -- id_pago generado (>0) | 0 error
    @Mensaje        NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
        BEGIN SET @Mensaje = 'No hay una caja abierta valida. Abra su caja primero.'; RETURN; END

        IF NOT EXISTS (SELECT 1 FROM metodo_pago WHERE id_metodo_pago = @id_metodo_pago)
        BEGIN SET @Mensaje = 'Metodo de pago invalido.'; RETURN; END

        DECLARE @total DECIMAL(30,2), @estado VARCHAR(50);
        SELECT @total = a.total_aviso, @estado = e.estado 
        FROM aviso a
        INNER JOIN estado e ON e.id_estado = a.estado_id_estado
        WHERE a.id_aviso = @id_aviso;

        IF @total IS NULL BEGIN SET @Mensaje = 'Aviso no encontrado.'; RETURN; END
        IF @estado = 'PAGADO'  BEGIN SET @Mensaje = 'El aviso ya esta pagado.'; RETURN; END
        IF @estado = 'ANULADO' BEGIN SET @Mensaje = 'El aviso esta anulado.'; RETURN; END

        -- Orden de cobro: primero el aviso mas antiguo del socio
        DECLARE @bloqueo VARCHAR(50) = dbo.fn_aviso_anterior_pendiente(@id_aviso);
        IF @bloqueo IS NOT NULL
        BEGIN SET @Mensaje = 'El socio tiene el aviso del periodo ' + @bloqueo + ' sin pagar. Los avisos se cobran del mas antiguo al mas reciente: cobre primero ese.'; RETURN; END

        -- Guarda de coherencia del desglose.
        -- total_aviso es una foto tomada al generar el aviso. El cierre de ciclo de
        -- mas abajo marca PAGADO *todos* los cargos PENDIENTE del socio+periodo,
        -- dando por hecho que son exactamente los que entraron en esa foto. Si la
        -- suma no cuadra, esa premisa es falsa y cobrar dejaria marcado como pagado
        -- algo que nunca se cobro. Se aborta ANTES de recibir el dinero, que es el
        -- unico momento en que abortar es gratis.
        DECLARE @socio_chk INT, @periodo_chk INT, @consumo_chk DECIMAL(30,2);
        SELECT @socio_chk   = socio_id_socio,
               @periodo_chk = periodo_id_periodo,
               @consumo_chk = total_consumo
        FROM aviso WHERE id_aviso = @id_aviso;

        DECLARE @desglose DECIMAL(30,2) =
              @consumo_chk
            + ISNULL((SELECT SUM(ce.monto) FROM cargo_extra ce
                      WHERE ce.socio_id_socio     = @socio_chk
                        AND ce.periodo_id_periodo = @periodo_chk
                        AND ce.estado             = 'PENDIENTE'), 0)
            + ISNULL((SELECT SUM(ci.monto_pago) FROM credito_inscripcion ci
                      WHERE ci.socio_id_socio     = @socio_chk
                        AND ci.periodo_id_periodo = @periodo_chk
                        AND ci.estado             = 'PENDIENTE'), 0);

        IF @desglose <> @total
        BEGIN
            SET @Mensaje = 'El detalle del aviso no coincide con su total (aviso Bs. ' +
                           CONVERT(VARCHAR, @total) + ' vs. detalle Bs. ' +
                           CONVERT(VARCHAR, @desglose) + '). No se registro ningun cobro. ' +
                           'Anule el aviso y vuelva a generarlo para que el total se recalcule.';
            RETURN;
        END

        DECLARE @recibido DECIMAL(30,2) = ISNULL(@monto_recibido, @total);
        IF @recibido < @total
        BEGIN SET @Mensaje = 'El monto recibido es menor al total del aviso (el pago es completo).'; RETURN; END
        DECLARE @vuelto DECIMAL(30,3) = @recibido - @total;

        DECLARE @id_pagado INT = (SELECT id_estado FROM estado WHERE estado = 'PAGADO');

        BEGIN TRAN;

        -- Si habia un QR pendiente para este aviso, caduca (se cobro en efectivo)
        UPDATE pago SET estado_pago = 'EXPIRADO'
        WHERE aviso_id_aviso = @id_aviso
          AND estado_pago    = 'PENDIENTE'
          AND id_transaccion IS NOT NULL;

        INSERT INTO pago (fecha_pago, monto_pagado, cajero, estado_pago, aviso_id_aviso,
                          metodo_pago_id_metodo_pago, vuelto, caja_id_caja)
        VALUES (GETDATE(), @total, @cajero, 'APROBADO', @id_aviso,
                @id_metodo_pago, @vuelto, @id_caja);

        DECLARE @id_pago INT = CAST(SCOPE_IDENTITY() AS INT);

        UPDATE aviso
        SET estado_id_estado = @id_pagado
        WHERE id_aviso = @id_aviso;

        -- obtener socio y periodo para cerrar ciclo
        DECLARE @socio_id INT, @periodo_id INT;
        SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo 
        FROM aviso 
        WHERE id_aviso = @id_aviso;

        -- cerrar el ciclo
        UPDATE cargo_extra
        SET estado = 'PAGADO'
        WHERE socio_id_socio = @socio_id 
          AND periodo_id_periodo = @periodo_id 
          AND estado = 'PENDIENTE';

        -- Se sella tambien el pago que la cancelo. Antes solo se cambiaba el
        -- estado y pago_id_pago quedaba NULL, asi que una cuota cobrada via
        -- aviso era indistinguible de la cuota inicial de inscripcion (que
        -- nace CANCELADO con su propio pago sin aviso).
        UPDATE credito_inscripcion
        SET estado       = 'CANCELADO',
            pago_id_pago = @id_pago
        WHERE socio_id_socio = @socio_id 
          AND periodo_id_periodo = @periodo_id 
          AND estado = 'PENDIENTE';

        COMMIT;

        -- RF-27: notificacion automatica al portal del socio (best-effort)
        EXEC dbo.sp_notificar_pago_confirmado @id_pago;

        SET @Resultado = @id_pago;
        SET @Mensaje   = 'Pago registrado correctamente. Vuelto: Bs. ' + CONVERT(VARCHAR, CAST(@vuelto AS DECIMAL(30,2)));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- 2b. Cobrar TODOS los avisos pendientes de un socio en un solo click ---------
--     Un pago (y por tanto un recibo) POR AVISO, igual que el cobro individual,
--     del mas antiguo al mas reciente, dentro de UNA transaccion: o se cobran
--     todos o ninguno. Reutiliza sp_registrar_pago_aviso, asi que aplica las
--     mismas reglas (caja abierta, desglose, orden de cobro, cierre de cargos y
--     cuotas, notificacion al socio). El vuelto se registra en el ultimo pago.
--     @IdsPago devuelve los ids generados separados por coma, para los recibos.
--     No llamarlo dentro de una transaccion externa: ante un fallo hace ROLLBACK
--     completo (el ROLLBACK de un SP anidado deshace toda la transaccion).
CREATE OR ALTER PROCEDURE dbo.sp_registrar_pago_multiple
    @id_socio       INT,
    @id_caja        INT,
    @id_metodo_pago INT,
    @monto_recibido DECIMAL(30,2) = NULL,   -- efectivo entregado por el total. NULL = exacto
    @cajero         VARCHAR(150),
    @Resultado      INT           OUTPUT,   -- cantidad de avisos cobrados (>0) | 0 error
    @Mensaje        NVARCHAR(500) OUTPUT,
    @IdsPago        VARCHAR(MAX)  OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';
    SET @IdsPago   = '';

    DECLARE @pend TABLE (orden INT IDENTITY(1,1) PRIMARY KEY, id_aviso INT, total DECIMAL(30,2));
    INSERT INTO @pend (id_aviso, total)
    SELECT a.id_aviso, a.total_aviso
    FROM aviso a
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    WHERE a.socio_id_socio = @id_socio
      AND e.estado NOT IN ('PAGADO', 'ANULADO')
    ORDER BY CAST(RIGHT(p.periodo, 4) + LEFT(p.periodo, 2) AS INT);

    DECLARE @n     INT           = (SELECT COUNT(*) FROM @pend);
    DECLARE @total DECIMAL(30,2) = (SELECT ISNULL(SUM(total), 0) FROM @pend);

    IF @n = 0
    BEGIN SET @Mensaje = 'El socio no tiene avisos pendientes de pago.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM caja WHERE id_caja = @id_caja AND estado = 1)
    BEGIN SET @Mensaje = 'No hay una caja abierta valida. Abra su caja primero.'; RETURN; END

    DECLARE @recibido DECIMAL(30,2) = ISNULL(@monto_recibido, @total);
    IF @recibido < @total
    BEGIN
        SET @Mensaje = 'El monto recibido (Bs. ' + CONVERT(VARCHAR, @recibido) + ') es menor al total de la deuda (Bs. ' + CONVERT(VARCHAR, @total) + ').';
        RETURN;
    END
    DECLARE @vuelto DECIMAL(30,2) = @recibido - @total;

    DECLARE @i INT = 1, @id_aviso INT, @t DECIMAL(30,2), @rec DECIMAL(30,2), @id_pago INT, @msg NVARCHAR(500);
    BEGIN TRY
        BEGIN TRAN;
        WHILE @i <= @n
        BEGIN
            SELECT @id_aviso = id_aviso, @t = total FROM @pend WHERE orden = @i;
            -- el vuelto va en el ultimo recibo; los anteriores se registran exactos
            SET @rec = CASE WHEN @i = @n THEN @t + @vuelto ELSE NULL END;
            SET @id_pago = 0;

            EXEC dbo.sp_registrar_pago_aviso @id_aviso, @id_caja, @id_metodo_pago, @rec, @cajero,
                                             @id_pago OUTPUT, @msg OUTPUT;

            IF ISNULL(@id_pago, 0) <= 0
            BEGIN
                -- Los pagos anteriores del lote se deshacen: o todos o ninguno
                IF @@TRANCOUNT > 0 ROLLBACK;
                SET @IdsPago = '';
                SET @Mensaje = 'No se cobro ningun aviso. Aviso #' + CAST(@id_aviso AS VARCHAR) + ': ' + ISNULL(@msg, '');
                RETURN;
            END

            SET @IdsPago = @IdsPago + CASE WHEN @IdsPago = '' THEN '' ELSE ',' END + CAST(@id_pago AS VARCHAR);
            SET @i = @i + 1;
        END
        COMMIT;

        SET @Resultado = @n;
        SET @Mensaje   = CAST(@n AS VARCHAR) + ' aviso(s) cobrado(s) por Bs. ' + CONVERT(VARCHAR, @total)
                       + '. Vuelto: Bs. ' + CONVERT(VARCHAR, @vuelto);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Resultado = 0;
        SET @IdsPago   = '';
        -- 266 = el SP anidado ya hizo su propio ROLLBACK (excepcion dentro de
        -- sp_registrar_pago_aviso); el motivo real viene en su @Mensaje.
        SET @Mensaje   = 'No se cobro ningun aviso. Aviso #' + CAST(ISNULL(@id_aviso, 0) AS VARCHAR) + ': '
                       + CASE WHEN ERROR_NUMBER() = 266 AND ISNULL(@msg, '') <> '' THEN @msg ELSE ERROR_MESSAGE() END;
    END CATCH
END
GO

-- 3. Pagos registrados en una caja (para la sesion del cajero) ---------------
CREATE OR ALTER PROCEDURE dbo.sp_listar_pagos_caja
    @id_caja INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.id_pago,
        p.fecha_pago,
        p.monto_pagado,
        p.vuelto,
        p.estado_pago,
        mp.metodo        AS nombre_metodo,
        p.aviso_id_aviso,
        s.nombre_socio,
        s.codigo_fijo
    FROM pago p
    INNER JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    LEFT  JOIN aviso a ON a.id_aviso = p.aviso_id_aviso
    LEFT  JOIN socio s ON s.id_socio = a.socio_id_socio
    WHERE p.caja_id_caja = @id_caja
    ORDER BY p.id_pago DESC;
END
GO

-- 4. Permiso ------------------------------------------------------------------
INSERT INTO permiso (accion, descripcion)
SELECT 'Gestionar Pago', 'Cobrar avisos y registrar pagos en caja'
WHERE NOT EXISTS (SELECT 1 FROM permiso WHERE accion = 'Gestionar Pago');
GO

-- 5. Obtener recibo de pago ----------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_recibo_pago_aviso
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Cabecera del recibo
    SELECT 
        p.id_pago,
        p.fecha_pago,
        s.nombre_socio,
        s.codigo_fijo,
        per.periodo AS nombre_periodo,
        l.consumo_m3 AS consumo,
        a.total_consumo,
        p.monto_pagado AS total_pagado,
        p.vuelto,
        p.cajero,
        mp.metodo AS metodo_pago,
        s.categoria,
        r.ruta AS nombre_ruta,
        s.ubicacion
    FROM pago p
    INNER JOIN aviso a ON a.id_aviso = p.aviso_id_aviso
    INNER JOIN socio s ON s.id_socio = a.socio_id_socio
    INNER JOIN periodo per ON per.id_periodo = a.periodo_id_periodo
    LEFT JOIN lectura l ON l.id_lectura = a.lectura_id_lectura
    LEFT JOIN ruta r ON r.id_ruta = s.ruta_id_ruta
    LEFT JOIN metodo_pago mp ON mp.id_metodo_pago = p.metodo_pago_id_metodo_pago
    WHERE p.id_pago = @id_pago;

    -- 2. Detalles del recibo (Concepto, Subtotal)
    DECLARE @id_aviso INT = (SELECT aviso_id_aviso FROM pago WHERE id_pago = @id_pago);
    DECLARE @total_consumo DECIMAL(30,2) = (SELECT total_consumo FROM aviso WHERE id_aviso = @id_aviso);

    CREATE TABLE #Detalle (
        concepto VARCHAR(255),
        subtotal DECIMAL(30,2)
    );

    IF @total_consumo > 0
    BEGIN
        INSERT INTO #Detalle (concepto, subtotal) VALUES ('Consumo Agua', @total_consumo);
    END

    DECLARE @socio_id_rec INT, @periodo_id_rec INT;
    SELECT @socio_id_rec = socio_id_socio, @periodo_id_rec = periodo_id_periodo 
    FROM aviso 
    WHERE id_aviso = @id_aviso;

    INSERT INTO #Detalle (concepto, subtotal)
    SELECT descripcion AS concepto, monto 
    FROM cargo_extra 
    WHERE socio_id_socio = @socio_id_rec 
      AND periodo_id_periodo = @periodo_id_rec
      AND estado <> 'ANULADO';   -- un cargo anulado no se cobro: fuera del recibo

    -- Mismo criterio que sp_detalle_aviso / sp_imprimir_aviso: la cuota inicial
    -- de inscripcion se cobro aparte al registrar al socio (su pago no tiene
    -- aviso), asi que no forma parte de lo que se pago con ESTE recibo.
    INSERT INTO #Detalle (concepto, subtotal)
    SELECT 'Cuota de Inscripción (' + CAST(ci.num_cuota AS VARCHAR) + ')', ci.monto_pago
    FROM credito_inscripcion ci
    WHERE ci.socio_id_socio = @socio_id_rec 
      AND ci.periodo_id_periodo = @periodo_id_rec
      AND NOT EXISTS (SELECT 1 FROM pago pg
                      WHERE pg.id_pago = ci.pago_id_pago
                        AND pg.aviso_id_aviso IS NULL);

    SELECT concepto, subtotal FROM #Detalle;
    DROP TABLE #Detalle;
END
GO
