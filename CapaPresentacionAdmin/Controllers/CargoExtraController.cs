using CapaModelo;
using CapaNegocio;
using CapaPresentacionAdmin.Filtros;
using System;
using System.Collections.Generic;
using System.Web.Mvc;
using static CapaModelo.CM_CargoExtra;

namespace CapaPresentacionAdmin.Controllers
{
    [Authorize]
    public class CargoExtraController : Controller
    {
        private readonly CN_CargoExtra cnCargoExtra = new CN_CargoExtra();

        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public ActionResult CargoExtra()
        {
            return View();
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult ListarPeriodos()
        {
            var lista = new CN_Lectura().ListarPeriodosAutomaticos();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult ObtenerPeriodoActual()
        {
            var periodo = new CN_Lectura().ObtenerPeriodoActual();
            return Json(new { data = periodo }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult ListarRutas()
        {
            var lista = new CN_Ruta().Listar();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult ListarTiposCargo()
        {
            var todos   = new CN_TipoCargo().Listar();
            var activos = todos.FindAll(t => t.estado == true);
            return Json(new { data = activos }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult VerificarAvisoExistente(int idSocio, int idPeriodo)
        {
            bool existe = new CN_Aviso().ExisteAvisoActivo(idSocio, idPeriodo);
            return Json(new { existe }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult BuscarSocios(string busqueda = "")
        {
            var lista = cnCargoExtra.BuscarSocios(busqueda);
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateInput(false)]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult RegistrarCargoExtra(int idPeriodo, int idSocio, int idTipoCargo,
                                              string monto, string descripcion)
        {
            try
            {
                decimal montoDecimal;
                if (!decimal.TryParse(monto, System.Globalization.NumberStyles.Any,
                                      System.Globalization.CultureInfo.InvariantCulture,
                                      out montoDecimal) || montoDecimal <= 0)
                {
                    return Json(new { exito = false, id = 0, mensaje = "El monto debe ser un número mayor a 0." });
                }
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                var obj = new CM_CargoExtra
                {
                    periodo_id_periodo = idPeriodo,
                    socio_id_socio     = idSocio,
                    tipo_cargo_id_tipo = idTipoCargo,
                    monto              = montoDecimal,
                    descripcion        = descripcion ?? ""
                };
                int id = cnCargoExtra.Registrar(obj, oUsuario.id_usuario_admin, out string Mensaje);
                return Json(new { exito = id > 0, id, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, id = 0, mensaje = ex.Message });
            }
        }

        [HttpPost]
        [ValidateInput(false)]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult RegistrarCargosExtra(int idPeriodo, int idSocio, List<CM_CargoExtra> cargos)
        {
            try
            {
                if (cargos == null || cargos.Count == 0)
                    return Json(new { exito = false, registrados = 0, mensaje = "Agrega al menos un cargo a la lista." });

                // Regla de negocio: los cargos extra solo se registran en el período actual
                var periodoActual = new CN_Lectura().ObtenerPeriodoActual();
                if (periodoActual == null || idPeriodo != periodoActual.id_periodo)
                    return Json(new { exito = false, registrados = 0, mensaje = "Solo se pueden registrar cargos en el período actual." });

                // Validación: no permitir el mismo tipo de cargo dos veces en el lote
                var tiposVistos = new HashSet<int>();
                foreach (var c in cargos)
                {
                    if (!tiposVistos.Add(c.tipo_cargo_id_tipo))
                        return Json(new { exito = false, registrados = 0, mensaje = "No puedes registrar el mismo tipo de cargo dos veces." });
                }

                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                int registrados = 0;
                var errores = new List<string>();

                foreach (var c in cargos)
                {
                    c.periodo_id_periodo = idPeriodo;
                    c.socio_id_socio     = idSocio;
                    int id = cnCargoExtra.Registrar(c, oUsuario.id_usuario_admin, out string msg);
                    if (id > 0) registrados++;
                    else        errores.Add((string.IsNullOrEmpty(c.descripcion) ? "Cargo" : c.descripcion) + ": " + msg);
                }

                string mensaje;
                if (registrados == cargos.Count)
                    mensaje = registrados + " cargo(s) registrado(s) correctamente.";
                else if (registrados > 0)
                    mensaje = registrados + " registrado(s), " + errores.Count + " omitido(s). " + string.Join(" | ", errores);
                else
                    mensaje = "No se registró ningún cargo. " + string.Join(" | ", errores);

                return Json(new { exito = registrados > 0, registrados, fallidos = errores.Count, mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, registrados = 0, mensaje = ex.Message });
            }
        }

        [HttpGet]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult ListarCargosExtra(int? idPeriodo, int? idRuta,
                                            string busqueda = "", int pagina = 1, int tamanoPagina = 10)
        {
            try
            {
                var resultado = cnCargoExtra.Listar(idPeriodo, idRuta, busqueda, pagina, tamanoPagina);
                if (resultado == null)
                    return Json(new { exito = false, mensaje = "Error al obtener los cargos." }, JsonRequestBehavior.AllowGet);
                return Json(new { exito = true, cargos = resultado.Cargos, totalRegistros = resultado.TotalRegistros }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        [ValidarPermisos(NombrePermiso = "Gestionar Cargo Extra")]
        public JsonResult AnularCargoExtra(int idCargo)
        {
            try
            {
                var oUsuario = (CM_Usuario_Activo)Session["Usuario"];
                bool ok = cnCargoExtra.Anular(idCargo, oUsuario.id_usuario_admin, out string Mensaje);
                return Json(new { exito = ok, mensaje = Mensaje });
            }
            catch (Exception ex)
            {
                return Json(new { exito = false, mensaje = ex.Message });
            }
        }
    }
}
