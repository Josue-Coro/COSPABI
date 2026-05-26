using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class TarifaController : Controller
    {
        // GET: Tarifa
        [ValidarPermisos(NombrePermiso = "Gestionar Tarifa")]
        public ActionResult Tarifa()
        {
            return View();
        }
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Tarifa")]
        public JsonResult ListarTarifa()
        {
            List<CM_Tarifa> lista = new CN_Tarifa().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Tarifa")]
        public JsonResult ListarRolSocio()
        {
            List<CM_RolSocio> lista = new CN_RolSocio().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [ValidarPermisos(NombrePermiso = "Editar Tarifa")]
        public ActionResult EditarTarifa()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Editar Tarifa")]
        public JsonResult EditarTarifa(CM_Tarifa obj)
        {
            string mensaje = string.Empty;
            int idUsuarioSesion = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            object resultado = new CN_Tarifa().Editar(obj, idUsuarioSesion, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}