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

        // Para poblar el select de usuarios en el filtro
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Visualizar Bitacora")]
        public JsonResult ListarUsuarios()
        {
            List<CM_Usuario> lista = new CN_Usuario().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }
    }
}