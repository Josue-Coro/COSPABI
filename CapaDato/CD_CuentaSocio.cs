using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_CuentaSocio
    {
        public CM_CuentaSocio_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_CuentaSocio_Paginado
            {
                Cuentas = new List<CM_CuentaSocio>()
            };

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_cuenta_socio", cn);
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
                            resultado.Cuentas.Add(new CM_CuentaSocio
                            {
                                id_cuenta_socio = Convert.ToInt32(dr["id_cuenta_socio"]),
                                usuario = dr["usuario"].ToString(),
                                ultimo_acceso = Convert.ToDateTime(dr["ultimo_acceso"]),
                                estado = Convert.ToBoolean(dr["estado"]),
                                socio_id_socio = Convert.ToInt32(dr["socio_id_socio"]),
                                nombre_socio = dr["nombre_socio"].ToString()
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

        public CM_CuentaSocio Obtener(int idCuentaSocio)
        {
            CM_CuentaSocio cuenta = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_cuenta_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdCuentaSocio", idCuentaSocio);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        cuenta = new CM_CuentaSocio
                        {
                            id_cuenta_socio = Convert.ToInt32(dr["id_cuenta_socio"]),
                            usuario = dr["usuario"].ToString(),
                            ultimo_acceso = Convert.ToDateTime(dr["ultimo_acceso"]),
                            estado = Convert.ToBoolean(dr["estado"]),
                            socio_id_socio = Convert.ToInt32(dr["socio_id_socio"])
                        };
                    }
                    dr.Close();
                }
            }
            catch
            {
                cuenta = null;
            }
            return cuenta;
        }

        public bool Registrar(CM_CuentaSocio cuenta, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_cuenta_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Usuario", cuenta.usuario);
                    cmd.Parameters.AddWithValue("@Contrasena", cuenta.contrasena);
                    cmd.Parameters.AddWithValue("@IdSocio", cuenta.socio_id_socio);

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

        public bool Editar(CM_CuentaSocio cuenta, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_editar_cuenta_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdCuentaSocio", cuenta.id_cuenta_socio);
                    cmd.Parameters.AddWithValue("@Usuario", cuenta.usuario);
                    cmd.Parameters.AddWithValue("@Contrasena", cuenta.contrasena ?? "");
                    cmd.Parameters.AddWithValue("@IdSocio", cuenta.socio_id_socio);

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

        public bool CambiarEstado(int idCuentaSocio, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_cambiar_estado_cuenta_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdCuentaSocio", idCuentaSocio);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        resultado = true;
                        Mensaje = "Estado actualizado correctamente.";
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

        // ---- Portal del Socio (HU18/HU19) ----

        public CM_PortalResumen ObtenerResumenPortal(int idSocio)
        {
            CM_PortalResumen resumen = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_portal_resumen_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            resumen = new CM_PortalResumen
                            {
                                deuda_total             = Convert.ToDecimal(dr["deuda_total"]),
                                avisos_pendientes       = Convert.ToInt32(dr["avisos_pendientes"]),
                                avisos_vencidos         = Convert.ToInt32(dr["avisos_vencidos"]),
                                notificaciones_sin_leer = Convert.ToInt32(dr["notificaciones_sin_leer"])
                            };
                        }
                    }
                }
            }
            catch { resumen = null; }
            return resumen;
        }

        public List<CM_PortalAviso> ListarAvisosPortal(int idSocio)
        {
            var lista = new List<CM_PortalAviso>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_portal_avisos_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_PortalAviso
                            {
                                id_aviso          = Convert.ToInt32(dr["id_aviso"]),
                                nombre_periodo    = dr["nombre_periodo"].ToString(),
                                fecha_emision     = Convert.ToDateTime(dr["fecha_emision"]),
                                fecha_vencimiento = Convert.ToDateTime(dr["fecha_vencimiento"]),
                                consumo_m3        = dr["consumo_m3"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(dr["consumo_m3"]),
                                total_aviso       = Convert.ToDecimal(dr["total_aviso"]),
                                deuda_actual      = Convert.ToDecimal(dr["deuda_actual"]),
                                estado            = dr["estado"].ToString(),
                                vencido           = Convert.ToInt32(dr["vencido"]) == 1
                            });
                        }
                    }
                }
            }
            catch { lista = null; }
            return lista;
        }

        public List<CM_PortalPago> ListarPagosPortal(int idSocio)
        {
            var lista = new List<CM_PortalPago>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_portal_pagos_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_PortalPago
                            {
                                id_pago        = Convert.ToInt32(dr["id_pago"]),
                                fecha_pago     = Convert.ToDateTime(dr["fecha_pago"]),
                                monto_pagado   = Convert.ToDecimal(dr["monto_pagado"]),
                                nombre_metodo  = dr["nombre_metodo"].ToString(),
                                aviso_id_aviso = dr["aviso_id_aviso"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"]),
                                concepto       = dr["concepto"].ToString()
                            });
                        }
                    }
                }
            }
            catch { lista = null; }
            return lista;
        }

        public List<CM_PortalNotificacion> ListarNotificacionesPortal(int idSocio)
        {
            var lista = new List<CM_PortalNotificacion>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_portal_notificaciones_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_PortalNotificacion
                            {
                                id_notificacion_socio = Convert.ToInt32(dr["id_notificacion_socio"]),
                                titulo                = dr["titulo"].ToString(),
                                mensaje               = dr["mensaje"].ToString(),
                                tipo                  = dr["tipo"].ToString(),
                                fecha_publicacion     = Convert.ToDateTime(dr["fecha_publicacion"]),
                                leido                 = Convert.ToBoolean(dr["leido"]),
                                fecha_lectura         = dr["fecha_lectura"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["fecha_lectura"])
                            });
                        }
                    }
                }
            }
            catch { lista = null; }
            return lista;
        }

        public bool MarcarNotificacionLeida(int idNotificacionSocio, int idSocio, out string Mensaje)
        {
            bool ok = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_portal_marcar_notificacion_leida", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_notificacion_socio", idNotificacionSocio);
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.NVarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    ok      = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) > 0;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex) { ok = false; Mensaje = ex.Message; }
            return ok;
        }
    }
}
