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
    public class RutaController : Controller
    {
        // GET: Ruta
        [ValidarPermisos(NombrePermiso = "Gestionar Ruta")]
        public ActionResult Ruta()
        {
            return View();
        }
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Ruta")]
        public JsonResult ListarRutas()
        {
            List<CM_Ruta> lista = new CN_Ruta().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Ruta")]
        public JsonResult RegistrarRuta(CM_Ruta obj)
        {
            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            object resultado = new CN_Ruta().Registrar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Ruta")]
        public JsonResult EditarRuta(CM_Ruta obj)
        {
            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            object resultado = new CN_Ruta().Editar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}