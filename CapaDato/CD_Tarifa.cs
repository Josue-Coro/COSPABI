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
    public class CD_Tarifa
    {
        public List<CM_Tarifa> Listar()
        {
            List<CM_Tarifa> lista = new List<CM_Tarifa>();
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_tarifa", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_Tarifa()
                            {
                                id_tarifa = Convert.ToInt32(dr["id_tarifa"]),
                                consumo_minimo_m3 = Convert.ToInt32(dr["consumo_minimo_m3"]),
                                monto_minimo = Convert.ToDecimal(dr["monto_minimo"]),
                                precio_m3 = Convert.ToInt32(dr["precio_m3"]),
                                rol_socio_id_rol_socio = Convert.ToInt32(dr["rol_socio_id_rol_socio"]),
                                rol_socio = new CM_RolSocio()
                                {
                                    rol_socio = dr["nombre_rol"].ToString()
                                }
                            });
                        }
                    }
                }
            }
            catch
            {
                lista = new List<CM_Tarifa>();
            }
            return lista;
        }

        public bool Editar(CM_Tarifa obj, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_editar_tarifa", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_tarifa", obj.id_tarifa);
                        cmd.Parameters.AddWithValue("@consumo_minimo_m3", obj.consumo_minimo_m3);
                        cmd.Parameters.AddWithValue("@monto_minimo", obj.monto_minimo);
                        cmd.Parameters.AddWithValue("@precio_m3", obj.precio_m3);
                        cmd.Parameters.AddWithValue("@rol_socio_id_rol_socio", obj.rol_socio_id_rol_socio);
                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                        conexion.Open();
                        cmd.ExecuteNonQuery();

                        resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                        Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }
            return resultado;
        }
    }
}
