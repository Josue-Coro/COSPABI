using CapaDato;
using CapaModelo;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_TipoCargo
    {
        private CD_TipoCargo cdtipo = new CD_TipoCargo();
        private CN_Bitacora bitacora = new CN_Bitacora();

        public List<CM_TipoCargo> Listar()
        {
            return cdtipo.Listar();
        }

        public int Registrar(CM_TipoCargo obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.nombre))
            {
                Mensaje = "El nombre del tipo de cargo es obligatorio.";
                return 0;
            }
            if (obj.monto <= 0)
            {
                Mensaje = "El monto debe ser mayor a cero.";
                return 0;
            }

            int idGenerado = cdtipo.Registrar(obj, idUsuario, out Mensaje);

            if (idGenerado > 0)
                bitacora.Registrar("Registro de tipo de cargo: " + obj.nombre, idUsuario);

            return idGenerado;
        }

        public bool Editar(CM_TipoCargo obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.nombre))
            {
                Mensaje = "El nombre del tipo de cargo es obligatorio.";
                return false;
            }
            if (obj.monto <= 0)
            {
                Mensaje = "El monto debe ser mayor a cero.";
                return false;
            }

            bool resultado = cdtipo.Editar(obj, idUsuario, out Mensaje);

            if (resultado)
                bitacora.Registrar("Edición de tipo de cargo: " + obj.nombre, idUsuario);

            return resultado;
        }

        public bool Eliminar(int id, int idUsuario, out string Mensaje)
        {
            bool resultado = cdtipo.Eliminar(id, idUsuario, out Mensaje);

            if (resultado)
                bitacora.Registrar("Desactivación de tipo de cargo ID: " + id, idUsuario);

            return resultado;
        }
    }
}