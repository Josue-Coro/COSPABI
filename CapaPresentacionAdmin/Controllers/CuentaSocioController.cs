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
    public class CuentaSocioController : Controller
    {
        private readonly CN_CuentaSocio cnCuentaSocio = new CN_CuentaSocio();
        private readonly CN_Socio cnSocio = new CN_Socio();

        [ValidarPermisos(NombrePermiso = "Gestionar Cuenta Socio")]
        public ActionResult CuentaSocio()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cuenta Socio")]
        public JsonResult Listar(string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            var resultado = cnCuentaSocio.Listar(busqueda, pagina, tamanoPagina);
            if (resultado != null)
            {
                return Json(new { exito = true, cuentas = resultado.Cuentas, totalRegistros = resultado.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { exito = false, mensaje = "Error al listar cuentas de socio" }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cuenta Socio")]
        public JsonResult ListarSocios(string busqueda = "", int pagina = 1, int tamanoPagina = 8)
        {
            var resultado = cnSocio.Listar(busqueda, pagina, tamanoPagina);
            if (resultado != null)
            {
                return Json(new { exito = true, socios = resultado.Socios, totalRegistros = resultado.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { exito = false, mensaje = "Error al listar socios" }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cuenta Socio")]
        public JsonResult ObtenerCuenta(int id)
        {
            var cuenta = cnCuentaSocio.Obtener(id);
            if (cuenta == null)
                return Json(new { exito = false, mensaje = "Cuenta no encontrada." }, JsonRequestBehavior.AllowGet);

            var socio = cnSocio.Obtener(cuenta.socio_id_socio);
            return Json(new
            {
                exito = true,
                cuenta = new
                {
                    cuenta.id_cuenta_socio,
                    cuenta.usuario,
                    cuenta.socio_id_socio,
                    nombre_socio = socio != null ? socio.nombre_socio : ""
                }
            }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Cuenta Socio")]
        public JsonResult Guardar(CM_CuentaSocio obj)
        {
            string mensaje = string.Empty;
            bool resultado = false;
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            int idUsuario = oUsuario?.id_usuario_admin ?? 0;

            if (obj.id_cuenta_socio == 0)
            {
                resultado = cnCuentaSocio.Registrar(obj, idUsuario, out mensaje);
            }
            else
            {
                resultado = cnCuentaSocio.Editar(obj, idUsuario, out mensaje);
            }

            return Json(new { exito = resultado, mensaje = mensaje });
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Cuenta Socio")]
        public JsonResult CambiarEstado(int id)
        {
            string mensaje = string.Empty;
            var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
            int idUsuario = oUsuario?.id_usuario_admin ?? 0;

            bool resultado = cnCuentaSocio.CambiarEstado(id, idUsuario, out mensaje);
            return Json(new { exito = resultado, mensaje = mensaje });
        }
    }
}