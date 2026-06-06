using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class CM_Periodo
    {
        /*CREATE TABLE periodo 
            (
             id_periodo INTEGER NOT NULL IDENTITY(1,1), 
             periodo VARCHAR (50) NOT NULL 
            )
        GO

        ALTER TABLE periodo ADD CONSTRAINT periodo_PK PRIMARY KEY CLUSTERED (id_periodo)
             WITH (
             ALLOW_PAGE_LOCKS = ON , 
             ALLOW_ROW_LOCKS = ON )
        GO*/
        public int id_periodo { get; set; }
        public string periodo { get; set; }
    }
}
