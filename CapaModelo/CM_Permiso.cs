using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Permiso
    {
        /*CREATE TABLE permiso 
            (
             id_permiso INTEGER NOT NULL IDENTITY(1,1), 
             accion VARCHAR (150) NOT NULL , 
             descripcion VARCHAR (150) 
            )
        GO*/
        public int id_permiso { get; set; }
        public string accion { get; set; }
        public string descripcion { get; set; }
    }
}
