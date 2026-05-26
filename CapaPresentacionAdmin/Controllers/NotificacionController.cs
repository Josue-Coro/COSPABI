using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class NotificacionController : Controller
    {
        // GET: Notificacion
        [ValidarPermisos(NombrePermiso = "Gestionar Notificaciones")]
        public ActionResult Notificacion()
        {
            return View();
        }
    }
}