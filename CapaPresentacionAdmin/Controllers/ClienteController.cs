using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers

{
    [Authorize]
    public class ClienteController : Controller
    {
        // GET: Cliente
        [ValidarPermisos(NombrePermiso = "Gestionar Cliente")]
        public ActionResult Cliente()
        {
            return View();
        }
    }
}