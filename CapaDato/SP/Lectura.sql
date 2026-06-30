USE [COSPABIRL1]
GO

-- =============================================
-- 1. Obtener o crear periodo
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_obtener_o_crear_periodo
    @periodo_nombre VARCHAR(50),
    @id_periodo     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Reiniciar el OUTPUT: si el caller pasa un valor previo y el periodo NO existe,
    -- el SELECT no tocaria la variable y devolveria un id incorrecto (stale).
    SET @id_periodo = NULL;

    SELECT @id_periodo = id_periodo
    FROM periodo
    WHERE periodo = @periodo_nombre;

    IF @id_periodo IS NULL
    BEGIN
        INSERT INTO periodo (periodo) VALUES (@periodo_nombre);
        SET @id_periodo = SCOPE_IDENTITY();
    END
END
GO

-- =============================================
-- 2. Listar medidores de una ruta para lecturar
--    Muestra: datos del socio, lectura anterior,
--    y si ya fue leido en el periodo actual
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_listar_medidores_para_lectura
    @id_ruta    INT,
    @id_periodo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.id_medidor,
        m.serie,
        s.id_socio,
        s.nombre_socio,
        s.codigo_fijo,

        -- Ultima lectura ANTES del periodo actual (sera la lectura_anterior)
        ISNULL(ult.lectura_actual, 0)                        AS lectura_anterior_valor,
        ult.fecha_lectura                                    AS fecha_ultima_lectura,

        -- Ya fue leido en el periodo actual?
        CASE WHEN act.id_lectura IS NOT NULL THEN 1 ELSE 0 END AS ya_leido,
        act.id_lectura                                       AS id_lectura_actual,
        act.lectura_anterior                                 AS lect_ant_registrada,
        act.lectura_actual                                   AS lect_act_registrada,
        act.consumo_m3                                       AS consumo_registrado,
        act.observacion                                      AS observacion_registrada,
        act.dias_lectura                                     AS dias_registrados

    FROM medidor m
    INNER JOIN socio s
        ON s.medidor_id_medidor = m.id_medidor
        AND s.ruta_id_ruta = @id_ruta

    -- Ultima lectura de otro periodo (para obtener lectura_anterior)
    OUTER APPLY (
        SELECT TOP 1
            l.lectura_actual,
            l.fecha_lectura
        FROM lectura l
        WHERE l.medidor_id_medidor = m.id_medidor
          AND l.periodo_id_periodo <> @id_periodo
        ORDER BY l.fecha_lectura DESC
    ) ult

    -- Lectura del periodo actual (para saber si ya fue registrada)
    LEFT JOIN lectura act
        ON act.medidor_id_medidor  = m.id_medidor
        AND act.periodo_id_periodo = @id_periodo

    ORDER BY s.codigo_fijo ASC;
END
GO

