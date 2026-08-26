using CapaModelo;
using CapaNegocio;
using System.Web.Mvc;

namespace CapaPresentacionCliente.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        // Portada publica de la cooperativa: es la puerta de entrada del sitio
        // (la ruta por defecto) y desde aqui se pasa al login del socio.
        // AllowAnonymous gana sobre el [Authorize] de la clase.
        [AllowAnonymous]
        public ActionResult Bienvenida()
        {
            // Si el socio ya inicio sesion no tiene sentido mostrarle la
            // portada: se le manda directo a su panel.
            if (Session["Socio"] is CM_CuentaSocio_Activo)
                return RedirectToAction("Index", "Home");

            return View();
        }

        public ActionResult Index()
        {
            CM_CuentaSocio_Activo sesion = Session["Socio"] as CM_CuentaSocio_Activo;
            CM_Aviso ultimoAviso = new CN_Aviso().ObtenerUltimoAviso(sesion.socio_id_socio);
            return View(ultimoAviso);
        }
    }
}
