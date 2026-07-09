using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CapaDato;
using CapaModelo;


namespace CapaNegocio
{
    public class CN_Login
    {
        private CD_Login objLogin = new CD_Login();
        private CN_Recursos Recursos = new CN_Recursos();
        private CN_Bitacora bitacora = new CN_Bitacora();
        public CM_Usuario_Activo Login(string usuario, string contraseñaPlana, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(usuario) || string.IsNullOrWhiteSpace(contraseñaPlana))
            {
                Mensaje = "Ingresa usuario y contraseña.";
                return null;
            }

            string contraseñaEncriptada = Recursos.ConvertirSha256(contraseñaPlana);

            // Los intentos fallidos y bloqueos los registra el SP en la bitácora
            CM_Usuario_Activo Usuario = objLogin.Login(usuario, contraseñaEncriptada, out Mensaje);

            if (Usuario != null)
            {
                bitacora.Registrar(
                    "Inicio de sesión exitoso",
                    Usuario.id_usuario_admin
                );
            }


            return Usuario;

        }
    }
}
