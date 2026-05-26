using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Medidor
    {
        public (List<CM_Medidor> lista, int totalRegistros) Listar(
            string busqueda, int pagina, int tamanoPagina)
        {
            List<CM_Medidor> lista = new List<CM_Medidor>();
            int totalRegistros = 0;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_listar_medidores", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Busqueda", busqueda ?? "");
                        cmd.Parameters.AddWithValue("@Pagina", pagina);
                        cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);

                        conexion.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            // Primer SELECT: total
                            if (dr.Read())
                                totalRegistros = Convert.ToInt32(dr["TotalRegistros"]);

                            // Segundo SELECT: datos
                            if (dr.NextResult())
                            {
                                while (dr.Read())
                                {
                                    lista.Add(new CM_Medidor()
                                    {
                                        id_medidor = Convert.ToInt32(dr["id_medidor"]),
                                        serie = dr["serie"].ToString(),
                                        numero = Convert.ToInt32(dr["numero"]),
                                        fecha_instalacion = dr["fecha_instalacion"] == DBNull.Value
                                                            ? (DateTime?)null
                                                            : Convert.ToDateTime(dr["fecha_instalacion"]),
                                        nombre_socio = dr["nombre_socio"] == DBNull.Value
                                                            ? null
                                                            : dr["nombre_socio"].ToString(),
                                        codigo_fijo = dr["codigo_fijo"] == DBNull.Value
                                                            ? (int?)null
                                                            : Convert.ToInt32(dr["codigo_fijo"])
                                    });
                                }
                            }
                        }
                    }
                }
            }
            catch
            {
                lista = new List<CM_Medidor>();
                totalRegistros = 0;
            }
            return (lista, totalRegistros);
        }

        public int Registrar(CM_Medidor obj, int idUsuario, out string Mensaje)
        {
            int idGenerado = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_crear_medidor", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@serie", obj.serie);
                        cmd.Parameters.AddWithValue("@numero", obj.numero);
                        cmd.Parameters.AddWithValue("@fecha_instalacion",
                            obj.fecha_instalacion.HasValue
                                ? (object)obj.fecha_instalacion.Value
                                : DBNull.Value);
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

        public bool Editar(CM_Medidor obj, int idUsuario, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_editar_medidor", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_medidor", obj.id_medidor);
                        cmd.Parameters.AddWithValue("@serie", obj.serie);
                        cmd.Parameters.AddWithValue("@numero", obj.numero);
                        cmd.Parameters.AddWithValue("@fecha_instalacion",
                            obj.fecha_instalacion.HasValue
                                ? (object)obj.fecha_instalacion.Value
                                : DBNull.Value);
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