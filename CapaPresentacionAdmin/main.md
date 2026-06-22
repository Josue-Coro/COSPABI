# Sistema de Diseño — COSPABI Admin
> Documentación de referencia para la capa de presentación del sistema de gestión web COSPABI.  
> Aplica a: `Login.cshtml`, `_Layout.cshtml` y todas las vistas de `CapaPresentacionAdmin`.

---

## 1. Framework CSS — Tailwind CSS

Se utiliza **Tailwind CSS v3** cargado desde CDN, sin proceso de compilación local.

```html
<script src="https://cdn.tailwindcss.com"></script>
```

### Configuración extendida (tailwind.config)
Se declara en cada vista o en el `_Layout.cshtml` dentro de un `<script>` justo después del CDN:

```js
tailwind.config = {
    theme: {
        extend: {
            colors: { /* ver sección Colores */ },
            fontFamily: {
                sans: ['Plus Jakarta Sans', 'sans-serif'],
            }
        }
    }
}
```

> **Nota importante:** Tailwind CDN no genera clases con decimales como `w-4.5` o `h-4.5`.  
> Para tamaños de íconos usar siempre `style="width:18px; height:18px;"` en lugar de clases Tailwind.

---

## 2. Tipografía

| Elemento        | Fuente               | Peso       | Uso                          |
|-----------------|----------------------|------------|------------------------------|
| Fuente principal | **Plus Jakarta Sans** | 400 / 500 / 600 / 700 | Todo el sistema           |
| Fallback        | `sans-serif`         | —          | Si no carga Google Fonts     |

### Carga de la fuente
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### Aplicación global en CSS
```css
body { font-family: 'Plus Jakarta Sans', sans-serif; }
```

### Escala tipográfica usada

| Uso                        | Clase Tailwind         |
|----------------------------|------------------------|
| Título principal (login)   | `text-2xl font-bold`   |
| Subtítulo / sección        | `text-xl font-semibold`|
| Texto de formulario        | `text-sm font-medium`  |
| Placeholder / ayuda        | `text-sm text-gray-400`|
| Labels de nav (sidebar)    | `text-[13.5px] font-medium` |
| Etiquetas de sección nav   | `text-[10.5px] font-semibold uppercase` |
| Footer / copyright         | `text-xs text-gray-500`|

---

## 3. Paleta de Colores

### 3.1 Color primario — Verde

Es el color de marca del sistema. Se usa en botones, acentos, badges y el ícono del logo.

| Token            | Valor hex   | Uso principal                            |
|------------------|-------------|------------------------------------------|
| `primary-50`     | `#f0fdf4`   | Fondos sutiles, hover en estados activos |
| `primary-100`    | `#dcfce7`   | Avatar del header (fondo iniciales)      |
| `primary-500`    | `#22c55e`   | Color principal: botones, ícono logo, badge notificación, franja accent |
| `primary-600`    | `#16a34a`   | Hover de botón primario, avatar sidebar  |
| `primary-700`    | `#15803d`   | Degradado secundario del botón           |

### 3.2 Color de superficie — Sidebar

| Token              | Valor hex   | Uso                              |
|--------------------|-------------|----------------------------------|
| `sidebar`          | `#1c2434`   | Fondo del sidebar y login body   |
| `sidebar-light`    | `#242f42`   | Variante clara del sidebar       |
| `sidebar-hover`    | `#2d3a4e`   | Hover de links en sidebar        |
| `sidebar-active`   | `#334155`   | Estado activo / seleccionado     |
| `sidebar-border`   | `#2d3a4e`   | Bordes internos del sidebar      |

### 3.3 Colores neutros (Tailwind estándar)

| Uso                        | Clase Tailwind          |
|----------------------------|-------------------------|
| Fondo general de la app    | `bg-slate-100`          |
| Fondo del header           | `bg-white`              |
| Texto principal            | `text-gray-800`         |
| Texto secundario / muted   | `text-gray-400`         |
| Bordes de inputs           | `border-gray-300`       |
| Fondo de inputs            | `bg-gray-50`            |
| Separadores                | `border-gray-200`       |

### 3.4 Color de error

