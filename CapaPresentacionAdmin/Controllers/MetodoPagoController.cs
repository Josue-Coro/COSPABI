using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class MetodoPagoController : Controller
    {
        private readonly CN_MetodoPago cnMetodoPago = new CN_MetodoPago();

        [ValidarPermisos(NombrePermiso = "Gestionar Metodo Pago")]
        public ActionResult MetodoPago()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Metodo Pago")]
        public JsonResult Listar(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            var resultado = cnMetodoPago.Listar(busqueda, pagina, tamanoPagina);
            if (resultado != null)
            {
                return Json(new { exito = true, metodos = resultado.Metodos, totalRegistros = resultado.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { exito = false, mensaje = "Error al listar métodos de pago" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Metodo Pago")]
        public JsonResult Guardar(CM_MetodoPago obj)
        {
            string mensaje = string.Empty;
            bool resultado = false;
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            int idUsuario = oUsuario?.id_usuario_admin ?? 0;

            if (obj.id_metodo_pago == 0)
            {
                resultado = cnMetodoPago.Registrar(obj, idUsuario, out mensaje);
            }
            else
            {
                resultado = cnMetodoPago.Editar(obj, idUsuario, out mensaje);
            }

            return Json(new { exito = resultado, mensaje = mensaje });
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Metodo Pago")]
        public JsonResult Eliminar(int id)
        {
            string mensaje = string.Empty;
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            int idUsuario = oUsuario?.id_usuario_admin ?? 0;

            bool resultado = cnMetodoPago.Eliminar(id, idUsuario, out mensaje);
            return Json(new { exito = resultado, mensaje = mensaje });
        }
    }
}