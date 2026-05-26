using System;

namespace CapaModelo
{
    public class CM_Medidor
    {
        /*CREATE TABLE medidor
            (
             id_medidor        INTEGER NOT NULL IDENTITY(1,1),
             serie             VARCHAR(150) NOT NULL,
             numero            INTEGER NOT NULL,
             fecha_instalacion DATE
            )*/
        public int id_medidor { get; set; }
        public string serie { get; set; }
        public int numero { get; set; }
        public DateTime? fecha_instalacion { get; set; }

        // Campos del JOIN con socio
        public string nombre_socio { get; set; }
        public int? codigo_fijo { get; set; }
    }
}