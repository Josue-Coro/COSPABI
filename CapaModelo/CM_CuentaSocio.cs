using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_CuentaSocio
    {
        public int id_cuenta_socio { get; set; }
        public string usuario { get; set; }
        public string contrasena { get; set; }
        public DateTime ultimo_acceso { get; set; }
        public bool estado { get; set; }

        public int socio_id_socio { get; set; }
        public CM_Socio socio { get; set; }

        // Propiedades auxiliares para listar
        public string nombre_socio { get; set; }
    }

    public class CM_CuentaSocio_Paginado
    {
        public int TotalRegistros { get; set; }
        public List<CM_CuentaSocio> Cuentas { get; set; }
    }

    // ---- Portal del Socio (HU18/HU19) ----

    public class CM_PortalResumen
    {
        public decimal deuda_total             { get; set; }
        public int     avisos_pendientes       { get; set; }
        public int     avisos_vencidos         { get; set; }
        public int     notificaciones_sin_leer { get; set; }
    }

    public class CM_PortalAviso
    {
        public int      id_aviso          { get; set; }
        public string   nombre_periodo    { get; set; }
        public DateTime fecha_emision     { get; set; }
        public DateTime fecha_vencimiento { get; set; }
        public decimal? consumo_m3        { get; set; }
        public decimal  total_aviso       { get; set; }
        public decimal  deuda_actual      { get; set; }
        public string   estado            { get; set; }
        public bool     vencido           { get; set; }
    }

    public class CM_PortalPago
    {
        public int      id_pago        { get; set; }
        public DateTime fecha_pago     { get; set; }
        public decimal  monto_pagado   { get; set; }
        public string   nombre_metodo  { get; set; }
        public int?     aviso_id_aviso { get; set; }
        public string   concepto       { get; set; }
    }

    public class CM_PortalNotificacion
    {
        public int       id_notificacion_socio { get; set; }
        public string    titulo                { get; set; }
        public string    mensaje               { get; set; }
        public string    tipo                  { get; set; }
        public DateTime  fecha_publicacion     { get; set; }
        public bool      leido                 { get; set; }
        public DateTime? fecha_lectura         { get; set; }
    }
}
