using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_RolSocio
    {
        /*CREATE TABLE rol_socio 
            (
             id_rol_socio INTEGER NOT NULL IDENTITY(1,1), 
             rol_socio VARCHAR (150) NOT NULL 
            )
        GO*/
        public int id_rol_socio { get; set; }
        public string rol_socio { get; set; }
    }
}
