using System;
using System.Collections.Generic;

namespace CapaModelo
{
    public class CM_Caja
    {
        public int       id_caja        { get; set; }
        public DateTime  fecha          { get; set; }
        public DateTime  hora_apertura  { get; set; }
        public DateTime? hora_cierre    { get; set; }
        public decimal   monto_apertura { get; set; }
        public decimal   monto_cobrado  { get; set; }
        public bool      estado         { get; set; }   // true = ABIERTA, false = CERRADA
        public int       usuario_admin_id_usuario_admin { get; set; }

        // Calculados en vivo (sp_caja_abierta)
        public decimal total_cobrado { get; set; }
        public int     num_pagos     { get; set; }
    }

    // Una fila del arqueo: total por metodo de pago
    public class CM_ArqueoMetodo
    {
        public string  metodo   { get; set; }
        public decimal total    { get; set; }
        public int     cantidad { get; set; }
    }

    // Arqueo completo de una caja (cabecera + detalle por metodo)
    public class CM_CajaArqueo
    {
        public int       id_caja          { get; set; }
        public DateTime  fecha            { get; set; }
        public DateTime  hora_apertura    { get; set; }
        public DateTime? hora_cierre      { get; set; }
        public bool      estado           { get; set; }
        public decimal   monto_apertura   { get; set; }
        public decimal   total_cobrado    { get; set; }
        public decimal   efectivo_cobrado { get; set; }
        public decimal   efectivo_esperado { get { return monto_apertura + efectivo_cobrado; } }
        public List<CM_ArqueoMetodo> porMetodo { get; set; }
    }

    public class CM_CajaListado
    {
        public int           TotalRegistros { get; set; }
        public List<CM_Caja> Cajas          { get; set; }
    }

    // ---- HU21: Reporte de Caja ----

    public class CM_ReporteCajaFila
    {
        public int      id_pago        { get; set; }
        public DateTime fecha_pago     { get; set; }
        public int?     aviso_id_aviso { get; set; }
        public string   tipo_cobro     { get; set; }
        public string   nombre_socio   { get; set; }
        public int?     codigo_fijo    { get; set; }
        public string   nombre_metodo  { get; set; }
        public string   cajero         { get; set; }
        public decimal  monto_pagado   { get; set; }
    }

    public class CM_ReporteCajaMetodo
    {
        public string  nombre_metodo { get; set; }
        public int     cantidad      { get; set; }
        public decimal total         { get; set; }
    }

    public class CM_ReporteCaja
    {
        public List<CM_ReporteCajaFila>   Pagos          { get; set; }
        public List<CM_ReporteCajaMetodo> TotalesMetodo  { get; set; }
        public int                        CantidadPagos  { get; set; }
        public decimal                    TotalRecaudado { get; set; }
    }

    // Reporte de pagos del sistema: cobros aprobados sin caja (portal del socio)
    public class CM_ReportePagoSistemaFila
    {
        public int      id_pago            { get; set; }
        public DateTime fecha_pago         { get; set; }
        public int?     aviso_id_aviso     { get; set; }
        public string   tipo_cobro         { get; set; }
        public string   nombre_socio       { get; set; }
        public int?     codigo_fijo        { get; set; }
        public string   nombre_periodo     { get; set; }
        public string   nombre_metodo      { get; set; }
        public string   id_transaccion     { get; set; }
        public string   codigo_recaudacion { get; set; }
        public string   forma_pago         { get; set; }
        public decimal  monto_pagado       { get; set; }
    }

    public class CM_ReportePagosSistema
    {
        public List<CM_ReportePagoSistemaFila> Pagos          { get; set; }
        public List<CM_ReporteCajaMetodo>      TotalesMetodo  { get; set; }
        public int                             CantidadPagos  { get; set; }
        public decimal                         TotalRecaudado { get; set; }
        // QR generados en el periodo que nadie llego a pagar (PENDIENTE/EXPIRADO)
        public int                             QrSinCobrar    { get; set; }
    }

