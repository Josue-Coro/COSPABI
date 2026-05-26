using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class LecturaController : Controller
    {
        // GET: Lectura
        [ValidarPermisos(NombrePermiso = "Gestionar Lecturas")]
        public ActionResult Lectura()
        {
            return View();
        }
    }
}