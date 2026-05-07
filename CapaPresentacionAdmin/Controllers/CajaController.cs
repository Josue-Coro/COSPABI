using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class CajaController : Controller
    {
        // GET: Caja
        [ValidarPermisos(NombrePermiso = "Gestionar Caja")]
        public ActionResult Caja()
        {
            return View();
        }
    }
}