using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class PagoController : Controller
    {
        private readonly CN_Pago cnPago = new CN_Pago();
        private readonly CN_Caja cnCaja = new CN_Caja();

        // GET: Pago
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public ActionResult Pago()
        {
            return View();
        }

        // Caja abierta del cajero + metodos de pago
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public JsonResult MiCaja()
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                var caja = cnCaja.ObtenerCajaAbierta(u.id_usuario_admin);
                var metodos = new CN_MetodoPago().Listar("", 1, 1000).Metodos;
                return Json(new { exito = true, caja, metodos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public JsonResult ListarPorCobrar(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var res = cnPago.ListarAvisosPorCobrar(busqueda, pagina, tamanoPagina);
                if (res == null)
                    return Json(new { exito = false, mensaje = "Error al listar los avisos." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, avisos = res.Avisos, totalRegistros = res.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public JsonResult RegistrarPago(int idAviso, int idMetodoPago, decimal? montoRecibido)
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                var caja = cnCaja.ObtenerCajaAbierta(u.id_usuario_admin);
                if (caja == null)
                    return Json(new { exito = false, mensaje = "Debe abrir su caja antes de cobrar." });

                string cajero = (u.nombre + " " + u.apellido).Trim();
                bool ok = cnPago.RegistrarPago(idAviso, caja.id_caja, idMetodoPago, montoRecibido,
                                               u.id_usuario_admin, cajero, out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public JsonResult PagosCaja()
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                var caja = cnCaja.ObtenerCajaAbierta(u.id_usuario_admin);
                if (caja == null)
                    return Json(new { exito = true, pagos = new object[0] }, JsonRequestBehavior.AllowGet);
                var pagos = cnPago.ListarPagosCaja(caja.id_caja);
                return Json(new { exito = true, pagos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
