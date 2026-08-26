using CapaModelo;
using System;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_LoginSocio
    {
        // Mensaje sale del SP: generico si la credencial falla, explicito si la
        // cuenta quedo bloqueada por intentos fallidos (Migracion 14).
        public CM_CuentaSocio_Activo Login(string usuario, string contrasena, out string mensaje)
        {
            CM_CuentaSocio_Activo cuenta = null;
            mensaje = string.Empty;

            using (SqlConnection oConexion = new SqlConnection(CD_Conexion.cn))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_login_socio", oConexion);
                cmd.Parameters.AddWithValue("@Usuario", usuario);
                cmd.Parameters.AddWithValue("@Contrasena", contrasena);
                cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction         = ParameterDirection.Output;
                cmd.Parameters.Add("@Mensaje",   SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                cmd.CommandType = CommandType.StoredProcedure;

                try
                {
                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        cuenta = new CM_CuentaSocio_Activo()
                        {
                            id_cuenta_socio  = Convert.ToInt32(dr["id_cuenta_socio"]),
                            usuario          = dr["usuario"].ToString(),
                            estado           = Convert.ToBoolean(dr["EstadoCuenta"]),
                            ultimo_acceso    = Convert.ToDateTime(dr["ultimo_acceso"]),
                            socio_id_socio   = Convert.ToInt32(dr["id_socio"]),
                            socio = new CM_Socio()
                            {
                                id_socio               = Convert.ToInt32(dr["id_socio"]),
                                nombre_socio           = dr["nombre_socio"].ToString(),
                                rol_socio_id_rol_socio = Convert.ToInt32(dr["id_rol_socio"]),
                                NombreRolSocio         = dr["NombreRolSocio"].ToString()
                            }
                        };
                    }

                    dr.Close();

                    // Los OUTPUT solo estan disponibles con el reader cerrado.
                    mensaje = cmd.Parameters["@Mensaje"].Value == DBNull.Value
                              ? string.Empty
                              : cmd.Parameters["@Mensaje"].Value.ToString();
                }
                catch
                {
                    cuenta  = null;
                    mensaje = string.Empty;
                }
            }

            return cuenta;
        }
    }
}
