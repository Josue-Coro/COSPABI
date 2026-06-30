using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using static CapaModelo.CM_CargoExtra;

namespace CapaDato
{
    public class CD_CargoExtra
    {
        public int Registrar(CM_CargoExtra obj, out string Mensaje)
        {
            int resultado = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_cargo_extra", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_periodo",    obj.periodo_id_periodo);
                    cmd.Parameters.AddWithValue("@id_socio",      obj.socio_id_socio);
                    cmd.Parameters.AddWithValue("@id_tipo_cargo", obj.tipo_cargo_id_tipo);
                    cmd.Parameters.AddWithValue("@monto",         obj.monto);
                    cmd.Parameters.AddWithValue("@descripcion",   obj.descripcion);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cn.Open();
                    cmd.ExecuteNonQuery();
                    resultado = Convert.ToInt32(cmd.Parameters["@Resultado"].Value);
                    Mensaje   = cmd.Parameters["@Mensaje"].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                resultado = 0;
                Mensaje   = ex.Message;
            }
            return resultado;
        }

        public CM_CargoExtraListado Listar(int? idPeriodo, int? idRuta,
                                           string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_CargoExtraListado { Cargos = new List<CM_CargoExtra>() };
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_cargos_extra", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_periodo",   (object)idPeriodo ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@id_ruta",      (object)idRuta    ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Busqueda",     busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina",       pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        resultado.Cargos.Add(new CM_CargoExtra
                        {
                            id_cargo_extra     = Convert.ToInt32(dr["id_cargo_extra"]),
                            monto              = Convert.ToDecimal(dr["monto"]),
                            descripcion        = dr["descripcion"].ToString(),
                            fecha_registro     = Convert.ToDateTime(dr["fecha_registro"]),
                            estado             = dr["estado"].ToString(),
                            tipo_cargo_id_tipo = Convert.ToInt32(dr["tipo_cargo_id_tipo"]),
                            socio_id_socio     = Convert.ToInt32(dr["socio_id_socio"]),
                            periodo_id_periodo = Convert.ToInt32(dr["periodo_id_periodo"]),
                            nombre_socio       = dr["nombre_socio"].ToString(),
                            codigo_fijo        = Convert.ToInt32(dr["codigo_fijo"]),
                            nombre_periodo     = dr["nombre_periodo"].ToString(),
                            nombre_tipo_cargo  = dr["nombre_tipo_cargo"].ToString(),
                            nombre_ruta        = dr["nombre_ruta"].ToString(),
                            aplicado           = Convert.ToBoolean(dr["aplicado"])
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

        public List<CM_Socio> BuscarSocios(string busqueda)
        {
            var lista = new List<CM_Socio>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    string sql = @"SELECT TOP 10 id_socio, nombre_socio, codigo_fijo
                                   FROM socio
                                   WHERE nombre_socio LIKE '%' + @b + '%'
                                      OR CAST(codigo_fijo AS VARCHAR) LIKE '%' + @b + '%'
                                   ORDER BY codigo_fijo";
                    SqlCommand cmd = new SqlCommand(sql, cn);
                    cmd.Parameters.AddWithValue("@b", busqueda ?? "");
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                        lista.Add(new CM_Socio
                        {
                            id_socio     = Convert.ToInt32(dr["id_socio"]),
                            nombre_socio = dr["nombre_socio"].ToString(),
                            codigo_fijo  = Convert.ToInt32(dr["codigo_fijo"])
                        });
                    dr.Close();
                }
            }
            catch { }
            return lista;
        }

        public bool Anular(int idCargo, out string Mensaje)
        {
            bool ok = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_anular_cargo_extra", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_cargo_extra", idCargo);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction          = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje",   SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
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
