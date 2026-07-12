# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> The user is from Bolivia and works in Spanish. **Respond in Spanish.**
> `CONTEXTO_COSPABI.md` is the authoritative handoff doc for domain rules (facturación, caja, pagos, Libélula) — read it for any business-logic work. `CapaPresentacionAdmin/main.md` has the color palette and component specs; **its CSS framework section is outdated** (describes CDN approach that was replaced — follow the compiled-CSS approach in this file instead).
> `AGENTS.md` mirrors this file for other coding agents — apply any edit to both files.

## What this is

COSPABI — management system for a water cooperative (cooperativa de agua) in Bolivia. Final engineering project. Handles socios, clientes, medidores, lecturas, **facturación (avisos)**, cargos extra, crédito de inscripción, **caja y pagos**, and roles/permisos.

**Stack:** ASP.NET MVC 5 on **.NET Framework 4.7.2** (C#, `System.Web.Mvc`). SQL Server backend accessed via raw `SqlClient` + stored procedures (no ORM).

## Architecture — 4 layers + 2 web fronts

Classic Capas (layered) architecture. Each entity flows through parallel files named by prefix:

- **`CapaModelo`** (`CM_*`) — POCOs only. Some files hold nested classes (e.g. `CM_Cliente` contains `CM_Cliente_Paginado`, accessed via `using static CapaModelo.CM_Cliente;`).
- **`CapaDato`** (`CD_*`) — data access. Each method opens a `SqlConnection` from `CD_Conexion.cn`, calls a stored procedure, maps the reader. **All SQL lives in stored procedures**, not in C# (the last inline queries were moved to `CapaDato/SP/ConsultasDirectasMigradas.sql`). SQL source files live in `CapaDato/SP/` (procedures, `CREATE OR ALTER`, one file per entity) and `CapaDato/BD/` (schema + numbered migrations).
- **`CapaNegocio`** (`CN_*`) — validation + business rules + **bitácora (audit log)**. The CN method validates, delegates to its CD counterpart, and on success calls `cnBitacora.Registrar("...", idUsuarioSesion)`. Controllers should call CN, never CD directly.
- **`CapaPresentacionAdmin`** — the main MVC web app (admin). This is where almost all work happens.
- **`CapaPresentacionCliente`** — socio self-service portal. Barely developed.

**Per-entity call chain:** `Controller → CN_X (validate + bitácora) → CD_X (SqlClient) → sp_x_* (stored proc)`.

### Stored-procedure return convention (IMPORTANT)

CD methods that mutate data use **output parameters** `@Resultado INT OUTPUT` and `@Mensaje VARCHAR(500) OUTPUT`, read after `ExecuteNonQuery()`. The matching SP must declare those OUTPUT params and `SET` them (not `SELECT` them). A mismatch here produces *"Procedure or function ... has too many arguments specified"* at runtime. Some SPs use a different name for the integer output (e.g. `@Generados` in `sp_generar_avisos_periodo`) — the names must match exactly between the CD call and the SP declaration. List/Obtener SPs instead return result sets read with `ExecuteReader`. When adding a mutating SP, follow the `@Resultado`/`@Mensaje` OUTPUT pattern to stay consistent with the CD layer.

### Auth & permissions

- Login stores `CM_Usuario_Activo` (with `ListaPermisos`) in `Session["Usuario"]`; the layout also reads `Session["NombreUsuario"]` / `Session["RolUsuario"]`. Passwords are SHA-256 (no salt) via `CN_Recursos.ConvertirSha256`.
- `sp_login_admin` enforces **account lockout**: 5 failed attempts → 15-min block (columns `intentos_fallidos`/`bloqueado_hasta` on `usuario_admin`, Migración 10). All counting/blocking and failure bitácora live in the SP; it returns both result sets (user + permisos) *and* `@Resultado`/`@Mensaje` OUTPUT params. Failure messages are deliberately generic so account existence isn't revealed.
- `permiso.modulo` (Migración 09) groups the 37 permisos into 7 modules; `sp_listar_permisos` returns them pre-sorted by module for the grouped UI in `Views/Permiso/Permiso.cshtml`.
- **The `SUPERADMIN` role is shielded** (cross-cutting, by role *name*): non-superadmin users can't see it or its users in listings (Rol, Usuario, Permiso, Bitácora filter) nor modify/assign it. Controllers compute `esSuperadmin` from `Session["Usuario"].nombre_rol` and pass it down (`CN_Rol.Listar(bool)`, `@IncluirSuperadmin` / `@SolicitanteEsSuperadmin` in the SPs); the SPs enforce the block. Any new listing or mutation touching roles/usuarios must respect this.
- Controllers are gated with `[ValidarPermisos(NombrePermiso = "...")]` (in `CapaPresentacionAdmin/Filtros/`). Permission names vary (e.g. `"Gestionar Caja"`, `"Visualizar Bitacora"`). No session → redirect to Login; session but missing permission → AccesoDenegado.
- **JsonResult shapes are not uniform:** mutation actions return `{ exito: bool, mensaje: string, ...data }`; read actions (Listar, Obtener) return `{ data: list }`. `PermisoController` is a further exception: returns `{ resultado: int }` (success = `resultado > 0`). Match the shape of the existing controller when writing JS consumers.

### UI modal pattern

Views use two modal approaches — pick the right one:
- **`iframe` modals with `Layout = null`**: the form view has no layout; the parent page opens it in a Bootstrap/custom modal. Simpler isolation, no script-ordering issues.
- **`@section scripts` modals**: the form lives in-page; script goes in `@section scripts { }` of the same view. Used when the form shares the main layout.

Cross-module constraint: **registering a new socio requires an open caja** — `sp_registrar_socio_con_inscripcion` receives `@id_caja` and the inscription payment is tied to that caja. The SocioController must call `CN_Caja.ObtenerCajaAbierta()` (or equivalent) before creating a socio.

### Printing / "PDF" output

There is **no server-side PDF library**. Printable documents (aviso, recibo de pago, reporte de caja) are standalone views without `_Layout` that call `window.print()` — see `Views/Aviso/ImprimirAviso.cshtml`, `Views/Pago/ImprimirRecibo.cshtml`, `Views/Caja/Reporte.cshtml`. Follow that pattern for new printable documents instead of adding a PDF package.

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

Some older SP files (`usuario.sql`, `Login.sql`) still carry legacy `CREATE TABLE` statements at the top — re-running them prints *"There is already an object named..."* errors. That noise is expected; the `CREATE OR ALTER PROCEDURE` batches after it still apply.

- Connection string `name="cadena"` is in each web project's `Web.config`. Local default: `DESKTOP-NLFU4EP\SQLEXPRESS`, catalog `COSPABIRL1`.

## Conventions you MUST follow

- **Do NOT create new `.cs` or `.cshtml` files** from outside Visual Studio. The `.csproj` files are old-style (non-SDK), so externally created files are not added to the project and won't compile. Instead: give the user the **list** of files to create in VS; they create them (stubs come as `internal class` → change to `public`); then you fill/edit them. **Never edit a `.csproj`.** `.sql` files are the exception — create and deploy those directly.
- In Razor views (`.cshtml`), a **literal `@` inside JavaScript** breaks the Razor parser. Avoid it or escape as `@@` (e.g. `@@keyframes`). Prefer server-side validation / `type="email"` over `@` in JS.
- `<script>` blocks in views that use `_Layout` must go in **`@section scripts { }`** — otherwise jQuery isn't loaded yet.
- Tailwind is **v4 compiled locally** (`@tailwindcss/cli`), not the CDN. Decimal utilities like `w-4.5` aren't standard; use inline `style="width:18px"` for precise icon sizing.

## Secrets

Libélula payment-gateway keys (`Libelula.AppKey`, `Libelula.UrlBase`) live in `CapaPresentacionAdmin/Secrets.config` (gitignored, merged via `<appSettings file="Secrets.config">`). Copy `Secrets.config.example` to set up locally. The QR/Libélula integration itself is **deferred** — schema columns exist on `pago` but the flow is not implemented (see `CONTEXTO_COSPABI.md` §5, §8).
