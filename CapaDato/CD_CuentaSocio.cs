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
    }
}
