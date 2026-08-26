using CapaDato;
using CapaModelo;

namespace CapaNegocio
{
    public class CN_LoginSocio
    {
        private readonly CD_LoginSocio objLogin   = new CD_LoginSocio();
        private readonly CN_Recursos   recursos   = new CN_Recursos();

        public CM_CuentaSocio_Activo Login(string usuario, string contrasena, out string mensaje)
        {
            mensaje = string.Empty;

            // Corta antes de tocar la BD: evita gastar consultas con envios vacios.
            if (string.IsNullOrWhiteSpace(usuario) || string.IsNullOrWhiteSpace(contrasena))
            {
                mensaje = "Usuario o contraseña incorrectos, o la cuenta no está activa.";
                return null;
            }

            string contrasenaHasheada = recursos.ConvertirSha256(contrasena);
            return objLogin.Login(usuario, contrasenaHasheada, out mensaje);
        }
    }
}
