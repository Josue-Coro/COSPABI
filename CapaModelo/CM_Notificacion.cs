using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Notificacion
    {
        public int id_notificacion { get; set; }
        public string titulo { get; set; }
        public string mensaje { get; set; }
        public string tipo { get; set; }
        public DateTime fecha_publicacion { get; set; }
        public bool estado { get; set; }

        // Propiedades para asignacion de socios
        public bool enviar_a_todos { get; set; }
        public string ids_socios { get; set; }
    }

    public class CM_Notificacion_Paginado
    {
        public int TotalRegistros { get; set; }
        public List<CM_Notificacion> Notificaciones { get; set; }
    }

    public class CM_NotificacionSocioItem
    {
        public int id_notificacion_socio { get; set; }
        public int socio_id_socio { get; set; }
        public string nombre_socio { get; set; }
        public int codigo_fijo { get; set; }
    }
}

