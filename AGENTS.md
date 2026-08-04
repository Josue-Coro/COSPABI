# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

> The user is from Bolivia and works in Spanish. **Respond in Spanish.**
> `CONTEXTO_COSPABI.md` is the authoritative handoff doc for domain rules (facturación, caja, pagos, Libélula) — read it for any business-logic work. `CapaPresentacionAdmin/main.md` has the color palette and component specs; **its CSS framework section is outdated** (describes CDN approach that was replaced — follow the compiled-CSS approach in CLAUDE.md instead).
> `CLAUDE.md` mirrors this file for Claude Code — apply any edit to both files.

## What this is

COSPABI — management system for a water cooperative (cooperativa de agua) in Bolivia. Final engineering project. Handles socios, clientes, medidores, lecturas, **facturación (avisos)**, cargos extra, crédito de inscripción, **caja y pagos (efectivo + QR Libélula)**, roles/permisos, **reportes (caja, morosidad)** and the **portal del socio**. All 6 modules / 22 user stories of the thesis scope are implemented.

**Stack:** ASP.NET MVC 5 on **.NET Framework 4.7.2** (C#, `System.Web.Mvc`). SQL Server backend accessed via raw `SqlClient` + stored procedures (no ORM).

## Architecture — 4 layers + 2 web fronts

Classic Capas (layered) architecture. Each entity flows through parallel files named by prefix:

- **`CapaModelo`** (`CM_*`) — POCOs only. Some files hold nested classes (e.g. `CM_Cliente` contains `CM_Cliente_Paginado`, accessed via `using static CapaModelo.CM_Cliente;`).
- **`CapaDato`** (`CD_*`) — data access. Each method opens a `SqlConnection` from `CD_Conexion.cn`, calls a stored procedure, maps the reader. **All SQL lives in stored procedures**, not in C# (the last inline queries were moved to `CapaDato/SP/ConsultasDirectasMigradas.sql`). SQL source files live in `CapaDato/SP/` (procedures, `CREATE OR ALTER`, one file per entity) and `CapaDato/BD/` (schema + numbered migrations). Most `SP/*.sql` names map 1:1 to an entity; the ones that don't: `AvisoImpresion.sql` (printable aviso + `sp_marcar_aviso_impreso`), `Estado.sql` (seeds the aviso state table), `Estadistica.sql` (admin dashboard), `Reporte.sql` (HU21/HU22), `PortalSocio.sql` (socio portal), `PagoQr.sql` (Libélula), `LoginSocio.sql` vs `Login.sql` (socio vs admin), `Rol_Socio.sql` (tariff category, *not* the permissions role), `ConsultasDirectasMigradas.sql` (ex-inline queries).
- **`CapaNegocio`** (`CN_*`) — validation + business rules + **bitácora (audit log)**. The CN method validates, delegates to its CD counterpart, and on success calls `cnBitacora.Registrar("...", idUsuarioSesion)`. Controllers should call CN, never CD directly.
- **`CapaPresentacionAdmin`** — the main MVC web app (admin). This is where almost all work happens.
- **`CapaPresentacionCliente`** — socio self-service portal (Bootstrap, NOT Tailwind). Login (`sp_login_socio`, session `Session["Socio"]` = `CM_CuentaSocio_Activo`), Home, Perfil, and `PortalController` (avisos, pagos, estado de cuenta, notificaciones con marcar-leída). **The socio id always comes from the session, never from the browser** — keep it that way in any new portal action. Portal SPs live in `CapaDato/SP/PortalSocio.sql`; portal CD/CN methods live in `CD_CuentaSocio`/`CN_CuentaSocio`.

**Per-entity call chain:** `Controller → CN_X (validate + bitácora) → CD_X (SqlClient) → sp_x_* (stored proc)`.

### Stored-procedure return convention (IMPORTANT)

CD methods that mutate data use **output parameters** `@Resultado INT OUTPUT` and `@Mensaje VARCHAR(500) OUTPUT`, read after `ExecuteNonQuery()`. The matching SP must declare those OUTPUT params and `SET` them (not `SELECT` them). A mismatch here produces *"Procedure or function ... has too many arguments specified"* at runtime. Some SPs use a different name for the integer output (e.g. `@Generados` in `sp_generar_avisos_periodo`) — the names must match exactly between the CD call and the SP declaration. List/Obtener SPs instead return result sets read with `ExecuteReader`. When adding a mutating SP, follow the `@Resultado`/`@Mensaje` OUTPUT pattern to stay consistent with the CD layer.

### Auth & permissions

- Login stores `CM_Usuario_Activo` (with `ListaPermisos`) in `Session["Usuario"]`; the layout also reads `Session["NombreUsuario"]` / `Session["RolUsuario"]`. Passwords are SHA-256 (no salt) via `CN_Recursos.ConvertirSha256`.
- `sp_login_admin` enforces **account lockout**: 5 failed attempts → 15-min block (columns `intentos_fallidos`/`bloqueado_hasta` on `usuario_admin`, Migración 10). All counting/blocking and failure bitácora live in the SP; it returns both result sets (user + permisos) *and* `@Resultado`/`@Mensaje` OUTPUT params. Failure messages are deliberately generic so account existence isn't revealed.
- `permiso.modulo` (Migración 09) groups the 37 permisos into 7 modules; `sp_listar_permisos` returns them pre-sorted by module for the grouped UI in `Views/Permiso/Permiso.cshtml`.
- **The `SUPERADMIN` role is shielded** (cross-cutting, by role *name*): non-superadmin users can't see it or its users in listings (Rol, Usuario, Permiso, Bitácora filter) nor modify/assign it. Controllers compute `esSuperadmin` from `Session["Usuario"].nombre_rol` and pass it down (`CN_Rol.Listar(bool)`, `@IncluirSuperadmin` / `@SolicitanteEsSuperadmin` in the SPs); the SPs enforce the block. Any new listing or mutation touching roles/usuarios must respect this.
- Controllers are gated with `[ValidarPermisos(NombrePermiso = "...")]` (in `CapaPresentacionAdmin/Filtros/`). Permission names vary (e.g. `"Gestionar Caja"`, `"Visualizar Bitacora"`). No session → redirect to Login; session but missing permission → AccesoDenegado.
- **Session expires after 15 min of inactivity (RNF-04)** in both web projects: `<forms timeout="15" slidingExpiration="true">` **and** `<sessionState timeout="15" />` in `Web.config`. Both numbers must stay in sync — Forms auth alone would keep the cookie alive after the `Session["Usuario"]`/`Session["Socio"]` object is gone, which crashes any action that casts it.
- **JsonResult shapes are not uniform** — always read the target action before writing its JS consumer:
  - older CRUD controllers (Aviso, Bitacora, CargoExtra, Lectura, Rol, Ruta, Socio, Tarifa, TipoCargo, Usuario): reads return `{ data: list }`, mutations `{ exito, mensaje, ...data }`.
  - newer controllers (Reporte, Notificacion, Caja, Pago, Home, and the whole `PortalController`): reads *also* return `{ exito, mensaje }` plus a **named** payload (`cajeros`, `notificaciones` + `totalRegistros`, `avisos`, `resumen`, …), not `data`.
  - `PermisoController` is a further exception: `{ resultado: int }` (success = `resultado > 0`).

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

### Reportes (HU21 caja / HU22 morosidad)

`ReporteController` has no CN/CD of its own: it reuses `CN_Caja.ReporteCaja` and `CN_Aviso.ReporteMorosidad` (SPs `sp_reporte_caja`, `sp_reporte_morosidad`, `sp_listar_cajeros_con_caja` in `CapaDato/SP/Reporte.sql`). Both CN methods write bitácora, so the controller passes `id_usuario_admin`. The cajero filter is SUPERADMIN-shielded like the rest (`ListarCajerosConCaja(esSuperadmin)`). Views render in-page and print with the `@@media print` pattern above. The admin dashboard is separate: `HomeController.ObtenerEstadisticas` → `CN_Dashboard` → `CapaDato/SP/Estadistica.sql`, for the current `MM/yyyy` period.

### Notificaciones

Admin CRUD (`NotificacionController` + `CapaDato/SP/Notificacion.sql`) sends a notificación to selected socios (`ids_socios`, CSV) or to all (`enviar_a_todos`), fanned out by `sp_asignar_notificacion_socios`. Two are generated by the system, not by hand: `sp_generar_notificaciones_vencimiento` (RF-27 recordatorios, N days before `fecha_vencimiento`, triggered from the UI button → `GenerarRecordatorios`) and `sp_notificar_pago_confirmado` (fired inside the payment flow). The socio reads them in the portal (`sp_portal_notificaciones_socio` / `sp_portal_marcar_notificacion_leida`). Keep new notification sources going through an SP so the socio-side fan-out stays consistent.

### Pasarela QR — Libélula (IMPLEMENTED)

Flow: `PagoController.GenerarQr` → `CN_Pago.GenerarPagoQr` (reads `sp_datos_deuda_qr`, calls `CN_Libelula.RegistrarDeuda`, inserts pago PENDIENTE via `sp_registrar_pago_qr_pendiente`) → socio pays → callback `PagoExitoso` (public GET, `[AllowAnonymous]`) or manual "Verificar pago" (`ConciliarQr`) → `sp_confirmar_pago_qr` approves and closes the cycle. SPs in `CapaDato/SP/PagoQr.sql`; HTTP client `CN_Libelula` (Newtonsoft.Json is installed in CapaNegocio; config injected from the controller via `ConfigurationManager`). Anti double-charge rules — do not break them:
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

The admin UI uses **Tailwind CSS compiled to a local stylesheet** (`Content/app.css`) — the old CDN approach was removed. After editing Tailwind classes or `Content/tailwind.css`, rebuild from `CapaPresentacionAdmin/`:

```bash
npm run build:css      # one-shot: tailwind.css -> app.css
npm run watch:css      # watch mode while developing
```

### Database deploy

Run the relevant `.sql` files against SQL Server (executable in chunks split on `GO`). SPs use `CREATE OR ALTER`, so re-running is safe. Apply `CapaDato/BD/Migracion_0N_*.sql` in order for schema changes. After editing any SP in `CapaDato/SP/*.sql`, **re-run that file against the database** — file edits do not touch the live DB.

Deploy from the CLI with sqlcmd — **`-f 65001` (UTF-8) and `-I` (QUOTED_IDENTIFIER ON) are both mandatory**:

```bash
"/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/sqlcmd" \
  -S "DESKTOP-NLFU4EP\SQLEXPRESS" -d COSPABIRL1 -f 65001 -I -i "CapaDato/SP/archivo.sql"
```

- `-f 65001`: column names contain `ñ` (e.g. `contraseña`); without it the file fails with *"Incorrect syntax near '�'"*.
- `-I`: several tables (`pago`, `credito_inscripcion`) have **filtered indexes**. SQL Server bakes the `QUOTED_IDENTIFIER` setting into a stored procedure at CREATE time. sqlcmd defaults it OFF, so deploying an SP without `-I` stores it with QI OFF — and any INSERT that proc does into a filtered-index table then fails at runtime **from the app too** (*"INSERT failed because the following SET options have incorrect settings: 'QUOTED_IDENTIFIER'"*), not just in sqlcmd. Always deploy SP files with `-I`. (.NET SqlClient connections already run QI ON, which is why only sqlcmd-deployed procs get corrupted.)

Latest migrations: **11** (`credito_inscripcion.pago_id_pago`, nullable FK to `pago`, so the Créditos screen can pull up the receipt of the inscription's first payment) and **12** (`tipo_cargo.automatico`, see *Cargos automáticos* above).

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

Libélula payment-gateway keys (`Libelula.AppKey`, `Libelula.UrlBase`, optional `Libelula.CallbackUrl`) live in `CapaPresentacionAdmin/Secrets.config` **only** — `CapaPresentacionCliente` has no `Secrets.config` and no gateway config, because the QR flow is driven by the cajero from the admin app; the socio portal only reads its avisos and pagos. The file is gitignored and merged via `<appSettings file="Secrets.config">`. Copy `Secrets.config.example` to set up locally. Without a valid AppKey the QR flow fails at "registrar deuda"; without CallbackUrl the QR flow still works locally via the "Verificar pago" conciliation button.
