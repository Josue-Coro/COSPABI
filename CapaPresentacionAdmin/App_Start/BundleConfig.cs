using System.Web;
using System.Web.Optimization;

namespace CapaPresentacionAdmin
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
    /// Versionado de Content/app.css: se regenera con `npm run build:css` pero la
    /// URL no cambia, asi que el navegador se queda con la copia vieja y la pagina
    /// sale a medio maquetar. Colgando la fecha de modificacion como querystring
    /// cada recompilacion produce una URL nueva. No se cachea el resultado a
    /// proposito: editar un .css no reinicia el AppDomain.
    /// </summary>
    public static class Recursos
    {
        public static string Version(string rutaVirtual)
        {
            try
            {
                string fisica = HttpContext.Current.Server.MapPath(rutaVirtual);
                return System.IO.File.GetLastWriteTimeUtc(fisica).Ticks.ToString();
            }
            catch (System.Exception)
            {
                return "0";
            }
        }

        public static string AppCss()
        {
            return Version("~/Content/app.css");
        }
    }
}
