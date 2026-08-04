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
    public class NotificacionController : Controller
    {
        private readonly CN_Notificacion cnNotificacion = new CN_Notificacion();

        [ValidarPermisos(NombrePermiso = "Gestionar Notificaciones")]
        public ActionResult Notificacion()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Notificaciones")]
        public JsonResult Listar(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            var resultado = cnNotificacion.Listar(busqueda, pagina, tamanoPagina);
            if (resultado != null)
            {
                return Json(new { exito = true, notificaciones = resultado.Notificaciones, totalRegistros = resultado.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { exito = false, mensaje = "Error al listar notificaciones" }, JsonRequestBehavior.AllowGet);
        }

        // RF-27: recordatorios automaticos de avisos por vencer
        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Notificaciones")]
        public JsonResult GenerarRecordatorios(int diasAntes = 3)
        {
            try
            {
                var u = (CM_Usuario_Activo)Session["Usuario"];
                int generados = cnNotificacion.GenerarRecordatoriosVencimiento(diasAntes, u.id_usuario_admin, out string mensaje);
                return Json(new { exito = true, generados, mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Notificaciones")]
        public JsonResult Guardar(CM_Notificacion obj)
        {
            string mensaje = string.Empty;
            bool resultado = false;
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            int idUsuario = oUsuario?.id_usuario_admin ?? 0;

            if (!obj.enviar_a_todos && string.IsNullOrWhiteSpace(obj.ids_socios))
            {
                return Json(new { exito = false, mensaje = "Debe seleccionar al menos un socio si no envía a todos." });
            }

            if (obj.id_notificacion == 0)
            {
                resultado = cnNotificacion.Registrar(obj, idUsuario, out mensaje);
            }
            else
            {
                resultado = cnNotificacion.Editar(obj, idUsuario, out mensaje);
            }

            return Json(new { exito = resultado, mensaje = mensaje });
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Notificaciones")]
        public JsonResult Eliminar(int id)
        {
            string mensaje = string.Empty;
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            int idUsuario = oUsuario?.id_usuario_admin ?? 0;

            bool resultado = cnNotificacion.Eliminar(id, idUsuario, out mensaje);
            return Json(new { exito = resultado, mensaje = mensaje });
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Notificaciones")]
        public JsonResult ObtenerSociosAsignados(int idNotificacion)
        {
            var socios = cnNotificacion.ListarSociosAsignados(idNotificacion);
            return Json(new { exito = true, socios = socios }, JsonRequestBehavior.AllowGet);
        }
    }
}