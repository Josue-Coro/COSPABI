using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_CargoExtra
    {
        /*CREATE TABLE cargo_extra 
            (
             id_carga_extra INTEGER NOT NULL IDENTITY(1,1), 
             monto DECIMAL (30,2) NOT NULL , 
             descripcion VARCHAR (150) NOT NULL , 
             fecha_registro DATE NOT NULL , 
             estado VARCHAR (150) NOT NULL , 
             tipo_cargo_id_tipo INTEGER NOT NULL , 
             socio_id_socio INTEGER NOT NULL , 
             periodo_id_periodo INTEGER NOT NULL 
            )
        GO

        ALTER TABLE cargo_extra ADD CONSTRAINT cargo_extra_PK PRIMARY KEY CLUSTERED (id_carga_extra)
             WITH (
             ALLOW_PAGE_LOCKS = ON , 
             ALLOW_ROW_LOCKS = ON )
        GO
        */
        public int id_carga_extra { get; set; }
        public decimal monto { get; set; }
        public string descripcion { get; set; }
        public DateTime fecha_registro { get; set; } 
        public bool estado { get; set; }
        public int tipo_cargo_id_tipo { get; set; }
        public CM_TipoCargo tipo_cargo { get; set; }
        public int socio_id_socio { get; set; }
        public CM_Socio socio { get; set; }
        public int periodo_id_periodo { get; set; }
        public CM_Periodo periodo { get; set; }
    }
}
