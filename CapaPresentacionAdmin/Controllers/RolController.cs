using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    public class RolController : Controller
    {
        [Authorize]
        // GET: Rol
        [ValidarPermisos(NombrePermiso = "Gestionar Rol")]
        public ActionResult Rol()
        {
            return View();
        }
    }
}