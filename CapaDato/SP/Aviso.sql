USE [COSPABIRL1]
GO

-- =============================================
-- Sembrar tabla estado (valores fijos, sin CRUD)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'GENERADO')
    INSERT INTO estado (estado) VALUES ('GENERADO');
IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'LECTURADO')
    INSERT INTO estado (estado) VALUES ('LECTURADO');
IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'IMPRESO')
    INSERT INTO estado (estado) VALUES ('IMPRESO');
IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'PAGADO')
    INSERT INTO estado (estado) VALUES ('PAGADO');
IF NOT EXISTS (SELECT 1 FROM estado WHERE estado = 'ANULADO')
    INSERT INTO estado (estado) VALUES ('ANULADO');
GO

-- =============================================
-- 1. sp_generar_avisos_periodo
--    Genera avisos para socios con lectura en el
--    periodo que aun no tienen aviso generado.
--    Calcula total segun tarifa del rol_socio.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_generar_avisos_periodo
    @id_periodo INT,
    @id_ruta    INT          = NULL,
    @Generados  INT          OUTPUT,
    @Mensaje    VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Generados = 0;
    SET @Mensaje   = '';

    DECLARE @id_estado_gen INT;
    SELECT @id_estado_gen = id_estado FROM estado WHERE estado = 'GENERADO';

    IF @id_estado_gen IS NULL
    BEGIN
        SET @Mensaje = 'Tabla estado no inicializada. Ejecute el script de siembra primero.';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        -- 0) Estampar los cargos automaticos (tipo_cargo.automatico = 1) a los socios
        --    que van a recibir aviso en este periodo. VA ANTES del INSERT del aviso:
        --    total_aviso es una foto inmutable, si el cargo se creara despues el aviso
        --    no lo incluiria pero el detalle si lo listaria (descuadre).
        --    El monto sale de tipo_cargo.monto, asi la cooperativa lo cambia desde la UI.
        INSERT INTO cargo_extra
            (monto, descripcion, fecha_registro, estado,
             tipo_cargo_id_tipo, socio_id_socio, periodo_id_periodo)
        SELECT DISTINCT
            CAST(tc.monto AS DECIMAL(30,2)),
            tc.nombre,
            CAST(GETDATE() AS DATE),
            'PENDIENTE',
            tc.id_tipo,
            s.id_socio,
            @id_periodo
        FROM lectura l
        INNER JOIN socio s ON s.medidor_id_medidor = l.medidor_id_medidor
        CROSS JOIN tipo_cargo tc
        WHERE l.periodo_id_periodo = @id_periodo
          AND (@id_ruta IS NULL OR s.ruta_id_ruta = @id_ruta)
          AND tc.automatico = 1
          AND tc.estado     = 1
          -- solo socios que efectivamente recibiran aviso ahora
          AND NOT EXISTS (
              SELECT 1 FROM aviso a
              WHERE a.socio_id_socio     = s.id_socio
                AND a.periodo_id_periodo = @id_periodo
                AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
          )
          -- no duplicar si el cargo ya existe (registrado a mano o en una corrida anterior)
          AND NOT EXISTS (
              SELECT 1 FROM cargo_extra ce
              WHERE ce.socio_id_socio     = s.id_socio
                AND ce.periodo_id_periodo = @id_periodo
                AND ce.tipo_cargo_id_tipo = tc.id_tipo
                AND ce.estado <> 'ANULADO'
          );

        -- 1) Crear los avisos del periodo. total_aviso = consumo + SUMA(cargos) + cuota_credito
        INSERT INTO aviso (
            fecha_emision, fecha_vencimiento,
            total_consumo, total_aviso, deuda_actual,
            estado_id_estado,
            socio_id_socio, periodo_id_periodo,
            lectura_id_lectura
        )
        SELECT
            CAST(GETDATE() AS DATE),
            CAST(DATEADD(DAY, 30, GETDATE()) AS DATE),
            calc.total_consumo,
            calc.total_consumo + calc.sum_cargos + calc.cuota_credito,   -- total_aviso
            calc.total_consumo + calc.sum_cargos + calc.cuota_credito,   -- deuda_actual
            @id_estado_gen,
            s.id_socio,
            l.periodo_id_periodo,
            l.id_lectura
        FROM lectura l
        INNER JOIN socio  s ON s.medidor_id_medidor     = l.medidor_id_medidor
        INNER JOIN tarifa t ON t.rol_socio_id_rol_socio = s.rol_socio_id_rol_socio
        CROSS APPLY (
            SELECT
                -- consumo segun tarifa del rol_socio
                total_consumo =
                    CASE
                        WHEN l.consumo_m3 <= ISNULL(t.consumo_minimo_m3, 0)
                            THEN CAST(t.monto_minimo AS DECIMAL(30,2))
                        ELSE CAST(
                                t.monto_minimo
                                + (l.consumo_m3 - ISNULL(t.consumo_minimo_m3, 0)) * t.precio_m3
                            AS DECIMAL(30,2))
                    END,
                -- SUMA de TODOS los cargos pendientes del socio en el periodo (1:N)
                sum_cargos = ISNULL((
                    SELECT SUM(ce.monto)
                    FROM cargo_extra ce
                    WHERE ce.socio_id_socio     = s.id_socio
                      AND ce.periodo_id_periodo = l.periodo_id_periodo
                      AND ce.estado             = 'PENDIENTE'), 0),
                -- cuota de credito de inscripcion del periodo (0..1). SUMA, no resta.
                cuota_credito = ISNULL((
                    SELECT SUM(ci.monto_pago)
                    FROM credito_inscripcion ci
                    WHERE ci.socio_id_socio     = s.id_socio
                      AND ci.periodo_id_periodo = l.periodo_id_periodo
                      AND ci.estado             = 'PENDIENTE'), 0)
        ) calc
        WHERE l.periodo_id_periodo = @id_periodo
          AND (@id_ruta IS NULL OR s.ruta_id_ruta = @id_ruta)
          -- excluir socios que ya tienen aviso activo en este periodo
          AND NOT EXISTS (
              SELECT 1 FROM aviso a
              WHERE a.socio_id_socio     = s.id_socio
                AND a.periodo_id_periodo = @id_periodo
                AND a.estado_id_estado <> (SELECT id_estado FROM estado WHERE estado = 'ANULADO')
          );

        SET @Generados = @@ROWCOUNT;

        COMMIT;

        IF @Generados = 0
            SET @Mensaje = 'No hay lecturas pendientes de aviso para el periodo y ruta seleccionados.';
        ELSE
            SET @Mensaje = CAST(@Generados AS VARCHAR) + ' aviso(s) generado(s) correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        SET @Generados = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- 2. sp_listar_avisos
