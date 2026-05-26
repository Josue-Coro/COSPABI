using CapaDato;
using CapaModelo;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Medidor
    {
        private CD_Medidor cdmedidor = new CD_Medidor();
        private CN_Bitacora bitacora = new CN_Bitacora();

        public (List<CM_Medidor> lista, int totalRegistros) Listar(
            string busqueda, int pagina, int tamanoPagina)
        {
            return cdmedidor.Listar(busqueda, pagina, tamanoPagina);
        }

        public int Registrar(CM_Medidor obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.serie))
            {
                Mensaje = "La serie del medidor es obligatoria.";
                return 0;
            }
            if (obj.numero <= 0)
            {
                Mensaje = "El número del medidor debe ser mayor a cero.";
                return 0;
            }

            int idGenerado = cdmedidor.Registrar(obj, idUsuario, out Mensaje);

            if (idGenerado > 0)
                bitacora.Registrar("Registro de medidor serie: " + obj.serie, idUsuario);

            return idGenerado;
        }

        public bool Editar(CM_Medidor obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.serie))
            {
                Mensaje = "La serie del medidor es obligatoria.";
                return false;
            }
            if (obj.numero <= 0)
            {
                Mensaje = "El número del medidor debe ser mayor a cero.";
                return false;
            }

            bool resultado = cdmedidor.Editar(obj, idUsuario, out Mensaje);

            if (resultado)
                bitacora.Registrar("Edición de medidor serie: " + obj.serie, idUsuario);

            return resultado;
        }
    }
}