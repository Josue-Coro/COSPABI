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
        public CM_Usuario_Activo Login(string usuario, string contraseñaPlana)
        {
            string contraseñaEncriptada = Recursos.ConvertirSha256(contraseñaPlana);

            CM_Usuario_Activo Usuario = objLogin.Login(usuario, contraseñaEncriptada);

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
