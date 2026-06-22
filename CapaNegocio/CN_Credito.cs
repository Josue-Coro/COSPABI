using CapaDato;
using CapaModelo;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Credito
    {
        private readonly CD_Credito cdCredito = new CD_Credito();

        public decimal ObtenerCostoVigente()
        {
            return cdCredito.ObtenerCostoVigente();
        }

        public CM_CreditoListado ListarPendientes(string busqueda, int pagina, int tamanoPagina)
        {
            return cdCredito.ListarPendientes(busqueda, pagina, tamanoPagina);
        }

        public List<CM_Credito> ObtenerDetalle(int idSocio)
        {
            return cdCredito.ObtenerDetalle(idSocio);
        }
    }
}
