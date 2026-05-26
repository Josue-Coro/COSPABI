using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System.Collections.Generic;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class TipoCargoController : Controller
    {
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public ActionResult TipoCargo()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public JsonResult ListarTipoCargo()
        {
            List<CM_TipoCargo> lista = new CN_TipoCargo().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public JsonResult RegistrarTipoCargo(CM_TipoCargo obj)
        {
            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            object resultado = new CN_TipoCargo().Registrar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public JsonResult EditarTipoCargo(CM_TipoCargo obj)
        {
            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            object resultado = new CN_TipoCargo().Editar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public JsonResult EliminarTipoCargo(int id)
        {
            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            bool resultado = new CN_TipoCargo().Eliminar(id, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}