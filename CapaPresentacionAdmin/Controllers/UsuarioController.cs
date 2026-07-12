using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System.Collections.Generic;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class UsuarioController : Controller
    {
        // El rol SUPERADMIN (ingeniero de TI) solo es visible/gestionable por otro SUPERADMIN.
        private bool EsSuperadmin()
        {
            var u = Session["Usuario"] as CM_Usuario_Activo;
            return u != null && (u.nombre_rol ?? "").ToUpper() == "SUPERADMIN";
        }

        [ValidarPermisos(NombrePermiso = "Gestionar Usuarios")]
        public ActionResult Usuario()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Usuarios")]
        public JsonResult ListarUsuarios()
        {
            // Si el solicitante no es SUPERADMIN, no se listan los usuarios SUPERADMIN
            List<CM_Usuario> lista = new CN_Usuario().Listar(EsSuperadmin());
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Usuarios")]
        public JsonResult ListarRoles()
        {
            List<CM_Rol> lista = new CN_Rol().Listar();
            // Solo roles activos para los selects
            var activos = lista.FindAll(r => r.estado == true);

            // Un no-superadmin no puede asignar el rol SUPERADMIN: se oculta del selector
            if (!EsSuperadmin())
                activos = activos.FindAll(r => (r.nombre ?? "").ToUpper() != "SUPERADMIN");

            return Json(new { data = activos }, JsonRequestBehavior.AllowGet);
        }

        [ValidarPermisos(NombrePermiso = "Crear Usuario")]
        public ActionResult CrearUsuario()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Crear Usuario")]
        public JsonResult RegistrarUsuario(CM_Usuario obj)
        {
            string mensaje = string.Empty;
            int idUsuarioSesion = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            object resultado = new CN_Usuario().Registrar(obj, idUsuarioSesion, EsSuperadmin(), out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [ValidarPermisos(NombrePermiso = "Editar Usuario")]
        public ActionResult EditarUsuario()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Editar Usuario")]
        public JsonResult EditarUsuario(CM_Usuario obj)
        {
            string mensaje = string.Empty;
            int idUsuarioSesion = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            object resultado = new CN_Usuario().Editar(obj, idUsuarioSesion, EsSuperadmin(), out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [ValidarPermisos(NombrePermiso = "Desactivar Usuario")]
        public ActionResult EliminarUsuario()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Desactivar Usuario")]
        public JsonResult EliminarUsuario(int id)
        {
            string mensaje = string.Empty;
            int idUsuarioSesion = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            bool resultado = new CN_Usuario().Eliminar(id, idUsuarioSesion, EsSuperadmin(), out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}