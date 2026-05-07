using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    public class TarifaController : Controller
    {
        [Authorize]
        // GET: Tarifa
        [ValidarPermisos(NombrePermiso = "Gestionar Tarifa")]
        public ActionResult Tarifa()
        {
            return View();
        }
    }
}