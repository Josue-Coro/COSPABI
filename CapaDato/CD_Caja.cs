using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Caja
    {
        public int AbrirCaja(int idUsuario, decimal montoApertura, out string Mensaje)
        {
            int idCaja = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_abrir_caja", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_usuario", idUsuario);
                    cmd.Parameters.AddWithValue("@monto_apertura", montoApertura);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.NVarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    idCaja  = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex) { idCaja = 0; Mensaje = ex.Message; }
            return idCaja;
        }

        public bool CerrarCaja(int idCaja, out string Mensaje)
        {
            bool ok = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_cerrar_caja", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_caja", idCaja);
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

        public CM_Caja ObtenerCajaAbierta(int idUsuario)
        {
            CM_Caja caja = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_caja_abierta", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_usuario", idUsuario);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        caja = new CM_Caja
                        {
                            id_caja        = Convert.ToInt32(dr["id_caja"]),
                            fecha          = Convert.ToDateTime(dr["fecha"]),
                            hora_apertura  = Convert.ToDateTime(dr["hora_apertura"]),
                            monto_apertura = Convert.ToDecimal(dr["monto_apertura"]),
                            estado         = Convert.ToBoolean(dr["estado"]),
                            total_cobrado  = Convert.ToDecimal(dr["total_cobrado"]),
                            num_pagos      = Convert.ToInt32(dr["num_pagos"])
                        };
                    }
                    dr.Close();
                }
            }
            catch { caja = null; }
            return caja;
        }

        public CM_CajaArqueo ObtenerArqueo(int idCaja)
        {
            CM_CajaArqueo arqueo = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_arqueo_caja", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_caja", idCaja);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        arqueo = new CM_CajaArqueo
                        {
                            id_caja          = Convert.ToInt32(dr["id_caja"]),
                            fecha            = Convert.ToDateTime(dr["fecha"]),
                            hora_apertura    = Convert.ToDateTime(dr["hora_apertura"]),
                            hora_cierre      = dr["hora_cierre"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["hora_cierre"]),
                            estado           = Convert.ToBoolean(dr["estado"]),
                            monto_apertura   = Convert.ToDecimal(dr["monto_apertura"]),
                            total_cobrado    = Convert.ToDecimal(dr["total_cobrado"]),
                            efectivo_cobrado = Convert.ToDecimal(dr["efectivo_cobrado"]),
                            porMetodo        = new List<CM_ArqueoMetodo>()
                        };
                    }
                    if (arqueo != null && dr.NextResult())
                    {
                        while (dr.Read())
                        {
                            arqueo.porMetodo.Add(new CM_ArqueoMetodo
                            {
                                metodo   = dr["metodo"].ToString(),
                                total    = Convert.ToDecimal(dr["total"]),
                                cantidad = Convert.ToInt32(dr["cantidad"])
                            });
                        }
                    }
                    dr.Close();
                }
            }
            catch { arqueo = null; }
            return arqueo;
        }

        public CM_CajaListado Listar(int idUsuario, int pagina, int tamanoPagina)
        {
            var resultado = new CM_CajaListado { Cajas = new List<CM_Caja>() };
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_cajas", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_usuario", idUsuario);
                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        resultado.Cajas.Add(new CM_Caja
                        {
                            id_caja        = Convert.ToInt32(dr["id_caja"]),
                            fecha          = Convert.ToDateTime(dr["fecha"]),
                            hora_apertura  = Convert.ToDateTime(dr["hora_apertura"]),
                            hora_cierre    = dr["hora_cierre"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["hora_cierre"]),
                            monto_apertura = Convert.ToDecimal(dr["monto_apertura"]),
                            monto_cobrado  = Convert.ToDecimal(dr["monto_cobrado"]),
                            estado         = Convert.ToBoolean(dr["estado"])
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

        // ---- HU21: Reporte de Caja ----

        public CM_ReporteCaja ReporteCaja(DateTime fechaInicio, DateTime fechaFin, int? idCajero)
        {
            CM_ReporteCaja reporte = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_reporte_caja", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio.Date);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin.Date);
                    cmd.Parameters.AddWithValue("@IdCajero", (object)idCajero ?? DBNull.Value);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        reporte = new CM_ReporteCaja
                        {
                            Pagos         = new List<CM_ReporteCajaFila>(),
                            TotalesMetodo = new List<CM_ReporteCajaMetodo>()
                        };
                        while (dr.Read())
                        {
                            reporte.Pagos.Add(new CM_ReporteCajaFila
                            {
                                id_pago        = Convert.ToInt32(dr["id_pago"]),
                                fecha_pago     = Convert.ToDateTime(dr["fecha_pago"]),
                                aviso_id_aviso = dr["aviso_id_aviso"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"]),
                                tipo_cobro     = dr["tipo_cobro"].ToString(),
                                nombre_socio   = dr["nombre_socio"] == DBNull.Value ? null : dr["nombre_socio"].ToString(),
                                codigo_fijo    = dr["codigo_fijo"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["codigo_fijo"]),
                                nombre_metodo  = dr["nombre_metodo"].ToString(),
                                cajero         = dr["cajero"].ToString(),
                                monto_pagado   = Convert.ToDecimal(dr["monto_pagado"])
                            });
                        }
                        if (dr.NextResult())
                        {
                            while (dr.Read())
                            {
                                reporte.TotalesMetodo.Add(new CM_ReporteCajaMetodo
                                {
                                    nombre_metodo = dr["nombre_metodo"].ToString(),
                                    cantidad      = Convert.ToInt32(dr["cantidad"]),
                                    total         = Convert.ToDecimal(dr["total"])
                                });
                            }
                        }
                        if (dr.NextResult() && dr.Read())
                        {
                            reporte.CantidadPagos  = Convert.ToInt32(dr["cantidad_pagos"]);
                            reporte.TotalRecaudado = Convert.ToDecimal(dr["total_recaudado"]);
                        }
                    }
                }
            }
            catch { reporte = null; }
            return reporte;
        }

        public List<CM_CajeroFiltro> ListarCajerosConCaja(bool solicitanteEsSuperadmin)
        {
            var lista = new List<CM_CajeroFiltro>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_cajeros_con_caja", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SolicitanteEsSuperadmin", solicitanteEsSuperadmin);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_CajeroFiltro
                            {
                                id_usuario_admin = Convert.ToInt32(dr["id_usuario_admin"]),
                                nombre_completo  = dr["nombre_completo"].ToString()
                            });
                        }
                    }
                }
            }
            catch { lista = null; }
            return lista;
        }
    }
}
