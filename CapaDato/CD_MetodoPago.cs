using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_MetodoPago
    {
        public CM_MetodoPago_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_MetodoPago_Paginado
            {
                Metodos = new List<CM_MetodoPago>()
            };

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_metodo_pago", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Busqueda", busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                        resultado.TotalRegistros = Convert.ToInt32(dr["TotalRegistros"]);

                    if (dr.NextResult())
                    {
                        while (dr.Read())
                        {
                            resultado.Metodos.Add(new CM_MetodoPago
                            {
                                id_metodo_pago = Convert.ToInt32(dr["id_metodo_pago"]),
                                metodo = dr["metodo"].ToString(),
                                referencia = dr["referencia"].ToString()
                            });
                        }
                    }
                    dr.Close();
                }
            }
            catch
            {
                resultado = null;
            }

            return resultado;
        }

        public CM_MetodoPago Obtener(int idMetodoPago)
        {
            CM_MetodoPago metodoPago = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_metodo_pago", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdMetodoPago", idMetodoPago);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        metodoPago = new CM_MetodoPago
                        {
                            id_metodo_pago = Convert.ToInt32(dr["id_metodo_pago"]),
                            metodo = dr["metodo"].ToString(),
                            referencia = dr["referencia"].ToString()
                        };
                    }
                    dr.Close();
                }
            }
            catch
            {
                metodoPago = null;
            }
            return metodoPago;
        }

        public bool Registrar(CM_MetodoPago metodoPago, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_metodo_pago", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Metodo", metodoPago.metodo);
                    cmd.Parameters.AddWithValue("@Referencia", metodoPago.referencia);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        resultado = Convert.ToInt32(dr["Resultado"]) == 1;
                        Mensaje = dr["Mensaje"].ToString();
                    }
                    dr.Close();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }
            return resultado;
        }

        public bool Editar(CM_MetodoPago metodoPago, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_editar_metodo_pago", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdMetodoPago", metodoPago.id_metodo_pago);
                    cmd.Parameters.AddWithValue("@Metodo", metodoPago.metodo);
                    cmd.Parameters.AddWithValue("@Referencia", metodoPago.referencia);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        resultado = Convert.ToInt32(dr["Resultado"]) == 1;
                        Mensaje = dr["Mensaje"].ToString();
                    }
                    dr.Close();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }
            return resultado;
        }

        public bool Eliminar(int idMetodoPago, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_eliminar_metodo_pago", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdMetodoPago", idMetodoPago);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        resultado = Convert.ToInt32(dr["Resultado"]) == 1;
                        Mensaje = dr["Mensaje"].ToString();
                    }
                    dr.Close();
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
