using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Notificacion
    {
        public CM_Notificacion_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_Notificacion_Paginado
            {
                Notificaciones = new List<CM_Notificacion>()
            };

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_notificaciones", cn);
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
                            resultado.Notificaciones.Add(new CM_Notificacion
                            {
                                id_notificacion = Convert.ToInt32(dr["id_notificacion"]),
                                titulo = dr["titulo"].ToString(),
                                mensaje = dr["mensaje"].ToString(),
                                tipo = dr["tipo"].ToString(),
                                fecha_publicacion = Convert.ToDateTime(dr["fecha_publicacion"]),
                                estado = Convert.ToBoolean(dr["estado"])
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

        public CM_Notificacion Obtener(int idNotificacion)
        {
            CM_Notificacion notificacion = null;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_notificacion", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdNotificacion", idNotificacion);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        notificacion = new CM_Notificacion
                        {
                            id_notificacion = Convert.ToInt32(dr["id_notificacion"]),
                            titulo = dr["titulo"].ToString(),
                            mensaje = dr["mensaje"].ToString(),
                            tipo = dr["tipo"].ToString(),
                            fecha_publicacion = Convert.ToDateTime(dr["fecha_publicacion"]),
                            estado = Convert.ToBoolean(dr["estado"])
                        };
                    }
                    dr.Close();
                }
            }
            catch
            {
                notificacion = null;
            }
            return notificacion;
        }

        public bool Registrar(CM_Notificacion notificacion, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            int idGenerado = 0;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_notificacion", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Titulo", notificacion.titulo);
                    cmd.Parameters.AddWithValue("@Mensaje", notificacion.mensaje);
                    cmd.Parameters.AddWithValue("@Tipo", notificacion.tipo);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        idGenerado = Convert.ToInt32(dr["IdGenerado"]);
                        resultado = Convert.ToInt32(dr["Resultado"]) == 1;
                        Mensaje = dr["Mensaje"].ToString();
                    }
                    dr.Close();

                    if (resultado && idGenerado > 0)
                    {
                        SqlCommand cmdAsignar = new SqlCommand("dbo.sp_asignar_notificacion_socios", cn);
                        cmdAsignar.CommandType = CommandType.StoredProcedure;
                        cmdAsignar.Parameters.AddWithValue("@IdNotificacion", idGenerado);
                        cmdAsignar.Parameters.AddWithValue("@EnviarATodos", notificacion.enviar_a_todos);
                        cmdAsignar.Parameters.AddWithValue("@IdsSocios", notificacion.ids_socios ?? "");
                        cmdAsignar.ExecuteNonQuery();
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

        public bool Editar(CM_Notificacion notificacion, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_editar_notificacion", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdNotificacion", notificacion.id_notificacion);
                    cmd.Parameters.AddWithValue("@Titulo", notificacion.titulo);
                    cmd.Parameters.AddWithValue("@Mensaje", notificacion.mensaje);
                    cmd.Parameters.AddWithValue("@Tipo", notificacion.tipo);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        resultado = Convert.ToInt32(dr["Resultado"]) == 1;
                        Mensaje = dr["Mensaje"].ToString();
                    }
                    dr.Close();

                    if (resultado)
                    {
                        SqlCommand cmdAsignar = new SqlCommand("dbo.sp_asignar_notificacion_socios", cn);
                        cmdAsignar.CommandType = CommandType.StoredProcedure;
                        cmdAsignar.Parameters.AddWithValue("@IdNotificacion", notificacion.id_notificacion);
                        cmdAsignar.Parameters.AddWithValue("@EnviarATodos", notificacion.enviar_a_todos);
                        cmdAsignar.Parameters.AddWithValue("@IdsSocios", notificacion.ids_socios ?? "");
                        cmdAsignar.ExecuteNonQuery();
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

        public List<CM_NotificacionSocioItem> ListarSociosAsignados(int idNotificacion)
        {
            var lista = new List<CM_NotificacionSocioItem>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_notificacion_socios", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdNotificacion", idNotificacion);

                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_NotificacionSocioItem
                            {
                                id_notificacion_socio = Convert.ToInt32(dr["id_notificacion_socio"]),
                                socio_id_socio = Convert.ToInt32(dr["socio_id_socio"]),
                                nombre_socio = dr["nombre_socio"].ToString(),
                                codigo_fijo = Convert.ToInt32(dr["codigo_fijo"])
                            });
                        }
                    }
                }
            }
            catch
            {
                lista = new List<CM_NotificacionSocioItem>();
            }
            return lista;
        }

        public bool Eliminar(int idNotificacion, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_eliminar_notificacion", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdNotificacion", idNotificacion);

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
    }
}
