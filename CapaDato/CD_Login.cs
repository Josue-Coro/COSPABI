using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CapaModelo;
using System.Data.SqlClient;
using System.Data;

namespace CapaDato
{
    public class CD_Login
    {

        public CM_Usuario_Activo Login(string usuario, string contrasenaHasheada, out string Mensaje)
        {
            CM_Usuario_Activo Usuario = null;
            Mensaje = string.Empty;

            using (SqlConnection oConexion = new SqlConnection(CD_Conexion.cn))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_login_admin", oConexion);
                cmd.Parameters.AddWithValue("@Usuario", usuario);
                cmd.Parameters.AddWithValue("@Contrasena", contrasenaHasheada);
                cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                cmd.Parameters.Add("@Mensaje",   SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                cmd.CommandType = CommandType.StoredProcedure;

                try
                {
                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    // --- PRIMER RESULT SET: DATOS DEL USUARIO ---
                    if (dr.Read())
                    {
                        // Si hay filas, el login fue exitoso. Mapeamos el usuario.
                        Usuario = new CM_Usuario_Activo()
                        {
                            id_usuario_admin = Convert.ToInt32(dr["id_usuario_admin"]),
                            nombre = dr["nombre"].ToString(),
                            apellido = dr["apellido"].ToString(),
                            usuario = dr["usuario"].ToString(),
                            estado = Convert.ToBoolean(dr["EstadoUsuario"]),
                            rol_id_dol = Convert.ToInt32(dr["id_rol"]),
                            nombre_rol = dr["NombreRol"].ToString(),
                            ListaPermisos = new List<CM_Permiso>()
                        };
                    }

                    if (Usuario != null)
                    {
                        if (dr.NextResult())
                        {
                            while (dr.Read())
                            {
                                Usuario.ListaPermisos.Add(new CM_Permiso()
                                {
                                    id_permiso = Convert.ToInt32(dr["id_permiso"]),
                                    accion = dr["accion"].ToString()
                                });
                            }
                        }
                    }

                    dr.Close();

                    // Los OUTPUT params están disponibles después de cerrar el reader
                    Mensaje = cmd.Parameters["@Mensaje"].Value?.ToString() ?? string.Empty;

                }
                catch
                {
                    Usuario = null;
                    Mensaje = "Error de conexión con la base de datos.";
                }
            }
            return Usuario;
        }
    }
}
