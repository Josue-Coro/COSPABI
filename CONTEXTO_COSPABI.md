# COSPABI — Contexto del proyecto (handoff para Claude Code)

> Documento de traspaso. Resume el estado, el modelo de datos y las reglas de
> trabajo del sistema COSPABI para retomar el trabajo en otra sesión.
> Fecha del traspaso: 2026-06-15.

---

## 1. Qué es

Sistema de gestión para una **cooperativa de agua (COSPABI)** en Bolivia —
proyecto final de Ingeniería de Sistemas. Maneja socios, clientes, medidores,
lecturas, **facturación (avisos)**, cargos extra, crédito de inscripción,
**caja y pagos**, roles/permisos, etc.

## 2. Stack y estructura

- **ASP.NET MVC 5 sobre .NET Framework 4.7.2** (C#), `System.Web.Mvc`.
- Arquitectura en capas:
  - `CapaModelo` — POCOs (`CM_*`).
  - `CapaDato` — acceso a datos con `SqlClient` + SPs (`CD_*`); SPs en `CapaDato/BD/` (esquema/migraciones) y `CapaDato/SP/` (procedimientos).
  - `CapaNegocio` — lógica + validaciones + bitácora (`CN_*`).
  - `CapaPresentacionAdmin` — web MVC admin (controllers + vistas Razor). Vistas con **Tailwind (Content/app.css) + jQuery**.
  - `CapaPresentacionCliente` — portal del socio (poco desarrollado).
- **No hay `.sln`**. Compilar por proyecto, ej.:
  `& "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" "CapaPresentacionAdmin\CapaPresentacionAdmin.csproj" /t:Build /p:Configuration=Debug`
  (compila las capas referenciadas; las vistas `.cshtml` se compilan en runtime).
- Patrón de UI admin: lista con buscador + paginación + modales (algunos en `iframe` con `Layout=null`, otros con `_Layout` + `@section scripts`).

## 3. Base de datos

- **SQL Server** (la instancia real soporta `CREATE OR ALTER`, `FORMAT`,
  índices filtrados; el header "2012" de los scripts es solo el target del
  modelador). Local: `DESKTOP-NLFU4EP\SQLEXPRESS`, BD `COSPABIRL1`. La cadena
  (`name="cadena"`) está en los `Web.config` de ambos proyectos web.
- Despliegue de SQL: ejecutar los archivos `.sql` (se pueden correr partiendo
  por líneas `GO`). Todos los SPs nuevos usan `CREATE OR ALTER` (re-ejecutables).
- **Migraciones** en `CapaDato/BD/`:
  - `Migracion_01_aviso_cargos_credito.sql` — relación aviso↔cargo/crédito.
  - `Migracion_02_credito_inscripcion.sql` — `periodo.costo_inscripcion` + `pago.aviso_id_aviso` nullable.
  - `Migracion_03_caja_pago.sql` — caja + `pago.caja_id_caja`.
  - `Migracion_04_pago_pasarela.sql` — columnas de pasarela en `pago` + `cliente.email`.

## 4. Modelo de facturación (modelo "ledger", "Caso 1")

- `cargo_extra` y `credito_inscripcion` son **obligaciones independientes**
  ligadas a `socio` + `periodo`; **nacen ANTES** del aviso. El `aviso` se genera
  al cierre y las **"estampa"** con `aviso_id_aviso` (FK, NULL hasta facturar).
  NO se relacionan por join socio+periodo, sino por el `aviso_id_aviso` estampado.
- Cardinalidad: **1 aviso : N `cargo_extra`**; **1 aviso : 0..1 `credito_inscripcion`**
  (lo último garantizado por índice único filtrado `credito_inscripcion_aviso_UX`).
- **`credito_inscripcion` = inscripción de socio nuevo.** Total configurable en
  `periodo.costo_inscripcion` (hoy 1700 Bs). Al registrarse paga un **monto
  inicial** (entero, mínimo fijo 500) → cuota 1 `CANCELADO`. El saldo se financia
  en 1-3 cuotas más **que el socio elige** (MÁX 4 cuotas contando la inicial),
  enteras, **resto a la última**, en periodos consecutivos siguientes (se crean
  si faltan; formato `MM/YYYY`). Si paga el total de una → 1 sola cuota CANCELADO.
  Cada cuota **SUMA** al `total_aviso` (deuda financiada, NO descuento).
- Estados de cargo/cuota: `PENDIENTE` / `CANCELADO` (la cuota) — sin estado
  "FACTURADO". El re-estampado lo evita `aviso_id_aviso IS NULL`, no el estado.
- `aviso.total_aviso` es **foto inmutable** (consumo + Σ cargos + cuota crédito +
  deuda_actual); se escribe una vez al generar. `deuda_actual` hoy = total_aviso.
- **Tarifa**: si `consumo_m3 <= consumo_minimo_m3` → `monto_minimo`; si no →
  `monto_minimo + (consumo - minimo) * precio_m3`. La tarifa es por `rol_socio`.
- Máquina de estados del aviso (tabla `estado`): `GENERADO → LECTURADO → IMPRESO
  → PAGADO` (+ `ANULADO`). `sp_cambiar_estado_aviso` solo avanza. PAGADO se setea
  desde el módulo de Pagos.
- **NO** se usó índice único `aviso(socio,periodo)` (se eliminó porque chocaba
  con el flujo anular→regenerar). La regla "1 aviso vigente por socio/periodo" la
  cuida el `NOT EXISTS (... estado != 'ANULADO')` de `sp_generar_avisos_periodo`.

## 5. Caja + Pagos + (futuro) Libélula

**Caja** (`estado` 1=ABIERTA, 0=CERRADA):
- **Una caja ABIERTA por cajero** (índice filtrado `caja_cajero_abierta_UX WHERE estado=1`).
- `caja.monto_apertura` = fondo inicial. `monto_cobrado` se calcula al cerrar
  = `SUM(pagos APROBADO de la caja)`. `hors_cierre` se renombró a `hora_cierre`
  (nullable). Historial **solo del cajero logueado**.
- SPs en `CapaDato/SP/Caja.sql`: `sp_abrir_caja`, `sp_caja_abierta`,
  `sp_cerrar_caja`, `sp_arqueo_caja` (cabecera + total por método), `sp_listar_cajas`.
- Capas: `CM_Caja`/`CD_Caja`/`CN_Caja`, `CajaController`, `Views/Caja/Caja.cshtml`.

**Pago** (manual, cobro en efectivo/método; pago COMPLETO, sin parciales):
- El vínculo caja↔pago vive en **`pago.caja_id_caja`** (se eliminó `aviso.caja_id_caja`).
- `sp_registrar_pago_aviso`: exige caja abierta → inserta pago `estado_pago='APROBADO'`,
  marca aviso `PAGADO` y **cierra el ciclo** (cargos→PAGADO, cuotas→CANCELADO).
- SPs en `CapaDato/SP/Pago.sql`: `sp_listar_avisos_por_cobrar`,
  `sp_registrar_pago_aviso`, `sp_listar_pagos_caja`.
- Capas: `CM_Pago`/`CD_Pago`/`CN_Pago`, `PagoController`, `Views/Pago/Pago.cshtml`.
- **El alta de socio exige caja abierta**: `sp_registrar_socio_con_inscripcion`
  recibe `@id_caja` y el pago de inscripción se liga a la caja.

**Circuito de efectivo (COMPLETO y funcionando):**
`abrir caja → registrar socio (inscripción→caja) / cobrar avisos (pago→caja, cierra ciclo) → cerrar caja con arqueo por método`.

**Pasarela QR — Libélula (DIFERIDA, aún NO implementada):**
- Las columnas en `pago` ya están listas: `identificador_deuda`, `id_transaccion`,
  `estado_pago` (PENDIENTE/APROBADO/RECHAZADO/EXPIRADO, reemplaza el viejo BIT),
  `forma_pago`, `codigo_recaudacion`, `url_pasarela`, `qr_url`; `fecha_pago` es DATETIME.
  Idempotencia: índice único filtrado `pago_id_transaccion_UX`.
- Flujo Libélula (manual en `C:\JOSUE_1_2026\Taller de grado I\API Pagos por QR\Libelula Manual...pdf`):
  POST `/rest/deuda/registrar` (envías `identificador`, `email_cliente`, `callback_url`,
  `lineas_detalle_deuda`) → devuelve `id_transaccion`, `url_pasarela_pagos`,
  `qr_simple_url`. El socio paga el QR → Libélula llama tu callback `PAGO EXITOSO`
  (`transaction_id`) → marcas APROBADO y cierras el ciclo. `consultar_pagos` por
  fechas = conciliación. Libélula **tokeniza** (cero datos de tarjeta → cero PCI).
- `cliente.email` ya existe (Libélula lo EXIGE). Pendiente para implementarla:
  callback público (ngrok en local), y opcionalmente factura SFE.
- **appkey de Libélula** en `CapaPresentacionAdmin/Secrets.config` (gitignored,
  combinado vía `<appSettings file="Secrets.config">`; hay `Secrets.config.example`).
  Llaves: `Libelula.AppKey`, `Libelula.UrlBase`.

## 6. Estado actual

**Hecho y verificado:**
- Esquema migrado (Migraciones 01–04, aplicadas).
- Facturación: SPs de aviso/cargo adaptados al modelo nuevo; detalle con N cargos.
- Crédito de inscripción: registro de socio crea las cuotas; pantalla Credito de seguimiento.
- CRUD de cliente con `email` (capa por capa).
- **Módulo Caja** completo. **Módulo Pago** (efectivo) completo. Alta de socio enganchada a caja.

**Pendiente:**
- Integración **QR/Libélula** (diferida por el usuario; esquema listo).
- Permisos nuevos sembrados pero hay que **asignarlos a los roles**:
  `Gestionar Avisos`, `Gestionar Credito Inscripcion`, `Gestionar Caja`, `Gestionar Pago`.
- Portal del socio (`CapaPresentacionCliente`) poco desarrollado.

## 7. Convenciones de trabajo (IMPORTANTES)

- **NO crear archivos `.cs` ni `.cshtml` nuevos** desde fuera de Visual Studio:
  el `.csproj` es estilo antiguo (no SDK), y un archivo creado por fuera no se
  agrega al proyecto y **no compila**. Flujo: dar al usuario la **lista** de
  archivos a crear; él los crea en VS; luego se **editan/llenan** (el stub viene
  `internal class` → cambiar a `public`). **Nunca tocar el `.csproj`.**
  Los archivos **`.sql` sí** se pueden crear/desplegar directamente.
- En vistas Razor (`.cshtml`), un **`@` literal dentro del JavaScript** rompe el
  parser ("no es válido al inicio de un bloque de código"). Evitarlo (validar en
  el servidor / usar `type="email"`) o escaparlo como `@@`.
- Los `<script>` en vistas que usan `_Layout` van en **`@section scripts { }`**
  (si no, jQuery no está cargado todavía).
- El usuario es de Bolivia, trabaja en español; las respuestas van en español.

## 8. Idea pendiente clave si retomas Libélula

Construir `CD/CN_Pago` + `PagoController` para: (1) generar la deuda en Libélula y
crear el `pago` PENDIENTE con `id_transaccion`/`qr_url`; (2) un endpoint público
`PagoExitoso(transaction_id)` que marque el pago APROBADO y cierre el ciclo;
(3) un job/acción de conciliación con `consultar_pagos`. Un pago QR cobrado en
ventanilla va a la caja del cajero; uno pagado online por el socio va con
`caja_id_caja = NULL`.
