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

    public class CM_CajeroFiltro
    {
        public int    id_usuario_admin { get; set; }
        public string nombre_completo  { get; set; }
    }
}
