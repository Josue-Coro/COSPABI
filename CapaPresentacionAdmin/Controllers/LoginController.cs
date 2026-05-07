using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using CapaModelo;
using CapaDato;

namespace CapaPresentacionAdmin.Controllers
{
    public class LoginController : Controller
    {
        // GET: Login
        public ActionResult Login()
        {
            return View();
        }
        [HttpPost]
        public JsonResult ValidarLogin(string usuario, string contrasena)
        {
            CM_Usuario_Activo oUsuario = new CM_Usuario_Activo();
            
            contrasena = CD_Recursos.ConvertirSha256(contrasena);

            string mensaje = string.Empty;

            oUsuario = new CD_Login().Login(usuario, contrasena);

            if (oUsuario != null)
            {
                Session["Usuario"] = oUsuario;
                Session["NombreUsuario"] = oUsuario.nombre + " " + oUsuario.apellido;
                Session["RolUsuario"] = oUsuario.nombre_rol;

                FormsAuthentication.SetAuthCookie(oUsuario.usuario, false);

                return Json(new
                {
                    resultado = true,
                    mensaje = "Acceso concedido.",
                    redirectUrl = Url.Action("Index", "Home")
                }, JsonRequestBehavior.AllowGet);

            }
            else
            {
                mensaje = "Correo o contraseña incorrectos, o el usuario/rol no está activo.";

                return Json(new
                {
                    resultado = false,
                    mensaje = mensaje
                }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult CerrarSesion()
        {
            FormsAuthentication.SignOut();
            Session["Usuario"] = null;
            Session.Clear();
            Session.Abandon();
            return RedirectToAction("Login", "Login");
        }


        public ActionResult AccesoDenegado()
        {
            return View();
        }
    }
}