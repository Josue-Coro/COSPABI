using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Permiso
    {
        // Todos los permisos del sistema
        public List<CM_Permiso> ListarTodos()
        {
            List<CM_Permiso> lista = new List<CM_Permiso>();
            try
            {
                using (SqlConnection con = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_permisos", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_Permiso()
                            {
                                id_permiso = Convert.ToInt32(dr["id_permiso"]),
                                accion = dr["accion"].ToString(),
                                descripcion = dr["descripcion"].ToString()
                            });
                        }
                    }
                }
            }
            catch { lista = new List<CM_Permiso>(); }
            return lista;
        }

        // Permisos que ya tiene un rol (para marcar checkboxes)
        public List<CM_Permiso> ListarPorRol(int id_rol)
        {
            List<CM_Permiso> lista = new List<CM_Permiso>();
            try
            {
                using (SqlConnection con = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_permisos_por_rol", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_rol", id_rol);
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_Permiso()
                            {
                                id_permiso = Convert.ToInt32(dr["id_permiso"]),
                                accion = dr["accion"].ToString(),
                                descripcion = dr["descripcion"].ToString()
                            });
                        }
                    }
                }
            }
            catch { lista = new List<CM_Permiso>(); }
            return lista;
        }

        // Guarda el estado completo de permisos para un rol (sync)
        public int GuardarPermisosRol(int id_rol, List<int> idsPermisos,
                                       int idUsuarioSesion, out string Mensaje)
        {
            int resultado = 0;
            Mensaje = string.Empty;
            try
            {
                // Construir el TVP como DataTable
                DataTable tvp = new DataTable();
                tvp.Columns.Add("id_permiso", typeof(int));
                foreach (int id in idsPermisos)
                    tvp.Rows.Add(id);

                using (SqlConnection con = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_guardar_permisos_rol", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_rol", id_rol);

                        SqlParameter pTvp = cmd.Parameters.AddWithValue("@TVP_Permisos", tvp);
                        pTvp.SqlDbType = SqlDbType.Structured;
                        pTvp.TypeName = "dbo.TVP_IdsPermisos";

                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                        con.Open();
                        cmd.ExecuteNonQuery();

                        resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                        Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                resultado = 0;
                Mensaje = ex.Message;
            }
            return resultado;
        }
    }
}