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
