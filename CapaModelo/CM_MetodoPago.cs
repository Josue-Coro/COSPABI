using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_MetodoPago
    {
        public int id_metodo_pago { get; set; }
        public string metodo { get; set; }
        public string referencia { get; set; }
    }

    public class CM_MetodoPago_Paginado
    {
        public int TotalRegistros { get; set; }
        public List<CM_MetodoPago> Metodos { get; set; }
    }
}
