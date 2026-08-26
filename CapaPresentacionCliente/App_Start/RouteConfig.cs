using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace CapaPresentacionCliente
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            // La raiz del sitio es la portada publica de la cooperativa.
            // Home/Bienvenida es [AllowAnonymous] y redirige al panel si el
            // socio ya tiene sesion; el login sigue en ~/Login/Login (es el
            // loginUrl del Web.config).
            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Bienvenida", id = UrlParameter.Optional }
            );
        }
    }
}
