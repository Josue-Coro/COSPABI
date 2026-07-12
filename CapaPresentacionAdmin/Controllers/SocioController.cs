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
        // Personas disponibles para el alta de socio: excluye a quienes ya tienen 4 socios (regla institucional)
        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Socio")]
        public JsonResult ListarPersonasDisponibles(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = new CN_Cliente().ListarDisponiblesParaSocio(busqueda, pagina, tamanoPagina);

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
        public JsonResult Obtener(int id)
        {
            try
            {
                var socio = new CN_Socio().Obtener(id);

                if (socio == null)
                    return Json(new { exito = false, mensaje = "Socio no encontrado." },
                                JsonRequestBehavior.AllowGet);

                return Json(new { exito = true, socio }, JsonRequestBehavior.AllowGet);
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
            var resultado = new CN_Medidor().ListarRegistrar(busqueda, pagina, tamanoPagina);
            return Json(new
            {
                data           = resultado.Medidores,
                totalRegistros = resultado.TotalRegistros,
                totalPaginas   = (int)Math.Ceiling((double)resultado.TotalRegistros / tamanoPagina),
                paginaActual   = pagina
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

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Registrar Socio")]
        public JsonResult DatosInscripcion()
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                decimal costo = new CN_Credito().ObtenerCostoVigente();
                var metodos = new CN_MetodoPago().Listar("", 1, 1000).Metodos;
                bool cajaAbierta = new CN_Caja().ObtenerCajaAbierta(oUsuario.id_usuario_admin) != null;
                return Json(new { exito = true, costo, metodos, cajaAbierta }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Registrar Socio")]
        public JsonResult Registrar(CM_Socio socio)
        {
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            var caja = new CN_Caja().ObtenerCajaAbierta(oUsuario.id_usuario_admin);
            if (caja == null)
                return Json(new { exito = false, mensaje = "Debe abrir su caja antes de registrar un socio (el pago de inscripción entra a caja)." });

            string cajero  = (oUsuario.nombre + " " + oUsuario.apellido).Trim();
            int idGenerado = new CN_Socio().Registrar(socio, oUsuario.id_usuario_admin, caja.id_caja, cajero, out string Mensaje, out int idPago);
            return Json(new { exito = idGenerado > 0, mensaje = Mensaje, idPago });
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
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            int idUsuario = oUsuario.id_usuario_admin;
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
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            int idUsuario = oUsuario.id_usuario_admin;
            bool resultado = new CN_Socio().Eliminar(id, idUsuario, out string Mensaje);
            return Json(new { exito = resultado, mensaje = Mensaje });
        }
    }
}