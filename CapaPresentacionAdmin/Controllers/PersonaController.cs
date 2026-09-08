using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Web.Mvc;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class PersonaController : Controller
    {
        [ValidarPermisos(NombrePermiso = "Gestionar Persona")]
        public ActionResult Persona()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Persona")]
        public JsonResult Listar(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = new CN_Persona().Listar(busqueda, pagina, tamanoPagina);

                if (resultado == null)
                    return Json(new { exito = false, mensaje = "Error al obtener los datos." },
                                JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    totalRegistros = resultado.TotalRegistros,
                    personas = resultado.Personas
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message },
                            JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Persona")]
        public JsonResult Obtener(int id)
        {
            try
            {
                var persona = new CN_Persona().Obtener(id);

                if (persona == null)
                    return Json(new { exito = false, mensaje = "Persona no encontrada." },
                                JsonRequestBehavior.AllowGet);

                return Json(new { exito = true, persona }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message },
                            JsonRequestBehavior.AllowGet);
            }
        }

        [ValidarPermisos(NombrePermiso = "Registrar Persona")]
        public ActionResult RegistrarPersona()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Registrar Persona")]
        public JsonResult Registrar(CM_Persona modelo)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool exito = new CN_Persona().Registrar(modelo, oUsuario.id_usuario_admin, out string Mensaje);

                return Json(new { exito, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [ValidarPermisos(NombrePermiso = "Editar Persona")]
        public ActionResult EditarPersona()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Editar Persona")]
        public JsonResult Editar(CM_Persona modelo)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool exito = new CN_Persona().Editar(modelo, oUsuario.id_usuario_admin, out string Mensaje);

                return Json(new { exito, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }

        [ValidarPermisos(NombrePermiso = "Eliminar Persona")]
        public ActionResult EliminarPersona()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Eliminar Persona")]
        public JsonResult CambiarEstado(int id)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool exito = new CN_Persona().CambiarEstado(id, oUsuario.id_usuario_admin, out string Mensaje);

                return Json(new { exito, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }
    }
}