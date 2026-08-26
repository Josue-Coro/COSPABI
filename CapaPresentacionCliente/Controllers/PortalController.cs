using CapaModelo;
using CapaNegocio;
using System;
using System.Configuration;
using System.Web.Mvc;

namespace CapaPresentacionCliente.Controllers
{
    // Portal del socio (HU18/HU19): consulta de avisos, pagos, estado de
    // cuenta y notificaciones. Todos los datos se filtran por el socio de la
    // sesion — nunca se recibe el id del socio desde el navegador.
    [Authorize]
    public class PortalController : Controller
    {
        private readonly CN_CuentaSocio cnCuentaSocio = new CN_CuentaSocio();
        private readonly CN_Pago        cnPago        = new CN_Pago();

        // El pago hecho desde el portal no pasa por ninguna caja: se registra
        // como cobro del sistema y queda fuera del arqueo y del reporte de caja
        // (lo recoge el reporte de pagos del sistema, en el panel admin).
        private const string CAJERO_PORTAL = "PORTAL SOCIO";
        private static readonly int? SIN_CAJA = null;
        // La bitacora se firma con el usuario SISTEMA: sp_registrar_bitacora
        // resuelve el 0 porque en el portal no hay un usuario admin detras.
        private const int    USUARIO_SISTEMA = 0;

        private int IdSocioSesion()
        {
            var sesion = Session["Socio"] as CM_CuentaSocio_Activo;
            return sesion == null ? 0 : sesion.socio_id_socio;
        }

        public ActionResult Avisos()
        {
            return View();
        }

        public ActionResult Pagos()
        {
            return View();
        }

        public ActionResult Notificaciones()
        {
            return View();
        }

        [HttpGet]
        public JsonResult Resumen()
        {
            try
            {
                var resumen = cnCuentaSocio.ObtenerResumenPortal(IdSocioSesion());
                if (resumen == null)
                    return Json(new { exito = false, mensaje = "No se pudo obtener el estado de cuenta." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, resumen }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult ListarAvisos()
        {
            try
            {
                var avisos = cnCuentaSocio.ListarAvisosPortal(IdSocioSesion());
                if (avisos == null)
                    return Json(new { exito = false, mensaje = "No se pudieron obtener los avisos." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, avisos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult ListarPagos()
        {
            try
            {
                var pagos = cnCuentaSocio.ListarPagosPortal(IdSocioSesion());
                if (pagos == null)
                    return Json(new { exito = false, mensaje = "No se pudieron obtener los pagos." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, pagos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public JsonResult ListarNotificaciones()
        {
            try
            {
                var notificaciones = cnCuentaSocio.ListarNotificacionesPortal(IdSocioSesion());
                if (notificaciones == null)
                    return Json(new { exito = false, mensaje = "No se pudieron obtener las notificaciones." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, notificaciones }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult MarcarLeida(int idNotificacionSocio)
        {
            try
            {
                bool ok = cnCuentaSocio.MarcarNotificacionLeida(idNotificacionSocio, IdSocioSesion(), out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        // ---- Pago con QR (pasarela Libelula) --------------------------------
        // El socio paga su propio aviso sin pasar por caja. El id del aviso lo
        // manda el navegador, asi que TODA llamada viaja con el socio de la
        // sesion y los SP rechazan lo que no sea suyo.

        private static CN_Libelula CrearClienteLibelula()
        {
            return new CN_Libelula(
                ConfigurationManager.AppSettings["Libelula.AppKey"],
                ConfigurationManager.AppSettings["Libelula.UrlBase"]);
        }

        // URL publica del callback. Sin tunel configurado apunta al propio
        // portal (inalcanzable desde internet en local): el socio confirma con
        // el boton "Ya pagué" del modal, que reconsulta la pasarela.
        private string ObtenerCallbackUrl()
        {
            string baseUrl = ConfigurationManager.AppSettings["Libelula.CallbackUrl"];
            if (string.IsNullOrWhiteSpace(baseUrl))
                baseUrl = Url.Action("PagoExitoso", "Portal", null, Request.Url.Scheme);
            return baseUrl;
        }

        [HttpPost]
        public JsonResult GenerarQr(int idAviso)
        {
            try
            {
                int idSocio = IdSocioSesion();
                if (idSocio <= 0)
                    return Json(new { exito = false, mensaje = "Tu sesión expiró. Vuelve a iniciar sesión." });

                bool ok = cnPago.GenerarPagoQr(idAviso, SIN_CAJA, CAJERO_PORTAL, USUARIO_SISTEMA,
                                               CrearClienteLibelula(), ObtenerCallbackUrl(),
                                               out CM_PagoQrPendiente qr, out string Mensaje,
                                               idSocio);
                return Json(new { exito = ok, mensaje = Mensaje, qr });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [HttpGet]
        public JsonResult EstadoQr(int idPago)
        {
            try
            {
                string estado = cnPago.ObtenerEstadoPago(idPago, IdSocioSesion());
                if (estado == null)
                    return Json(new { exito = false, mensaje = "Pago no encontrado." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, estado }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // "Ya pagué": consulta la pasarela por ESTE pago (no por todos los
        // pendientes del sistema, que es cosa del cajero) y lo aprueba si la
        // pasarela confirma que la deuda esta pagada.
        [HttpPost]
        public JsonResult VerificarQr(int idPago)
        {
            try
            {
                int idSocio = IdSocioSesion();
                if (idSocio <= 0)
                    return Json(new { exito = false, mensaje = "Tu sesión expiró. Vuelve a iniciar sesión." });

                bool ok = cnPago.VerificarPagoQrSocio(idPago, idSocio, CrearClienteLibelula(),
                                                      out string estado, out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje, estado });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        // Callback publico de Libelula (PAGO EXITOSO). Sin sesion: la
        // autenticidad no sale del GET, se verifica reconsultando la deuda en
        // la pasarela dentro de CN_Pago.ConfirmarPagoQr.
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
    }
}
