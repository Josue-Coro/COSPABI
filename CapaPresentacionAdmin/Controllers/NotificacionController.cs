using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    public class NotificacionController : Controller
    {
        [Authorize]
        // GET: Notificacion
        [ValidarPermisos(NombrePermiso = "Gestionar Notificaciones")]
        public ActionResult Notificacion()
        {
            return View();
        }
    }
}