using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    public class UsuarioController : Controller
    {
        [Authorize]
        // GET: Usuario
        public ActionResult Usuario()
        {
            return View();
        }
    }
}