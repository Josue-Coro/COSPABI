using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Services.Description;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class RolController : Controller
    {
        // El rol SUPERADMIN solo es visible/gestionable por otro SUPERADMIN.
        private bool EsSuperadmin()
        {
            var u = Session["Usuario"] as CM_Usuario_Activo;
            return u != null && (u.nombre_rol ?? "").ToUpper() == "SUPERADMIN";
        }

        // GET: Rol
        [ValidarPermisos(NombrePermiso = "Gestionar Rol")]
        public ActionResult Rol()
        {
            return View();
        }
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Rol")]
        public JsonResult ListarRoles()
        {
            // Si el solicitante no es SUPERADMIN, no se lista el rol SUPERADMIN
            List<CM_Rol> lista = new CN_Rol().Listar(EsSuperadmin());
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }


        [ValidarPermisos(NombrePermiso = "Crear Rol")]
        public ActionResult CrearRol()
        {
            return View();
        }
        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Crear Rol")]
        public JsonResult RegistrarRol(CM_Rol obj)
        {
            object resultado;
            string mensaje = string.Empty;
           
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            resultado = new CN_Rol().Registrar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);

        }



        [ValidarPermisos(NombrePermiso = "Editar Rol")]
        public ActionResult EditarRol()
        {
            return View();
        }
        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Editar Rol")]
        public JsonResult EditarRol(CM_Rol obj)
        {
            object resultado;
            string mensaje = string.Empty;

            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            resultado = new CN_Rol().Editar(obj, idUsuario, EsSuperadmin(), out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }


        [ValidarPermisos(NombrePermiso = "Desactivar Rol")]
        public ActionResult EliminarRol()
        {
            return View();
        }
        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Desactivar Rol")]
        public JsonResult EliminarRol(int id)
        {
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            bool resultado = new CN_Rol().Eliminar(id, idUsuario, EsSuperadmin(), out string mensaje);

            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

    }
}