using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Usuario_Activo
    {
        public int id_usuario_admin { get; set; }
        public string nombre { get; set; } 
        public string apellido { get; set; } 
        public string usuario { get; set; } 
        public string contraseña { get; set; } 
        public bool estado { get; set; }
        public DateTime fecha_creacion { get; set; }
        public int rol_id_dol { get; set; }
        public CM_Rol rol { get; set; }
        public string nombre_rol { get; set; } 
        public string descripcion_rol { get; set; } 
        public bool EstadoRol { get; set; }
        public List<CM_Permiso> ListaPermisos { get; set; } 


    }
}
