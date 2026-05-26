using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDato
{
    public class CD_RolSocio
    {
        public List<CM_RolSocio> Listar()
        {
            List<CM_RolSocio> lista = new List<CM_RolSocio>();
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_roles_socio", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_RolSocio()
                            {
                                id_rol_socio = Convert.ToInt32(dr["id_rol_socio"]),
                                rol_socio = dr["rol_socio"].ToString()
                            });
                        }
                    }
                }
            }
            catch
            {
                lista = new List<CM_RolSocio>();
            }
            return lista;
        }

    }
}
