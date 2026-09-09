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

        public bool CerrarCaja(int idCaja, int idUsuario, bool esSuperadmin, out string Mensaje)
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
                    cmd.Parameters.AddWithValue("@id_usuario", idUsuario);
                    cmd.Parameters.AddWithValue("@es_superadmin", esSuperadmin);
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

        public CM_CajaArqueo ObtenerArqueo(int idCaja, int idUsuario, bool esSuperadmin)
        {
            CM_CajaArqueo arqueo = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_arqueo_caja", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_caja", idCaja);
                    cmd.Parameters.AddWithValue("@id_usuario", idUsuario);
                    cmd.Parameters.AddWithValue("@es_superadmin", esSuperadmin);
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

        // Pagos aprobados que no pasaron por caja (el socio los pago desde el
        // portal). Mismo formato de 3 resultsets que sp_reporte_caja.
        public CM_ReportePagosSistema ReportePagosSistema(DateTime fechaInicio, DateTime fechaFin)
        {
            CM_ReportePagosSistema reporte = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_reporte_pagos_sistema", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio.Date);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin.Date);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        reporte = new CM_ReportePagosSistema
                        {
                            Pagos         = new List<CM_ReportePagoSistemaFila>(),
                            TotalesMetodo = new List<CM_ReporteCajaMetodo>()
                        };
                        while (dr.Read())
                        {
                            reporte.Pagos.Add(new CM_ReportePagoSistemaFila
                            {
                                id_pago            = Convert.ToInt32(dr["id_pago"]),
                                fecha_pago         = Convert.ToDateTime(dr["fecha_pago"]),
                                aviso_id_aviso     = dr["aviso_id_aviso"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"]),
                                tipo_cobro         = dr["tipo_cobro"].ToString(),
                                nombre_socio       = dr["nombre_socio"] == DBNull.Value ? null : dr["nombre_socio"].ToString(),
                                codigo_fijo        = dr["codigo_fijo"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["codigo_fijo"]),
                                nombre_periodo     = dr["nombre_periodo"] == DBNull.Value ? null : dr["nombre_periodo"].ToString(),
                                nombre_metodo      = dr["nombre_metodo"].ToString(),
                                id_transaccion     = dr["id_transaccion"] == DBNull.Value ? null : dr["id_transaccion"].ToString(),
                                codigo_recaudacion = dr["codigo_recaudacion"] == DBNull.Value ? null : dr["codigo_recaudacion"].ToString(),
                                forma_pago         = dr["forma_pago"] == DBNull.Value ? null : dr["forma_pago"].ToString(),
                                monto_pagado       = Convert.ToDecimal(dr["monto_pagado"])
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
                            reporte.QrSinCobrar    = Convert.ToInt32(dr["qr_sin_cobrar"]);
                        }
                    }
                }
            }
            catch { reporte = null; }
            return reporte;
        }

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

        // ---- Facturas cobradas ----
        public CM_ReporteCobros ReporteCobros(DateTime fechaInicio, DateTime fechaFin, int? idCajero, string origen)
        {
            CM_ReporteCobros reporte = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_reporte_cobros", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio.Date);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin.Date);
                    cmd.Parameters.AddWithValue("@IdCajero", (object)idCajero ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Origen", origen ?? "CAJA");
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        reporte = new CM_ReporteCobros
                        {
                            Cobros     = new List<CM_ReporteCobroFila>(),
                            Subtotales = new List<CM_ReporteCobroSubtotal>()
                        };
                        while (dr.Read())
                        {
                            reporte.Cobros.Add(new CM_ReporteCobroFila
                            {
                                id_pago        = Convert.ToInt32(dr["id_pago"]),
                                fecha_pago     = Convert.ToDateTime(dr["fecha_pago"]),
                                aviso_id_aviso = dr["aviso_id_aviso"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"]),
                                tipo_cobro     = dr["tipo_cobro"].ToString(),
                                codigo_fijo    = dr["codigo_fijo"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["codigo_fijo"]),
                                nombre_socio   = dr["nombre_socio"] == DBNull.Value ? null : dr["nombre_socio"].ToString(),
                                nombre_periodo = dr["nombre_periodo"] == DBNull.Value ? null : dr["nombre_periodo"].ToString(),
                                nombre_metodo  = dr["nombre_metodo"].ToString(),
                                cajero         = dr["cajero"].ToString(),
                                caja_id_caja   = dr["caja_id_caja"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["caja_id_caja"]),
                                monto_pagado   = Convert.ToDecimal(dr["monto_pagado"])
                            });
                        }
                        if (dr.NextResult())
                        {
                            while (dr.Read())
                            {
                                reporte.Subtotales.Add(new CM_ReporteCobroSubtotal
                                {
                                    tipo_cobro = dr["tipo_cobro"].ToString(),
                                    cantidad   = Convert.ToInt32(dr["cantidad"]),
                                    total      = Convert.ToDecimal(dr["total"])
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

        // ---- Arqueo general por concepto (rango de fechas o una caja) ----
        public CM_ArqueoGeneral ArqueoGeneral(DateTime? fechaInicio, DateTime? fechaFin, int? idCajero, string origen, int? idCaja)
        {
            CM_ArqueoGeneral reporte = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_reporte_arqueo_general", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio.HasValue ? (object)fechaInicio.Value.Date : DBNull.Value);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin.HasValue ? (object)fechaFin.Value.Date : DBNull.Value);
                    cmd.Parameters.AddWithValue("@IdCajero", (object)idCajero ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Origen", origen ?? "CAJA");
                    cmd.Parameters.AddWithValue("@IdCaja", (object)idCaja ?? DBNull.Value);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        reporte = new CM_ArqueoGeneral
                        {
                            Conceptos     = new List<CM_ArqueoConcepto>(),
                            TotalesMetodo = new List<CM_ReporteCajaMetodo>()
                        };
                        while (dr.Read())
                        {
                            reporte.Conceptos.Add(new CM_ArqueoConcepto
                            {
                                nro      = Convert.ToInt32(dr["nro"]),
                                servicio = dr["servicio"].ToString(),
                                cantidad = Convert.ToInt32(dr["cantidad"]),
                                cobrado  = Convert.ToDecimal(dr["cobrado"])
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
                            reporte.CantidadPagos     = Convert.ToInt32(dr["cantidad_pagos"]);
                            reporte.TotalRecaudado    = Convert.ToDecimal(dr["total_recaudado"]);
                            reporte.CantidadConceptos = Convert.ToInt32(dr["cantidad_conceptos"]);
                        }
                    }
                }
            }
            catch { reporte = null; }
            return reporte;
        }

        // ---- HU24: pagos de inscripcion ----
        public CM_ReporteInscripcion ReportePagosInscripcion(DateTime fechaInicio, DateTime fechaFin)
        {
            CM_ReporteInscripcion reporte = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_reporte_pagos_inscripcion", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio.Date);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin.Date);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        reporte = new CM_ReporteInscripcion
                        {
                            Cuotas     = new List<CM_ReporteInscripcionCuota>(),
                            Pendientes = new List<CM_ReporteInscripcionPendiente>()
                        };
                        while (dr.Read())
                        {
                            reporte.Cuotas.Add(new CM_ReporteInscripcionCuota
                            {
                                codigo_fijo     = Convert.ToInt32(dr["codigo_fijo"]),
                                nombre_socio    = dr["nombre_socio"].ToString(),
                                total_credito   = Convert.ToDecimal(dr["total_credito"]),
                                num_cuota       = Convert.ToInt32(dr["num_cuota"]),
                                total_cuotas    = Convert.ToInt32(dr["total_cuotas"]),
                                monto_cuota     = Convert.ToDecimal(dr["monto_cuota"]),
                                saldo_pendiente = Convert.ToDecimal(dr["saldo_pendiente"]),
                                fecha_pago      = Convert.ToDateTime(dr["fecha_pago"]),
                                id_pago         = Convert.ToInt32(dr["id_pago"]),
                                aviso_id_aviso  = dr["aviso_id_aviso"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"]),
                                nombre_periodo  = dr["nombre_periodo"].ToString(),
                                nombre_metodo   = dr["nombre_metodo"].ToString(),
                                estado_credito  = dr["estado_credito"].ToString()
                            });
                        }
                        if (dr.NextResult())
                        {
                            while (dr.Read())
                            {
                                reporte.Pendientes.Add(new CM_ReporteInscripcionPendiente
                                {
                                    codigo_fijo       = Convert.ToInt32(dr["codigo_fijo"]),
                                    nombre_socio      = dr["nombre_socio"].ToString(),
                                    total_credito     = Convert.ToDecimal(dr["total_credito"]),
                                    pagado            = Convert.ToDecimal(dr["pagado"]),
                                    saldo             = Convert.ToDecimal(dr["saldo"]),
                                    cuotas_pendientes = Convert.ToInt32(dr["cuotas_pendientes"]),
                                    total_cuotas      = Convert.ToInt32(dr["total_cuotas"]),
                                    proximo_periodo   = dr["proximo_periodo"] == DBNull.Value ? null : dr["proximo_periodo"].ToString(),
                                    proximo_monto     = dr["proximo_monto"] == DBNull.Value ? 0 : Convert.ToDecimal(dr["proximo_monto"])
                                });
                            }
                        }
                        if (dr.NextResult() && dr.Read())
                        {
                            reporte.CantidadCuotas        = Convert.ToInt32(dr["cantidad_cuotas"]);
                            reporte.MontoCobrado          = Convert.ToDecimal(dr["monto_cobrado"]);
                            reporte.SociosCobrados        = Convert.ToInt32(dr["socios_cobrados"]);
                            reporte.SociosCancelaronTotal = Convert.ToInt32(dr["socios_cancelaron_total"]);
                            reporte.SociosConPendientes   = Convert.ToInt32(dr["socios_con_pendientes"]);
                            reporte.SaldoTotalPendiente   = Convert.ToDecimal(dr["saldo_total_pendiente"]);
                        }
                    }
                }
            }
            catch { reporte = null; }
            return reporte;
        }
    }
}
