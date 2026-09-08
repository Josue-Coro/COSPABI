-- =============================================================================
-- Migracion 16 - Backfill de email en clientes legacy
-- =============================================================================
-- Contexto: el email es obligatorio desde que existe el pago por QR (Libelula
-- exige 'email_cliente' para registrar la deuda), pero las personas cargadas
-- antes de esa regla quedaron con email NULL. Como sp_editar_cliente tambien
-- exige el email, esas filas quedaron CONGELADAS: no se les puede corregir ni
-- el telefono sin darles antes un correo.
--
-- Este script les asigna un correo derivado del nombre.
--
-- DOMINIO: se usa un subdominio que NO entrega correo, a proposito.
--   Un correo inventado sobre un dominio real (gmail.com) puede existir de
--   verdad, y Libelula envia el comprobante del pago a esa direccion: datos de
--   cobranza de un socio llegando al buzon de un desconocido.
--   Ademas deja los correos ficticios identificables de un vistazo:
--       SELECT * FROM cliente WHERE email LIKE '%@sincorreo.cospabi.bo';
--   para reemplazarlos por el correo real cuando el socio lo entregue.
--
-- Idempotente: solo toca filas con email NULL o vacio. Re-ejecutarlo no
-- reescribe ningun correo ya asignado.
-- =============================================================================

SET NOCOUNT ON;
GO

DECLARE @Dominio VARCHAR(100) = '@sincorreo.cospabi.bo';  -- <-- cambiar aqui si se quiere otro

-- ---------------------------------------------------------------------------
-- 1. Candidatos: primer nombre + primer apellido, normalizados
-- ---------------------------------------------------------------------------
-- El primer apellido es la PENULTIMA palabra ("Carlos Alberto Mamani Quispe"
-- -> Mamani). Se obtiene como la segunda palabra de la cadena invertida.
-- Los acentos se quitan con NCHAR(codigo) en vez de literales acentuados para
-- que el script no dependa del encoding con que se abra o se despliegue.

IF OBJECT_ID('tempdb..#backfill') IS NOT NULL DROP TABLE #backfill;

SELECT
    c.id_cliente,
    c.nombre_completo,
    candidato = base.txt + @Dominio,
    base.txt
INTO #backfill
FROM dbo.cliente c
-- normalizar: minusculas y espacios colapsados
CROSS APPLY (SELECT n = LTRIM(RTRIM(LOWER(REPLACE(REPLACE(REPLACE(
                 c.nombre_completo,'  ',' '),'  ',' '),'  ',' '))))) x
-- primer nombre
CROSS APPLY (SELECT p1 = LEFT(x.n, CHARINDEX(' ', x.n + ' ') - 1)) a
-- primer apellido = segunda palabra de la cadena invertida, re-invertida
CROSS APPLY (SELECT r = REVERSE(x.n)) b
CROSS APPLY (SELECT rr = SUBSTRING(b.r, CHARINDEX(' ', b.r + ' ') + 1, LEN(b.r))) d
CROSS APPLY (SELECT ap = REVERSE(LEFT(d.rr, CHARINDEX(' ', d.rr + ' ') - 1))) e
-- quitar acentos, enie y todo lo que no sea [a-z0-9.]
CROSS APPLY (SELECT crudo = a.p1 + '.' + CASE WHEN e.ap = '' THEN a.p1 ELSE e.ap END) f
CROSS APPLY (SELECT lim =
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            f.crudo,
            NCHAR(225),'a'),   -- a con tilde
            NCHAR(233),'e'),   -- e con tilde
            NCHAR(237),'i'),   -- i con tilde
            NCHAR(243),'o'),   -- o con tilde
            NCHAR(250),'u'),   -- u con tilde
            NCHAR(252),'u'),   -- u con dieresis
            NCHAR(241),'n'),   -- enie
            ' ','')) g
CROSS APPLY (SELECT txt = base_limpia.v FROM (SELECT v =
        -- descartar cualquier caracter restante fuera de [a-z0-9.]
        (SELECT CAST('' AS VARCHAR(150)) +
                CASE WHEN SUBSTRING(g.lim, v.number, 1) LIKE '[a-z0-9.]'
                     THEN SUBSTRING(g.lim, v.number, 1) ELSE '' END
         FROM master.dbo.spt_values v
         WHERE v.type = 'P' AND v.number BETWEEN 1 AND LEN(g.lim)
         ORDER BY v.number
         FOR XML PATH(''))
    ) base_limpia) base
WHERE c.email IS NULL OR LTRIM(RTRIM(c.email)) = '';

-- ---------------------------------------------------------------------------
-- 2. Resolver colisiones (entre si y contra correos ya existentes)
-- ---------------------------------------------------------------------------
-- Si dos personas comparten primer nombre y primer apellido, o si el correo ya
-- pertenece a otro cliente, se desambigua con el id_cliente. cliente_email_UX
-- (Migracion 15) rechazaria el UPDATE de lo contrario.

UPDATE b
SET candidato = b.txt + '.' + CAST(b.id_cliente AS VARCHAR(10)) + @Dominio
FROM #backfill b
WHERE EXISTS (SELECT 1 FROM dbo.cliente c2
              WHERE LTRIM(RTRIM(c2.email)) = b.candidato)
   OR EXISTS (SELECT 1 FROM #backfill b2
              WHERE b2.candidato = b.candidato AND b2.id_cliente < b.id_cliente);

-- ---------------------------------------------------------------------------
-- 3. Aplicar
-- ---------------------------------------------------------------------------
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE c
    SET c.email = b.candidato
    FROM dbo.cliente c
    INNER JOIN #backfill b ON b.id_cliente = c.id_cliente
    WHERE c.email IS NULL OR LTRIM(RTRIM(c.email)) = '';

    PRINT 'OK  Clientes actualizados: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
END CATCH

-- ---------------------------------------------------------------------------
-- 4. Reporte
-- ---------------------------------------------------------------------------
SELECT id_cliente, nombre_completo, email
FROM dbo.cliente
WHERE email LIKE '%@sincorreo.cospabi.bo'
ORDER BY id_cliente;

SELECT total_personas = COUNT(*),
       sin_email      = SUM(CASE WHEN email IS NULL OR LTRIM(RTRIM(email)) = '' THEN 1 ELSE 0 END),
       ficticios      = SUM(CASE WHEN email LIKE '%@sincorreo.cospabi.bo' THEN 1 ELSE 0 END)
FROM dbo.cliente;

DROP TABLE #backfill;
GO
