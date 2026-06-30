USE [COSPABIRL1]
GO
-- =============================================
-- SP_Socio_Listar (con paginación y búsqueda)
-- =============================================
CREATE OR ALTER PROCEDURE sp_listar_socio
    @Busqueda     NVARCHAR(255) = '',
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT
        s.id_socio,
        s.nombre_socio,
        s.cliente_id_cliente,
        c.nombre_completo                  AS nombre_cliente,
        c.ci                               AS ci_cliente,
        s.rol_socio_id_rol_socio,
        rs.rol_socio                       AS nombre_rol_socio,
        s.medidor_id_medidor,
        m.serie                            AS serie_medidor,
        s.ruta_id_ruta,
        r.ruta                             AS nombre_ruta,
        s.ubicacion,
        s.num_casa,
        s.num_ocupantes,
        s.tipo_instalacion,
        s.dim_instalacion,
        s.actividad,
        s.categoria,
        s.fecha_registro,
        s.codigo_fijo,
        s.estado
    FROM socio s
    INNER JOIN cliente      c  ON c.id_cliente      = s.cliente_id_cliente
    INNER JOIN rol_socio    rs ON rs.id_rol_socio   = s.rol_socio_id_rol_socio
    LEFT JOIN  medidor      m  ON m.id_medidor      = s.medidor_id_medidor
    INNER JOIN ruta         r  ON r.id_ruta         = s.ruta_id_ruta
    WHERE
        s.nombre_socio     LIKE '%' + @Busqueda + '%'
        OR c.nombre_completo LIKE '%' + @Busqueda + '%'
        OR c.ci              LIKE '%' + @Busqueda + '%'
        OR m.serie           LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%'
    ORDER BY s.id_socio DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;

    -- Total registros para paginación
    SELECT COUNT(*) AS TotalRegistros
    FROM socio s
    INNER JOIN cliente c ON c.id_cliente = s.cliente_id_cliente
    LEFT JOIN  medidor  m ON m.id_medidor  = s.medidor_id_medidor
    WHERE
        s.nombre_socio       LIKE '%' + @Busqueda + '%'
        OR c.nombre_completo LIKE '%' + @Busqueda + '%'
        OR c.ci              LIKE '%' + @Busqueda + '%'
        OR m.serie           LIKE '%' + @Busqueda + '%'
        OR CAST(s.codigo_fijo AS NVARCHAR) LIKE '%' + @Busqueda + '%';
END
GO

-- =============================================
-- SP_Socio_Registrar
-- =============================================
CREATE OR ALTER PROCEDURE sp_registrar_socio
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
    @estado                  BIT           = 1,
    @Resultado               INT OUTPUT,
    @Mensaje                 NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que el cliente exista
        IF NOT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = @cliente_id_cliente)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El cliente seleccionado no existe.';
            RETURN;
        END

        -- Validar que el medidor no esté ya asignado a otro socio (solo si no es NULL)
        IF @medidor_id_medidor IS NOT NULL AND EXISTS (SELECT 1 FROM socio WHERE medidor_id_medidor = @medidor_id_medidor)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El medidor seleccionado ya está asignado a otro socio.';
            RETURN;
        END

        -- Validar código fijo único
        IF EXISTS (SELECT 1 FROM socio WHERE codigo_fijo = @codigo_fijo)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El código fijo ingresado ya existe.';
            RETURN;
        END

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
            @fecha_registro, @ruta_id_ruta, @codigo_fijo, @estado
        );

        SET @Resultado = SCOPE_IDENTITY();
        SET @Mensaje   = 'Socio registrado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = -1;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- SP_Socio_Editar
