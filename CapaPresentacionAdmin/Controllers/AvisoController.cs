using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class AvisoController : Controller
    {
        private readonly CN_Aviso cnAviso = new CN_Aviso();

        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public ActionResult Aviso()
        {
            return View();
        }
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public JsonResult ListarPeriodos()
        {
            List<CM_Periodo> lista = new CN_Lectura().ListarPeriodosAutomaticos();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public JsonResult ListarRutas()
        {
            List<CM_Ruta> lista = new CN_Ruta().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public JsonResult ListarEstados()
        {
            var lista = cnAviso.ListarEstados();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public JsonResult GenerarAvisos(int idPeriodo, int? idRuta)
        {
            try
            {
                var oUsuario  = (CM_Usuario_Activo)Session["Usuario"];
                int generados = cnAviso.GenerarAvisos(idPeriodo, idRuta, oUsuario.id_usuario_admin, out string Mensaje);
                return Json(new { exito = generados >= 0, generados, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, generados = 0, mensaje = ex.Message });
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public JsonResult ListarAvisos(int? idPeriodo, int? idEstado, int? idRuta,
                                       string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = cnAviso.Listar(idPeriodo, idEstado, idRuta, busqueda, pagina, tamanoPagina);
                if (resultado == null)
                    return Json(new { exito = false, mensaje = "Error al obtener los avisos." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, avisos = resultado.Avisos, totalRegistros = resultado.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public JsonResult ObtenerDetalle(int idAviso)
        {
            try
            {
                var detalle = cnAviso.ObtenerDetalle(idAviso);
                if (detalle == null)
                    return Json(new { exito = false, mensaje = "Aviso no encontrado." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, data = detalle }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Vista imprimible del aviso (se abre en otra pestaña y dispara window.print()).
        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public ActionResult ImprimirAviso(int idAviso)
        {
            var datos = cnAviso.ObtenerParaImpresion(idAviso);
            if (datos == null)
                return HttpNotFound("Aviso no encontrado.");
            return View(datos);
        }
        [ValidarPermisos(NombrePermiso = "Anular Avisos")]
        public ActionResult AnularAviso()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Anular Avisos")]
        public JsonResult AnularAviso(int idAviso)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool ok      = cnAviso.AnularAviso(idAviso, oUsuario.id_usuario_admin, out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Avisos")]
        public JsonResult CambiarEstado(int idAviso, int idEstado)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool ok      = cnAviso.CambiarEstado(idAviso, idEstado, oUsuario.id_usuario_admin, out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }
    }
}