using CapaDato;
using CapaModelo;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Ruta
    {
        private CD_Ruta cdruta = new CD_Ruta();
        private CN_Bitacora bitacora = new CN_Bitacora();

        public List<CM_Ruta> Listar()
        {
            return cdruta.Listar();
        }

        public int Registrar(CM_Ruta obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.ruta <= 0)
            {
                Mensaje = "El número de ruta debe ser mayor a cero.";
                return 0;
            }

            int idGenerado = cdruta.Registrar(obj, idUsuario, out Mensaje);

            if (idGenerado > 0)
                bitacora.Registrar("Registro de nueva ruta: " + obj.ruta, idUsuario);

            return idGenerado;
        }

        public bool Editar(CM_Ruta obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.ruta <= 0)
            {
                Mensaje = "El número de ruta debe ser mayor a cero.";
                return false;
            }

            bool resultado = cdruta.Editar(obj, idUsuario, out Mensaje);

            if (resultado)
                bitacora.Registrar("Edición de ruta: " + obj.ruta, idUsuario);

            return resultado;
        }
    }
}