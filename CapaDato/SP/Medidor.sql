CREATE PROCEDURE [dbo].[sp_listar_medidores]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    -- Total de registros para la paginación
    SELECT COUNT(*) AS TotalRegistros
    FROM medidor m
    LEFT JOIN socio s ON s.medidor_id_medidor = m.id_medidor
    WHERE (
        @Busqueda = ''
        OR m.serie        LIKE '%' + @Busqueda + '%'
        OR CAST(m.numero  AS VARCHAR) LIKE '%' + @Busqueda + '%'
        OR s.nombre_socio LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS VARCHAR) LIKE '%' + @Busqueda + '%'
    );

    -- Datos paginados
    SELECT
        m.id_medidor,
        m.serie,
        m.numero,
        m.fecha_instalacion,
        s.nombre_socio,
        s.codigo_fijo
    FROM medidor m
    LEFT JOIN socio s ON s.medidor_id_medidor = m.id_medidor
    WHERE (
        @Busqueda = ''
        OR m.serie        LIKE '%' + @Busqueda + '%'
        OR CAST(m.numero  AS VARCHAR) LIKE '%' + @Busqueda + '%'
        OR s.nombre_socio LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS VARCHAR) LIKE '%' + @Busqueda + '%'
    )
    ORDER BY m.id_medidor DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO

--probar sp_listar_medidores
EXEC dbo.sp_listar_medidores @Busqueda = '', @Pagina = 1, @TamanoPagina = 1000;
GO
EXEC dbo.sp_listar_medidores_socio @Busqueda = '', @Pagina = 1, @TamanoPagina = 1000;
GO


-- listar medidores que no esten asignado a ningun socio
CREATE PROCEDURE [dbo].[sp_listar_medidores_socio]
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    -- Total de registros para la paginación
    SELECT COUNT(*) AS TotalRegistros
    FROM medidor m
    LEFT JOIN socio s ON s.medidor_id_medidor = m.id_medidor
    WHERE (
        @Busqueda = ''
        OR m.serie        LIKE '%' + @Busqueda + '%'
        OR CAST(m.numero  AS VARCHAR) LIKE '%' + @Busqueda + '%'
        OR s.nombre_socio LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS VARCHAR) LIKE '%' + @Busqueda + '%'
    );

    -- Datos paginados
    SELECT
        m.id_medidor,
        m.serie,
        m.numero,
        m.fecha_instalacion,
        s.nombre_socio,
        s.codigo_fijo
        FROM medidor m
        LEFT JOIN socio s ON s.medidor_id_medidor = m.id_medidor
        WHERE s.medidor_id_medidor IS NULL
        AND (
            @Busqueda = ''
            OR m.serie        LIKE '%' + @Busqueda + '%'
            OR CAST(m.numero  AS VARCHAR) LIKE '%' + @Busqueda + '%'
        )
        ORDER BY m.id_medidor DESC
        OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

END
GO

--Probar sp_listar_medidores_socio

-- Registrar medidor
CREATE PROCEDURE [dbo].[sp_crear_medidor]
    @serie            VARCHAR(150),
    @numero           INTEGER,
    @fecha_instalacion DATE,
    @Resultado        INT OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[medidor] WHERE serie = @serie)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[medidor] WHERE numero = @numero)
        BEGIN
            INSERT INTO [dbo].[medidor] (serie, numero, fecha_instalacion)
            VALUES (@serie, @numero, @fecha_instalacion);
            SET @Resultado = SCOPE_IDENTITY();
            SET @Mensaje   = 'Medidor registrado correctamente.';
        END
        ELSE
            SET @Mensaje = 'Ya existe un medidor con este número.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un medidor con esta serie.';
END
GO

-- Editar medidor
CREATE PROCEDURE [dbo].[sp_editar_medidor]
    @id_medidor       INTEGER,
    @serie            VARCHAR(150),
    @numero           INTEGER,
    @fecha_instalacion DATE,
    @Resultado        INT OUTPUT,
    @Mensaje          VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    IF NOT EXISTS (SELECT 1 FROM [dbo].[medidor] WHERE serie = @serie AND id_medidor <> @id_medidor)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM [dbo].[medidor] WHERE numero = @numero AND id_medidor <> @id_medidor)
        BEGIN
            UPDATE [dbo].[medidor]
            SET serie             = @serie,
                numero            = @numero,
                fecha_instalacion = @fecha_instalacion
            WHERE id_medidor = @id_medidor;
            SET @Resultado = 1;
            SET @Mensaje   = 'Medidor actualizado correctamente.';
        END
        ELSE
            SET @Mensaje = 'Ya existe un medidor con este número.';
    END
    ELSE
        SET @Mensaje = 'Ya existe un medidor con esta serie.';
END
GO