using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System.Collections.Generic;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class BitacoraController : Controller
    {
        
        [ValidarPermisos(NombrePermiso = "Visualizar Bitacora")]
        public ActionResult Bitacora()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Visualizar Bitacora")]
        public JsonResult ListarBitacora(string fechaInicio, string fechaFin, int idUsuario = 0)
        {
            List<CM_Bitacora> lista = new CN_Bitacora()
                .Listar(fechaInicio, fechaFin, idUsuario);

            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Visualizar Bitacora")]
        public JsonResult ListarUsuarios()
        {
            // Un no-superadmin no ve al SUPERADMIN ni en el filtro de la bitácora
            var u = Session["Usuario"] as CM_Usuario_Activo;
            bool esSuper = u != null && (u.nombre_rol ?? "").ToUpper() == "SUPERADMIN";

            List<CM_Usuario> lista = new CN_Usuario().Listar(esSuper);
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }
    }
}