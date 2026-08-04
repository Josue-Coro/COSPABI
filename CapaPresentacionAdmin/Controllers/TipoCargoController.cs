using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System.Collections.Generic;
using System.Globalization;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class TipoCargoController : Controller
    {
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public ActionResult TipoCargo()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public JsonResult ListarTipoCargo()
        {
            List<CM_TipoCargo> lista = new CN_TipoCargo().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        // El monto llega como string y se parsea con InvariantCulture (mismo patrón que
        // CargoExtraController): el navegador envía "55.000" con punto, y el model binder
        // por defecto lo parsea con la cultura es-BO, donde el punto no es decimal ni
        // separador de miles válido para NumberStyles.Float -> el monto quedaba en 0.
        private static bool TryParseMonto(string monto, out decimal valor)
        {
            return decimal.TryParse(monto, NumberStyles.Any, CultureInfo.InvariantCulture, out valor);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public JsonResult RegistrarTipoCargo(string nombre, string monto, bool estado, bool automatico = false)
        {
            if (!TryParseMonto(monto, out decimal montoDecimal))
                return Json(new { resultado = 0, mensaje = "El monto debe ser un número válido." }, JsonRequestBehavior.AllowGet);

            var obj = new CM_TipoCargo
            {
                nombre     = nombre,
                monto      = montoDecimal,
                estado     = estado,
                automatico = automatico
            };

            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            object resultado = new CN_TipoCargo().Registrar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public JsonResult EditarTipoCargo(int id_tipo, string nombre, string monto, bool estado, bool automatico = false)
        {
            if (!TryParseMonto(monto, out decimal montoDecimal))
                return Json(new { resultado = false, mensaje = "El monto debe ser un número válido." }, JsonRequestBehavior.AllowGet);

            var obj = new CM_TipoCargo
            {
                id_tipo    = id_tipo,
                nombre     = nombre,
                monto      = montoDecimal,
                estado     = estado,
                automatico = automatico
            };

            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            object resultado = new CN_TipoCargo().Editar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar TipoCargo")]
        public JsonResult EliminarTipoCargo(int id)
        {
            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            bool resultado = new CN_TipoCargo().Eliminar(id, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}