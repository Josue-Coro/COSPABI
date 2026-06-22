using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Pago
    {
        public CM_AvisoPorCobrarListado ListarAvisosPorCobrar(string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_AvisoPorCobrarListado { Avisos = new List<CM_AvisoPorCobrar>() };
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_avisos_por_cobrar", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Busqueda", busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        resultado.Avisos.Add(new CM_AvisoPorCobrar
                        {
                            id_aviso          = Convert.ToInt32(dr["id_aviso"]),
                            total_aviso       = Convert.ToDecimal(dr["total_aviso"]),
                            deuda_actual      = Convert.ToDecimal(dr["deuda_actual"]),
                            estado            = dr["estado"].ToString(),
                            fecha_emision     = Convert.ToDateTime(dr["fecha_emision"]),
                            fecha_vencimiento = Convert.ToDateTime(dr["fecha_vencimiento"]),
                            nombre_socio      = dr["nombre_socio"].ToString(),
                            codigo_fijo       = Convert.ToInt32(dr["codigo_fijo"]),
                            nombre_periodo    = dr["nombre_periodo"].ToString()
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

        public bool RegistrarPago(int idAviso, int idCaja, int idMetodoPago, decimal? montoRecibido,
                                  string cajero, out string Mensaje)
        {
            bool ok = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_pago_aviso", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_aviso", idAviso);
                    cmd.Parameters.AddWithValue("@id_caja", idCaja);
                    cmd.Parameters.AddWithValue("@id_metodo_pago", idMetodoPago);
                    cmd.Parameters.AddWithValue("@monto_recibido", (object)montoRecibido ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@cajero", cajero ?? "");
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.NVarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    ok      = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex) { ok = false; Mensaje = ex.Message; }
            return ok;
        }

        public List<CM_Pago> ListarPagosCaja(int idCaja)
        {
            var lista = new List<CM_Pago>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_pagos_caja", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_caja", idCaja);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        lista.Add(new CM_Pago
                        {
                            id_pago        = Convert.ToInt32(dr["id_pago"]),
                            fecha_pago     = Convert.ToDateTime(dr["fecha_pago"]),
                            monto_pagado   = Convert.ToDecimal(dr["monto_pagado"]),
                            vuelto         = dr["vuelto"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(dr["vuelto"]),
                            estado_pago    = dr["estado_pago"].ToString(),
                            nombre_metodo  = dr["nombre_metodo"].ToString(),
                            aviso_id_aviso = dr["aviso_id_aviso"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"]),
                            nombre_socio   = dr["nombre_socio"] == DBNull.Value ? null : dr["nombre_socio"].ToString(),
                            codigo_fijo    = dr["codigo_fijo"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["codigo_fijo"])
                        });
                    }
                    dr.Close();
                }
            }
            catch { lista = null; }
            return lista;
        }
    }
}