| Uso                  | Clase Tailwind                          |
|----------------------|-----------------------------------------|
| Texto del mensaje    | `text-red-700`                          |
| Fondo del alerta     | `bg-red-50`                             |
| Borde del alerta     | `border border-red-200`                 |
| Ítem peligroso (dropdown) | `color: #dc2626` / hover `bg-red-50` |

---

## 4. Componentes Clave

### 4.1 Botón primario
```html
<button class="btn-primary w-full py-2.5 rounded-xl text-sm font-semibold text-white">
    Iniciar Sesión
</button>
```
```css
.btn-primary {
    background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
    transition: opacity 0.2s, transform 0.15s, box-shadow 0.2s;
}
.btn-primary:hover:not(:disabled) {
    opacity: 0.92;
    transform: translateY(-1px);
    box-shadow: 0 8px 20px rgba(34,197,94,0.30);
}
```

### 4.2 Input de formulario
```html
<input class="input-field w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-xl text-sm bg-gray-50">
```
```css
.input-field {
    transition: border-color 0.2s, box-shadow 0.2s;
}
.input-field:focus {
    border-color: #22c55e;
    box-shadow: 0 0 0 3px rgba(34,197,94,0.15);
    outline: none;
}
```

### 4.3 Alerta de error
```html
<div id="errorMsg" class="hidden flex items-start gap-2.5 text-red-700 text-sm
     bg-red-50 border border-red-200 px-4 py-3 rounded-xl"
     role="alert" aria-live="assertive">
    <!-- ícono SVG + <span id="errorText"> -->
</div>
```

### 4.4 Franja de acento (Login card + Layout header)
```css
/* Login: borde superior de la card */
.h-1\.5.bg-gradient-to-r.from-primary-500.to-primary-700

/* Layout: franja de 3px arriba del header */
.top-accent {
    background: linear-gradient(90deg, #22c55e 0%, #15803d 100%);
    height: 3px;
}
```

### 4.5 Link de navegación (Sidebar)
```css
.nav-link {
    display: flex; align-items: center; gap: 10px;
    padding: 9px 14px; border-radius: 8px;
    font-size: 13.5px; font-weight: 500;
    color: #94a3b8; text-decoration: none;
    transition: background 0.15s, color 0.15s;
}
.nav-link:hover  { background: #2d3a4e; color: #e2e8f0; }
.nav-link.active { background: rgba(34,197,94,0.12); color: #22c55e; }
```

---

## 5. Animaciones

| Nombre       | Uso                              | Detalle                                         |
|--------------|----------------------------------|-------------------------------------------------|
| `cardEnter`  | Entrada de la card del login     | `translateY(18px) → 0` + `scale(0.98 → 1)`, 0.45s |
| `fadeIn`     | Transición entre páginas (`main`)| `translateY(8px) → 0` + opacity, 0.25s          |
| `animate-spin` (Tailwind) | Spinner del botón al validar | Ícono SVG circular giratorio |

---

## 6. Buenas Prácticas Aplicadas

- **`autocomplete`** en inputs de login: `username` y `current-password` para gestores de contraseñas.
- **`aria-live="assertive"`** en el mensaje de error para lectores de pantalla.
- **`aria-label`** en botones de ícono (toggle contraseña, hamburger, notificaciones).
- **`aria-haspopup` y `aria-expanded`** en el botón del dropdown de perfil.
- **Validación en cliente** antes del AJAX: campos vacíos se detectan sin llamar al servidor.
- **`$.trim()`** aplicado al campo usuario para evitar espacios accidentales.
- **`@@keyframes`** escapado correctamente en Razor (`.cshtml`) en lugar de `@keyframes`.
- **Clases decimales de Tailwind evitadas** (`w-4.5`): usar `style="width:18px"` en su lugar.
- **Sesión en sidebar y header**: iniciales y nombre del usuario se leen de `Session["NombreUsuario"]` y `Session["RolUsuario"]`.
- **Enlace activo del sidebar** se detecta automáticamente comparando `window.location.pathname` con el `href` de cada `.nav-link`.

---

## 7. Estructura de Archivos Relevantes

```
CapaPresentacionAdmin/
├── Views/
│   ├── Shared/
│   │   └── _Layout.cshtml       ← Layout principal con sidebar + header
│   └── Login/
│       └── Login.cshtml         ← Vista de autenticación (sin Layout)
├── Content/
│   └── tailwind-output.css      ← CSS compilado (si se usa CLI de Tailwind)
└── Scripts/
    └── ...
```

