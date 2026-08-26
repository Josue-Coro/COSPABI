using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Usuario
    {
        public int id_usuario_admin { get; set; }
        public string nombre { get; set; } = string.Empty;
        public string apellido { get; set; } = string.Empty;
        public string usuario { get; set; } = string.Empty;
        public string contraseña { get; set; } = string.Empty;
        public bool estado { get; set; }
        public DateTime fecha_creacion { get; set; }
        public int rol_id_rol { get; set; }
        public CM_Rol rol { get; set; }
    }
}
