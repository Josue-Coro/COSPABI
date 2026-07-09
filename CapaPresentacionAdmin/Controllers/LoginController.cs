using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using CapaModelo;
using CapaDato;
using CapaNegocio;

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
            CM_Usuario_Activo oUsuario = new CN_Login().Login(usuario, contrasena, out string mensaje);

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
                // El mensaje viene del SP: genérico si falló la credencial,
                // explícito si la cuenta está bloqueada por intentos fallidos.
                if (string.IsNullOrEmpty(mensaje))
                    mensaje = "Usuario o contraseña incorrectos, o el usuario/rol no está activo.";

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