---

-----------------
Cómo funciona Cargo Extra ahora mismo
Flujo completo
1. El admin registra un cargo extra

Va a Cargo Extra → Registrar, llena:

Período (MM/YYYY)
Socio — búsqueda por nombre o código, sale una tabla y hace clic en el socio
Tipo de Cargo — un catálogo (multa, reconexión, daño, etc.), al seleccionarlo auto-completa el monto y descripción
Monto y Descripción (editables)
Se guarda con estado = PENDIENTE.

2. Validaciones del SP sp_registrar_cargo_extra

El socio debe existir
No puede haber un cargo del mismo tipo para el mismo socio y período si ya hay uno PENDIENTE (evita duplicados)
Se inserta con estado PENDIENTE
3. El cargo queda "flotando" hasta que se generan los avisos

Cuando el admin genera avisos (sp_generar_avisos_periodo), el SP busca si ese socio tiene un cargo PENDIENTE en ese período y lo suma al aviso:


total_aviso = total_consumo + cargo_extra - credito
El cargo queda absorbido — el listado lo marca como "En aviso: Sí" (campo aplicado).

4. Anulación

Solo se puede anular si:

Estado = PENDIENTE
No está aplicado a ningún aviso (si ya está en un aviso, no se puede anular)
Estado visual en el historial
Campo	Qué muestra
Estado	Badge PENDIENTE (amarillo) o ANULADO (rojo)
En Aviso	"En aviso" (verde) o "Libre" (gris)
Acción	Botón Anular solo si PENDIENTE + Libre
Limitación actual importante
Si el admin registra un cargo extra después de que ya se generaron los avisos del período, ese cargo queda en estado PENDIENTE pero no se aplica automáticamente al aviso existente — queda como "Libre" y no tiene efecto en el cobro de ese período.
------------------------
Flujo completo del sistema de Avisos
1. Prerrequisitos (lo que debe existir antes)

Socio → tiene Medidor → está en una Ruta → tiene Tarifa (por rol_socio)
Período (MM/YYYY) → debe existir o se auto-crea
2. Paso 1 — Registro de Lectura
El admin va a Lectura → Registrar Lecturas, selecciona Período y Ruta. El sistema carga todos los medidores de esa ruta con:

Lectura anterior (del período previo)
Estado: si ya fue leído en este período (verde) o no
El admin ingresa la lectura actual por medidor. El SP valida:

lectura_actual >= lectura_anterior
Que no exista ya una lectura para ese medidor/período
Calcula: consumo_m3 = lectura_actual - lectura_anterior
3. Paso 2 — Cargo Extra (opcional)
Si un socio tiene un cargo adicional (multa, reconexión, etc.), el admin va a Cargo Extra → Registrar y asigna al socio en ese período. Queda en estado PENDIENTE.

4. Paso 3 — Generar Avisos
El admin va a Aviso → Generar y selecciona Período (y opcionalmente Ruta). El SP sp_generar_avisos_periodo hace:


-- Para cada socio que tiene lectura en ese período y NO tiene aviso aún:
total_consumo = MAX(consumo_minimo_tarifa, consumo_m3) × precio_m3_tarifa
cargo_extra   = monto del cargo_extra PENDIENTE (si existe)
credito       = monto del credito_inscripcion (si existe)
total_aviso   = total_consumo + cargo_extra - credito
vencimiento   = hoy + 30 días
estado        = GENERADO
El aviso creado "absorbe" el cargo_extra (lo marca como aplicado).

5. Ciclo de vida del Aviso (estados)

GENERADO → LECTURADO → IMPRESO → PAGADO
GENERADO: Recién creado por el sistema
LECTURADO: Verificado (confirma los datos)
IMPRESO: Listo para entrega física al socio
PAGADO: Solo desde el módulo de Pagos (bloqueado en AvisoController)
El cambio de estado es solo ascendente — no se puede retroceder.

6. Filtros del historial
El listado de avisos permite filtrar por:

Período, Estado, Ruta, Búsqueda (nombre/código socio)
Paginación completa
Avisos vencidos no pagados se resaltan en rojo