-- =============================================
-- 3. Registrar una lectura
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_registrar_lectura
    @fecha_lectura                  DATE,
    @lectura_anterior               INT,
    @lectura_actual                 INT,
    @observacion                    VARCHAR(255),
    @usuario_admin_id_usuario_admin INT,
    @medidor_id_medidor             INT,
    @periodo_id_periodo             INT,
    @ruta_id_ruta                   INT          = NULL, -- Se mantiene en firma por compatibilidad C#
    @Resultado                      INT          OUTPUT,
    @Mensaje                        VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;

    BEGIN TRY

        -- Validar que no exista ya lectura para este medidor en este periodo
        IF EXISTS (
            SELECT 1 FROM lectura
            WHERE medidor_id_medidor = @medidor_id_medidor
              AND periodo_id_periodo = @periodo_id_periodo
        )
        BEGIN
            SET @Resultado = -1;
            SET @Mensaje = 'Este medidor ya tiene una lectura registrada en el periodo seleccionado.';
            RETURN;
        END

        -- Validar que lectura_actual >= lectura_anterior
        IF @lectura_actual < @lectura_anterior
        BEGIN
            SET @Resultado = -2;
            SET @Mensaje = 'La lectura actual no puede ser menor que la lectura anterior ('
                           + CAST(@lectura_anterior AS VARCHAR) + ').';
            RETURN;
        END

        -- Calcular consumo
        DECLARE @consumo_m3 DECIMAL(30,2) = @lectura_actual - @lectura_anterior;

        -- Calcular dias desde la ultima lectura
        DECLARE @dias_lectura INT = 30;
        SELECT TOP 1
            @dias_lectura = DATEDIFF(DAY, l.fecha_lectura, @fecha_lectura)
        FROM lectura l
        WHERE l.medidor_id_medidor = @medidor_id_medidor
          AND l.periodo_id_periodo <> @periodo_id_periodo
        ORDER BY l.fecha_lectura DESC;

        -- Insertar la lectura
        INSERT INTO lectura (
            fecha_lectura, lectura_anterior, lectura_actual,
            dias_lectura, observacion, consumo_m3,
            usuario_admin_id_usuario_admin,
            medidor_id_medidor, periodo_id_periodo
        )
        VALUES (
            @fecha_lectura, @lectura_anterior, @lectura_actual,
            @dias_lectura, @observacion, @consumo_m3,
            @usuario_admin_id_usuario_admin,
            @medidor_id_medidor, @periodo_id_periodo
        );

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje   = 'Lectura registrada correctamente.';

    END TRY
    BEGIN CATCH
        SET @Resultado = -99;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- 4. Historial de lecturas con paginacion y filtros
--    JOIN a socio via medidor (sin socio_id en lectura)
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_listar_lecturas
    @id_periodo   INT           = NULL,
    @id_ruta      INT           = NULL,
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        l.id_lectura,
        l.fecha_lectura,
        l.lectura_anterior,
        l.lectura_actual,
        l.dias_lectura,
        l.consumo_m3,
        l.observacion,
        m.serie                                      AS serie_medidor,
        s.nombre_socio,
        s.codigo_fijo,
        p.periodo                                    AS nombre_periodo,
        r.ruta                                       AS nombre_ruta,
        u.nombre + ' ' + u.apellido                  AS nombre_usuario
    FROM lectura l
    INNER JOIN medidor       m ON m.id_medidor        = l.medidor_id_medidor
    INNER JOIN socio         s ON s.medidor_id_medidor = m.id_medidor
    INNER JOIN periodo       p ON p.id_periodo        = l.periodo_id_periodo
    INNER JOIN ruta          r ON r.id_ruta           = s.ruta_id_ruta
    INNER JOIN usuario_admin u ON u.id_usuario_admin  = l.usuario_admin_id_usuario_admin
    WHERE
        (@id_periodo IS NULL OR l.periodo_id_periodo = @id_periodo)
        AND (@id_ruta IS NULL OR s.ruta_id_ruta = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR m.serie        LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        )
    ORDER BY l.fecha_lectura DESC, l.id_lectura DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- Total para paginacion
    SELECT COUNT(*) AS TotalRegistros
    FROM lectura l
    INNER JOIN medidor m ON m.id_medidor        = l.medidor_id_medidor
    INNER JOIN socio   s ON s.medidor_id_medidor = m.id_medidor
    WHERE
        (@id_periodo IS NULL OR l.periodo_id_periodo = @id_periodo)
        AND (@id_ruta IS NULL OR s.ruta_id_ruta = @id_ruta)
        AND (
            @Busqueda = ''
            OR s.nombre_socio LIKE '%' + @Busqueda + '%'
            OR m.serie        LIKE '%' + @Busqueda + '%'
            OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
        );
END
GO

-- =============================================
-- 5. Agregar permiso "Registrar Lecturas" si no existe
-- =============================================
INSERT INTO permiso (accion, descripcion)
SELECT 'Registrar Lecturas', 'Registrar lecturas de medidores por ruta'
WHERE NOT EXISTS (
    SELECT 1 FROM permiso WHERE accion = 'Registrar Lecturas'
);
GO
