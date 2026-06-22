using CapaDato;
using CapaModelo;

namespace CapaNegocio
{
    public class CN_Dashboard
    {
        private readonly CD_Dashboard cdDashboard = new CD_Dashboard();

        public CM_Dashboard ObtenerEstadisticas(string periodo)
        {
            return cdDashboard.ObtenerEstadisticas(periodo);
        }
    }
}