--    Listado paginado con filtros por periodo,
--    estado, ruta y busqueda por nombre/codigo.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_listar_avisos
    @id_periodo   INT           = NULL,
    @id_estado    INT           = NULL,
    @id_ruta      INT           = NULL,
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_consumo,
        a.total_aviso,
        a.deuda_actual,
        e.estado                                                                  AS estado,
        a.estado_id_estado,
        e.estado                                                                  AS nombre_estado,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo                                                                 AS nombre_periodo,
        r.ruta                                                                    AS nombre_ruta,
        CASE WHEN EXISTS (
            SELECT 1 FROM cargo_extra ce 
            WHERE ce.socio_id_socio = a.socio_id_socio AND ce.periodo_id_periodo = a.periodo_id_periodo
        ) THEN 1 ELSE 0 END                                                       AS tiene_cargo_extra,
        CASE WHEN EXISTS (
            SELECT 1 FROM credito_inscripcion ci 
            WHERE ci.socio_id_socio = a.socio_id_socio AND ci.periodo_id_periodo = a.periodo_id_periodo
        ) THEN 1 ELSE 0 END                                                       AS tiene_credito
    FROM aviso    a
    INNER JOIN socio   s ON s.id_socio   = a.socio_id_socio
    INNER JOIN ruta    r ON r.id_ruta    = s.ruta_id_ruta
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    WHERE
        (@id_periodo IS NULL OR a.periodo_id_periodo = @id_periodo)
        AND (@id_estado IS NULL OR a.estado_id_estado = @id_estado)
        AND (@id_ruta   IS NULL OR s.ruta_id_ruta     = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        )
    ORDER BY a.id_aviso DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- Total para paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM aviso a
    INNER JOIN socio s ON s.id_socio = a.socio_id_socio
    WHERE
        (@id_periodo IS NULL OR a.periodo_id_periodo = @id_periodo)
        AND (@id_estado IS NULL OR a.estado_id_estado = @id_estado)
        AND (@id_ruta   IS NULL OR s.ruta_id_ruta     = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        );
END
GO

-- =============================================
-- 3. sp_cambiar_estado_aviso
--    Solo avanza estado (no retrocede).
--    PAGADO unicamente desde modulo de Pagos.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_cambiar_estado_aviso
    @id_aviso  INT,
    @id_estado INT,
    @Resultado INT          OUTPUT,
    @Mensaje   VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    BEGIN TRY
        DECLARE @estado_actual INT;
        SELECT @estado_actual = estado_id_estado
        FROM aviso WHERE id_aviso = @id_aviso;

        IF @estado_actual IS NULL
        BEGIN
            SET @Mensaje = 'Aviso no encontrado.';
            RETURN;
        END

        IF @id_estado <= @estado_actual
        BEGIN
            SET @Mensaje = 'No se puede retroceder el estado de un aviso.';
            RETURN;
        END

        DECLARE @id_pagado INT;
        SELECT @id_pagado = id_estado FROM estado WHERE estado = 'PAGADO';
        IF @id_estado = @id_pagado
        BEGIN
            SET @Mensaje = 'El estado PAGADO solo puede asignarse desde el modulo de Pagos.';
            RETURN;
        END

        DECLARE @nombre_estado VARCHAR(150);
        SELECT @nombre_estado = estado FROM estado WHERE id_estado = @id_estado;

        UPDATE aviso
        SET estado_id_estado = @id_estado
        WHERE id_aviso = @id_aviso;

        SET @Resultado = 1;
        SET @Mensaje   = 'Estado actualizado a ' + ISNULL(@nombre_estado, '') + '.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- 4. sp_ultimo_aviso_socio
