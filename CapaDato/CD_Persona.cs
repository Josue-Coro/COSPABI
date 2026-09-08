using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using static CapaModelo.CM_Persona;

namespace CapaDato
{
    public class CD_Persona
    {
        public CM_Persona_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            return ListarInterno("dbo.sp_listar_personas", busqueda, pagina, tamanoPagina);
        }

        // Personas que aún pueden ser socio (menos de 4 socios). Para el alta de socio.
        public CM_Persona_Paginado ListarDisponiblesParaSocio(string busqueda, int pagina, int tamanoPagina)
        {
            return ListarInterno("dbo.sp_listar_personas_disponibles_socio", busqueda, pagina, tamanoPagina);
        }

        private CM_Persona_Paginado ListarInterno(string nombreSp, string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_Persona_Paginado
            {
                Personas = new List<CM_Persona>()
            };

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand(nombreSp, cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Busqueda", busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    // Primer result set: total
                    if (dr.Read())
                        resultado.TotalRegistros = Convert.ToInt32(dr["TotalRegistros"]);

                    // Segundo result set: datos
                    if (dr.NextResult())
                    {
                        while (dr.Read())
                        {
                            resultado.Personas.Add(new CM_Persona
                            {
                                id_persona = Convert.ToInt32(dr["id_persona"]),
                                nombre_completo = dr["nombre_completo"].ToString(),
                                ci = dr["ci"].ToString(),
                                genero = dr["genero"].ToString(),
                                telefono = dr["telefono"] == DBNull.Value
                                                       ? (int?)null
                                                       : Convert.ToInt32(dr["telefono"]),
                                fecha_nacimiento = Convert.ToDateTime(dr["fecha_nacimiento"]),
                                fecha_registro = Convert.ToDateTime(dr["fecha_registro"]),
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

        public CM_Persona Obtener(int idPersona)
        {
            CM_Persona persona = null;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_persona", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdPersona", idPersona);

                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        persona = new CM_Persona
                        {
                            id_persona = Convert.ToInt32(dr["id_persona"]),
                            nombre_completo = dr["nombre_completo"].ToString(),
                            ci = dr["ci"].ToString(),
                            genero = dr["genero"].ToString(),
                            telefono = dr["telefono"] == DBNull.Value
                                                   ? (int?)null
                                                   : Convert.ToInt32(dr["telefono"]),
                            fecha_nacimiento = Convert.ToDateTime(dr["fecha_nacimiento"]),
                            fecha_registro = Convert.ToDateTime(dr["fecha_registro"]),
                            estado = Convert.ToBoolean(dr["estado"])
                        };
                    }

                    dr.Close();
                }
            }
            catch
            {
                persona = null;
            }

            return persona;
        }

        public bool Registrar(CM_Persona persona, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_persona", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@NombreCompleto", persona.nombre_completo);
                    cmd.Parameters.AddWithValue("@CI", persona.ci);
                    cmd.Parameters.AddWithValue("@Genero", persona.genero);
                    cmd.Parameters.AddWithValue("@Telefono", (object)persona.telefono ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@FechaNacimiento", persona.fecha_nacimiento);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }

            return resultado;
        }

        public bool Editar(CM_Persona persona, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_editar_persona", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdPersona", persona.id_persona);
                    cmd.Parameters.AddWithValue("@NombreCompleto", persona.nombre_completo);
                    cmd.Parameters.AddWithValue("@CI", persona.ci);
                    cmd.Parameters.AddWithValue("@Genero", persona.genero);
                    cmd.Parameters.AddWithValue("@Telefono", (object)persona.telefono ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@FechaNacimiento", persona.fecha_nacimiento);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
                Mensaje = ex.Message;
            }

            return resultado;
        }

        public bool CambiarEstado(int idPersona, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;

            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_cambiar_estado_persona", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdPersona", idPersona);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cn.Open();
                    cmd.ExecuteNonQuery();

                    resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value) == 1;
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
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