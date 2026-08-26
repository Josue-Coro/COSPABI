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

        // esSuperadmin viaja desde el controlador (rol de la sesion): un cajero
        // solo cierra su propia caja, el SUPERADMIN puede cerrar cualquiera.
        public bool CerrarCaja(int idCaja, int idUsuario, bool esSuperadmin, out string Mensaje)
        {
            bool ok = cdCaja.CerrarCaja(idCaja, idUsuario, esSuperadmin, out Mensaje);
            if (ok)
                cnBitacora.Registrar("Cerró la caja #" + idCaja, idUsuario);
            return ok;
        }

        public CM_Caja ObtenerCajaAbierta(int idUsuario)
        {
            return cdCaja.ObtenerCajaAbierta(idUsuario);
        }

        // El arqueo expone montos y detalle de pagos: solo el dueno de la caja
        // (o el SUPERADMIN) puede pedirlo. Devuelve null para una caja ajena.
        public CM_CajaArqueo ObtenerArqueo(int idCaja, int idUsuario, bool esSuperadmin)
        {
            return cdCaja.ObtenerArqueo(idCaja, idUsuario, esSuperadmin);
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

        // ---- Reporte de pagos del sistema (portal del socio, sin caja) ----

        public CM_ReportePagosSistema ReportePagosSistema(System.DateTime fechaInicio,
                                                          System.DateTime fechaFin,
                                                          int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (fechaFin < fechaInicio)
            {
                Mensaje = "La fecha final no puede ser menor a la inicial.";
                return null;
            }

            var reporte = cdCaja.ReportePagosSistema(fechaInicio, fechaFin);
            if (reporte == null)
            {
                Mensaje = "Error al generar el reporte de pagos del sistema.";
                return null;
            }
            cnBitacora.Registrar("Genero el reporte de pagos del sistema (" +
                fechaInicio.ToString("dd/MM/yyyy") + " - " + fechaFin.ToString("dd/MM/yyyy") + ")", idUsuario);
            return reporte;
        }

        public System.Collections.Generic.List<CM_CajeroFiltro> ListarCajerosConCaja(bool solicitanteEsSuperadmin)
        {
            return cdCaja.ListarCajerosConCaja(solicitanteEsSuperadmin);
        }
    }
}
