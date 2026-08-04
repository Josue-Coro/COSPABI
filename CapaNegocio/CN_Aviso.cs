using CapaDato;
using CapaModelo;
using System.Collections.Generic;
using static CapaModelo.CM_Aviso;

namespace CapaNegocio
{
    public class CN_Aviso
    {
        private readonly CD_Aviso    cdAviso    = new CD_Aviso();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public int GenerarAvisos(int idPeriodo, int? idRuta, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (idPeriodo <= 0)
            {
                Mensaje = "Debe seleccionar un periodo.";
                return -1;
            }
            int generados = cdAviso.GenerarAvisos(idPeriodo, idRuta, out Mensaje);
            if (generados > 0)
                cnBitacora.Registrar("Genero " + generados + " aviso(s) para el periodo id=" + idPeriodo, idUsuario);
            return generados;
        }

        public CM_AvisoListado Listar(int? idPeriodo, int? idEstado, int? idRuta,
                                      string busqueda, int pagina, int tamanoPagina)
        {
            return cdAviso.Listar(idPeriodo, idEstado, idRuta, busqueda, pagina, tamanoPagina);
        }

        public bool CambiarEstado(int idAviso, int idEstado, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (idAviso  <= 0) { Mensaje = "Aviso no valido.";  return false; }
            if (idEstado <= 0) { Mensaje = "Estado no valido."; return false; }
            bool ok = cdAviso.CambiarEstado(idAviso, idEstado, out Mensaje);
            if (ok)
                cnBitacora.Registrar("Cambio estado del aviso " + idAviso + " a id_estado=" + idEstado, idUsuario);
            return ok;
        }

        // Marcado automatico al imprimir. No devuelve error a la vista: si el aviso
        // ya estaba IMPRESO/PAGADO/ANULADO simplemente no cambia nada.
        public bool MarcarImpreso(int idAviso, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (idAviso <= 0) { Mensaje = "Aviso no valido."; return false; }
            bool ok = cdAviso.MarcarImpreso(idAviso, out Mensaje);
            if (ok)
                cnBitacora.Registrar("Imprimió el aviso " + idAviso + " (estado -> IMPRESO)", idUsuario);
            return ok;
        }

        public bool ExisteAvisoActivo(int idSocio, int idPeriodo)
        {
            return cdAviso.ExisteAvisoActivo(idSocio, idPeriodo);
        }

        public bool AnularAviso(int idAviso, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (idAviso <= 0) { Mensaje = "Aviso no válido."; return false; }
            bool ok = cdAviso.AnularAviso(idAviso, out Mensaje);
            if (ok)
                cnBitacora.Registrar("Anuló el aviso id=" + idAviso, idUsuario);
            return ok;
        }

        public CM_AvisoDetalle ObtenerDetalle(int idAviso)
        {
            return cdAviso.ObtenerDetalle(idAviso);
        }

        public CM_AvisoImpresion ObtenerParaImpresion(int idAviso)
        {
            return cdAviso.ObtenerParaImpresion(idAviso);
        }

        public CM_Aviso ObtenerUltimoAviso(int idSocio)
        {
            return cdAviso.ObtenerUltimoAviso(idSocio);
        }

        public List<CM_Estado> ListarEstados()
        {
            return cdAviso.ListarEstados();
        }

        // ---- HU22: Reporte de Morosidad ----

        public CM_ReporteMorosidad ReporteMorosidad(System.DateTime? fechaInicio, System.DateTime? fechaFin,
                                                    int? idRuta, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (fechaInicio.HasValue && fechaFin.HasValue && fechaFin < fechaInicio)
            {
                Mensaje = "La fecha final no puede ser menor a la inicial.";
                return null;
            }

            var reporte = cdAviso.ReporteMorosidad(fechaInicio, fechaFin, idRuta);
            if (reporte == null)
            {
                Mensaje = "Error al generar el reporte de morosidad.";
                return null;
            }
            cnBitacora.Registrar("Genero el reporte de morosidad", idUsuario);
            return reporte;
        }
    }
}
