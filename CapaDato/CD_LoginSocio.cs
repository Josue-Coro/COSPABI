using CapaModelo;
using System;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_LoginSocio
    {
        public CM_CuentaSocio_Activo Login(string usuario, string contrasena)
        {
            CM_CuentaSocio_Activo cuenta = null;

            using (SqlConnection oConexion = new SqlConnection(CD_Conexion.cn))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_login_socio", oConexion);
                cmd.Parameters.AddWithValue("@Usuario", usuario);
                cmd.Parameters.AddWithValue("@Contrasena", contrasena);
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
                }
                catch
                {
                    cuenta = null;
                }
            }

            return cuenta;
        }
    }
}
