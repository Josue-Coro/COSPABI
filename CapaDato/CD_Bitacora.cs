using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDato
{
    public class CD_Bitacora
    {
        /// <summary>
        /// Registra una acción en la bitácora del sistema.
        /// Llamar desde cualquier clase de CapaDato tras una operación relevante.
        /// </summary>
        /// <param name="accion">Descripción de la acción realizada.</param>
        /// <param name="idUsuario">ID del usuario admin que realizó la acción.</param>
        /// <returns>True si se registró correctamente, false si hubo error.</returns>
        public bool Registrar(string accion, int idUsuario)
        {
            try
            {
                using (SqlConnection oConexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("dbo.sp_registrar_bitacora", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Accion", accion);
                    cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    return true;
                }
            }
            catch
            {
                return false;
            }
        }
    }
}
