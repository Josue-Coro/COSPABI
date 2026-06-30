using System;
using System.Collections.Generic;

namespace CapaModelo
{
    // Un aviso pendiente de cobro
    public class CM_AvisoPorCobrar
    {
        public int      id_aviso          { get; set; }
        public decimal  total_aviso       { get; set; }
        public decimal  deuda_actual      { get; set; }
        public string   estado            { get; set; }
        public DateTime fecha_emision     { get; set; }
        public DateTime fecha_vencimiento { get; set; }
        public string   nombre_socio      { get; set; }
        public int      codigo_fijo       { get; set; }
        public string   nombre_periodo    { get; set; }
    }

    public class CM_AvisoPorCobrarListado
    {
        public int                      TotalRegistros { get; set; }
        public List<CM_AvisoPorCobrar>  Avisos         { get; set; }
    }

    // Un pago registrado (para la sesion de caja)
    public class CM_Pago
    {
        public int      id_pago        { get; set; }
        public DateTime fecha_pago     { get; set; }
        public decimal  monto_pagado   { get; set; }
        public decimal? vuelto         { get; set; }
        public string   estado_pago    { get; set; }
        public string   nombre_metodo  { get; set; }
        public int?     aviso_id_aviso { get; set; }
        public string   nombre_socio   { get; set; }
        public int?     codigo_fijo    { get; set; }
    }

    public class CM_ReciboPagoDetalle
    {
        public string  concepto { get; set; }
        public decimal subtotal { get; set; }
    }

    public class CM_ReciboPago
    {
        public int      id_pago        { get; set; }
        public DateTime fecha_pago     { get; set; }
        public string   nombre_socio   { get; set; }
        public int?     codigo_fijo    { get; set; }
        public string   nombre_periodo { get; set; }
        public decimal? consumo        { get; set; }
        public decimal  total_consumo  { get; set; }
        public decimal  total_pagado   { get; set; }
        public decimal? vuelto         { get; set; }
        public string   cajero         { get; set; }
        public string   metodo_pago    { get; set; }
        public string   categoria      { get; set; }
        public string   nombre_ruta    { get; set; }
        public string   ubicacion      { get; set; }
        
        public List<CM_ReciboPagoDetalle> Detalles { get; set; }
    }
}
