using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    // Representa una lectura registrada (tabla lectura)
    public class CM_Lectura
    {
        public int id_lectura { get; set; }
        public DateTime fecha_lectura { get; set; }
        public int lectura_anterior { get; set; }
        public int lectura_actual { get; set; }
        public int dias_lectura { get; set; }
        public string observacion { get; set; }
        public decimal consumo_m3 { get; set; }

        // FKs
        public int usuario_admin_id_usuario_admin { get; set; }
        public int medidor_id_medidor { get; set; }
        public int periodo_id_periodo { get; set; }
        public int ruta_id_ruta { get; set; }

        // Campos de display (vienen de JOINs en los SPs)
        public string nombre_socio { get; set; }
        public int codigo_fijo { get; set; }
        public string serie_medidor { get; set; }
        public string nombre_periodo { get; set; }
        public string nombre_ruta { get; set; }
        public string nombre_usuario { get; set; }

        // Wrapper para listado paginado (historial)
        public class CM_LecturaListado
        {
            public int TotalRegistros { get; set; }
            public List<CM_Lectura> Lecturas { get; set; }
        }
    }

    // Representa un medidor en pantalla de registro de lecturas
    // (resultado de sp_listar_medidores_para_lectura)
    public class CM_MedidorParaLectura
    {
        public int id_medidor { get; set; }
        public string serie { get; set; }
        public int id_socio { get; set; }
        public string nombre_socio { get; set; }
        public int codigo_fijo { get; set; }

        // Lectura anterior (del último período registrado)
        public int lectura_anterior_valor { get; set; }
        public DateTime? fecha_ultima_lectura { get; set; }

        // Estado en el período actual
        public bool ya_leido { get; set; }
        public int? id_lectura_actual { get; set; }
        public int? lect_ant_registrada { get; set; }
        public int? lect_act_registrada { get; set; }
        public decimal? consumo_registrado { get; set; }
        public string observacion_registrada { get; set; }
        public int? dias_registrados { get; set; }
    }
}
