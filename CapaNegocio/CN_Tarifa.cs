using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CapaModelo;   
using CapaDato;
namespace CapaNegocio
{
    public class CN_Tarifa
    {
        private readonly CD_Tarifa cdTarifa = new CD_Tarifa();
        private readonly CN_Bitacora cdBitacora = new CN_Bitacora();

        public List<CM_Tarifa> Listar()
        {
            return cdTarifa.Listar();

        }
        public bool Editar(CM_Tarifa obj, int idUsuarioSesion, out string mensaje)
        {
            mensaje = string.Empty;

            if (obj.id_tarifa <= 0)
            {
                mensaje = "Tarifa no válida.";
                return false;
            }
            if (obj.consumo_minimo_m3 < 0)
            {
                mensaje = "Consumo mínimo no puede ser negativo.";
                return false;
            }
            if (obj.monto_minimo < 0)
            {
                mensaje = "Monto mínimo no puede ser negativo.";
                return false;
            }
            if (obj.precio_m3 < 0)
            {
                mensaje = "Precio por m3 no puede ser negativo.";
                return false;
            }


            bool resultado = cdTarifa.Editar(obj, idUsuarioSesion, out mensaje);

            if (resultado)
                cdBitacora.Registrar("Edición de la tarifa: " + obj.id_tarifa, idUsuarioSesion);

            return resultado;
        }
    }
}
