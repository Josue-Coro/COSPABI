using CapaModelo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace CapaPresentacionAdmin.Filtros
{
    public class ValidarPermisosAttribute : ActionFilterAttribute
    {
        public string NombrePermiso { get; set; }

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            // 1. Obtener el objeto de usuario de la sesión
            CM_Usuario_Activo oUsuario = (CM_Usuario_Activo)HttpContext.Current.Session["Usuario"];

            // 2. Verificar si el usuario y la lista de permisos existen
            if (oUsuario != null && oUsuario.ListaPermisos != null)
            {
                // 3. Verificar si el usuario tiene el permiso requerido
                // Buscamos si existe alguna acción en su lista de permisos que coincida con NombrePermiso.
                bool tienePermiso = oUsuario.ListaPermisos
                                        .Any(p => p.accion.ToUpper() == NombrePermiso.ToUpper());

                if (!tienePermiso)
                {
                    // 4. Si NO tiene permiso, redirigir a la vista de Acceso Denegado
                    filterContext.Result = new RedirectToRouteResult(
                        new RouteValueDictionary
                        {
                            { "controller", "Login" },
                            { "action", "AccesoDenegado" }
                        });
                }
            }
            else
            {
                // Si la sesión expiró o no existe el objeto Usuario, redirigir al Login.
                filterContext.Result = new RedirectToRouteResult(
                    new RouteValueDictionary
                    {
                        { "controller", "Login" },
                        { "action", "Login" }
                    });
            }

            base.OnActionExecuting(filterContext);
        }
    }
}