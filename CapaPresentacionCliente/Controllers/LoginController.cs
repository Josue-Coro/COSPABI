using CapaModelo;
using CapaNegocio;
using System.Web.Mvc;
using System.Web.Security;

namespace CapaPresentacionCliente.Controllers
{
    public class LoginController : Controller
    {
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public JsonResult ValidarLogin(string usuario, string contrasena)
        {
            CM_CuentaSocio_Activo oSocio = new CN_LoginSocio().Login(usuario, contrasena);

            if (oSocio != null)
            {
                Session["Socio"]       = oSocio;
                Session["NombreSocio"] = oSocio.socio.nombre_socio;
                Session["RolSocio"]    = oSocio.socio.NombreRolSocio;

                FormsAuthentication.SetAuthCookie(oSocio.usuario, false);

                return Json(new
                {
                    resultado   = true,
                    mensaje     = "Acceso concedido.",
                    redirectUrl = Url.Action("Index", "Home")
                }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json(new
                {
                    resultado = false,
                    mensaje   = "Usuario o contraseña incorrectos, o la cuenta no está activa."
                }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult CerrarSesion()
        {
            FormsAuthentication.SignOut();
            Session["Socio"] = null;
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("Login", "Login");
        }
    }
}