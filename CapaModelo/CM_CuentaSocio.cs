using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_CuentaSocio
    {
        public int id_cuenta_socio { get; set; }
        public string usuario { get; set; }
        public string contrasena { get; set; }
        public DateTime ultimo_acceso { get; set; }
        public bool estado { get; set; }

        public int socio_id_socio { get; set; }
        public CM_Socio socio { get; set; }

        // Propiedades auxiliares para listar
        public string nombre_socio { get; set; }
    }

    public class CM_CuentaSocio_Paginado
    {
        public int TotalRegistros { get; set; }
        public List<CM_CuentaSocio> Cuentas { get; set; }
    }
}
