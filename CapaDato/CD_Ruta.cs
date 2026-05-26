using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Ruta
    {
        public List<CM_Ruta> Listar()
        {
            List<CM_Ruta> lista = new List<CM_Ruta>();
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_rutas", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_Ruta()
                            {
                                id_ruta = Convert.ToInt32(dr["id_ruta"]),
                                ruta = Convert.ToInt32(dr["ruta"]),
                                descripcion = dr["descripcion"].ToString()
                            });
                        }
                    }
                }
            }
            catch
            {
                lista = new List<CM_Ruta>();
            }
            return lista;
        }

        public int Registrar(CM_Ruta obj, int idUsuario, out string Mensaje)
        {
            int idGenerado = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_crear_ruta", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@ruta", obj.ruta);
                        cmd.Parameters.AddWithValue("@descripcion", obj.descripcion);
                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                        conexion.Open();
                        cmd.ExecuteNonQuery();

                        idGenerado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                        Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                idGenerado = 0;
                Mensaje = ex.Message;
            }
            return idGenerado;
        }

        public bool Editar(CM_Ruta obj, int idUsuario, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_editar_ruta", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_ruta", obj.id_ruta);
                        cmd.Parameters.AddWithValue("@ruta", obj.ruta);
                        cmd.Parameters.AddWithValue("@descripcion", obj.descripcion);
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