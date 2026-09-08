using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class TarifaController : Controller
    {
        // GET: Tarifa
        [ValidarPermisos(NombrePermiso = "Gestionar Tarifa")]
        public ActionResult Tarifa()
        {
            return View();
        }
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Tarifa")]
        public JsonResult ListarTarifa()
        {
            List<CM_Tarifa> lista = new CN_Tarifa().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Tarifa")]
        public JsonResult ListarRolSocio()
        {
            List<CM_RolSocio> lista = new CN_RolSocio().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [ValidarPermisos(NombrePermiso = "Editar Tarifa")]
        public ActionResult EditarTarifa()
        {
            return View();
        }

        // monto_minimo llega como string y se parsea con InvariantCulture (mismo patron
        // que TipoCargoController). No hay <globalization> en Web.config, asi que el
        // model binder usa la cultura de la maquina (es-BO, coma decimal) y rechazaba
        // el "50.5" que manda el navegador -> el monto se bindeaba en 0 sin avisar.
        // consumo_minimo_m3 y precio_m3 siguen siendo int: sus columnas son INT.
        private static bool TryParseMonto(string monto, out decimal valor)
        {
            return decimal.TryParse(monto, NumberStyles.Any, CultureInfo.InvariantCulture, out valor);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Editar Tarifa")]
        public JsonResult EditarTarifa(int id_tarifa, int consumo_minimo_m3, string monto_minimo,
                                       int precio_m3, int rol_socio_id_rol_socio)
        {
            if (!TryParseMonto(monto_minimo, out decimal montoMinimo))
                return Json(new { resultado = false, mensaje = "El monto mínimo debe ser un número válido." }, JsonRequestBehavior.AllowGet);

            CM_Tarifa obj = new CM_Tarifa
            {
                id_tarifa              = id_tarifa,
                consumo_minimo_m3      = consumo_minimo_m3,
                monto_minimo           = montoMinimo,
                precio_m3              = precio_m3,
                rol_socio_id_rol_socio = rol_socio_id_rol_socio
            };

            string mensaje = string.Empty;
            int idUsuarioSesion = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;

            bool resultado = new CN_Tarifa().Editar(obj, idUsuarioSesion, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}