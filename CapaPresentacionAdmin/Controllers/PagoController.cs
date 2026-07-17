using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Configuration;
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
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public ActionResult ImprimirRecibo(int idPago)
        {
            var recibo = cnPago.ObtenerReciboPago(idPago);
            if (recibo == null) return RedirectToAction("Pago");
            return View(recibo);
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
                                               u.id_usuario_admin, cajero, out int idPago, out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje, idPago = idPago });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        // ---- Pago QR (pasarela Libelula) ------------------------------------

        private static CN_Libelula CrearClienteLibelula()
        {
            return new CN_Libelula(
                ConfigurationManager.AppSettings["Libelula.AppKey"],
                ConfigurationManager.AppSettings["Libelula.UrlBase"]);
        }

        // URL publica del callback (en local: tunel ngrok, Secrets.config)
        private string ObtenerCallbackUrl()
        {
            string baseUrl = ConfigurationManager.AppSettings["Libelula.CallbackUrl"];
            if (string.IsNullOrWhiteSpace(baseUrl))
                baseUrl = Url.Action("PagoExitoso", "Pago", null, Request.Url.Scheme);
            return baseUrl;
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public JsonResult GenerarQr(int idAviso)
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                var caja = cnCaja.ObtenerCajaAbierta(u.id_usuario_admin);
                if (caja == null)
                    return Json(new { exito = false, mensaje = "Debe abrir su caja antes de cobrar." });

                string cajero = (u.nombre + " " + u.apellido).Trim();
                bool ok = cnPago.GenerarPagoQr(idAviso, caja.id_caja, cajero, u.id_usuario_admin,
                                               CrearClienteLibelula(), ObtenerCallbackUrl(),
                                               out CM_PagoQrPendiente qr, out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje, qr });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public JsonResult EstadoQr(int idPago)
        {
            try
            {
                string estado = cnPago.ObtenerEstadoPago(idPago);
                if (estado == null)
                    return Json(new { exito = false, mensaje = "Pago no encontrado." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, estado }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Callback publico de Libelula (PAGO EXITOSO): GET ?transaction_id=...
        // Sin sesion ni permisos; la autenticidad se verifica reconsultando la
        // deuda en la pasarela antes de aprobar (CN_Pago.ConfirmarPagoQr).
        [HttpGet]
        [AllowAnonymous]
        public ContentResult PagoExitoso(string transaction_id)
        {
            try
            {
                bool ok = cnPago.ConfirmarPagoQr(transaction_id, CrearClienteLibelula(), out string mensaje);
                Response.StatusCode = ok ? 200 : 400;
                return Content(ok ? "OK" : mensaje, "text/plain");
            }
            catch (Exception)
            {
                Response.StatusCode = 500;
                return Content("ERROR", "text/plain");
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Pago")]
        public JsonResult ConciliarQr()
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                int confirmados = cnPago.ConciliarPagosQr(CrearClienteLibelula(), u.id_usuario_admin, out string Mensaje);
                return Json(new { exito = true, mensaje = Mensaje, confirmados });
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
