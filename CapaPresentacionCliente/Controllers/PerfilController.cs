using CapaModelo;
using CapaNegocio;
using System.Web.Mvc;

namespace CapaPresentacionCliente.Controllers
{
    [Authorize]
    public class PerfilController : Controller
    {
        public ActionResult Index()
        {
            CM_CuentaSocio_Activo sesion = Session["Socio"] as CM_CuentaSocio_Activo;
            CM_Socio socio = new CN_Socio().Obtener(sesion.socio_id_socio);
            return View(socio);
        }
    }
}