using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Usuario
    {
        /*CREATE TABLE usuario_admin 
            (
             id_usuario_admin INTEGER NOT NULL IDENTITY(1,1), 
             nombre VARCHAR (255) NOT NULL , 
             apellido VARCHAR (255) NOT NULL , 
             usuario VARCHAR (255) NOT NULL , 
             contraseña VARCHAR (550) NOT NULL , 
             estado BIT NOT NULL , 
             fecha_creacion DATE NOT NULL , 
             rol_id_rol INTEGER NOT NULL 
            )
        GO*/
        public int id_usuario_admin { get; set; }
        public string nombre { get; set; } = string.Empty;
        public string apellido { get; set; } = string.Empty;
        public string usuario { get; set; } = string.Empty;
        public string contraseña { get; set; } = string.Empty;
        public bool estado { get; set; }
        public DateTime fecha_creacion { get; set; }
        public int rol_id_dol { get; set; }
        public CM_Rol rol { get; set; }
    }
}
