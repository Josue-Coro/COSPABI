using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class ReporteController : Controller
    {
        private readonly CN_Caja  cnCaja  = new CN_Caja();
        private readonly CN_Aviso cnAviso = new CN_Aviso();

        private bool EsSuperadmin()
        {
            var u = (CM_Usuario_Activo)Session["Usuario"];
            return u != null && u.nombre_rol == "SUPERADMIN";
        }

        // ---- HU21: Reporte de Caja ----

        [ValidarPermisos(NombrePermiso = "Generar Reporte Caja")]
        public ActionResult Caja()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Generar Reporte Caja")]
        public JsonResult Cajeros()
        {
            try
            {
                var cajeros = cnCaja.ListarCajerosConCaja(EsSuperadmin());
                if (cajeros == null)
                    return Json(new { exito = false, mensaje = "Error al listar los cajeros." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, cajeros }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Generar Reporte Caja")]
        public JsonResult DatosCaja(string fechaInicio, string fechaFin, int? idCajero)
        {
            try
            {
                if (!DateTime.TryParse(fechaInicio, out DateTime fi) ||
                    !DateTime.TryParse(fechaFin, out DateTime ff))
                    return Json(new { exito = false, mensaje = "Debe indicar un rango de fechas valido." }, JsonRequestBehavior.AllowGet);

                var u = (CM_Usuario_Activo)Session["Usuario"];
                var reporte = cnCaja.ReporteCaja(fi, ff, idCajero, u.id_usuario_admin, out string Mensaje);
                if (reporte == null)
                    return Json(new { exito = false, mensaje = Mensaje }, JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    pagos = reporte.Pagos,
                    totalesMetodo = reporte.TotalesMetodo,
                    cantidadPagos = reporte.CantidadPagos,
                    totalRecaudado = reporte.TotalRecaudado
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // ---- Facturas cobradas (detalle de cobros, estilo del reporte historico) ----

        [ValidarPermisos(NombrePermiso = "Generar Reporte Caja")]
        public ActionResult Cobros()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Generar Reporte Caja")]
        public JsonResult DatosCobros(string fechaInicio, string fechaFin, int? idCajero, string origen)
        {
            try
            {
                if (!DateTime.TryParse(fechaInicio, out DateTime fi) ||
                    !DateTime.TryParse(fechaFin, out DateTime ff))
                    return Json(new { exito = false, mensaje = "Debe indicar un rango de fechas valido." }, JsonRequestBehavior.AllowGet);

                var u = (CM_Usuario_Activo)Session["Usuario"];
                var reporte = cnCaja.ReporteCobros(fi, ff, idCajero, origen, u.id_usuario_admin, out string Mensaje);
                if (reporte == null)
                    return Json(new { exito = false, mensaje = Mensaje }, JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    cobros = reporte.Cobros,
                    subtotales = reporte.Subtotales,
                    cantidadPagos = reporte.CantidadPagos,
                    totalRecaudado = reporte.TotalRecaudado
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // ---- Arqueo general (recaudacion por concepto) ----

        [ValidarPermisos(NombrePermiso = "Generar Reporte Caja")]
        public ActionResult Arqueo()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Generar Reporte Caja")]
        public JsonResult DatosArqueo(string fechaInicio, string fechaFin, int? idCajero, string origen)
        {
            try
            {
                if (!DateTime.TryParse(fechaInicio, out DateTime fi) ||
                    !DateTime.TryParse(fechaFin, out DateTime ff))
                    return Json(new { exito = false, mensaje = "Debe indicar un rango de fechas valido." }, JsonRequestBehavior.AllowGet);

                var u = (CM_Usuario_Activo)Session["Usuario"];
                var reporte = cnCaja.ArqueoGeneral(fi, ff, idCajero, origen, u.id_usuario_admin, out string Mensaje);
                if (reporte == null)
                    return Json(new { exito = false, mensaje = Mensaje }, JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    conceptos = reporte.Conceptos,
                    totalesMetodo = reporte.TotalesMetodo,
                    cantidadPagos = reporte.CantidadPagos,
                    cantidadConceptos = reporte.CantidadConceptos,
                    totalRecaudado = reporte.TotalRecaudado
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // ---- Reporte de pagos del sistema (cobrados por el portal del socio) ----

        [ValidarPermisos(NombrePermiso = "Generar Reporte Pagos Sistema")]
        public ActionResult PagosSistema()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Generar Reporte Pagos Sistema")]
        public JsonResult DatosPagosSistema(string fechaInicio, string fechaFin)
        {
            try
            {
                if (!DateTime.TryParse(fechaInicio, out DateTime fi) ||
                    !DateTime.TryParse(fechaFin, out DateTime ff))
                    return Json(new { exito = false, mensaje = "Debe indicar un rango de fechas valido." }, JsonRequestBehavior.AllowGet);

                var u = (CM_Usuario_Activo)Session["Usuario"];
                var reporte = cnCaja.ReportePagosSistema(fi, ff, u.id_usuario_admin, out string Mensaje);
                if (reporte == null)
                    return Json(new { exito = false, mensaje = Mensaje }, JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    pagos = reporte.Pagos,
                    totalesMetodo = reporte.TotalesMetodo,
                    cantidadPagos = reporte.CantidadPagos,
                    totalRecaudado = reporte.TotalRecaudado,
                    qrSinCobrar = reporte.QrSinCobrar
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [ValidarPermisos(NombrePermiso = "Reporte de Pagos de Inscripción")]
        public ActionResult PagosInscripcion()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Reporte de Pagos de Inscripción")]
        public JsonResult DatosPagosInscripcion(string fechaInicio, string fechaFin)
        {
            try
            {
                if (!DateTime.TryParse(fechaInicio, out DateTime fi) ||
                    !DateTime.TryParse(fechaFin, out DateTime ff))
                    return Json(new { exito = false, mensaje = "Debe indicar un rango de fechas valido." }, JsonRequestBehavior.AllowGet);

                var u = (CM_Usuario_Activo)Session["Usuario"];
                var reporte = cnCaja.ReportePagosInscripcion(fi, ff, u.id_usuario_admin, out string Mensaje);
                if (reporte == null)
                    return Json(new { exito = false, mensaje = Mensaje }, JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    cuotas = reporte.Cuotas,
                    pendientes = reporte.Pendientes,
                    cantidadCuotas = reporte.CantidadCuotas,
                    montoCobrado = reporte.MontoCobrado,
                    sociosCobrados = reporte.SociosCobrados,
                    sociosCancelaronTotal = reporte.SociosCancelaronTotal,
                    sociosConPendientes = reporte.SociosConPendientes,
                    saldoTotalPendiente = reporte.SaldoTotalPendiente
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // ---- HU22: Reporte de Morosidad ----

        [ValidarPermisos(NombrePermiso = "Generar Reporte Morosidad")]
        public ActionResult Morosidad()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Generar Reporte Morosidad")]
        public JsonResult DatosMorosidad(string fechaInicio, string fechaFin, int? idRuta)
        {
            try
            {
                DateTime? fi = DateTime.TryParse(fechaInicio, out DateTime dfi) ? dfi : (DateTime?)null;
                DateTime? ff = DateTime.TryParse(fechaFin, out DateTime dff) ? dff : (DateTime?)null;

                var u = (CM_Usuario_Activo)Session["Usuario"];
                var reporte = cnAviso.ReporteMorosidad(fi, ff, idRuta, u.id_usuario_admin, out string Mensaje);
                if (reporte == null)
                    return Json(new { exito = false, mensaje = Mensaje }, JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    avisos = reporte.Avisos,
                    cantidadSocios = reporte.CantidadSocios,
                    cantidadAvisos = reporte.CantidadAvisos,
                    totalAdeudado = reporte.TotalAdeudado
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Generar Reporte Morosidad")]
        public JsonResult Rutas()
        {
            try
            {
                var rutas = new CN_Ruta().Listar();
                return Json(new { exito = true, rutas }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
