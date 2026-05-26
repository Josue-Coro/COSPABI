using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Usuario
    {
        public List<CM_Usuario> Listar()
        {
            List<CM_Usuario> lista = new List<CM_Usuario>();
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_usuarios", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_Usuario()
                            {
                                id_usuario_admin = Convert.ToInt32(dr["id_usuario_admin"]),
                                nombre = dr["nombre"].ToString(),
                                apellido = dr["apellido"].ToString(),
                                usuario = dr["usuario"].ToString(),
                                estado = Convert.ToBoolean(dr["estado"]),
                                fecha_creacion = Convert.ToDateTime(dr["fecha_creacion"]),
                                rol_id_dol = Convert.ToInt32(dr["rol_id_rol"]),
                                rol = new CM_Rol()
                                {
                                    nombre = dr["nombre_rol"].ToString()
                                }
                            });
                        }
                    }
                }
            }
            catch
            {
                lista = new List<CM_Usuario>();
            }
            return lista;
        }

        public int Registrar(CM_Usuario obj, int idUsuarioSesion, out string Mensaje)
        {
            int idGenerado = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_crear_usuario", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@nombre", obj.nombre);
                        cmd.Parameters.AddWithValue("@apellido", obj.apellido);
                        cmd.Parameters.AddWithValue("@usuario", obj.usuario);
                        cmd.Parameters.AddWithValue("@contrasena", obj.contraseña);
                        cmd.Parameters.AddWithValue("@estado", obj.estado);
                        cmd.Parameters.AddWithValue("@rol_id_rol", obj.rol_id_dol);
                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                        conexion.Open();
                        cmd.ExecuteNonQuery();

                        idGenerado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                        Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                idGenerado = 0;
                Mensaje = ex.Message;
            }
            return idGenerado;
        }

        public bool Editar(CM_Usuario obj, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_editar_usuario", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_usuario_admin", obj.id_usuario_admin);
                        cmd.Parameters.AddWithValue("@nombre", obj.nombre);
                        cmd.Parameters.AddWithValue("@apellido", obj.apellido);
                        cmd.Parameters.AddWithValue("@usuario", obj.usuario);
                        // Si contraseña viene vacía se pasa vacío — el SP decide si actualiza o no
                        cmd.Parameters.AddWithValue("@contrasena", obj.contraseña ?? string.Empty);
                        cmd.Parameters.AddWithValue("@estado", obj.estado);
                        cmd.Parameters.AddWithValue("@rol_id_rol", obj.rol_id_dol);
                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                        conexion.Open();
                        cmd.ExecuteNonQuery();

                        resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                        Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }
            return resultado;
        }

        public bool Eliminar(int id_usuario_admin, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_eliminar_usuario", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_usuario_admin", id_usuario_admin);
                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                        conexion.Open();
                        cmd.ExecuteNonQuery();

                        resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                        Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                    }
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