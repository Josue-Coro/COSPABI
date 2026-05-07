using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Data;



namespace CapaDato
{
    public class CD_Conexion
    {
        
         public static string cn = ConfigurationManager.ConnectionStrings["cadena"].ToString();
        
    }
}
