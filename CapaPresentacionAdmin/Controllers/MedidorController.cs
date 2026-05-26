using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class MedidorController : Controller
    {
        [ValidarPermisos(NombrePermiso = "Gestionar Medidor")]
        public ActionResult Medidor()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Medidor")]
        public JsonResult ListarMedidores(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            var (lista, total) = new CN_Medidor().Listar(busqueda, pagina, tamanoPagina);
            return Json(new
            {
                data = lista,
                totalRegistros = total,
                totalPaginas = (int)Math.Ceiling((double)total / tamanoPagina),
                paginaActual = pagina
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Medidor")]
        public JsonResult RegistrarMedidor(CM_Medidor obj)
        {
            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            object resultado = new CN_Medidor().Registrar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Medidor")]
        public JsonResult EditarMedidor(CM_Medidor obj)
        {
            string mensaje = string.Empty;
            int idUsuario = ((CM_Usuario_Activo)Session["Usuario"]).id_usuario_admin;
            object resultado = new CN_Medidor().Editar(obj, idUsuario, out mensaje);
            return Json(new { resultado = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
        }
    }
}