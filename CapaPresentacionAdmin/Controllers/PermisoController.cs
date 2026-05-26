using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System.Collections.Generic;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class PermisoController : Controller
    {
        [ValidarPermisos(NombrePermiso = "Gestionar Permiso")]
        public ActionResult Permiso()
        {
            return View();
        }

        // Lista todos los roles (para la tabla principal)
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Permiso")]
        public JsonResult ListarRoles()
        {
            List<CM_Rol> lista = new CN_Rol().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        // Lista todos los permisos con flag asignado según el rol
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Permiso")]
        public JsonResult ListarPermisosRol(int id_rol)
        {
            List<CM_Permiso> lista = new CN_Permiso().ListarConEstado(id_rol);
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        // Guarda el sync completo de permisos de un rol
        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Permiso")]
        public JsonResult GuardarPermisosRol(int id_rol, List<int> permisos)
        {
            string mensaje = string.Empty;
            int idUsuarioSesion = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            // permisos puede llegar null si no hay ninguno marcado
            if (permisos == null)
                permisos = new List<int>();

            int resultado = new CN_Permiso()
                .GuardarPermisosRol(id_rol, permisos, idUsuarioSesion, out mensaje);

            return Json(new { resultado = resultado, mensaje = mensaje });
        }
    }
}