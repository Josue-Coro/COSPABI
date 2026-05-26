using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static CapaModelo.CM_Socio;

namespace CapaDato
{
    public class CD_Socio
    {
        public CM_SocioListado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_SocioListado
            {
                Socios = new List<CM_Socio>()
            };

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Busqueda", busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    // Primer result set: filas de socios
                    while (dr.Read())
                    {
                        resultado.Socios.Add(new CM_Socio
                        {
                            id_socio = Convert.ToInt32(dr["id_socio"]),
                            nombre_socio = dr["nombre_socio"].ToString(),
                            cliente_id_cliente = Convert.ToInt32(dr["cliente_id_cliente"]),
                            nombre_cliente = dr["nombre_cliente"].ToString(),
                            ci_cliente = dr["ci_cliente"].ToString(),
                            rol_socio_id_rol_socio = Convert.ToInt32(dr["rol_socio_id_rol_socio"]),
                            NombreRolSocio = dr["nombre_rol_socio"].ToString(),
                            medidor_id_medidor = Convert.ToInt32(dr["medidor_id_medidor"]),
                            num_serie_medidor = dr["serie_medidor"].ToString(),
                            ruta_id_ruta = Convert.ToInt32(dr["ruta_id_ruta"]),
                            nombre_ruta = dr["nombre_ruta"].ToString(),
                            ubicacion = dr["ubicacion"] == DBNull.Value ? 0 : Convert.ToInt32(dr["ubicacion"]),
                            num_casa = dr["num_casa"] == DBNull.Value ? 0 : Convert.ToInt32(dr["num_casa"]),
                            num_ocupantes = dr["num_ocupantes"] == DBNull.Value ? 0 : Convert.ToInt32(dr["num_ocupantes"]),
                            tipo_instalacion = dr["tipo_instalacion"].ToString(),
                            dim_instalacion = dr["dim_instalacion"].ToString(),
                            actividad = dr["actividad"].ToString(),
                            categoria = dr["categoria"].ToString(),
                            fecha_registro = Convert.ToDateTime(dr["fecha_registro"]),
                            codigo_fijo = Convert.ToInt32(dr["codigo_fijo"])
                        });
                    }

                    // Segundo result set: total registros
                    if (dr.NextResult() && dr.Read())
                        resultado.TotalRegistros = Convert.ToInt32(dr["TotalRegistros"]);

                    dr.Close();
                }
            }
            catch
            {
                resultado = null;
            }

            return resultado;
        }
        public CM_Socio Obtener(int idSocio)
        {
            CM_Socio socio = null;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.SP_Socio_ObtenerPorId", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        socio = new CM_Socio
                        {
                            id_socio = Convert.ToInt32(dr["id_socio"]),
                            nombre_socio = dr["nombre_socio"].ToString(),
                            cliente_id_cliente = Convert.ToInt32(dr["cliente_id_cliente"]),
                            nombre_cliente = dr["nombre_cliente"].ToString(),
                            ci_cliente = dr["ci_cliente"].ToString(),
                            rol_socio_id_rol_socio = Convert.ToInt32(dr["rol_socio_id_rol_socio"]),
                            NombreRolSocio = dr["nombre_rol_socio"].ToString(),
                            medidor_id_medidor = Convert.ToInt32(dr["medidor_id_medidor"]),
                            num_serie_medidor = dr["serie_medidor"].ToString(),
                            ruta_id_ruta = Convert.ToInt32(dr["ruta_id_ruta"]),
                            nombre_ruta = dr["nombre_ruta"].ToString(),
                            ubicacion = dr["ubicacion"] == DBNull.Value ? 0 : Convert.ToInt32(dr["ubicacion"]),
                            num_casa = dr["num_casa"] == DBNull.Value ? 0 : Convert.ToInt32(dr["num_casa"]),
                            num_ocupantes = dr["num_ocupantes"] == DBNull.Value ? 0 : Convert.ToInt32(dr["num_ocupantes"]),
                            tipo_instalacion = dr["tipo_instalacion"].ToString(),
                            dim_instalacion = dr["dim_instalacion"].ToString(),
                            actividad = dr["actividad"].ToString(),
                            categoria = dr["categoria"].ToString(),
                            fecha_registro = Convert.ToDateTime(dr["fecha_registro"]),
                            codigo_fijo = Convert.ToInt32(dr["codigo_fijo"])
                        };
                    }

                    dr.Close();
                }
            }
            catch
            {
                socio = null;
            }

            return socio;
        }

        public int Registrar(CM_Socio socio, int idUsuarioSesion, out string Mensaje)
        {
            int idGenerado = 0;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@nombre_socio", socio.nombre_socio);
                    cmd.Parameters.AddWithValue("@cliente_id_cliente", socio.cliente_id_cliente);
                    cmd.Parameters.AddWithValue("@rol_socio_id_rol_socio", socio.rol_socio_id_rol_socio);
                    cmd.Parameters.AddWithValue("@ubicacion", socio.ubicacion);
                    cmd.Parameters.AddWithValue("@medidor_id_medidor", socio.medidor_id_medidor);
                    cmd.Parameters.AddWithValue("@num_casa", socio.num_casa);
                    cmd.Parameters.AddWithValue("@num_ocupantes", socio.num_ocupantes);
                    cmd.Parameters.AddWithValue("@tipo_instalacion", (object)socio.tipo_instalacion ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@dim_instalacion", (object)socio.dim_instalacion ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@actividad", socio.actividad);
                    cmd.Parameters.AddWithValue("@categoria", socio.categoria);
                    cmd.Parameters.AddWithValue("@fecha_registro", socio.fecha_registro);
                    cmd.Parameters.AddWithValue("@ruta_id_ruta", socio.ruta_id_ruta);
                    cmd.Parameters.AddWithValue("@codigo_fijo", socio.codigo_fijo);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    idGenerado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                idGenerado = 0;
                Mensaje = ex.Message;
            }

            return idGenerado;
        }

        public bool Editar(CM_Socio socio, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_editar_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", socio.id_socio);
                    cmd.Parameters.AddWithValue("@nombre_socio", socio.nombre_socio);
                    cmd.Parameters.AddWithValue("@cliente_id_cliente", socio.cliente_id_cliente);
                    cmd.Parameters.AddWithValue("@rol_socio_id_rol_socio", socio.rol_socio_id_rol_socio);
                    cmd.Parameters.AddWithValue("@ubicacion", socio.ubicacion);
                    cmd.Parameters.AddWithValue("@medidor_id_medidor", socio.medidor_id_medidor);
                    cmd.Parameters.AddWithValue("@num_casa", socio.num_casa);
                    cmd.Parameters.AddWithValue("@num_ocupantes", socio.num_ocupantes);
                    cmd.Parameters.AddWithValue("@tipo_instalacion", (object)socio.tipo_instalacion ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@dim_instalacion", (object)socio.dim_instalacion ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@actividad", socio.actividad);
                    cmd.Parameters.AddWithValue("@categoria", socio.categoria);
                    cmd.Parameters.AddWithValue("@fecha_registro", socio.fecha_registro);
                    cmd.Parameters.AddWithValue("@ruta_id_ruta", socio.ruta_id_ruta);
                    cmd.Parameters.AddWithValue("@codigo_fijo", socio.codigo_fijo);
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


        public bool Eliminar(int idSocio, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_eliminar_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);
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
