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

        public List<CM_Usuario> Listar()
        {
            return cdUsuario.Listar();
        }

        public int Registrar(CM_Usuario obj, int idUsuarioSesion, out string Mensaje)
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

            int idGenerado = cdUsuario.Registrar(obj, idUsuarioSesion, out Mensaje);

            if (idGenerado > 0)
                cdBitacora.Registrar("Registro de nuevo usuario: " + obj.usuario, idUsuarioSesion);

            return idGenerado;
        }

        public bool Editar(CM_Usuario obj, int idUsuarioSesion, out string Mensaje)
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

            bool resultado = cdUsuario.Editar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cdBitacora.Registrar("Edición del usuario: " + obj.usuario, idUsuarioSesion);

            return resultado;
        }

        public bool Eliminar(int id, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = cdUsuario.Eliminar(id, idUsuarioSesion, out Mensaje);

            if (resultado)
                cdBitacora.Registrar("Desactivación del usuario con ID: " + id, idUsuarioSesion);

            return resultado;
        }
    }
}