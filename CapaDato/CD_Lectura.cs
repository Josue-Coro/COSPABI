using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using static CapaModelo.CM_Lectura;

namespace CapaDato
{
    public class CD_Lectura
    {
        // Carga todos los medidores de una ruta con su lectura anterior y estado del período actual
        public List<CM_MedidorParaLectura> ListarMedidoresParaLectura(int idRuta, int idPeriodo)
        {
            var lista = new List<CM_MedidorParaLectura>();

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_medidores_para_lectura", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_ruta", idRuta);
                    cmd.Parameters.AddWithValue("@id_periodo", idPeriodo);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new CM_MedidorParaLectura
                        {
                            id_medidor            = Convert.ToInt32(dr["id_medidor"]),
                            serie                 = dr["serie"].ToString(),
                            id_socio              = Convert.ToInt32(dr["id_socio"]),
                            nombre_socio          = dr["nombre_socio"].ToString(),
                            codigo_fijo           = Convert.ToInt32(dr["codigo_fijo"]),
                            lectura_anterior_valor= dr["lectura_anterior_valor"] == DBNull.Value ? 0 : Convert.ToInt32(dr["lectura_anterior_valor"]),
                            fecha_ultima_lectura  = dr["fecha_ultima_lectura"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["fecha_ultima_lectura"]),
                            ya_leido              = Convert.ToInt32(dr["ya_leido"]) == 1,
                            id_lectura_actual     = dr["id_lectura_actual"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["id_lectura_actual"]),
                            lect_ant_registrada   = dr["lect_ant_registrada"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["lect_ant_registrada"]),
                            lect_act_registrada   = dr["lect_act_registrada"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["lect_act_registrada"]),
                            consumo_registrado    = dr["consumo_registrado"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(dr["consumo_registrado"]),
                            observacion_registrada= dr["observacion_registrada"] == DBNull.Value ? null : dr["observacion_registrada"].ToString(),
                            dias_registrados      = dr["dias_registrados"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["dias_registrados"])
                        });
                    }

                    dr.Close();
                }
            }
            catch
            {
                lista = null;
            }

            return lista;
        }

        // Registra la lectura de un medidor
        public int Registrar(CM_Lectura obj, int idUsuario, out string Mensaje)
        {
            int idGenerado = 0;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_lectura", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@fecha_lectura",                  obj.fecha_lectura);
                    cmd.Parameters.AddWithValue("@lectura_anterior",               obj.lectura_anterior);
                    cmd.Parameters.AddWithValue("@lectura_actual",                 obj.lectura_actual);
                    cmd.Parameters.AddWithValue("@observacion",                    (object)obj.observacion ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@usuario_admin_id_usuario_admin", idUsuario);
                    cmd.Parameters.AddWithValue("@medidor_id_medidor",             obj.medidor_id_medidor);
                    cmd.Parameters.AddWithValue("@periodo_id_periodo",             obj.periodo_id_periodo);
                    cmd.Parameters.AddWithValue("@ruta_id_ruta",                   obj.ruta_id_ruta);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    idGenerado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                    Mensaje    = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                idGenerado = 0;
                Mensaje    = ex.Message;
            }

            return idGenerado;
        }

        // Historial paginado de lecturas ya registradas
        public CM_LecturaListado Listar(int? idPeriodo, int? idRuta, string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_LecturaListado
            {
                Lecturas = new List<CM_Lectura>()
            };

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_lecturas", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_periodo",   (object)idPeriodo   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@id_ruta",      (object)idRuta      ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Busqueda",     busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina",       pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        resultado.Lecturas.Add(new CM_Lectura
                        {
                            id_lectura                       = Convert.ToInt32(dr["id_lectura"]),
                            fecha_lectura                    = Convert.ToDateTime(dr["fecha_lectura"]),
                            lectura_anterior                 = Convert.ToInt32(dr["lectura_anterior"]),
                            lectura_actual                   = Convert.ToInt32(dr["lectura_actual"]),
                            dias_lectura                     = Convert.ToInt32(dr["dias_lectura"]),
                            consumo_m3                       = Convert.ToDecimal(dr["consumo_m3"]),
                            observacion                      = dr["observacion"] == DBNull.Value ? null : dr["observacion"].ToString(),
                            serie_medidor                    = dr["serie_medidor"].ToString(),
                            nombre_socio                     = dr["nombre_socio"].ToString(),
                            codigo_fijo                      = Convert.ToInt32(dr["codigo_fijo"]),
                            nombre_periodo                   = dr["nombre_periodo"].ToString(),
                            nombre_ruta                      = dr["nombre_ruta"].ToString(),
                            nombre_usuario                   = dr["nombre_usuario"].ToString()
                        });
                    }

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

        // Auto-crea el período en BD si no existe y devuelve su id_periodo
        public int ObtenerOCrearPeriodo(string periodoNombre)
        {
            int idPeriodo = 0;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_o_crear_periodo", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@periodo_nombre", periodoNombre);
                    cmd.Parameters.Add("@id_periodo", SqlDbType.Int).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    idPeriodo = Convert.ToInt32(cmd.Parameters["@id_periodo"].Value);
                }
            }
            catch
            {
                idPeriodo = 0;
            }

            return idPeriodo;
        }
    }
}
