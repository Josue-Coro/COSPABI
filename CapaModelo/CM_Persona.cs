using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Cliente
    {
        public int id_cliente { get; set; }
        public string nombre_completo { get; set; }
        public string ci { get; set; }
        public string genero { get; set; }
        public int? telefono { get; set; }
        public string email { get; set; }
        public DateTime fecha_nacimiento { get; set; }
        public DateTime fecha_registro { get; set; }
        public bool estado { get; set; }
        public class CM_Cliente_Paginado
        {
            public int TotalRegistros { get; set; }
            public List<CM_Cliente> Clientes { get; set; }
        }
    }
}
