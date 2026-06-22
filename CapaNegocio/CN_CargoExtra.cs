using CapaDato;
using CapaModelo;
using System.Collections.Generic;
using static CapaModelo.CM_CargoExtra;

namespace CapaNegocio
{
    public class CN_CargoExtra
    {
        private readonly CD_CargoExtra cdCargoExtra = new CD_CargoExtra();
        private readonly CN_Bitacora   cnBitacora   = new CN_Bitacora();

        public int Registrar(CM_CargoExtra obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (obj.periodo_id_periodo <= 0) { Mensaje = "Selecciona un periodo.";     return 0; }
            if (obj.socio_id_socio     <= 0) { Mensaje = "Selecciona un socio.";       return 0; }
            if (obj.tipo_cargo_id_tipo <= 0) { Mensaje = "Selecciona el tipo de cargo."; return 0; }
            if (obj.monto              <= 0) { Mensaje = "El monto debe ser mayor a 0."; return 0; }

            int id = cdCargoExtra.Registrar(obj, out Mensaje);
            if (id > 0)
                cnBitacora.Registrar("Registro cargo extra id=" + id + " para socio " + obj.socio_id_socio, idUsuario);
            return id;
        }

        public CM_CargoExtraListado Listar(int? idPeriodo, int? idRuta,
                                           string busqueda, int pagina, int tamanoPagina)
        {
            return cdCargoExtra.Listar(idPeriodo, idRuta, busqueda, pagina, tamanoPagina);
        }

        public List<CM_Socio> BuscarSocios(string busqueda)
        {
            return cdCargoExtra.BuscarSocios(busqueda);
        }

        public bool Anular(int idCargo, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            if (idCargo <= 0) { Mensaje = "Cargo no valido."; return false; }

            bool ok = cdCargoExtra.Anular(idCargo, out Mensaje);
            if (ok)
                cnBitacora.Registrar("Anulo cargo extra id=" + idCargo, idUsuario);
            return ok;
        }
    }
}
