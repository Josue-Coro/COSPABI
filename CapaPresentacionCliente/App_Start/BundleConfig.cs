using System;
using System.IO;
using System.Web;
using System.Web.Optimization;

namespace CapaPresentacionCliente
{
    public class BundleConfig
    {
        // Para obtener más información sobre las uniones, visite https://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            // Utilice la versión de desarrollo de Modernizr para desarrollar y obtener información sobre los formularios.  De esta manera estará
            // para la producción, use la herramienta de compilación disponible en https://modernizr.com para seleccionar solo las pruebas que necesite.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new Bundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap.css",
                      "~/Content/site.css"));
        }
    }

    /// <summary>
    /// Versionado de los archivos estaticos del portal.
    /// </summary>
    /// <remarks>
    /// Content/app.css se regenera cada vez que se corre `npm run build:css`, pero
    /// la URL no cambia: el navegador se queda con la copia vieja y la pagina sale
    /// a medio maquetar (se ven los colores y la tipografia, que ya estaban en la
    /// version cacheada, pero faltan las utilidades nuevas). Colgando la fecha de
    /// modificacion del archivo como querystring, cada recompilacion produce una
    /// URL distinta y el navegador vuelve a bajarlo solo.
    ///
    /// No se cachea el resultado a proposito: editar un .css no reinicia el
    /// AppDomain, asi que un valor memorizado no se enteraria del cambio.
    /// </remarks>
    public static class Recursos
    {
        public static string Version(string rutaVirtual)
        {
            try
            {
                string fisica = HttpContext.Current.Server.MapPath(rutaVirtual);
                return File.GetLastWriteTimeUtc(fisica).Ticks.ToString();
            }
            catch (Exception)
            {
                // Si el archivo no esta donde se espera, no vale la pena tumbar la
                // pagina por esto: se sirve sin version.
                return "0";
            }
        }

        public static string AppCss()
        {
            return Version("~/Content/app.css");
        }
    }
}
