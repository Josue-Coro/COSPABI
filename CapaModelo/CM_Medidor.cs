using System;
using System.Collections.Generic;

namespace CapaModelo
{
    public class CM_Medidor
    {
        public int id_medidor { get; set; }
        public string serie { get; set; }
        public int numero { get; set; }
        public DateTime? fecha_instalacion { get; set; }

        // Campos del JOIN con socio
        public string nombre_socio { get; set; }
        public int? codigo_fijo { get; set; }

        public class CM_MedidorListado
        {
            public int               TotalRegistros { get; set; }
            public List<CM_Medidor>  Medidores      { get; set; }
        }
    }
}