
-- ══════════════════════════════════════════
-- LISTAR con paginación y búsqueda
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_listar_metodo_pago
(
    @Busqueda     VARCHAR(250) = '',
    @Pagina       INT          = 1,
    @TamanoPagina INT          = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;

    SELECT COUNT(*) AS TotalRegistros
    FROM metodo_pago
    WHERE (@Busqueda = ''
           OR metodo LIKE '%' + @Busqueda + '%'
           OR referencia LIKE '%' + @Busqueda + '%');

    SELECT
        id_metodo_pago,
        metodo,
        referencia
    FROM metodo_pago
    WHERE (@Busqueda = ''
           OR metodo LIKE '%' + @Busqueda + '%'
           OR referencia LIKE '%' + @Busqueda + '%')
    ORDER BY id_metodo_pago DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END
GO

-- ══════════════════════════════════════════
-- OBTENER por ID
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_obtener_metodo_pago
(
    @IdMetodoPago INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_metodo_pago,
        metodo,
        referencia
    FROM metodo_pago
    WHERE id_metodo_pago = @IdMetodoPago;
END
GO

-- ══════════════════════════════════════════
-- REGISTRAR
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_registrar_metodo_pago
(
    @Metodo       VARCHAR(150),
    @Referencia   VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM metodo_pago WHERE metodo = @Metodo)
    BEGIN
        SELECT 0 AS Resultado, 'Este método de pago ya existe.' AS Mensaje;
        RETURN;
    END

    INSERT INTO metodo_pago (
        metodo,
        referencia
    )
    VALUES (
        @Metodo,
        @Referencia
    );

    SELECT 1 AS Resultado, 'Método de pago registrado correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- EDITAR
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_editar_metodo_pago
(
    @IdMetodoPago INT,
    @Metodo       VARCHAR(150),
    @Referencia   VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM metodo_pago WHERE metodo = @Metodo AND id_metodo_pago <> @IdMetodoPago)
    BEGIN
        SELECT 0 AS Resultado, 'El nombre del método de pago ya está en uso.' AS Mensaje;
        RETURN;
    END

    UPDATE metodo_pago SET
        metodo     = @Metodo,
        referencia = @Referencia
    WHERE id_metodo_pago = @IdMetodoPago;

    SELECT 1 AS Resultado, 'Método de pago actualizado correctamente.' AS Mensaje;
END
GO

-- ══════════════════════════════════════════
-- ELIMINAR (Físico con validación)
-- ══════════════════════════════════════════
CREATE PROCEDURE dbo.sp_eliminar_metodo_pago
(
    @IdMetodoPago INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM pago WHERE metodo_pago_id_metodo_pago = @IdMetodoPago)
    BEGIN
        SELECT 0 AS Resultado, 'El método de pago ya está en uso (asociado a un pago).' AS Mensaje;
        RETURN;
    END

    DELETE FROM metodo_pago
    WHERE id_metodo_pago = @IdMetodoPago;

    SELECT 1 AS Resultado, 'Método de pago eliminado correctamente.' AS Mensaje;
END
GO
