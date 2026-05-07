using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Bitacora
    {
        public int id_bitacora { get; set; }
        public string accion { get; set; }
        public DateTime fecha { get; set; }
        public DateTime hora { get; set; }
        public int usuario_admin_id_usuario_admin { get; set; }
    }
}
