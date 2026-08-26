using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class CajaController : Controller
    {
        private readonly CN_Caja cnCaja = new CN_Caja();

        // El SUPERADMIN supervisa cualquier caja; el resto solo la suya.
        private bool EsSuperadmin()
        {
            var u = Session["Usuario"] as CM_Usuario_Activo;
            return u != null && (u.nombre_rol ?? "").ToUpper() == "SUPERADMIN";
        }

        // GET: Caja
        [ValidarPermisos(NombrePermiso = "Gestionar Caja")]
        public ActionResult Caja()
        {
            return View();
        }
        // Caja abierta del cajero logueado (o null)
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Caja")]
        public JsonResult EstadoCaja()
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                var caja = cnCaja.ObtenerCajaAbierta(u.id_usuario_admin);
                return Json(new { exito = true, caja }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Caja")]
        public JsonResult AbrirCaja(decimal montoApertura)
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                int id = cnCaja.AbrirCaja(u.id_usuario_admin, montoApertura, out string Mensaje);
                return Json(new { exito = id > 0, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Caja")]
        public JsonResult CerrarCaja(int idCaja)
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                bool ok = cnCaja.CerrarCaja(idCaja, u.id_usuario_admin, EsSuperadmin(), out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Caja")]
        public JsonResult Arqueo(int idCaja)
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                var arqueo = cnCaja.ObtenerArqueo(idCaja, u.id_usuario_admin, EsSuperadmin());
                if (arqueo == null)
                    return Json(new { exito = false, mensaje = "Caja no encontrada." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, arqueo }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Caja")]
        public JsonResult Historial(int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                var res = cnCaja.Listar(u.id_usuario_admin, pagina, tamanoPagina);
                if (res == null)
                    return Json(new { exito = false, mensaje = "Error al listar las cajas." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, cajas = res.Cajas, totalRegistros = res.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Caja")]
        public ActionResult Reporte(int idCaja)
        {
            var u = (CM_Usuario_Activo)Session["Usuario"];
            var arqueo = cnCaja.ObtenerArqueo(idCaja, u.id_usuario_admin, EsSuperadmin());
            if (arqueo == null)
            {
                // Tambien es la respuesta cuando la caja existe pero es de otro
                // cajero: no confirmamos su existencia.
                return HttpNotFound("La caja especificada no fue encontrada.");
            }

            var cnPago = new CN_Pago();
            var pagos = cnPago.ListarPagosCaja(idCaja);

            ViewBag.Arqueo = arqueo;
            ViewBag.Pagos = pagos;

            return View();
        }
    }
}
