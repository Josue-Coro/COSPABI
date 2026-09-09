using CapaModelo;
using CapaNegocio;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    /// <summary>
    /// "Mi perfil": el usuario autenticado ve y edita SUS propios datos.
    /// No lleva [ValidarPermisos] porque no hay permiso de negocio asociado:
    /// basta con tener sesión. El id siempre sale de Session["Usuario"], nunca
    /// del navegador, así que nadie puede tocar el perfil de otro usuario.
    /// </summary>
    [Authorize]
    public class PerfilController : Controller
    {
        private CM_Usuario_Activo UsuarioSesion()
        {
            return Session["Usuario"] as CM_Usuario_Activo;
        }

        public ActionResult Perfil()
        {
            if (UsuarioSesion() == null)
                return RedirectToAction("Login", "Login");
            return View();
        }

        [HttpGet]
        public JsonResult Obtener()
        {
            var u = UsuarioSesion();
            if (u == null)
                return Json(new { exito = false, mensaje = "Sesión expirada." }, JsonRequestBehavior.AllowGet);

            var cn = new CN_Usuario();
            CM_PerfilAdmin perfil = cn.ObtenerPerfil(u.id_usuario_admin);
            if (perfil == null)
                return Json(new { exito = false, mensaje = "No se pudo cargar el perfil." }, JsonRequestBehavior.AllowGet);

            var actividad = cn.ActividadReciente(u.id_usuario_admin, 10);
            return Json(new { exito = true, perfil = perfil, actividad = actividad }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Editar(string nombre, string apellido)
        {
            var u = UsuarioSesion();
            if (u == null)
                return Json(new { exito = false, mensaje = "Sesión expirada." });

            string mensaje;
            bool exito = new CN_Usuario().EditarPerfil(u.id_usuario_admin, nombre, apellido, out mensaje);

            if (exito)
            {
                // El header y el sidebar leen estos valores: se refrescan sin re-login.
                u.nombre = nombre.Trim();
                u.apellido = apellido.Trim();
                Session["Usuario"] = u;
                Session["NombreUsuario"] = u.nombre + " " + u.apellido;
            }

            return Json(new { exito = exito, mensaje = mensaje });
        }

        [HttpPost]
        public JsonResult CambiarContrasena(string actual, string nueva, string confirmacion)
        {
            var u = UsuarioSesion();
            if (u == null)
                return Json(new { exito = false, mensaje = "Sesión expirada." });

            string mensaje;
            bool exito = new CN_Usuario().CambiarContrasena(u.id_usuario_admin, actual, nueva, confirmacion, out mensaje);
            return Json(new { exito = exito, mensaje = mensaje });
        }
    }
}
