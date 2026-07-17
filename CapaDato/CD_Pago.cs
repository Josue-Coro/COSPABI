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
                                  string cajero, out int idPago, out string Mensaje)
        {
            bool ok = false;
            idPago = 0;
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
                    idPago  = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                    ok      = idPago > 0;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex) { ok = false; idPago = 0; Mensaje = ex.Message; }
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

        // ---- Pago QR (pasarela Libelula) ------------------------------------

        public CM_DatosDeudaQr ObtenerDatosDeudaQr(int idAviso)
        {
            CM_DatosDeudaQr datos = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_datos_deuda_qr", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_aviso", idAviso);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            datos = new CM_DatosDeudaQr
                            {
                                id_aviso       = Convert.ToInt32(dr["id_aviso"]),
                                total_aviso    = Convert.ToDecimal(dr["total_aviso"]),
                                estado         = dr["estado"].ToString(),
                                nombre_socio   = dr["nombre_socio"].ToString(),
                                codigo_fijo    = Convert.ToInt32(dr["codigo_fijo"]),
                                nombre_periodo = dr["nombre_periodo"].ToString(),
                                email          = dr["email"] == DBNull.Value ? null : dr["email"].ToString(),
                                Detalles       = new List<CM_ReciboPagoDetalle>()
                            };
                            if (dr["pendiente_id_pago"] != DBNull.Value)
                            {
                                datos.Pendiente = new CM_PagoQrPendiente
                                {
                                    id_pago        = Convert.ToInt32(dr["pendiente_id_pago"]),
                                    id_transaccion = dr["pendiente_id_transaccion"].ToString(),
                                    url_pasarela   = dr["pendiente_url_pasarela"] == DBNull.Value ? null : dr["pendiente_url_pasarela"].ToString(),
                                    qr_url         = dr["pendiente_qr_url"] == DBNull.Value ? null : dr["pendiente_qr_url"].ToString()
                                };
                            }
                        }
                        if (datos != null && dr.NextResult())
                        {
                            while (dr.Read())
                            {
                                datos.Detalles.Add(new CM_ReciboPagoDetalle
                                {
                                    concepto = dr["concepto"].ToString(),
                                    subtotal = Convert.ToDecimal(dr["subtotal"])
                                });
                            }
                        }
                    }
                }
            }
            catch { datos = null; }
            return datos;
        }

        public bool RegistrarPagoQrPendiente(int idAviso, int? idCaja, string cajero,
                                             string identificadorDeuda, string idTransaccion,
                                             string urlPasarela, string qrUrl,
                                             out int idPago, out string Mensaje)
        {
            bool ok = false;
            idPago = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_pago_qr_pendiente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_aviso", idAviso);
                    cmd.Parameters.AddWithValue("@id_caja", (object)idCaja ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@cajero", cajero ?? "");
                    cmd.Parameters.AddWithValue("@identificador_deuda", identificadorDeuda);
                    cmd.Parameters.AddWithValue("@id_transaccion", idTransaccion);
                    cmd.Parameters.AddWithValue("@url_pasarela", (object)urlPasarela ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@qr_url", (object)qrUrl ?? DBNull.Value);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.NVarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    idPago  = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                    ok      = idPago > 0;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex) { ok = false; idPago = 0; Mensaje = ex.Message; }
            return ok;
        }

        public CM_PagoQr ObtenerPagoQrPorTransaccion(string idTransaccion)
        {
            CM_PagoQr pago = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_pago_qr", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_transaccion", idTransaccion);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            pago = new CM_PagoQr
                            {
                                id_pago             = Convert.ToInt32(dr["id_pago"]),
                                identificador_deuda = dr["identificador_deuda"].ToString(),
                                id_transaccion      = dr["id_transaccion"].ToString(),
                                estado_pago         = dr["estado_pago"].ToString(),
                                monto_pagado        = Convert.ToDecimal(dr["monto_pagado"]),
                                aviso_id_aviso      = dr["aviso_id_aviso"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"]),
                                caja_id_caja        = dr["caja_id_caja"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["caja_id_caja"])
                            };
                        }
                    }
                }
            }
            catch { pago = null; }
            return pago;
        }

        public bool ConfirmarPagoQr(string idTransaccion, string formaPago, string codigoRecaudacion,
                                    out int idPago, out string Mensaje)
        {
            bool ok = false;
            idPago = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_confirmar_pago_qr", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_transaccion", idTransaccion);
                    cmd.Parameters.AddWithValue("@forma_pago", (object)formaPago ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@codigo_recaudacion", (object)codigoRecaudacion ?? DBNull.Value);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.NVarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    idPago  = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                    ok      = idPago > 0;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex) { ok = false; idPago = 0; Mensaje = ex.Message; }
            return ok;
        }

        public string ObtenerEstadoPago(int idPago)
        {
            string estado = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_estado_pago_qr", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_pago", idPago);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read()) estado = dr["estado_pago"].ToString();
                    }
                }
            }
            catch { estado = null; }
            return estado;
        }

        public List<CM_PagoQr> ListarPagosQrPendientes()
        {
            var lista = new List<CM_PagoQr>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_pagos_qr_pendientes", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_PagoQr
                            {
                                id_pago             = Convert.ToInt32(dr["id_pago"]),
                                identificador_deuda = dr["identificador_deuda"].ToString(),
                                id_transaccion      = dr["id_transaccion"].ToString(),
                                estado_pago         = "PENDIENTE",
                                monto_pagado        = Convert.ToDecimal(dr["monto_pagado"]),
                                aviso_id_aviso      = dr["aviso_id_aviso"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"])
                            });
                        }
                    }
                }
            }
            catch { lista = null; }
            return lista;
        }

        public CM_ReciboPago ObtenerReciboPago(int idPago)
        {
            return ObtenerRecibo("dbo.sp_recibo_pago_aviso", idPago);
        }

        // Recibo del pago inicial de inscripcion (pago sin aviso, ligado al credito).
        public CM_ReciboPago ObtenerReciboInscripcion(int idPago)
        {
            return ObtenerRecibo("dbo.sp_recibo_pago_inscripcion", idPago);
        }

        private CM_ReciboPago ObtenerRecibo(string nombreSp, int idPago)
        {
            CM_ReciboPago recibo = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand(nombreSp, cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_pago", idPago);
                    cn.Open();
                    
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            recibo = new CM_ReciboPago
                            {
                                id_pago = Convert.ToInt32(dr["id_pago"]),
                                fecha_pago = Convert.ToDateTime(dr["fecha_pago"]),
                                nombre_socio = dr["nombre_socio"].ToString(),
                                codigo_fijo = dr["codigo_fijo"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["codigo_fijo"]),
                                nombre_periodo = dr["nombre_periodo"].ToString(),
                                consumo = dr["consumo"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(dr["consumo"]),
                                total_consumo = Convert.ToDecimal(dr["total_consumo"]),
                                total_pagado = Convert.ToDecimal(dr["total_pagado"]),
                                vuelto = dr["vuelto"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(dr["vuelto"]),
                                cajero = dr["cajero"].ToString(),
                                metodo_pago = dr["metodo_pago"].ToString(),
                                categoria = dr["categoria"].ToString(),
                                nombre_ruta = dr["nombre_ruta"].ToString(),
                                ubicacion = dr["ubicacion"].ToString(),
                                Detalles = new List<CM_ReciboPagoDetalle>()
                            };
                        }
                        
                        if (recibo != null && dr.NextResult())
                        {
                            while (dr.Read())
                            {
                                recibo.Detalles.Add(new CM_ReciboPagoDetalle
                                {
                                    concepto = dr["concepto"].ToString(),
                                    subtotal = Convert.ToDecimal(dr["subtotal"])
                                });
                            }
                        }
                    }
                }
            }
            catch { recibo = null; }
            return recibo;
        }
    }
}