-- =============================================
CREATE OR ALTER PROCEDURE sp_editar_socio
    @id_socio                INT,
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
    @estado                  BIT           = 1,
    @Resultado               INT OUTPUT,
    @Mensaje                 NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM socio WHERE id_socio = @id_socio)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El socio no existe.';
            RETURN;
        END

        -- Validar medidor no asignado a OTRO socio (solo si no es NULL)
        IF @medidor_id_medidor IS NOT NULL AND EXISTS (
            SELECT 1 FROM socio 
            WHERE medidor_id_medidor = @medidor_id_medidor 
              AND id_socio <> @id_socio
        )
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El medidor ya está asignado a otro socio.';
            RETURN;
        END

        -- Validar código fijo único en OTRO socio
        IF EXISTS (
            SELECT 1 FROM socio 
            WHERE codigo_fijo = @codigo_fijo 
              AND id_socio <> @id_socio
        )
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El código fijo ya existe en otro socio.';
            RETURN;
        END

        UPDATE socio SET
            nombre_socio           = @nombre_socio,
            cliente_id_cliente     = @cliente_id_cliente,
            rol_socio_id_rol_socio = @rol_socio_id_rol_socio,
            ubicacion              = @ubicacion,
            medidor_id_medidor     = @medidor_id_medidor,
            num_casa               = @num_casa,
            num_ocupantes          = @num_ocupantes,
            tipo_instalacion       = @tipo_instalacion,
            dim_instalacion        = @dim_instalacion,
            actividad              = @actividad,
            categoria              = @categoria,
            fecha_registro         = @fecha_registro,
            ruta_id_ruta           = @ruta_id_ruta,
            codigo_fijo            = @codigo_fijo,
            estado                 = @estado
        WHERE id_socio = @id_socio;

        SET @Resultado = 1;
        SET @Mensaje   = 'Socio actualizado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = -1;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- SP_Socio_Eliminar
-- =============================================
CREATE OR ALTER PROCEDURE SP_Socio_Eliminar
    @id_socio  INT,
    @Resultado INT OUTPUT,
    @Mensaje   NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM socio WHERE id_socio = @id_socio)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'El socio no existe.';
            RETURN;
        END

        -- Validar que no tenga avisos o créditos asociados
        -- (ajustá los nombres de tabla si son distintos en tu BD)
        IF EXISTS (SELECT 1 FROM credito_inscripcion WHERE socio_id_socio = @id_socio)
        BEGIN
            SET @Resultado = 0;
            SET @Mensaje = 'No se puede eliminar: el socio tiene créditos de inscripción asociados.';
            RETURN;
        END

        DELETE FROM socio WHERE id_socio = @id_socio;

        SET @Resultado = 1;
        SET @Mensaje   = 'Socio eliminado exitosamente.';
    END TRY
    BEGIN CATCH
        SET @Resultado = -1;
        SET @Mensaje   = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- SP_Socio_ObtenerPorId
-- =============================================
CREATE OR ALTER PROCEDURE SP_Socio_ObtenerPorId
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        s.id_socio,
        s.nombre_socio,
        s.cliente_id_cliente,
        c.nombre_completo                  AS nombre_cliente,
        c.ci                               AS ci_cliente,
        s.rol_socio_id_rol_socio,
        rs.rol_socio                       AS nombre_rol_socio,
        s.medidor_id_medidor,
        m.serie                            AS serie_medidor,
        s.ruta_id_ruta,
        r.ruta                             AS nombre_ruta,
        s.ubicacion,
        s.num_casa,
        s.num_ocupantes,
        s.tipo_instalacion,
        s.dim_instalacion,
        s.actividad,
        s.categoria,
        s.fecha_registro,
        s.codigo_fijo,
        s.estado
    FROM socio s
    INNER JOIN cliente      c  ON c.id_cliente      = s.cliente_id_cliente
    INNER JOIN rol_socio    rs ON rs.id_rol_socio   = s.rol_socio_id_rol_socio
    LEFT JOIN  medidor      m  ON m.id_medidor      = s.medidor_id_medidor
    INNER JOIN ruta         r  ON r.id_ruta         = s.ruta_id_ruta
    WHERE s.id_socio = @id_socio;
END
GO