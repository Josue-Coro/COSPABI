using CapaModelo;
using System;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Dashboard
    {
        public CM_Dashboard ObtenerEstadisticas(string periodo)
        {
            var stats = new CM_Dashboard { Periodo = periodo };

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_estadisticas_dashboard", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@periodo", periodo);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        stats.TotalSocios    = Convert.ToInt32(dr["TotalSocios"]);
                        stats.TotalClientes  = Convert.ToInt32(dr["TotalClientes"]);
                        stats.TotalMedidores = Convert.ToInt32(dr["TotalMedidores"]);
                        stats.TotalRutas     = Convert.ToInt32(dr["TotalRutas"]);
                        stats.TotalUsuarios  = Convert.ToInt32(dr["TotalUsuarios"]);
                        stats.TotalLecturas  = Convert.ToInt32(dr["TotalLecturas"]);
                        stats.TotalAvisos    = Convert.ToInt32(dr["TotalAvisos"]);
                    }
                }
            }
            catch { }

            return stats;
        }
    }
}
