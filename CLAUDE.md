# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> The user is from Bolivia and works in Spanish. **Respond in Spanish.**
> `CONTEXTO_COSPABI.md` is the authoritative handoff doc for domain rules (facturación, caja, pagos, Libélula) — read it for any business-logic work. `CapaPresentacionAdmin/main.md` has the color palette and component specs; **its CSS framework section is outdated** (describes CDN approach that was replaced — follow the compiled-CSS approach in this file instead).
> `AGENTS.md` mirrors this file for other coding agents — apply any edit to both files.

## What this is

COSPABI — management system for a water cooperative (cooperativa de agua) in Bolivia. Final engineering project. Handles socios, clientes, medidores, lecturas, **facturación (avisos)**, cargos extra, crédito de inscripción, **caja y pagos (efectivo + QR Libélula)**, roles/permisos, **reportes (caja, morosidad)** and the **portal del socio**. All 6 modules / 22 user stories of the thesis scope are implemented.

**Stack:** ASP.NET MVC 5 on **.NET Framework 4.7.2** (C#, `System.Web.Mvc`). SQL Server backend accessed via raw `SqlClient` + stored procedures (no ORM).

## Architecture — 4 layers + 2 web fronts

Classic Capas (layered) architecture. Each entity flows through parallel files named by prefix:

- **`CapaModelo`** (`CM_*`) — POCOs only. Some files hold nested classes (e.g. `CM_Cliente` contains `CM_Cliente_Paginado`, accessed via `using static CapaModelo.CM_Cliente;`).
- **`CapaDato`** (`CD_*`) — data access. Each method opens a `SqlConnection` from `CD_Conexion.cn`, calls a stored procedure, maps the reader. **All SQL lives in stored procedures**, not in C# (the last inline queries were moved to `CapaDato/SP/ConsultasDirectasMigradas.sql`). SQL source files live in `CapaDato/SP/` (procedures, `CREATE OR ALTER`, one file per entity) and `CapaDato/BD/` (schema + numbered migrations). Most `SP/*.sql` names map 1:1 to an entity; the ones that don't: `AvisoImpresion.sql` (printable aviso + `sp_marcar_aviso_impreso`), `Estado.sql` (seeds the aviso state table), `Estadistica.sql` (admin dashboard), `Reporte.sql` (HU21/HU22), `PortalSocio.sql` (socio portal), `PagoQr.sql` (Libélula), `LoginSocio.sql` vs `Login.sql` (socio vs admin), `Rol_Socio.sql` (tariff category, *not* the permissions role), `ConsultasDirectasMigradas.sql` (ex-inline queries).
- **`CapaNegocio`** (`CN_*`) — validation + business rules + **bitácora (audit log)**. The CN method validates, delegates to its CD counterpart, and on success calls `cnBitacora.Registrar("...", idUsuarioSesion)`. Controllers should call CN, never CD directly.
- **`CapaPresentacionAdmin`** — the main MVC web app (admin). This is where almost all work happens.
- **`CapaPresentacionCliente`** — socio self-service portal. **Tailwind v4 compilado, igual que el admin pero con su propio `package.json` / `Content/tailwind.css` / `Content/app.css`** (design system M3 propio: ver *CSS (Tailwind)* abajo). Bootstrap ya no se usa en las vistas del portal, aunque los archivos siguen en `Content/`/`Scripts/`. **La raiz del sitio ya no es el login**: `RouteConfig` apunta a `Home/Bienvenida`, la portada publica de la cooperativa (`[AllowAnonymous]`, `Layout = null`, redirige a `Home/Index` si ya hay sesion). Sus datos concretos —direccion, telefono, correo, indicadores— viven en un unico bloque de variables al inicio de la vista, y lo que queda vacio no se pinta. Login (`sp_login_socio`, session `Session["Socio"]` = `CM_CuentaSocio_Activo`), Home, Perfil, and `PortalController` (avisos, pagos, estado de cuenta, notificaciones con marcar-leída). **The socio id always comes from the session, never from the browser** — keep it that way in any new portal action. Portal SPs live in `CapaDato/SP/PortalSocio.sql`; portal CD/CN methods live in `CD_CuentaSocio`/`CN_CuentaSocio`.

**Per-entity call chain:** `Controller → CN_X (validate + bitácora) → CD_X (SqlClient) → sp_x_* (stored proc)`.

### Domain entity map (who points at whom)

Not obvious from file names — several modules only make sense together:

- **`cliente` is the person; `socio` is the membership built on top of one** (`socio.cliente_id_cliente`). Registrar Socio starts by picking an existing persona (`sp_listar_personas_disponibles_socio`), so personal data (CI, nombre, contacto) is edited in the Cliente module, never in Socio.
- **`socio`** carries `codigo_fijo` (the number the cajero types everywhere) plus FKs to `rol_socio` (tariff category), `ruta` (reading route) and a **nullable** `medidor` — a socio can exist without a meter.
- **`tarifa` hangs off `rol_socio`, not off socio**: `consumo_minimo_m3` / `monto_minimo` / `precio_m3` per category are what turn a `lectura` into the consumo line of the aviso.
- **`cuenta_socio`** = the socio's portal credentials (usuario/contraseña/estado, 1:1 with socio), created from the admin app (`CuentaSocioController`) and consumed by `sp_login_socio`. Unrelated to `usuario_admin`.
- **`credito_inscripcion`** = the inscription fee split into cuotas (`num_cuota`, `monto_pago`, `estado`, `aviso_id_aviso`, `pago_id_pago`). `CreditoController` shows a per-socio resumen (total / pagado / saldo / próxima cuota) and reuses `Views/Pago/ImprimirRecibo.cshtml` for the inscription receipt.
- **`metodo_pago`** is a small admin CRUD (efectivo, QR, …) referenced by pagos and by the inscription's initial payment.

### Stored-procedure return convention (IMPORTANT)

CD methods that mutate data use **output parameters** `@Resultado INT OUTPUT` and `@Mensaje VARCHAR(500) OUTPUT`, read after `ExecuteNonQuery()`. The matching SP must declare those OUTPUT params and `SET` them (not `SELECT` them). A mismatch here produces *"Procedure or function ... has too many arguments specified"* at runtime. Some SPs use a different name for the integer output (e.g. `@Generados` in `sp_generar_avisos_periodo`) — the names must match exactly between the CD call and the SP declaration. List/Obtener SPs instead return result sets read with `ExecuteReader`. When adding a mutating SP, follow the `@Resultado`/`@Mensaje` OUTPUT pattern to stay consistent with the CD layer.

### Auth & permissions

- Login stores `CM_Usuario_Activo` (with `ListaPermisos`) in `Session["Usuario"]`; the layout also reads `Session["NombreUsuario"]` / `Session["RolUsuario"]`. Passwords are SHA-256 (no salt) via `CN_Recursos.ConvertirSha256`.
- `sp_login_admin` enforces **account lockout**: 5 failed attempts → 15-min block (columns `intentos_fallidos`/`bloqueado_hasta` on `usuario_admin`, Migración 10). All counting/blocking and failure bitácora live in the SP; it returns both result sets (user + permisos) *and* `@Resultado`/`@Mensaje` OUTPUT params. Failure messages are deliberately generic so account existence isn't revealed.
- `permiso.modulo` (Migración 09) groups the 37 permisos into 7 modules; `sp_listar_permisos` returns them pre-sorted by module for the grouped UI in `Views/Permiso/Permiso.cshtml`.
- **The `SUPERADMIN` role is shielded** (cross-cutting, by role *name*): non-superadmin users can't see it or its users in listings (Rol, Usuario, Permiso, Bitácora filter) nor modify/assign it. Controllers compute `esSuperadmin` from `Session["Usuario"].nombre_rol` and pass it down (`CN_Rol.Listar(bool)`, `@IncluirSuperadmin` / `@SolicitanteEsSuperadmin` in the SPs); the SPs enforce the block. Any new listing or mutation touching roles/usuarios must respect this.
- Controllers are gated with `[ValidarPermisos(NombrePermiso = "...")]` (in `CapaPresentacionAdmin/Filtros/`). Permission names vary in style (e.g. `"Gestionar Caja"`, `"Visualizar Bitacora"`, `"Gestionar TipoCargo"`) and must match the `permiso.accion` rows exactly (the column is `accion`, not `nombre`) — 36 distinct names are enforced today; list them with `grep -rho 'NombrePermiso = "[^"]*"' CapaPresentacionAdmin/Controllers | sort -u`. No session → redirect to Login; session but missing permission → AccesoDenegado.
- **`sp_login_socio` enforces the same lockout** (Migración 14): 5 failed attempts → 15-min block on `cuenta_socio`. Like the admin one, all counting and blocking lives in the SP so no alternate path can skip it, and failure messages stay generic. Both `LoginController`s call `Session.Clear()` before populating the authenticated session (session fixation).
- **Caja ownership is enforced in the SPs, not just the UI**: `sp_cerrar_caja` and `sp_arqueo_caja` take `@id_usuario` + `@es_superadmin` and refuse a caja belonging to another cajero (they answer *"Caja no encontrada"* / an empty result set, so they never confirm it exists). `Gestionar Caja` is a per-cajero permission, so without this guard any cajero could close or read another's drawer by changing `idCaja` in the request. `CajaController` derives `esSuperadmin` from `Session["Usuario"].nombre_rol`, same as the rest. `sp_listar_cajas` already filtered by owner.
- **Security headers and cookie flags live in `Web.config`** (both projects, identical): `<httpCookies httpOnlyCookies="true" sameSite="Lax">`, `<customErrors mode="RemoteOnly">`, and a `<system.webServer><httpProtocol><customHeaders>` block with CSP, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy` and `Permissions-Policy`. The CSP still needs `'unsafe-inline'` because every view carries inline `<script>`; `img-src` allows `https:` for the Libélula QR image. Set `requireSSL="true"`, uncomment HSTS and flip `debug="false"` when deploying over HTTPS.
- **Session expires after 15 min of inactivity (RNF-04)** in both web projects: `<forms timeout="15" slidingExpiration="true">` **and** `<sessionState timeout="15" />` in `Web.config`. Both numbers must stay in sync — Forms auth alone would keep the cookie alive after the `Session["Usuario"]`/`Session["Socio"]` object is gone, which crashes any action that casts it.
- **JsonResult shapes are not uniform — and reads and mutations follow different conventions.** Always read the target action before writing its JS consumer; several controllers mix both styles (e.g. `AvisoController` returns `{ data }` from `Listar` but `{ exito, avisos }` from its newer actions).
  - **Reads**: `{ data: list }` in the older CRUD controllers (Aviso, Bitacora, CargoExtra, Lectura, Permiso, Rol, Ruta, Socio, Tarifa, TipoCargo, Usuario); `{ exito, mensaje }` + a **named** payload (`cajeros`, `notificaciones` + `totalRegistros`, `avisos`, `clientes`, `creditos`, `cuentas`, `metodos`, `resumen`, …) in the newer ones (Caja, Cliente, Credito, CuentaSocio, Home, Medidor, MetodoPago, Notificacion, Pago, Reporte and the whole `PortalController`).
  - **Mutations**: `{ resultado: int, mensaje }` — success = `resultado > 0` — in **Medidor, Permiso, Rol, Ruta, Tarifa, TipoCargo, Usuario**; `{ exito: bool, mensaje }` everywhere else (Aviso, Caja, CargoExtra, Cliente, Credito, CuentaSocio, Lectura, MetodoPago, Notificacion, Pago, Socio). `TipoCargoController` returns `resultado = false` (a bool) on one validation branch and an int on the rest — use a truthy check there, not `> 0`.

### UI modal pattern

Views use two modal approaches — pick the right one:
- **`iframe` modals with `Layout = null`**: the form view has no layout; the parent page opens it in a Bootstrap/custom modal. Simpler isolation, no script-ordering issues.
- **`@section scripts` modals**: the form lives in-page; script goes in `@section scripts { }` of the same view. Used when the form shares the main layout.

Cross-module constraint: **registering a new socio requires an open caja** — `sp_registrar_socio_con_inscripcion` receives `@id_caja` and the inscription payment is tied to that caja. The SocioController must call `CN_Caja.ObtenerCajaAbierta()` (or equivalent) before creating a socio.

### Printing / "PDF" output

There is **no server-side PDF library**. Two patterns, both ending in `window.print()`:
- **Standalone views** without `_Layout` (aviso, recibo de pago, arqueo de caja) — see `Views/Aviso/ImprimirAviso.cshtml`, `Views/Pago/ImprimirRecibo.cshtml`, `Views/Caja/Reporte.cshtml`.
- **In-page printing** with `@@media print` CSS that hides `aside, header, .no-print` and neutralizes the layout's `overflow`/`h-screen` containers (otherwise the print clips to one page) — see `Views/Reporte/Caja.cshtml` / `Views/Reporte/Morosidad.cshtml`. Use this when the report lives inside `_Layout` and no new `.cshtml` can be created.

### Avisos — ciclo de estados y cargos automáticos

The aviso state machine is **fully automatic**; there is no manual state control in the UI:

`GENERADO` (created by `sp_generar_avisos_periodo`, which only emits for socios **with a lectura** in the period) → `IMPRESO` (`sp_marcar_aviso_impreso`, fired by `AvisoController.ImprimirAviso` when the print view is opened) → `PAGADO` (Pagos module only — `sp_cambiar_estado_aviso` explicitly rejects it) · `ANULADO` (Anular Avisos).

`LECTURADO` (id 2) is **retired from the cycle** — every aviso already implies a lectura. The row stays in `estado` for historical avisos, and `sp_marcar_aviso_impreso` still accepts it as a source state. `sp_cambiar_estado_aviso` / `CN_Aviso.CambiarEstado` survive with no callers (kept for administrative corrections); the controller action was removed.

**Cargos automáticos (Migración 12):** `tipo_cargo.automatico = 1` (+ `estado = 1`) makes a charge stamp itself on every aviso — the real case is `TASA AFCOOP` (Bs. 0.50) for all socios. `sp_generar_avisos_periodo` inserts those `cargo_extra` rows **inside the same transaction and before the `INSERT INTO aviso`**: `total_aviso` is an immutable snapshot, so a charge created afterwards would be listed in the detalle/impresión but missing from the total. Amount comes from `tipo_cargo.monto`, and a `NOT EXISTS` on non-ANULADO charges of the same tipo/socio/periodo keeps per-ruta or repeated runs from duplicating it. No extra cleanup is needed: paying the aviso already marks every pending charge of that socio/periodo as `PAGADO`, and `sp_anular_cargo_extra` refuses to void a charge whose aviso already exists.

### Pago QR desde el portal del socio

`PortalController` (CapaPresentacionCliente) reuses the whole admin chain — `CN_Pago` / `CN_Libelula` / the same SPs — with three deliberate differences:

- **`idCaja = null`, `cajero = "PORTAL SOCIO"`, `idUsuario = 0`** (which `sp_registrar_bitacora` resolves to SISTEMA). The payment lands as a *pago del sistema*: outside the arqueo and outside `sp_reporte_caja`.
- **Every call carries the socio from session** (`GenerarQr`, `EstadoQr`, `VerificarQr` pass `IdSocioSesion()`); only the aviso id comes from the browser and the SPs reject anything not owned by that socio. Never add a portal action that takes the socio id from the request.
- **`VerificarQr` is not `ConciliarQr`.** `CN_Pago.VerificarPagoQrSocio` touches a single pago belonging to that socio; the admin's `ConciliarPagosQr` sweeps every pending QR in the system and writes admin bitácora. Keep them apart.

`PagoExitoso` exists on both sides (`/Pago/PagoExitoso` and `/Portal/PagoExitoso`), both `[AllowAnonymous]`, both re-querying the pasarela before approving. UI: "Pagar QR" button per unpaid aviso in `Views/Portal/Avisos.cshtml`, custom modal (no Bootstrap JS), 5s polling and a "Ya pagué / Verificar" button — the local substitute for the callback, since there is no tunnel. Ese modal tiene **tres estados en un mismo diálogo** (`qrVistaQr` / `qrVistaExito` / `qrVistaError`): las pantallas de "pago exitoso" y "pago rechazado" del diseño viven ahí, **no** son rutas nuevas — `/Portal/PagoExitoso` tiene que seguir siendo el `ContentResult` de texto plano que llama Libélula.

### Reportes (HU21 caja / HU22 morosidad)

`ReporteController` has no CN/CD of its own: it reuses `CN_Caja.ReporteCaja`, `CN_Caja.ReportePagosSistema` and `CN_Aviso.ReporteMorosidad` (SPs `sp_reporte_caja`, `sp_reporte_morosidad`, `sp_listar_cajeros_con_caja` in `CapaDato/SP/Reporte.sql`). Both CN methods write bitácora, so the controller passes `id_usuario_admin`. The cajero filter is SUPERADMIN-shielded like the rest (`ListarCajerosConCaja(esSuperadmin)`). Views render in-page and print with the `@@media print` pattern above. The admin dashboard is separate: `HomeController.ObtenerEstadisticas` → `CN_Dashboard` → `CapaDato/SP/Estadistica.sql`, for the current `MM/yyyy` period.

### Pagos del sistema (portal del socio, sin caja)

A payment can be approved with `caja_id_caja = NULL` — `sp_registrar_pago_qr_pendiente` takes `@id_caja = NULL` ("pago online sin caja") and `sp_confirmar_pago_qr` nulls the caja out when the cajero's caja already closed. That money is real but never passed through a drawer, so it is reported apart:

- **`sp_reporte_caja` only counts payments with a caja** (`caja_id_caja IS NOT NULL`). Before Migración 13 the "todos los cajeros" option silently mixed them in, because the cajero filter is `(@IdCajero IS NULL OR ...)` over a LEFT JOIN.
- **`sp_reporte_pagos_sistema`** (same 3-resultset shape) reports the ones without caja, plus `qr_sin_cobrar` (QR generated in the period that nobody paid). Gated by the `Generar Reporte Pagos Sistema` permission; view in `Views/Reporte/PagosSistema.cshtml`.
- `sp_cerrar_caja` was always safe — it filters `p.caja_id_caja = @id_caja`.

**Usuario SISTEMA** (Migración 13): `bitacora.usuario_admin_id_usuario_admin` is NOT NULL with an FK, so actions born in the portal had no valid author. `sp_registrar_bitacora` now resolves `@IdUsuario <= 0` (or a non-existent id) to the `SISTEMA` user — rol CAJERO, `estado = 0` and a non-SHA-256 password, so `sp_login_admin` rejects it at the estado check before ever comparing the hash. Any portal-side CN call should pass `idUsuario = 0` rather than inventing one.

**Ownership del QR**: `sp_datos_deuda_qr` and `sp_estado_pago_qr` take an optional `@id_socio`. The portal must always pass the socio from session (the aviso id comes from the browser); the admin omits it and keeps full access. `sp_estado_pago_qr` also returns `id_transaccion` so the portal can ask for a verification against the pasarela without receiving it from the browser.

**Email obligatorio**: the QR flow dies without `cliente.email`, so the rule is enforced at three points, all inside SPs so no path can skip it:

- **At the source** — `sp_registrar_cliente` / `sp_editar_cliente` normalize (`SET @Email = NULLIF(LTRIM(RTRIM(@Email)), '')`) and then reject a NULL/blank email with `@Resultado = 0`. Normalizing matters beyond tidiness: the stored value travels verbatim to Libélula as `email_cliente`, and a leading space breaks the debt registration. `CN_Cliente` validates the same thing first (plus format, via `CN_Recursos.EsEmailValido`) so the user gets the message without a round trip.
- **At the portal account** — `sp_registrar_cuenta_socio` / `sp_editar_cuenta_socio` refuse to create or reassign an account when the socio's persona has no email, and the socio picker in `CuentaSocio.cshtml` shows those socios as "Sin correo" and blocks selection.
- **At the QR** — `CN_Pago.GenerarPagoQr` bails out with a clear message before calling the gateway.

`cliente.email` is still **nullable in the DB with no unique index**: the column predates the rule and legacy rows have none (21 of 26 personas as of Migración 14, 9 of them already socios), so a NOT NULL constraint would need a backfill first. Uniqueness likewise rests on the `IF EXISTS` check inside the two SPs, not on an index. Neither the Cliente listing nor `CrearSocio.cshtml` flags a persona without email.

### Notificaciones

Admin CRUD (`NotificacionController` + `CapaDato/SP/Notificacion.sql`) sends a notificación to selected socios (`ids_socios`, CSV) or to all (`enviar_a_todos`), fanned out by `sp_asignar_notificacion_socios`. Two are generated by the system, not by hand: `sp_generar_notificaciones_vencimiento` (RF-27 recordatorios, N days before `fecha_vencimiento`, triggered from the UI button → `GenerarRecordatorios`) and `sp_notificar_pago_confirmado` (fired inside the payment flow). The socio reads them in the portal (`sp_portal_notificaciones_socio` / `sp_portal_marcar_notificacion_leida`). Keep new notification sources going through an SP so the socio-side fan-out stays consistent.

### Pasarela QR — Libélula (IMPLEMENTED)

Two entry points, one flow — the cajero from the admin app (`PagoController`) and the socio from his portal (`PortalController`, see *Pago QR desde el portal* below). Flow: `PagoController.GenerarQr` → `CN_Pago.GenerarPagoQr` (reads `sp_datos_deuda_qr`, calls `CN_Libelula.RegistrarDeuda`, inserts pago PENDIENTE via `sp_registrar_pago_qr_pendiente`) → socio pays → callback `PagoExitoso` (public GET, `[AllowAnonymous]`) or manual "Verificar pago" (`ConciliarQr`) → `sp_confirmar_pago_qr` approves and closes the cycle. SPs in `CapaDato/SP/PagoQr.sql`; HTTP client `CN_Libelula` (Newtonsoft.Json is installed in CapaNegocio; config injected from the controller via `ConfigurationManager`). Anti double-charge rules — do not break them:
- Debt registered in Libélula with `fecha_vencimiento` = same day 23:59; a pending QR is only **reused if generated today**; older pendientes are auto-EXPIRADO (on new QR, on cash payment of the same aviso, and on conciliation).
- The callback **never trusts the GET**: it re-queries `/rest/deuda/consultar_deudas/por_identificador` and only approves if `pagado=true`. Idempotent via unique filtered index `pago_id_transaccion_UX`.
- Confirming rejects avisos PAGADO/ANULADO (expires the QR) and, if the cajero's caja already closed, approves with `caja_id_caja = NULL` so a closed arqueo is never distorted.
- No ngrok by user decision: local testing relies on the "Verificar pago" button; `Libelula.CallbackUrl` (Secrets.config) is only needed for live callbacks.

## Build & run

**There IS a solution file** (`COSPABI.slnx`, the new XML format) despite what older notes say. There is **no classic `.sln`**. Build per project with MSBuild (this compiles referenced layers; `.cshtml` views compile at runtime):

```bash
& "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" \
  "CapaPresentacionAdmin\CapaPresentacionAdmin.csproj" /t:Build /p:Configuration=Debug
```

Run the web app from Visual Studio (IIS Express). There are **no automated tests** in this repo.

After rebuilding DLLs, **IIS Express keeps serving the old binaries** — the user must Stop/Start the app in VS and hard-refresh (Ctrl+F5). If a change "doesn't show up", suspect this first.

### CSS (Tailwind)

**Los dos front-ends usan Tailwind v4 compilado a un `Content/app.css` local** — el enfoque por CDN fue eliminado. Cada proyecto tiene su propio `package.json`, su `Content/tailwind.css` y sus tokens: **no comparten hoja de estilos**. Tras tocar clases de Tailwind o el `tailwind.css`, recompila **desde la carpeta del proyecto que editaste**:

```bash
npm run build:css      # one-shot: tailwind.css -> app.css
npm run watch:css      # watch mode while developing
```

Si un botón o un bloque sale sin estilo, lo primero que hay que sospechar es un `app.css` desactualizado.

En **CapaPresentacionCliente** eso ya no puede pasar por caché del navegador: las tres vistas que enlazan la hoja (`_Layout`, `Login`, `Bienvenida`) lo hacen como `~/Content/app.css?v=@Recursos.AppCss()`, y `Recursos` (en `App_Start/BundleConfig.cs`) cuelga la fecha de modificación del archivo, así que cada `npm run build:css` genera una URL nueva. **El admin todavía no lo tiene**: ahí sigue haciendo falta Ctrl+Shift+R tras recompilar el CSS. El síntoma típico de la caché vieja es una página a medio maquetar —colores y tipografía correctos, pero sin paddings, sin `gap` y con los grids apilados—, porque lo que falta son justo las utilidades nuevas.

Diferencias entre ambos `tailwind.css`:

- **Admin**: paleta corta (`primary-*`, `sidebar-*`) sobre el layout oscuro del panel.
- **Cliente**: design system completo estilo Material 3 (`primary-container`, `surface-container-*`, `outline-variant`, `on-surface-variant`…) más una escala tipográfica con nombre (`text-headline-lg`, `text-body-md`, `text-label-sm`, `text-caption`, `text-nav-link`) y espaciados con nombre (`p-card-padding`, `gap-gutter-grid`). Vienen de los mockups del portal; los nombres de clase son los mismos que en esos archivos.

**Nada de CDNs en ninguno de los dos front-ends.** La CSP (`script-src 'self'`, `style-src 'self'`, `font-src 'self'`) bloquea en silencio cualquier `<link>`/`<script>` externo. Reglas:

- **jQuery siempre local**: las vistas con `_Layout` lo reciben de `@Scripts.Render("~/bundles/jquery")`; las vistas `Layout = null` (modales en iframe, Login, AccesoDenegado, impresiones) deben traerlo con `<script src="@Url.Content("~/Scripts/jquery-3.7.0.min.js")"></script>`. Si falta, el bloqueo de CSP deja `$ is not defined`, ningún `submit` se intercepta y **el `<form>` se envía nativo por GET** — así aparecieron usuario y contraseña en la query string del login. Por eso el form del login lleva `method="post"` como red de seguridad.
- **Plus Jakarta Sans es local en los dos proyectos**: `CapaPresentacionAdmin/fonts/*.woff2` y `CapaPresentacionCliente/fonts/*.woff2`, cada uno con su `@font-face` al inicio de su `Content/tailwind.css`. Nunca reintroducir `fonts.googleapis.com`.

Dos reglas propias del portal del socio:

- **Fuente e iconos son locales, no de Google.** La CSP del `Web.config` deja `font-src 'self'` y `style-src 'self'`, así que un `<link>` a `fonts.googleapis.com` **se bloquea en silencio** (le pasaba al layout viejo). Plus Jakarta Sans vive en `CapaPresentacionCliente/fonts/*.woff2` con su `@font-face` dentro de `tailwind.css`. Material Symbols se sustituyó por un **sprite SVG** declarado una sola vez en `_Layout.cshtml`; se usa con `<svg class="ic"><use href="#ic-nombre"></use></svg>`.
- **`@keyframes` va en `tailwind.css`, nunca en una vista**: un `@` literal en un `.cshtml` rompe el parser de Razor.

### Database deploy

Run the relevant `.sql` files against SQL Server (executable in chunks split on `GO`). Most SPs use `CREATE OR ALTER`, so re-running is safe — **except `Medidor.sql`, `MetodoPago.sql`, `Ruta.sql` and `Tarifa.sql`, which still use plain `CREATE PROCEDURE`** and fail on re-run with *"There is already an object named..."*; convert the batch you touch to `CREATE OR ALTER` (or `DROP` first) before deploying it. Apply `CapaDato/BD/Migracion_0N_*.sql` in order for schema changes. After editing any SP in `CapaDato/SP/*.sql`, **re-run that file against the database** — file edits do not touch the live DB.

Deploy from the CLI with sqlcmd — **`-f 65001` (UTF-8) and `-I` (QUOTED_IDENTIFIER ON) are both mandatory**:

```bash
"/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/sqlcmd" \
  -S "DESKTOP-NLFU4EP\SQLEXPRESS" -d COSPABIRL1 -f 65001 -I -i "CapaDato/SP/archivo.sql"
```

- `-f 65001`: column names contain `ñ` (e.g. `contraseña`); without it the file fails with *"Incorrect syntax near '�'"*.
- `-I`: several tables (`pago`, `credito_inscripcion`) have **filtered indexes**. SQL Server bakes the `QUOTED_IDENTIFIER` setting into a stored procedure at CREATE time. sqlcmd defaults it OFF, so deploying an SP without `-I` stores it with QI OFF — and any INSERT that proc does into a filtered-index table then fails at runtime **from the app too** (*"INSERT failed because the following SET options have incorrect settings: 'QUOTED_IDENTIFIER'"*), not just in sqlcmd. Always deploy SP files with `-I`. (.NET SqlClient connections already run QI ON, which is why only sqlcmd-deployed procs get corrupted.)

Latest migrations: **11** (`credito_inscripcion.pago_id_pago`, nullable FK to `pago`, so the Créditos screen can pull up the receipt of the inscription's first payment), **12** (`tipo_cargo.automatico`, see *Cargos automáticos* above) and **13** (permiso `Generar Reporte Pagos Sistema` + `usuario_admin` **SISTEMA** + rename of the legacy `QR` payment method, see *Pagos del sistema* below). Migración **14** adds `cuenta_socio.intentos_fallidos` / `bloqueado_hasta` — the socio portal now has the same 5-attempt / 15-minute lockout the admin login had since Migración 10, enforced inside `sp_login_socio` (which gained `@Resultado`/`@Mensaje` OUTPUT params, so `CD_LoginSocio.Login` takes an `out string mensaje`).

Migration numbering is **not** a clean sequence: there are two different `Migracion_05_*` files (`normalizar_instalacion_socio` and `nullable_simple`) — both belong to the BD4→BD5 step and both must be applied. `CapaDato/BD/` also holds the full-schema snapshots (`BD3/BD4/BD5.sql`) and `Datos_Prueba.sql`; the root-level `BD3.sql` and `temp.txt` are stale leftovers — don't use them as reference.

Some older SP files (`usuario.sql`, `Login.sql`) still carry legacy `CREATE TABLE` statements at the top — re-running them prints *"There is already an object named..."* errors. That noise is expected; the `CREATE OR ALTER PROCEDURE` batches after it still apply.

- Connection string `name="cadena"` is in each web project's `Web.config`. Local default: `DESKTOP-NLFU4EP\SQLEXPRESS`, catalog `COSPABIRL1`.

## Conventions you MUST follow

- **New `.cs`/`.cshtml` files must be registered in the `.csproj`** (old-style, non-SDK — unregistered files don't compile). Default flow: give the user the **list** of files to create in VS; they create them (stubs come as `internal class` → change to `public`); then you fill/edit them. Only with the user's **explicit permission** may you create the files yourself AND add the matching `<Compile>`/`<Content>` entries to the `.csproj` (done once for `PortalController` + `Views/Portal/*` in CapaPresentacionCliente). Prefer adding methods/classes to existing files to avoid the issue entirely. `.sql` files are always created and deployed directly.
- **Decimal amounts must travel as `string` and be parsed with `InvariantCulture`.** There is no `<globalization culture>` in `Web.config`, so MVC's model binder parses with the machine culture (es-BO, comma decimal) using `NumberStyles.Float` — which rejects the `"55.000"` the browser sends, silently binding the amount to `0` and surfacing as a bogus *"El monto debe ser mayor a cero"*. Any action taking a `decimal` from a form must instead take `string` + `decimal.TryParse(..., NumberStyles.Any, CultureInfo.InvariantCulture, ...)`, and the JS should normalize `,` → `.` before posting. See `TipoCargoController` and `CargoExtraController`.
- In Razor views (`.cshtml`), a **literal `@` inside JavaScript** breaks the Razor parser. Avoid it or escape as `@@` (e.g. `@@keyframes`). Prefer server-side validation / `type="email"` over `@` in JS.
- `<script>` blocks in views that use `_Layout` must go in **`@section scripts { }`** — otherwise jQuery isn't loaded yet.
- Tailwind is **v4 compiled locally** (`@tailwindcss/cli`), not the CDN. Decimal utilities like `w-4.5` aren't standard; use inline `style="width:18px"` for precise icon sizing.

## Secrets

Libélula payment-gateway keys (`Libelula.AppKey`, `Libelula.UrlBase`, optional `Libelula.CallbackUrl`) live in a `Secrets.config` in **both** web projects — the cooperative has a single Libélula merchant account, so `CapaPresentacionCliente/Secrets.config` carries the **same** AppKey as the admin one (the socio generates his own QR from the portal). The file is gitignored (by name, so both are covered) and merged via `<appSettings file="Secrets.config">`. Copy `Secrets.config.example` to set up locally. Without a valid AppKey the QR flow fails at "registrar deuda"; without CallbackUrl it still works locally via the manual verification button on each side.
