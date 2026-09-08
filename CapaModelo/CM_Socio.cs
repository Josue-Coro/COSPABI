using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public  class CM_Socio
    {
        public int id_socio { get; set; }
        public string nombre_socio { get; set; }

        // FK Persona (identidad: CI, nombre). Hasta 4 socios por persona.
        public int persona_id_persona { get; set; }
        public CM_Persona persona { get; set; }
        public string nombre_persona { get; set; }
        public string ci_persona { get; set; }
        // Correo del socio (quien usa el medidor): obligatorio, sin el no hay
        // cuenta de portal ni pago QR (la pasarela lo exige). Migracion 17.
        public string correo { get; set; }

        // FK RolSocio
        public int rol_socio_id_rol_socio { get; set; }
        public CM_RolSocio rol_socio { get; set; }
        public string NombreRolSocio { get; set; }

        // FK Medidor
        public int? medidor_id_medidor { get; set; }
        public CM_Medidor medidor { get; set; }
        public string num_serie_medidor { get; set; }

        // FK Ruta
        public int ruta_id_ruta { get; set; }
        public CM_Ruta ruta { get; set; }
        public string nombre_ruta { get; set; }

        // Campos propios
        public int ubicacion { get; set; }
        public int num_casa { get; set; }
        public int num_ocupantes { get; set; }
        public string tipo_instalacion { get; set; }
        public string dim_instalacion { get; set; }
        public string actividad { get; set; }
        public string categoria { get; set; }
        public DateTime fecha_registro { get; set; }
        public int codigo_fijo { get; set; }
        public bool estado { get; set; }

        // ── Inscripción (solo para el alta de socio; no son columnas de la tabla socio) ──
        public decimal monto_inicial  { get; set; }
        public int     num_cuotas     { get; set; }
        public int     id_metodo_pago { get; set; }

        public class CM_SocioListado
        {
            public int TotalRegistros { get; set; }
            public System.Collections.Generic.List<CM_Socio> Socios { get; set; }
        }
    }
}
