using CapaDato;
using CapaModelo;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Usuario
    {
        private readonly CD_Usuario cdUsuario = new CD_Usuario();
        private readonly CN_Bitacora cdBitacora = new CN_Bitacora();
        private CN_Recursos Recursos = new CN_Recursos();

        public List<CM_Usuario> Listar(bool incluirSuperadmin)
        {
            return cdUsuario.Listar(incluirSuperadmin);
        }

        public int Registrar(CM_Usuario obj, int idUsuarioSesion, bool solicitanteEsSuperadmin, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.nombre))
            {
                Mensaje = "El nombre del usuario es obligatorio.";
                return 0;
            }
            if (!CN_Recursos.EsNombreValido(obj.nombre))
            {
                Mensaje = "El nombre solo puede contener letras y espacios (sin números).";
                return 0;
            }
            if (string.IsNullOrWhiteSpace(obj.apellido))
            {
                Mensaje = "El apellido del usuario es obligatorio.";
                return 0;
            }
            if (!CN_Recursos.EsNombreValido(obj.apellido))
            {
                Mensaje = "El apellido solo puede contener letras y espacios (sin números).";
                return 0;
            }
            if (string.IsNullOrWhiteSpace(obj.usuario))
            {
                Mensaje = "El nombre de usuario es obligatorio.";
                return 0;
            }
            if (!CN_Recursos.EsUsuarioValido(obj.usuario))
            {
                Mensaje = "El nombre de usuario debe tener de 3 a 30 caracteres, sin espacios (solo letras, números, punto, guion y guion bajo).";
                return 0;
            }
            if (string.IsNullOrWhiteSpace(obj.contraseña))
            {
                Mensaje = "La contraseña es obligatoria.";
                return 0;
            }
            if (obj.contraseña.Length < 6)
            {
                Mensaje = "La contraseña debe tener al menos 6 caracteres.";
                return 0;
            }
            if (obj.rol_id_rol <= 0)
            {
                Mensaje = "Debes seleccionar un rol.";
                return 0;
            }
            string contraseñaEncriptada = Recursos.ConvertirSha256(obj.contraseña);
                        obj.contraseña = contraseñaEncriptada;

            int idGenerado = cdUsuario.Registrar(obj, idUsuarioSesion, solicitanteEsSuperadmin, out Mensaje);

            if (idGenerado > 0)
                cdBitacora.Registrar("Registro de nuevo usuario: " + obj.usuario, idUsuarioSesion);

            return idGenerado;
        }

        public bool Editar(CM_Usuario obj, int idUsuarioSesion, bool solicitanteEsSuperadmin, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.nombre))
            {
                Mensaje = "El nombre del usuario es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsNombreValido(obj.nombre))
            {
                Mensaje = "El nombre solo puede contener letras y espacios (sin números).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.apellido))
            {
                Mensaje = "El apellido del usuario es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsNombreValido(obj.apellido))
            {
                Mensaje = "El apellido solo puede contener letras y espacios (sin números).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.usuario))
            {
                Mensaje = "El nombre de usuario es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsUsuarioValido(obj.usuario))
            {
                Mensaje = "El nombre de usuario debe tener de 3 a 30 caracteres, sin espacios (solo letras, números, punto, guion y guion bajo).";
                return false;
            }
            // Contraseña es opcional al editar — solo valida longitud si viene con valor
            if (!string.IsNullOrWhiteSpace(obj.contraseña) && obj.contraseña.Length < 6)
            {
                Mensaje = "La contraseña debe tener al menos 6 caracteres.";
                return false;
            }
            if (obj.rol_id_rol <= 0)
            {
                Mensaje = "Debes seleccionar un rol.";
                return false;
            }
            string contraseñaEncriptada = string.IsNullOrWhiteSpace(obj.contraseña) ? null : Recursos.ConvertirSha256(obj.contraseña);
            if (!string.IsNullOrWhiteSpace(contraseñaEncriptada))
                obj.contraseña = contraseñaEncriptada;

            bool resultado = cdUsuario.Editar(obj, idUsuarioSesion, solicitanteEsSuperadmin, out Mensaje);

            if (resultado)
                cdBitacora.Registrar("Edición del usuario: " + obj.usuario, idUsuarioSesion);

            return resultado;
        }

        public bool Eliminar(int id, int idUsuarioSesion, bool solicitanteEsSuperadmin, out string Mensaje)
        {
            bool resultado = cdUsuario.Eliminar(id, idUsuarioSesion, solicitanteEsSuperadmin, out Mensaje);

            if (resultado)
                cdBitacora.Registrar("Desactivación del usuario con ID: " + id, idUsuarioSesion);

            return resultado;
        }

        // ================= Mi perfil (usuario de la sesión) =================

        public CM_PerfilAdmin ObtenerPerfil(int idUsuarioSesion)
        {
            return cdUsuario.ObtenerPerfil(idUsuarioSesion);
        }

        public List<CM_Bitacora> ActividadReciente(int idUsuarioSesion, int top = 10)
        {
            return cdUsuario.ActividadReciente(idUsuarioSesion, top);
        }

        public bool EditarPerfil(int idUsuarioSesion, string nombre, string apellido, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(nombre))
            {
                Mensaje = "El nombre es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsNombreValido(nombre))
            {
                Mensaje = "El nombre solo puede contener letras y espacios (sin números).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(apellido))
            {
                Mensaje = "El apellido es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsNombreValido(apellido))
            {
                Mensaje = "El apellido solo puede contener letras y espacios (sin números).";
                return false;
            }

            bool resultado = cdUsuario.EditarPerfil(idUsuarioSesion, nombre.Trim(), apellido.Trim(), out Mensaje);

            if (resultado)
                cdBitacora.Registrar("Actualización de datos del propio perfil", idUsuarioSesion);

            return resultado;
        }

        public bool CambiarContrasena(int idUsuarioSesion, string actual, string nueva, string confirmacion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(actual))
            {
                Mensaje = "Debes ingresar tu contraseña actual.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(nueva) || nueva.Length < 6)
            {
                Mensaje = "La nueva contraseña debe tener al menos 6 caracteres.";
                return false;
            }
            if (nueva != confirmacion)
            {
                Mensaje = "La confirmación no coincide con la nueva contraseña.";
                return false;
            }
            if (nueva == actual)
            {
                Mensaje = "La nueva contraseña debe ser distinta a la actual.";
                return false;
            }

            bool resultado = cdUsuario.CambiarContrasena(
                idUsuarioSesion,
                Recursos.ConvertirSha256(actual),
                Recursos.ConvertirSha256(nueva),
                out Mensaje);

            if (resultado)
                cdBitacora.Registrar("Cambio de contraseña del propio perfil", idUsuarioSesion);

            return resultado;
        }
    }
}
