using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CapaDato;
using CapaModelo;

namespace CapaNegocio
{
    public class CN_Rol
    {
        private CD_Rol cdrol = new CD_Rol();
        private CN_Bitacora CD_Bitacora = new CN_Bitacora();

        public List<CM_Rol> Listar(bool incluirSuperadmin = true)
        {
            return cdrol.Listar(incluirSuperadmin);
        }
        public int Registrar(CM_Rol obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;

            //validarciones
            if(string.IsNullOrWhiteSpace(obj.nombre))
            {
                Mensaje = "El nombre del rol no puede ser vacío";
                return 0;
            }
            if (!CN_Recursos.EsNombreValido(obj.nombre))
            {
                Mensaje = "El nombre del rol solo puede contener letras y espacios (sin números).";
                return 0;
            }
            if (string.IsNullOrWhiteSpace(obj.descripcion))
            {
                Mensaje = "La descripción del rol no puede ser vacía";
                return 0;
            }
            if (obj.estado == null)
            {
                Mensaje = "El estado del rol (Activo/Inactivo) es obligatorio.";
                return 0;
            }

            int idGenerado = cdrol.Registrar(obj, idUsuario, out Mensaje);

            if (idGenerado > 0) 
                CD_Bitacora.Registrar("Registro de nuevo rol: " + obj.nombre, idUsuario);

            return idGenerado;
        }
        public bool Editar(CM_Rol obj, int idUsuario, bool solicitanteEsSuperadmin, out string Mensaje)
        {
            Mensaje = string.Empty;
            //validarciones
            if (string.IsNullOrWhiteSpace(obj.nombre))
            {
                Mensaje = "El nombre del rol no puede ser vacío";
                return false;
            }
            if (!CN_Recursos.EsNombreValido(obj.nombre))
            {
                Mensaje = "El nombre del rol solo puede contener letras y espacios (sin números).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.descripcion))
            {
                Mensaje = "La descripción del rol no puede ser vacía";
                return false;
            }
            if (obj.estado == null)
            {
                Mensaje = "El estado del rol (Activo/Inactivo) es obligatorio.";
                return false;
            }
            bool resultado = cdrol.Editar(obj, idUsuario, solicitanteEsSuperadmin, out Mensaje);

            if (resultado)
                CD_Bitacora.Registrar("Edición del rol: " + obj.nombre, idUsuario);

            return resultado;
        }
        public bool Eliminar(int id, int idUsuario, bool solicitanteEsSuperadmin, out string Mensaje)
        {
            bool resultado = cdrol.Eliminar(id, idUsuario, solicitanteEsSuperadmin, out Mensaje);

            if (resultado) 
                CD_Bitacora.Registrar("Eliminación del rol con ID: " + id, idUsuario);

            return resultado;
        }
    }
}
