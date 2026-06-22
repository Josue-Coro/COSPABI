using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class CreditoController : Controller
    {
        // GET: Credito
        [ValidarPermisos(NombrePermiso = "Gestionar Credito Inscripcion")]
        public ActionResult Credito()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Credito Inscripcion")]
        public JsonResult Listar(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = new CN_Credito().ListarPendientes(busqueda, pagina, tamanoPagina);
                if (resultado == null)
                    return Json(new { exito = false, mensaje = "Error al obtener los créditos." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, creditos = resultado.Creditos, totalRegistros = resultado.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Credito Inscripcion")]
        public JsonResult Detalle(int idSocio)
        {
            try
            {
                var lista = new CN_Credito().ObtenerDetalle(idSocio);
                if (lista == null)
                    return Json(new { exito = false, mensaje = "No se pudo obtener el detalle." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, cuotas = lista }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
