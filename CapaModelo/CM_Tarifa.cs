using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Tarifa
    {
        /*CREATE TABLE tarifa 
            (
             id_tarifa INTEGER NOT NULL IDENTITY(1,1), 
             consumo_minimo_m3 INTEGER , 
             monto_minimo DECIMAL (30,3) NOT NULL , 
             precio_m3 INTEGER NOT NULL , 
             rol_socio_id_rol_socio INTEGER NOT NULL 
            )
        GO*/
        public int id_tarifa { get; set; }
        public int consumo_minimo_m3 { get; set; }
        public decimal monto_minimo { get; set; }
        public int precio_m3 { get; set; }   
        public int rol_socio_id_rol_socio { get; set; }
        public CM_RolSocio rol_socio { get; set; }
    }
}
