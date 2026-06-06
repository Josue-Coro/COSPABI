using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class ReporteController : Controller
    {
        [ValidarPermisos(NombrePermiso = "Generar Reporte Caja")]
        // GET: Reporte
        public ActionResult Caja()
        {
            return View();
        }
        [ValidarPermisos(NombrePermiso = "Generar Reporte Morosidad")]
        public ActionResult Morosidad()
        {
            return View();
        }
    }
}