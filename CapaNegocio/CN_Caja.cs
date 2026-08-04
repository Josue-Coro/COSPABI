using CapaDato;
using CapaModelo;

namespace CapaNegocio
{
    public class CN_Caja
    {
        private readonly CD_Caja     cdCaja     = new CD_Caja();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public int AbrirCaja(int idUsuario, decimal montoApertura, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (montoApertura < 0)
            {
                Mensaje = "El monto de apertura no puede ser negativo.";
                return 0;
            }

            int id = cdCaja.AbrirCaja(idUsuario, montoApertura, out Mensaje);
            if (id > 0)
                cnBitacora.Registrar("Abrió la caja #" + id + " con fondo Bs. " + montoApertura, idUsuario);
            return id;
        }

        public bool CerrarCaja(int idCaja, int idUsuario, out string Mensaje)
        {
            bool ok = cdCaja.CerrarCaja(idCaja, out Mensaje);
            if (ok)
                cnBitacora.Registrar("Cerró la caja #" + idCaja, idUsuario);
            return ok;
        }

        public CM_Caja ObtenerCajaAbierta(int idUsuario)
        {
            return cdCaja.ObtenerCajaAbierta(idUsuario);
        }

        public CM_CajaArqueo ObtenerArqueo(int idCaja)
        {
            return cdCaja.ObtenerArqueo(idCaja);
        }

        public CM_CajaListado Listar(int idUsuario, int pagina, int tamanoPagina)
        {
            return cdCaja.Listar(idUsuario, pagina, tamanoPagina);
        }

        // ---- HU21: Reporte de Caja ----

        public CM_ReporteCaja ReporteCaja(System.DateTime fechaInicio, System.DateTime fechaFin,
                                          int? idCajero, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (fechaFin < fechaInicio)
            {
                Mensaje = "La fecha final no puede ser menor a la inicial.";
                return null;
            }

            var reporte = cdCaja.ReporteCaja(fechaInicio, fechaFin, idCajero);
            if (reporte == null)
            {
                Mensaje = "Error al generar el reporte de caja.";
                return null;
            }
            cnBitacora.Registrar("Genero el reporte de caja (" +
                fechaInicio.ToString("dd/MM/yyyy") + " - " + fechaFin.ToString("dd/MM/yyyy") + ")", idUsuario);
            return reporte;
        }

        public System.Collections.Generic.List<CM_CajeroFiltro> ListarCajerosConCaja(bool solicitanteEsSuperadmin)
        {
            return cdCaja.ListarCajerosConCaja(solicitanteEsSuperadmin);
        }
    }
}