--    Devuelve el aviso mas reciente de un socio
--    para el portal cliente.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_ultimo_aviso_socio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_consumo,
        a.total_aviso,
        a.deuda_actual,
        e.estado  AS estado,
        a.estado_id_estado,
        e.estado  AS nombre_estado,
        p.periodo AS nombre_periodo
    FROM aviso    a
    INNER JOIN estado  e ON e.id_estado  = a.estado_id_estado
    INNER JOIN periodo p ON p.id_periodo = a.periodo_id_periodo
    WHERE a.socio_id_socio = @id_socio
    ORDER BY a.id_aviso DESC;
END
GO

-- =============================================
-- 5. sp_anular_aviso
--    Marca un aviso como ANULADO (no lo elimina).
--    Solo aplica si el aviso no esta PAGADO.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_anular_aviso
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

        IF @estado_actual = 'PAGADO'
        BEGIN
            SET @Mensaje = 'No se puede anular un aviso PAGADO.';
            RETURN;
        END

        IF @estado_actual = 'ANULADO'
        BEGIN
            SET @Mensaje = 'El aviso ya estaba anulado.';
            RETURN;
        END

        DECLARE @id_estado_anulado INT;
        SELECT @id_estado_anulado = id_estado FROM estado WHERE estado = 'ANULADO';

        UPDATE aviso
        SET estado_id_estado = @id_estado_anulado
        WHERE id_aviso = @id_aviso;

        SET @Resultado = 1;
        SET @Mensaje   = 'Aviso anulado correctamente. Ya puede registrar cargos y regenerar el aviso.';
    END TRY
    BEGIN CATCH
        SET @Resultado = 0;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- 6. sp_detalle_aviso
--    Devuelve el desglose completo de un aviso:
--    socio, lectura, tarifa, cargo extra, credito.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_detalle_aviso
    @id_aviso INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Cabecera: socio, lectura, tarifa, totales y cuota de credito (0..1)
    SELECT
        a.id_aviso,
        a.fecha_emision,
        a.fecha_vencimiento,
        a.total_consumo,
        a.total_aviso,
        a.deuda_actual,
        e.estado        AS estado,
        -- Socio
        s.nombre_socio,
        s.codigo_fijo,
        -- Ruta y Periodo
        r.ruta          AS nombre_ruta,
        p.periodo       AS nombre_periodo,
        e.estado        AS nombre_estado,
        -- Medidor y Lectura
        m.serie         AS serie_medidor,
        l.lectura_anterior,
        l.lectura_actual,
        l.consumo_m3,
        l.dias_lectura,
        -- Tarifa y Rol
        rs.rol_socio    AS nombre_rol,
        t.monto_minimo,
        t.consumo_minimo_m3,
        t.precio_m3,
        -- Suma de cargos extra del socio en el periodo (1:N)
        ISNULL((SELECT SUM(ce.monto) FROM cargo_extra ce
                WHERE ce.socio_id_socio = a.socio_id_socio
                  AND ce.periodo_id_periodo = a.periodo_id_periodo), 0) AS total_cargos,
        -- Cuota de credito de inscripcion (0..1)
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

    -- 2) Lista de cargos extra del aviso (N filas)
    DECLARE @socio_id INT, @periodo_id INT;
    SELECT @socio_id = socio_id_socio, @periodo_id = periodo_id_periodo FROM aviso WHERE id_aviso = @id_aviso;

    SELECT
        ce.id_cargo_extra,
        ce.monto,
        ce.descripcion,
        ce.fecha_registro,
        tc.nombre AS nombre_tipo_cargo
    FROM cargo_extra ce
    INNER JOIN tipo_cargo tc ON tc.id_tipo = ce.tipo_cargo_id_tipo
    WHERE ce.socio_id_socio = @socio_id
      AND ce.periodo_id_periodo = @periodo_id
    ORDER BY ce.id_cargo_extra;
END
GO

-- =============================================
-- Permiso para Gestionar Avisos
-- =============================================
INSERT INTO permiso (accion, descripcion)
SELECT 'Gestionar Avisos', 'Generar y gestionar avisos de cobro'
WHERE NOT EXISTS (
    SELECT 1 FROM permiso WHERE accion = 'Gestionar Avisos'
);
GO
