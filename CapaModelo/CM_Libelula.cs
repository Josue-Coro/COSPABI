using System.Collections.Generic;

namespace CapaModelo
{
    // DTOs de la pasarela Libelula (Manual de Integracion v2.145).
    // Los nombres de propiedad coinciden con el JSON de la API (snake_case)
    // para serializar/deserializar sin atributos.

    // Linea de detalle de una deuda (lineas_detalle_deuda)
    public class CM_LibelulaLineaDetalle
    {
        public string  concepto       { get; set; }
        public int     cantidad       { get; set; }
        public decimal costo_unitario { get; set; }
    }

    // Request: POST /rest/deuda/registrar
    public class CM_LibelulaDeudaRequest
    {
        public string appkey         { get; set; }
        public string email_cliente  { get; set; }
        public string identificador  { get; set; }
        public string descripcion    { get; set; }
        public string fecha_vencimiento { get; set; }
        public string callback_url   { get; set; }
        public string url_retorno    { get; set; }
        public string nombre_cliente { get; set; }
        public bool   emite_factura  { get; set; }
        public List<CM_LibelulaLineaDetalle> lineas_detalle_deuda { get; set; }
    }

    // Response: POST /rest/deuda/registrar
    public class CM_LibelulaDeudaResponse
    {
        public bool   error              { get; set; }
        public string mensaje            { get; set; }
        public string id_transaccion     { get; set; }
        public string url_pasarela_pagos { get; set; }
        public string qr_simple_url      { get; set; }
    }

    // Estado de una deuda: POST /rest/deuda/consultar_deudas/por_identificador
    public class CM_LibelulaDeudaEstado
    {
        public string  identificador      { get; set; }
        public bool    pagado             { get; set; }
        public bool    deuda_expirada     { get; set; }
        public string  forma_pago         { get; set; }
        public string  codigo_recaudacion { get; set; }
        public decimal valor_total        { get; set; }
    }

    // Un pago confirmado: POST /rest/deuda/consultar_pagos (conciliacion)
    public class CM_LibelulaPagoConciliado
    {
        public string  id_transaccion     { get; set; }
        public string  identificador      { get; set; }
        public string  forma_pago         { get; set; }
        public string  codigo_recaudacion { get; set; }
        public decimal monto_pagado       { get; set; }
    }
}
