using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class ClienteController : Controller
    {
        [ValidarPermisos(NombrePermiso = "Gestionar Cliente")]
        public ActionResult Cliente()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cliente")]
        public JsonResult Listar(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = new CN_Cliente().Listar(busqueda, pagina, tamanoPagina);

                if (resultado == null)
                    return Json(new { exito = false, mensaje = "Error al obtener los datos." },
                                JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    totalRegistros = resultado.TotalRegistros,
                    clientes = resultado.Clientes
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message },
                            JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cliente")]
        public JsonResult Obtener(int id)
        {
            try
            {
                var cliente = new CN_Cliente().Obtener(id);

                if (cliente == null)
                    return Json(new { exito = false, mensaje = "Cliente no encontrado." },
                                JsonRequestBehavior.AllowGet);

                return Json(new { exito = true, cliente }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message },
                            JsonRequestBehavior.AllowGet);
            }
        }

        [ValidarPermisos(NombrePermiso = "Registrar Cliente")]
        public ActionResult RegistrarCliente()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Registrar Cliente")]
        public JsonResult Registrar(CM_Cliente modelo)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool exito = new CN_Cliente().Registrar(modelo, oUsuario.id_usuario_admin, out string Mensaje);

                return Json(new { exito, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [ValidarPermisos(NombrePermiso = "Editar Cliente")]
        public ActionResult EditarCliente()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Editar Cliente")]
        public JsonResult Editar(CM_Cliente modelo)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool exito = new CN_Cliente().Editar(modelo, oUsuario.id_usuario_admin, out string Mensaje);

                return Json(new { exito, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [ValidarPermisos(NombrePermiso = "Eliminar Cliente")]
        public ActionResult EliminarCliente()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Eliminar Cliente")]
        public JsonResult CambiarEstado(int id)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool exito = new CN_Cliente().CambiarEstado(id, oUsuario.id_usuario_admin, out string Mensaje);

                return Json(new { exito, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }
    }
}