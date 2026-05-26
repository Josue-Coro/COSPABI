using CapaDato;
using CapaModelo;
using System.Collections.Generic;
using System.Linq;

namespace CapaNegocio
{
    public class CN_Permiso
    {
        private readonly CD_Permiso cdPermiso = new CD_Permiso();
        private readonly CD_Rol cdRol = new CD_Rol();
        private readonly CN_Bitacora cdBitacora = new CN_Bitacora();

        // Devuelve todos los permisos con flag "asignado" según el rol
        public List<CM_Permiso> ListarConEstado(int id_rol)
        {
            List<CM_Permiso> todos = cdPermiso.ListarTodos();
            List<CM_Permiso> asignados = cdPermiso.ListarPorRol(id_rol);

            HashSet<int> idsAsignados = new HashSet<int>(
                asignados.Select(p => p.id_permiso)
            );

            foreach (var p in todos)
                p.asignado = idsAsignados.Contains(p.id_permiso);

            return todos;
        }

        public int GuardarPermisosRol(int id_rol, List<int> idsPermisos,
                                       int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (id_rol <= 0)
            {
                Mensaje = "El rol especificado no es válido.";
                return 0;
            }

            // idsPermisos puede ser lista vacía (revocar todos) — es válido
            if (idsPermisos == null)
                idsPermisos = new List<int>();

            int resultado = cdPermiso.GuardarPermisosRol(
                id_rol, idsPermisos, idUsuarioSesion, out Mensaje);

            if (resultado > 0)
                cdBitacora.Registrar(
                    "Actualización de permisos del rol ID: " + id_rol, idUsuarioSesion);

            return resultado;
        }
    }
}