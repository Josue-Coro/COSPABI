using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class PagoController : Controller
    {
        // GET: Pago
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public ActionResult Pago()
        {
            return View();
        }
    }
}