using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class CargoExtraController : Controller
    {
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        // GET: CargoExtra
        public ActionResult CargoExtra()
        {
            return View();
        }
    }
}