USE [COSPABIRL1]
GO

-- ══════════════════════════════════════════
-- SP LOGIN SOCIO (Panel Cliente)
--
-- Espejo de sp_login_admin: el conteo de intentos fallidos y el bloqueo viven
-- aqui dentro, no en la capa web, para que ninguna ruta alterna los salte.
-- Requiere la Migracion 14 (cuenta_socio.intentos_fallidos / bloqueado_hasta).
--
-- Los mensajes de fallo son deliberadamente genericos: no revelan si el
-- usuario existe. La unica excepcion es el bloqueo, que si se informa porque
-- el socio necesita saber por que no puede entrar.
-- ══════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_login_socio
(
    @Usuario    VARCHAR(150),
    @Contrasena VARCHAR(500),
    @Resultado  INT          OUTPUT,   -- 1 = OK, 0 = credenciales invalidas, -1 = cuenta bloqueada
    @Mensaje    VARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    SET @Mensaje   = '';

    DECLARE @MAX_INTENTOS INT = 5;    -- intentos permitidos antes de bloquear
    DECLARE @MIN_BLOQUEO  INT = 15;   -- minutos de bloqueo

    DECLARE @id        INT,
            @hash      VARCHAR(500),
            @intentos  INT,
            @bloqueado DATETIME,
            @estado    BIT;

    SELECT
        @id        = cs.id_cuenta_socio,
        @hash      = cs.contraseña,
        @intentos  = cs.intentos_fallidos,
        @bloqueado = cs.bloqueado_hasta,
        @estado    = cs.estado
    FROM cuenta_socio cs
    WHERE cs.usuario = @Usuario;

    -- Cuenta inexistente o inactiva: mismo mensaje generico
    IF @id IS NULL OR @estado = 0
    BEGIN
        SET @Mensaje = 'Usuario o contraseña incorrectos, o la cuenta no está activa.';
        SELECT NULL AS id_cuenta_socio, NULL AS usuario, NULL AS EstadoCuenta,
               NULL AS ultimo_acceso, NULL AS id_socio, NULL AS nombre_socio,
               NULL AS id_rol_socio, NULL AS NombreRolSocio
        WHERE 1 = 0;
        RETURN;
    END

    -- Cuenta bloqueada por intentos fallidos
    IF @bloqueado IS NOT NULL AND @bloqueado > GETDATE()
    BEGIN
        SET @Resultado = -1;
        SET @Mensaje   = 'Cuenta bloqueada por intentos fallidos. Intenta nuevamente en '
                       + CAST(DATEDIFF(MINUTE, GETDATE(), @bloqueado) + 1 AS VARCHAR)
                       + ' minuto(s).';
        SELECT NULL AS id_cuenta_socio, NULL AS usuario, NULL AS EstadoCuenta,
               NULL AS ultimo_acceso, NULL AS id_socio, NULL AS nombre_socio,
               NULL AS id_rol_socio, NULL AS NombreRolSocio
        WHERE 1 = 0;
        RETURN;
    END

    -- Contraseña incorrecta: acumular intento y bloquear al llegar al limite
    IF @hash <> @Contrasena
    BEGIN
        SET @intentos = @intentos + 1;

        IF @intentos >= @MAX_INTENTOS
        BEGIN
            UPDATE cuenta_socio
            SET intentos_fallidos = 0,
                bloqueado_hasta   = DATEADD(MINUTE, @MIN_BLOQUEO, GETDATE())
            WHERE id_cuenta_socio = @id;

            SET @Resultado = -1;
            SET @Mensaje   = 'Cuenta bloqueada por ' + CAST(@MIN_BLOQUEO AS VARCHAR)
                           + ' minutos tras ' + CAST(@MAX_INTENTOS AS VARCHAR)
                           + ' intentos fallidos.';
        END
        ELSE
        BEGIN
            UPDATE cuenta_socio
            SET intentos_fallidos = @intentos
            WHERE id_cuenta_socio = @id;

            SET @Mensaje = 'Usuario o contraseña incorrectos, o la cuenta no está activa.';
        END

        SELECT NULL AS id_cuenta_socio, NULL AS usuario, NULL AS EstadoCuenta,
               NULL AS ultimo_acceso, NULL AS id_socio, NULL AS nombre_socio,
               NULL AS id_rol_socio, NULL AS NombreRolSocio
        WHERE 1 = 0;
        RETURN;
    END

    -- Login exitoso: resetear contador, bloqueo y sellar el ultimo acceso
    UPDATE cuenta_socio
    SET intentos_fallidos = 0,
        bloqueado_hasta   = NULL,
        ultimo_acceso     = GETDATE()
    WHERE id_cuenta_socio = @id;

    SET @Resultado = 1;
    SET @Mensaje   = 'Acceso concedido.';

    SELECT
        cs.id_cuenta_socio,
        cs.usuario,
        cs.estado           AS EstadoCuenta,
        cs.ultimo_acceso,
        s.id_socio,
        s.nombre_socio,
        rs.id_rol_socio,
        rs.rol_socio        AS NombreRolSocio
    FROM cuenta_socio cs
    INNER JOIN socio s      ON cs.socio_id_socio        = s.id_socio
    INNER JOIN rol_socio rs ON s.rol_socio_id_rol_socio = rs.id_rol_socio
    WHERE cs.id_cuenta_socio = @id;
END
GO
