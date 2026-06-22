using System;
using System.Collections.Generic;

namespace CapaModelo
{
    public class CM_CargoExtra
    {
        public int      id_carga_extra      { get; set; }
        public decimal  monto               { get; set; }
        public string   descripcion         { get; set; }
        public DateTime fecha_registro      { get; set; }
        public string   estado              { get; set; }
        public int      tipo_cargo_id_tipo  { get; set; }
        public int      socio_id_socio      { get; set; }
        public int      periodo_id_periodo  { get; set; }

        // Display (JOINs en SPs)
        public string nombre_socio      { get; set; }
        public int    codigo_fijo       { get; set; }
        public string nombre_periodo    { get; set; }
        public string nombre_tipo_cargo { get; set; }
        public string nombre_ruta       { get; set; }
        public bool   aplicado          { get; set; }

        public class CM_CargoExtraListado
        {
            public int                  TotalRegistros { get; set; }
            public List<CM_CargoExtra>  Cargos         { get; set; }
        }
    }
}
