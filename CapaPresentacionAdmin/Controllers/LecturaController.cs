using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class LecturaController : Controller
    {
        private readonly CN_Lectura cnLectura = new CN_Lectura();

        [ValidarPermisos(NombrePermiso = "Gestionar Lecturas")]
        public ActionResult Lectura()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Lecturas")]
        public JsonResult ListarPeriodos()
        {
            List<CM_Periodo> lista = cnLectura.ListarPeriodosAutomaticos();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Lecturas")]
        public JsonResult ListarRutas()
        {
            List<CM_Ruta> lista = new CN_Ruta().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Lecturas")]
        public JsonResult ListarMedidoresParaLectura(int idRuta, int idPeriodo)
        {
            try
            {
                var lista = cnLectura.ListarMedidoresParaLectura(idRuta, idPeriodo);

                if (lista == null)
                    return Json(new { exito = false, mensaje = "Error al cargar los medidores." }, JsonRequestBehavior.AllowGet);

                return Json(new { exito = true, medidores = lista }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Lecturas")]
        public JsonResult Registrar(CM_Lectura obj)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                obj.fecha_lectura = DateTime.Today;

                int idGenerado = cnLectura.Registrar(obj, oUsuario.id_usuario_admin, out string Mensaje);
                return Json(new { exito = idGenerado > 0, mensaje = Mensaje, idGenerado });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Lecturas")]
        public JsonResult ListarHistorial(int? idPeriodo, int? idRuta, string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = cnLectura.Listar(idPeriodo, idRuta, busqueda, pagina, tamanoPagina);

                if (resultado == null)
                    return Json(new { exito = false, mensaje = "Error al obtener el historial." }, JsonRequestBehavior.AllowGet);

                return Json(new { exito = true, lecturas = resultado.Lecturas, totalRegistros = resultado.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}