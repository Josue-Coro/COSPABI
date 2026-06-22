using CapaModelo;
using CapaNegocio;
using System.Web.Mvc;

namespace CapaPresentacionCliente.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            CM_CuentaSocio_Activo sesion = Session["Socio"] as CM_CuentaSocio_Activo;
            CM_Aviso ultimoAviso = new CN_Aviso().ObtenerUltimoAviso(sesion.socio_id_socio);
            return View(ultimoAviso);
        }
    }
}