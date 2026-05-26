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
    public class CD_Bitacora
    {
        
        public bool Registrar(string accion, int idUsuario)
        {
            try
            {
                using (SqlConnection oConexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_bitacora", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Accion", accion);
                    cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    return true;
                }
            }
            catch
            {
                return false;
            }
        }
        public List<CM_Bitacora> Listar(DateTime? fechaInicio, DateTime? fechaFin, int? idUsuario)
        {
            List<CM_Bitacora> lista = new List<CM_Bitacora>();
            try
            {
                using (SqlConnection con = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_bitacora", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@fecha_inicio",
                        fechaInicio.HasValue ? (object)fechaInicio.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@fecha_fin",
                        fechaFin.HasValue ? (object)fechaFin.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@id_usuario",
                        idUsuario.HasValue && idUsuario.Value > 0
                            ? (object)idUsuario.Value : DBNull.Value);

                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_Bitacora()
                            {
                                id_bitacora = Convert.ToInt32(dr["id_bitacora"]),
                                accion = dr["accion"].ToString(),
                                fecha = Convert.ToDateTime(dr["fecha"]),
                                hora = Convert.ToDateTime(dr["hora"]),
                                id_usuario = Convert.ToInt32(dr["usuario_admin_id_usuario_admin"]),
                                nombre_completo = dr["nombre_completo"].ToString(),
                                usuario = dr["usuario"].ToString()
                            });
                        }
                    }
                }
            }
            catch { lista = new List<CM_Bitacora>(); }
            return lista;
        }
    }
}
