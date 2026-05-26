using CapaDato;
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
    public class SocioController : Controller
    {
        // GET: Socio
        [ValidarPermisos(NombrePermiso = "Gestionar Socio")]
        public ActionResult Socio()
        {
            return View();
        }
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Socio")]
        public JsonResult ListarRolSocio()
        {
            
            List<CM_RolSocio> lista = new CN_RolSocio().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Socio")]
        public JsonResult Listar(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = new CN_Socio().Listar(busqueda, pagina, tamanoPagina);

                if (resultado == null)
                    return Json(new { exito = false, mensaje = "Error al obtener los datos." },
                                JsonRequestBehavior.AllowGet);

                return Json(new
                {
                    exito = true,
                    totalRegistros = resultado.TotalRegistros,
                    socios = resultado.Socios
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message },
                            JsonRequestBehavior.AllowGet);
            }
        }


        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Socio")]
        public JsonResult ListarCliente(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = new CD_Cliente().Listar(busqueda, pagina, tamanoPagina);

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
        [ValidarPermisos(NombrePermiso = "Gestionar Socio")]
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


        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Socio")]
        public JsonResult ListarRutas()
        {
            List<CM_Ruta> lista = new CN_Ruta().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }



        [ValidarPermisos(NombrePermiso = "Registrar Socio")]
        public ActionResult CrearSocio()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Registrar Socio")]
        public JsonResult Registrar(CM_Socio socio)
        {
            int idUsuario = Convert.ToInt32(Session["id_usuario_admin"]);
            int idGenerado = new CN_Socio().Registrar(socio, idUsuario, out string Mensaje);
            return Json(new { exito = idGenerado > 0, mensaje = Mensaje });
        }




        [ValidarPermisos(NombrePermiso = "Editar Socio")]
        public ActionResult EditarSocio()
        {
            return View();
        }


        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Editar Socio")]
        public JsonResult Editar(CM_Socio socio)
        {
            int idUsuario = Convert.ToInt32(Session["id_usuario_admin"]);
            bool resultado = new CN_Socio().Editar(socio, idUsuario, out string Mensaje);
            return Json(new { exito = resultado, mensaje = Mensaje });
        }



        [ValidarPermisos(NombrePermiso = "Eliminar Socio")]
        public ActionResult EliminarSocio()
        {
            return View();
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Eliminar Socio")]
        public JsonResult Eliminar(int id)
        {
            int idUsuario = Convert.ToInt32(Session["id_usuario_admin"]);
            bool resultado = new CN_Socio().Eliminar(id, idUsuario, out string Mensaje);
            return Json(new { exito = resultado, mensaje = Mensaje });
        }
    }
}