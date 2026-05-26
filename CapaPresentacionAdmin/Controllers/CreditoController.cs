using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class CreditoController : Controller
    {        
        // GET: Credito
        [ValidarPermisos(NombrePermiso = "Gestionar Credito")]
        public ActionResult Credito()
        {
            return View();
        }
    }
}