    public class CM_CajeroFiltro
    {
        public int    id_usuario_admin { get; set; }
        public string nombre_completo  { get; set; }
    }

    // ---- Reporte "Facturas cobradas" (sp_reporte_cobros) ----
    public class CM_ReporteCobroFila
    {
        public int      id_pago        { get; set; }
        public DateTime fecha_pago     { get; set; }
        public int?     aviso_id_aviso { get; set; }
        public string   tipo_cobro     { get; set; }
        public int?     codigo_fijo    { get; set; }
        public string   nombre_socio   { get; set; }
        public string   nombre_periodo { get; set; }
        public string   nombre_metodo  { get; set; }
        public string   cajero         { get; set; }
        public int?     caja_id_caja   { get; set; }
        public decimal  monto_pagado   { get; set; }
    }

    public class CM_ReporteCobroSubtotal
    {
        public string  tipo_cobro { get; set; }
        public int     cantidad   { get; set; }
        public decimal total      { get; set; }
    }

    public class CM_ReporteCobros
    {
        public List<CM_ReporteCobroFila>     Cobros         { get; set; }
        public List<CM_ReporteCobroSubtotal> Subtotales     { get; set; }
        public int                           CantidadPagos  { get; set; }
        public decimal                       TotalRecaudado { get; set; }
    }

    // ---- "Arqueo general" por concepto (sp_reporte_arqueo_general) ----
    public class CM_ArqueoConcepto
    {
        public int     nro      { get; set; }
        public string  servicio { get; set; }
        public int     cantidad { get; set; }
        public decimal cobrado  { get; set; }
    }

    public class CM_ArqueoGeneral
    {
        public List<CM_ArqueoConcepto>    Conceptos          { get; set; }
        public List<CM_ReporteCajaMetodo> TotalesMetodo      { get; set; }
        public int                        CantidadPagos      { get; set; }
        public int                        CantidadConceptos  { get; set; }
        public decimal                    TotalRecaudado     { get; set; }
    }

    // ---- HU24: Reporte de pagos de inscripcion (sp_reporte_pagos_inscripcion) ----
    public class CM_ReporteInscripcionCuota
    {
        public int      codigo_fijo     { get; set; }
        public string   nombre_socio    { get; set; }
        public decimal  total_credito   { get; set; }
        public int      num_cuota       { get; set; }
        public int      total_cuotas    { get; set; }
        public decimal  monto_cuota     { get; set; }
        public decimal  saldo_pendiente { get; set; }
        public DateTime fecha_pago      { get; set; }
        public int      id_pago         { get; set; }
        public int?     aviso_id_aviso  { get; set; }
        public string   nombre_periodo  { get; set; }
        public string   nombre_metodo   { get; set; }
        public string   estado_credito  { get; set; }   // CANCELADO = credito saldado | PENDIENTE
    }

    public class CM_ReporteInscripcionPendiente
    {
        public int     codigo_fijo       { get; set; }
        public string  nombre_socio      { get; set; }
        public decimal total_credito     { get; set; }
        public decimal pagado            { get; set; }
        public decimal saldo             { get; set; }
        public int     cuotas_pendientes { get; set; }
        public int     total_cuotas      { get; set; }
        public string  proximo_periodo   { get; set; }
        public decimal proximo_monto     { get; set; }
    }

    public class CM_ReporteInscripcion
    {
        public List<CM_ReporteInscripcionCuota>     Cuotas                { get; set; }
        public List<CM_ReporteInscripcionPendiente> Pendientes            { get; set; }
        public int                                  CantidadCuotas        { get; set; }
        public decimal                              MontoCobrado          { get; set; }
        public int                                  SociosCobrados        { get; set; }
        public int                                  SociosCancelaronTotal { get; set; }
        public int                                  SociosConPendientes   { get; set; }
        public decimal                              SaldoTotalPendiente   { get; set; }
    }
}
