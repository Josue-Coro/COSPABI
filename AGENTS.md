# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

> The user is from Bolivia and works in Spanish. **Respond in Spanish.**
> `CONTEXTO_COSPABI.md` is the authoritative handoff doc for domain rules (facturación, caja, pagos, Libélula) — read it for any business-logic work. `CapaPresentacionAdmin/main.md` is the UI design system (colors, typography, components).

## What this is

COSPABI — management system for a water cooperative (cooperativa de agua) in Bolivia. Final engineering project. Handles socios, clientes, medidores, lecturas, **facturación (avisos)**, cargos extra, crédito de inscripción, **caja y pagos**, and roles/permisos.

**Stack:** ASP.NET MVC 5 on **.NET Framework 4.7.2** (C#, `System.Web.Mvc`). SQL Server backend accessed via raw `SqlClient` + stored procedures (no ORM).

## Architecture — 4 layers + 2 web fronts

Classic Capas (layered) architecture. Each entity flows through parallel files named by prefix:

- **`CapaModelo`** (`CM_*`) — POCOs only. Some files hold nested classes (e.g. `CM_Cliente` contains `CM_Cliente_Paginado`, accessed via `using static CapaModelo.CM_Cliente;`).
- **`CapaDato`** (`CD_*`) — data access. Each method opens a `SqlConnection` from `CD_Conexion.cn`, calls a stored procedure, maps the reader. **All SQL lives in stored procedures**, not in C#. SQL source files live in `CapaDato/SP/` (procedures, `CREATE OR ALTER`) and `CapaDato/BD/` (schema + numbered migrations).
- **`CapaNegocio`** (`CN_*`) — validation + business rules + **bitácora (audit log)**. The CN method validates, delegates to its CD counterpart, and on success calls `cnBitacora.Registrar("...", idUsuarioSesion)`. Controllers should call CN, never CD directly.
- **`CapaPresentacionAdmin`** — the main MVC web app (admin). This is where almost all work happens.
- **`CapaPresentacionCliente`** — socio self-service portal. Barely developed.

**Per-entity call chain:** `Controller → CN_X (validate + bitácora) → CD_X (SqlClient) → sp_x_* (stored proc)`.

### Stored-procedure return convention (IMPORTANT)

CD methods that mutate data use **output parameters** `@Resultado INT OUTPUT` and `@Mensaje VARCHAR(500) OUTPUT`, read after `ExecuteNonQuery()`. The matching SP must declare those OUTPUT params and `SET` them (not `SELECT` them). A mismatch here produces *"Procedure or function ... has too many arguments specified"* at runtime. List/Obtener SPs instead return result sets read with `ExecuteReader`. When adding a mutating SP, follow the `@Resultado`/`@Mensaje` OUTPUT pattern to stay consistent with the CD layer.

### Auth & permissions

- Login stores `CM_Usuario_Activo` (with `ListaPermisos`) in `Session["Usuario"]`; the layout also reads `Session["NombreUsuario"]` / `Session["RolUsuario"]`.
- Controllers are gated with `[ValidarPermisos(NombrePermiso = "Gestionar X")]` (in `CapaPresentacionAdmin/Filtros/`). No session → redirect to Login; session but missing permission → AccesoDenegado.
- Controller actions return `JsonResult` shaped `{ exito, mensaje, ...data }`; views consume via jQuery AJAX. Page actions return `View()`. **Exception:** `PermisoController` returns `{ resultado: int }` (success = `resultado > 0`), not `exito` — match the shape per controller in JS.

## Build & run

**There IS a solution file** (`COSPABI.slnx`, the new XML format) despite what older notes say. There is **no classic `.sln`**. Build per project with MSBuild (this compiles referenced layers; `.cshtml` views compile at runtime):

```bash
& "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" \
  "CapaPresentacionAdmin\CapaPresentacionAdmin.csproj" /t:Build /p:Configuration=Debug
```

Run the web app from Visual Studio (IIS Express). There are **no automated tests** in this repo.

### CSS (Tailwind)

The admin UI uses **Tailwind CSS compiled to a local stylesheet** (`Content/app.css`) — the old CDN approach was removed. After editing Tailwind classes or `Content/tailwind.css`, rebuild from `CapaPresentacionAdmin/`:

```bash
npm run build:css      # one-shot: tailwind.css -> app.css
npm run watch:css      # watch mode while developing
```

### Database deploy

Run the relevant `.sql` files against SQL Server (executable in chunks split on `GO`). SPs use `CREATE OR ALTER`, so re-running is safe. Apply `CapaDato/BD/Migracion_0N_*.sql` in order for schema changes. After editing any SP in `CapaDato/SP/*.sql`, **re-run that file against the database** — file edits do not touch the live DB.

- Connection string `name="cadena"` is in each web project's `Web.config`. Local default: `DESKTOP-NLFU4EP\SQLEXPRESS`, catalog `COSPABIRL1`.

## Conventions you MUST follow

- **Do NOT create new `.cs` or `.cshtml` files** from outside Visual Studio. The `.csproj` files are old-style (non-SDK), so externally created files are not added to the project and won't compile. Instead: give the user the **list** of files to create in VS; they create them (stubs come as `internal class` → change to `public`); then you fill/edit them. **Never edit a `.csproj`.** `.sql` files are the exception — create and deploy those directly.
- In Razor views (`.cshtml`), a **literal `@` inside JavaScript** breaks the Razor parser. Avoid it or escape as `@@` (e.g. `@@keyframes`). Prefer server-side validation / `type="email"` over `@` in JS.
- `<script>` blocks in views that use `_Layout` must go in **`@section scripts { }`** — otherwise jQuery isn't loaded yet.
- Tailwind is **v4 compiled locally** (`@tailwindcss/cli`), not the CDN. Decimal utilities like `w-4.5` aren't standard; use inline `style="width:18px"` for precise icon sizing.

## Secrets

Libélula payment-gateway keys (`Libelula.AppKey`, `Libelula.UrlBase`) live in `CapaPresentacionAdmin/Secrets.config` (gitignored, merged via `<appSettings file="Secrets.config">`). Copy `Secrets.config.example` to set up locally. The QR/Libélula integration itself is **deferred** — schema columns exist on `pago` but the flow is not implemented (see `CONTEXTO_COSPABI.md` §5, §8).
