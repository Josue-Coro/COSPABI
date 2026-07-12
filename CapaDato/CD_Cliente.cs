using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using static CapaModelo.CM_Cliente;

namespace CapaDato
{
    public class CD_Cliente
    {
        public CM_Cliente_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            return ListarInterno("dbo.sp_listar_clientes", busqueda, pagina, tamanoPagina);
        }

        // Personas que aún pueden ser socio (menos de 4 socios). Para el alta de socio.
        public CM_Cliente_Paginado ListarDisponiblesParaSocio(string busqueda, int pagina, int tamanoPagina)
        {
            return ListarInterno("dbo.sp_listar_personas_disponibles_socio", busqueda, pagina, tamanoPagina);
        }

        private CM_Cliente_Paginado ListarInterno(string nombreSp, string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_Cliente_Paginado
            {
                Clientes = new List<CM_Cliente>()
            };

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand(nombreSp, cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Busqueda", busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    // Primer result set: total
                    if (dr.Read())
                        resultado.TotalRegistros = Convert.ToInt32(dr["TotalRegistros"]);

                    // Segundo result set: datos
                    if (dr.NextResult())
                    {
                        while (dr.Read())
                        {
                            resultado.Clientes.Add(new CM_Cliente
                            {
                                id_cliente = Convert.ToInt32(dr["id_cliente"]),
                                nombre_completo = dr["nombre_completo"].ToString(),
                                ci = dr["ci"].ToString(),
                                genero = dr["genero"].ToString(),
                                telefono = dr["telefono"] == DBNull.Value
                                                       ? (int?)null
                                                       : Convert.ToInt32(dr["telefono"]),
                                email = dr["email"] == DBNull.Value ? null : dr["email"].ToString(),
                                fecha_nacimiento = Convert.ToDateTime(dr["fecha_nacimiento"]),
                                fecha_registro = Convert.ToDateTime(dr["fecha_registro"]),
                                estado = Convert.ToBoolean(dr["estado"])
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

        public CM_Cliente Obtener(int idCliente)
        {
            CM_Cliente cliente = null;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_cliente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdCliente", idCliente);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        cliente = new CM_Cliente
                        {
                            id_cliente = Convert.ToInt32(dr["id_cliente"]),
                            nombre_completo = dr["nombre_completo"].ToString(),
                            ci = dr["ci"].ToString(),
                            genero = dr["genero"].ToString(),
                            telefono = dr["telefono"] == DBNull.Value
                                                   ? (int?)null
                                                   : Convert.ToInt32(dr["telefono"]),
                            email = dr["email"] == DBNull.Value ? null : dr["email"].ToString(),
                            fecha_nacimiento = Convert.ToDateTime(dr["fecha_nacimiento"]),
                            fecha_registro = Convert.ToDateTime(dr["fecha_registro"]),
                            estado = Convert.ToBoolean(dr["estado"])
                        };
                    }

                    dr.Close();
                }
            }
            catch
            {
                cliente = null;
            }

            return cliente;
        }

        public bool Registrar(CM_Cliente cliente, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_cliente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@NombreCompleto", cliente.nombre_completo);
                    cmd.Parameters.AddWithValue("@CI", cliente.ci);
                    cmd.Parameters.AddWithValue("@Genero", cliente.genero);
                    cmd.Parameters.AddWithValue("@Telefono", (object)cliente.telefono ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Email", (object)cliente.email ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@FechaNacimiento", cliente.fecha_nacimiento);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }

            return resultado;
        }

        public bool Editar(CM_Cliente cliente, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_editar_cliente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdCliente", cliente.id_cliente);
                    cmd.Parameters.AddWithValue("@NombreCompleto", cliente.nombre_completo);
                    cmd.Parameters.AddWithValue("@CI", cliente.ci);
                    cmd.Parameters.AddWithValue("@Genero", cliente.genero);
                    cmd.Parameters.AddWithValue("@Telefono", (object)cliente.telefono ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Email", (object)cliente.email ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@FechaNacimiento", cliente.fecha_nacimiento);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }

            return resultado;
        }

        public bool CambiarEstado(int idCliente, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_cambiar_estado_cliente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdCliente", idCliente);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
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