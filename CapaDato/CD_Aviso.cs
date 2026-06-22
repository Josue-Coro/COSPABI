using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using static CapaModelo.CM_Aviso;

namespace CapaDato
{
    public class CD_Aviso
    {
        public int GenerarAvisos(int idPeriodo, int? idRuta, out string Mensaje)
        {
            int generados = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_generar_avisos_periodo", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_periodo", idPeriodo);
                    cmd.Parameters.AddWithValue("@id_ruta",    (object)idRuta ?? DBNull.Value);
                    cmd.Parameters.Add("@Generados", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    generados = Convert.ToInt32(cmd.Parameters["@Generados"].Value);
                    Mensaje   = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                generados = -1;
                Mensaje   = ex.Message;
            }
            return generados;
        }

        public CM_AvisoListado Listar(int? idPeriodo, int? idEstado, int? idRuta,
                                      string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_AvisoListado { Avisos = new List<CM_Aviso>() };
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_avisos", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_periodo",   (object)idPeriodo  ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@id_estado",    (object)idEstado   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@id_ruta",      (object)idRuta     ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Busqueda",     busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina",       pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        resultado.Avisos.Add(new CM_Aviso
                        {
                            id_aviso          = Convert.ToInt32(dr["id_aviso"]),
                            fecha_emision     = Convert.ToDateTime(dr["fecha_emision"]),
                            fecha_vencimiento = Convert.ToDateTime(dr["fecha_vencimiento"]),
                            total_consumo     = Convert.ToDecimal(dr["total_consumo"]),
                            total_aviso       = Convert.ToDecimal(dr["total_aviso"]),
                            deuda_actual      = Convert.ToDecimal(dr["deuda_actual"]),
                            estado            = dr["estado"].ToString(),
                            estado_id_estado  = Convert.ToInt32(dr["estado_id_estado"]),
                            nombre_socio      = dr["nombre_socio"].ToString(),
                            codigo_fijo       = Convert.ToInt32(dr["codigo_fijo"]),
                            nombre_periodo    = dr["nombre_periodo"].ToString(),
                            nombre_ruta       = dr["nombre_ruta"].ToString(),
                            nombre_estado     = dr["nombre_estado"].ToString(),
                            tiene_cargo_extra = Convert.ToBoolean(dr["tiene_cargo_extra"]),
                            tiene_credito     = Convert.ToBoolean(dr["tiene_credito"])
                        });
                    }
                    if (dr.NextResult() && dr.Read())
                        resultado.TotalRegistros = Convert.ToInt32(dr["TotalRegistros"]);
                    dr.Close();
                }
            }
            catch { resultado = null; }
            return resultado;
        }

        public bool CambiarEstado(int idAviso, int idEstado, out string Mensaje)
        {
            bool ok = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_cambiar_estado_aviso", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_aviso",  idAviso);
                    cmd.Parameters.AddWithValue("@id_estado", idEstado);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    ok      = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) > 0;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex) { ok = false; Mensaje = ex.Message; }
            return ok;
        }

        public CM_Aviso ObtenerUltimoAviso(int idSocio)
        {
            CM_Aviso aviso = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_ultimo_aviso_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        aviso = new CM_Aviso
                        {
                            id_aviso          = Convert.ToInt32(dr["id_aviso"]),
                            fecha_emision     = Convert.ToDateTime(dr["fecha_emision"]),
                            fecha_vencimiento = Convert.ToDateTime(dr["fecha_vencimiento"]),
                            total_consumo     = Convert.ToDecimal(dr["total_consumo"]),
                            total_aviso       = Convert.ToDecimal(dr["total_aviso"]),
                            deuda_actual      = Convert.ToDecimal(dr["deuda_actual"]),
                            estado            = dr["estado"].ToString(),
                            estado_id_estado  = Convert.ToInt32(dr["estado_id_estado"]),
                            nombre_estado     = dr["nombre_estado"].ToString(),
                            nombre_periodo    = dr["nombre_periodo"].ToString()
                        };
                    }
                    dr.Close();
                }
            }
            catch { aviso = null; }
            return aviso;
        }

        public bool ExisteAvisoActivo(int idSocio, int idPeriodo)
        {
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand(
                        "SELECT 1 FROM aviso WHERE socio_id_socio = @idSocio AND periodo_id_periodo = @idPeriodo AND estado != 'ANULADO'", cn);
                    cmd.Parameters.AddWithValue("@idSocio",   idSocio);
                    cmd.Parameters.AddWithValue("@idPeriodo", idPeriodo);
                    cn.Open();
                    return cmd.ExecuteScalar() != null;
                }
            }
            catch { return false; }
        }

        public bool AnularAviso(int idAviso, out string Mensaje)
        {
            bool ok = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_anular_aviso", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_aviso", idAviso);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    ok      = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) > 0;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex) { ok = false; Mensaje = ex.Message; }
            return ok;
        }

        public CM_AvisoDetalle ObtenerDetalle(int idAviso)
        {
            CM_AvisoDetalle detalle = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_detalle_aviso", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_aviso", idAviso);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        detalle = new CM_AvisoDetalle
                        {
                            id_aviso                = Convert.ToInt32(dr["id_aviso"]),
                            fecha_emision           = Convert.ToDateTime(dr["fecha_emision"]),
                            fecha_vencimiento       = Convert.ToDateTime(dr["fecha_vencimiento"]),
                            total_consumo           = Convert.ToDecimal(dr["total_consumo"]),
                            total_aviso             = Convert.ToDecimal(dr["total_aviso"]),
                            deuda_actual            = Convert.ToDecimal(dr["deuda_actual"]),
                            nombre_estado           = dr["nombre_estado"].ToString(),
                            nombre_socio            = dr["nombre_socio"].ToString(),
                            codigo_fijo             = Convert.ToInt32(dr["codigo_fijo"]),
                            nombre_ruta             = dr["nombre_ruta"].ToString(),
                            nombre_periodo          = dr["nombre_periodo"].ToString(),
                            serie_medidor           = dr["serie_medidor"].ToString(),
                            lectura_anterior        = Convert.ToDecimal(dr["lectura_anterior"]),
                            lectura_actual          = Convert.ToDecimal(dr["lectura_actual"]),
                            consumo_m3              = Convert.ToDecimal(dr["consumo_m3"]),
                            dias_lectura            = Convert.ToInt32(dr["dias_lectura"]),
                            nombre_rol              = dr["nombre_rol"].ToString(),
                            monto_minimo            = Convert.ToDecimal(dr["monto_minimo"]),
                            consumo_minimo_m3       = Convert.ToDecimal(dr["consumo_minimo_m3"]),
                            precio_m3               = Convert.ToDecimal(dr["precio_m3"]),
                            total_cargos            = Convert.ToDecimal(dr["total_cargos"]),
                            monto_credito           = dr["monto_credito"] is DBNull ? (decimal?)null : Convert.ToDecimal(dr["monto_credito"]),
                            cargos                  = new List<CM_CargoExtra>()
                        };
                    }

                    // Segundo result set: lista de cargos extra (1:N)
                    if (detalle != null && dr.NextResult())
                    {
                        while (dr.Read())
                        {
                            detalle.cargos.Add(new CM_CargoExtra
                            {
                                id_carga_extra    = Convert.ToInt32(dr["id_carga_extra"]),
                                monto             = Convert.ToDecimal(dr["monto"]),
                                descripcion       = dr["descripcion"].ToString(),
                                fecha_registro    = Convert.ToDateTime(dr["fecha_registro"]),
                                nombre_tipo_cargo = dr["nombre_tipo_cargo"].ToString()
                            });
                        }
                    }
                    dr.Close();
                }
            }
            catch { detalle = null; }
            return detalle;
        }

        public List<CM_Estado> ListarEstados()
        {
            var lista = new List<CM_Estado>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand(
                        "SELECT id_estado, estado FROM estado ORDER BY id_estado", cn);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                        lista.Add(new CM_Estado
                        {
                            id_estado = Convert.ToInt32(dr["id_estado"]),
                            estado    = dr["estado"].ToString()
                        });
                    dr.Close();
                }
            }
            catch { lista = null; }
            return lista;
        }
    }
}
