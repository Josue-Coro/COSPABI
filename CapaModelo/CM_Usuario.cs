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

    /// <summary>Datos del propio usuario para la pantalla "Mi perfil" (sp_obtener_perfil_admin).</summary>
    public class CM_PerfilAdmin
    {
        public int id_usuario_admin { get; set; }
        public string nombre { get; set; } = string.Empty;
        public string apellido { get; set; } = string.Empty;
        public string usuario { get; set; } = string.Empty;
        public bool estado { get; set; }
        public DateTime fecha_creacion { get; set; }
        public string nombre_rol { get; set; } = string.Empty;
        public string descripcion_rol { get; set; } = string.Empty;
        public int cantidad_permisos { get; set; }
        public int acciones_bitacora { get; set; }
        public DateTime? ultimo_acceso { get; set; }
        public int cajas_abiertas_total { get; set; }
    }
}
