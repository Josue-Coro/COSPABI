using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Usuario
    {
        public List<CM_Usuario> Listar(bool incluirSuperadmin)
        {
            List<CM_Usuario> lista = new List<CM_Usuario>();
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_usuarios", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IncluirSuperadmin", incluirSuperadmin);
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
                                rol_id_rol = Convert.ToInt32(dr["rol_id_rol"]),
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

        public int Registrar(CM_Usuario obj, int idUsuarioSesion, bool solicitanteEsSuperadmin, out string Mensaje)
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
                        cmd.Parameters.AddWithValue("@rol_id_rol", obj.rol_id_rol);
                        cmd.Parameters.AddWithValue("@SolicitanteEsSuperadmin", solicitanteEsSuperadmin);
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

        public bool Editar(CM_Usuario obj, int idUsuarioSesion, bool solicitanteEsSuperadmin, out string Mensaje)
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
                        cmd.Parameters.AddWithValue("@rol_id_rol", obj.rol_id_rol);
                        cmd.Parameters.AddWithValue("@SolicitanteEsSuperadmin", solicitanteEsSuperadmin);
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

        public bool Eliminar(int id_usuario_admin, int idUsuarioSesion, bool solicitanteEsSuperadmin, out string Mensaje)
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
                        cmd.Parameters.AddWithValue("@SolicitanteEsSuperadmin", solicitanteEsSuperadmin);
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

        // ================= Mi perfil (usuario de la sesión) =================

        public CM_PerfilAdmin ObtenerPerfil(int idUsuarioAdmin)
        {
            CM_PerfilAdmin perfil = null;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_obtener_perfil_admin", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_usuario_admin", idUsuarioAdmin);
                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            perfil = new CM_PerfilAdmin()
                            {
                                id_usuario_admin = Convert.ToInt32(dr["id_usuario_admin"]),
                                nombre = dr["nombre"].ToString(),
                                apellido = dr["apellido"].ToString(),
                                usuario = dr["usuario"].ToString(),
                                estado = Convert.ToBoolean(dr["estado"]),
                                fecha_creacion = Convert.ToDateTime(dr["fecha_creacion"]),
                                nombre_rol = dr["nombre_rol"].ToString(),
                                descripcion_rol = dr["descripcion_rol"] == DBNull.Value ? string.Empty : dr["descripcion_rol"].ToString(),
                                cantidad_permisos = Convert.ToInt32(dr["cantidad_permisos"]),
                                acciones_bitacora = Convert.ToInt32(dr["acciones_bitacora"]),
                                ultimo_acceso = dr["ultimo_acceso"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(dr["ultimo_acceso"]),
                                cajas_abiertas_total = Convert.ToInt32(dr["cajas_abiertas_total"])
                            };
                        }
                    }
                }
            }
            catch
            {
                perfil = null;
            }
            return perfil;
        }

        public List<CM_Bitacora> ActividadReciente(int idUsuarioAdmin, int top)
        {
            List<CM_Bitacora> lista = new List<CM_Bitacora>();
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_actividad_reciente_admin", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_usuario_admin", idUsuarioAdmin);
                    cmd.Parameters.AddWithValue("@top", top);
                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_Bitacora()
                            {
                                id_bitacora = Convert.ToInt32(dr["id_bitacora"]),
                                accion = dr["accion"].ToString(),
                                fecha_hora = Convert.ToDateTime(dr["fecha_hora"]),
                                id_usuario = Convert.ToInt32(dr["usuario_admin_id_usuario_admin"]),
                                nombre_completo = dr["nombre_completo"].ToString(),
                                usuario = dr["usuario"].ToString()
                            });
                        }
                    }
                }
            }
            catch
            {
                lista = new List<CM_Bitacora>();
            }
            return lista;
        }

        public bool EditarPerfil(int idUsuarioAdmin, string nombre, string apellido, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_editar_perfil_admin", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_usuario_admin", idUsuarioAdmin);
                        cmd.Parameters.AddWithValue("@nombre", nombre);
                        cmd.Parameters.AddWithValue("@apellido", apellido);
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

        public bool CambiarContrasena(int idUsuarioAdmin, string hashActual, string hashNuevo, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_cambiar_contrasena_admin", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@id_usuario_admin", idUsuarioAdmin);
                        cmd.Parameters.AddWithValue("@contrasena_actual", hashActual);
                        cmd.Parameters.AddWithValue("@contrasena_nueva", hashNuevo);
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
