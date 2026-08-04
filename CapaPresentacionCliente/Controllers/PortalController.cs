using CapaModelo;
using CapaNegocio;
using System;
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
    }
}
