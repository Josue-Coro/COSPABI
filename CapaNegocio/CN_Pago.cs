using CapaDato;
using CapaModelo;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Pago
    {
        private readonly CD_Pago     cdPago     = new CD_Pago();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public CM_AvisoPorCobrarListado ListarAvisosPorCobrar(string busqueda, int pagina, int tamanoPagina)
        {
            return cdPago.ListarAvisosPorCobrar(busqueda, pagina, tamanoPagina);
        }

        public bool RegistrarPago(int idAviso, int idCaja, int idMetodoPago, decimal? montoRecibido,
                                  int idUsuario, string cajero, out int idPago, out string Mensaje)
        {
            Mensaje = string.Empty;
            idPago = 0;

            if (idAviso <= 0)      { Mensaje = "Debe seleccionar un aviso.";        return false; }
            if (idMetodoPago <= 0) { Mensaje = "Debe seleccionar un método de pago."; return false; }

            bool ok = cdPago.RegistrarPago(idAviso, idCaja, idMetodoPago, montoRecibido, cajero, out idPago, out Mensaje);
            if (ok)
                cnBitacora.Registrar("Cobró el aviso #" + idAviso + " (caja #" + idCaja + ")", idUsuario);
            return ok;
        }

        public List<CM_Pago> ListarPagosCaja(int idCaja)
        {
            return cdPago.ListarPagosCaja(idCaja);
        }

        public CM_ReciboPago ObtenerReciboPago(int idPago)
        {
            return cdPago.ObtenerReciboPago(idPago);
        }

        public CM_ReciboPago ObtenerReciboInscripcion(int idPago)
        {
            return cdPago.ObtenerReciboInscripcion(idPago);
        }
    }
}
