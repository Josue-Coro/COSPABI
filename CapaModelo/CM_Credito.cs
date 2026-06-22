using System.Collections.Generic;

namespace CapaModelo
{
    // Una cuota de credito de inscripcion (1 fila por cuota)
    public class CM_Credito
    {
        public int     id_credito         { get; set; }
        public decimal monto_pago         { get; set; }
        public string  estado             { get; set; }
        public int     num_cuota          { get; set; }
        public int     socio_id_socio     { get; set; }
        public int     periodo_id_periodo { get; set; }
        public int?    aviso_id_aviso     { get; set; }
        public bool    en_aviso           { get; set; }

        // Campos de display (JOINs en SPs)
        public string  nombre_socio   { get; set; }
        public int     codigo_fijo    { get; set; }
        public string  nombre_periodo { get; set; }
    }

    // Resumen por socio para la lista de seguimiento
    public class CM_CreditoResumen
    {
        public int     id_socio          { get; set; }
        public int     codigo_fijo       { get; set; }
        public string  nombre_socio      { get; set; }
        public decimal total_inscripcion { get; set; }
        public decimal pagado            { get; set; }
        public decimal saldo             { get; set; }
        public int     cuotas_pendientes { get; set; }
        public string  proximo_periodo   { get; set; }
        public decimal proximo_monto     { get; set; }
    }

    public class CM_CreditoListado
    {
        public int                     TotalRegistros { get; set; }
        public List<CM_CreditoResumen> Creditos       { get; set; }
    }
}
