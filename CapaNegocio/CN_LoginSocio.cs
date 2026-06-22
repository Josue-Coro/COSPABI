using CapaDato;
using CapaModelo;

namespace CapaNegocio
{
    public class CN_LoginSocio
    {
        private readonly CD_LoginSocio objLogin   = new CD_LoginSocio();
        private readonly CN_Recursos   recursos   = new CN_Recursos();

        public CM_CuentaSocio_Activo Login(string usuario, string contrasena)
        {
            string contrasenaHasheada = recursos.ConvertirSha256(contrasena);
            return objLogin.Login(usuario, contrasenaHasheada);
        }
    }
}
