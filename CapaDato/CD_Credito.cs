using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace CapaDato
{
    public class CD_Credito
    {
        // Costo de inscripción vigente = último costo configurado en periodo.costo_inscripcion
        public decimal ObtenerCostoVigente()
        {
            decimal costo = 0;
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_obtener_costo_inscripcion_vigente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cn.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) costo = Convert.ToDecimal(r);
                }
            }
            catch { costo = 0; }
            return costo;
        }

        // Socios con cuotas de inscripción pendientes (resumen paginado)
        public CM_CreditoListado ListarPendientes(string busqueda, int pagina, int tamanoPagina)
        {
            var resultado = new CM_CreditoListado { Creditos = new List<CM_CreditoResumen>() };
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_listar_creditos_pendientes", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Busqueda", busqueda ?? "");
                    cmd.Parameters.AddWithValue("@Pagina", pagina);
                    cmd.Parameters.AddWithValue("@TamanoPagina", tamanoPagina);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        resultado.Creditos.Add(new CM_CreditoResumen
                        {
                            id_socio          = Convert.ToInt32(dr["id_socio"]),
                            codigo_fijo       = Convert.ToInt32(dr["codigo_fijo"]),
                            nombre_socio      = dr["nombre_socio"].ToString(),
                            total_inscripcion = Convert.ToDecimal(dr["total_inscripcion"]),
                            pagado            = Convert.ToDecimal(dr["pagado"]),
                            saldo             = Convert.ToDecimal(dr["saldo"]),
                            cuotas_pendientes = Convert.ToInt32(dr["cuotas_pendientes"]),
                            proximo_periodo   = dr["proximo_periodo"] is DBNull ? null : dr["proximo_periodo"].ToString(),
                            proximo_monto     = Convert.ToDecimal(dr["proximo_monto"])
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

        // Cuotas de inscripción de un socio (detalle)
        public List<CM_Credito> ObtenerDetalle(int idSocio)
        {
            var lista = new List<CM_Credito>();
            try
            {
                using (SqlConnection cn = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_detalle_credito_socio", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@id_socio", idSocio);
                    cn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    while (dr.Read())
                    {
                        lista.Add(new CM_Credito
                        {
                            id_credito     = Convert.ToInt32(dr["id_credito"]),
                            num_cuota      = Convert.ToInt32(dr["num_cuota"]),
                            nombre_periodo = dr["nombre_periodo"].ToString(),
                            monto_pago     = Convert.ToDecimal(dr["monto_pago"]),
                            estado         = dr["estado"].ToString(),
                            en_aviso       = Convert.ToInt32(dr["en_aviso"]) == 1,
                            aviso_id_aviso = dr["aviso_id_aviso"] is DBNull ? (int?)null : Convert.ToInt32(dr["aviso_id_aviso"]),
                            pago_id_pago   = dr["pago_id_pago"] is DBNull ? (int?)null : Convert.ToInt32(dr["pago_id_pago"])
                        });
                    }
                    dr.Close();
                }
            }
            catch { lista = null; }
            return lista;
        }
    }
}
