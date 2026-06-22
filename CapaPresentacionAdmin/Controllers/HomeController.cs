using CapaModelo;
using CapaNegocio;
using System;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public JsonResult ObtenerEstadisticas()
        {
            try
            {
                string periodo = DateTime.Today.Month.ToString("D2") + "/" + DateTime.Today.Year;
                CM_Dashboard stats = new CN_Dashboard().ObtenerEstadisticas(periodo);

                return Json(new
                {
                    exito          = true,
                    totalSocios    = stats.TotalSocios,
                    totalClientes  = stats.TotalClientes,
                    totalMedidores = stats.TotalMedidores,
                    totalRutas     = stats.TotalRutas,
                    totalUsuarios  = stats.TotalUsuarios,
                    totalLecturas  = stats.TotalLecturas,
                    totalAvisos    = stats.TotalAvisos,
                    periodo        = stats.Periodo
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}