using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Rol
    {
        /*CREATE TABLE rol 
            (
             id_rol INTEGER NOT NULL IDENTITY(1,1), 
             nombre VARCHAR (150) NOT NULL , 
             descripcion VARCHAR (250) , 
             estado BIT NOT NULL 
            )
        GO*/
        public int id_rol { get; set; }
        public string nombre { get; set; }
        public  string descripcion { get; set; }
        public bool estado { get; set; } 
    }
}
