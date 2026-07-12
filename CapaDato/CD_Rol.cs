using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDato
{
    public class CD_Rol
    {
        /*--listar roles sp
        create procedure [dbo].[sp_listar_roles]
        AS
        BEGIN
            SET NOCOUNT ON;

            SELECT [id_rol]
                  ,[nombre]
                  ,[descripcion]
                  ,[estado]
              FROM [dbo].[rol]
        END
        go*/
        public List<CM_Rol> Listar(bool incluirSuperadmin = true)
        {
            List<CM_Rol> lista = new List<CM_Rol>();
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    SqlCommand cmd = new SqlCommand("sp_listar_roles", conexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IncluirSuperadmin", incluirSuperadmin);
                    conexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new CM_Rol()
                            {
                                id_rol = Convert.ToInt32(dr["id_rol"]),
                                nombre = dr["nombre"].ToString(),
                                descripcion = dr["descripcion"].ToString(),
                                estado = Convert.ToBoolean(dr["estado"])
                            });
                        }
                    }
                }
            }
            catch 
            {
                lista = new List<CM_Rol>();
            }
            return lista;
        }
        /*--crear rol sp 
        create procedure [dbo].[sp_crear_rol]
            @nombre nvarchar(100),
            @descripcion nvarchar(255),
            @estado bit,
            @Resultado INT OUTPUT,
            @Mensaje VARCHAR(500) OUTPUT
        as
        begin
            SET NOCOUNT ON;
            SET @Resultado = 0;
            SET @Mensaje = '';

            -- Validar que el nombre no esté duplicado
            IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE nombre = @nombre)
            BEGIN
                INSERT INTO [dbo].[rol] (nombre, descripcion, estado)
                VALUES (@nombre, @descripcion, @estado);
                SET @Resultado = SCOPE_IDENTITY();
                SET @Mensaje = 'Rol registrado correctamente.';
            END
            ELSE
                SET @Mensaje = 'Ya existe un rol con este nombre.';
    
        end*/
        //crae rol
        public int Registrar(CM_Rol obj, int idUsuario, out string Mensaje)
        {
            int idGenerado = 0;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_crear_rol", conexion))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@nombre", obj.nombre);
                        cmd.Parameters.AddWithValue("@descripcion", obj.descripcion);
                        cmd.Parameters.AddWithValue("@estado", obj.estado);
                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;

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

        /*--editar rol sp
        create procedure [dbo].[sp_editar_rol]
            @id_rol int,
            @nombre nvarchar(100),
            @descripcion nvarchar(255),
            @estado bit,
            @Resultado INT OUTPUT,
            @Mensaje VARCHAR(500) OUTPUT
        AS
        BEGIN
            SET NOCOUNT ON;
            SET @Resultado = 0;
            SET @Mensaje = '';
            IF NOT EXISTS (SELECT 1 FROM [dbo].[rol] WHERE nombre = @nombre)
            BEGIN
                  UPDATE [dbo].[rol]
                  SET nombre = @nombre, descripcion = @descripcion, estado = @estado
                  WHERE id_rol = @id_rol;

                  SET @Resultado = 1;
                  SET @Mensaje = 'Rol actualizado correctamente.';
             END
             ELSE
                  SET @Mensaje = 'Ya existe un rol con este nombre.';
        END
        */
        public bool Editar(CM_Rol obj, int idUsuario, bool solicitanteEsSuperadmin, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_editar_rol", conexion))
                    {
                        cmd.Parameters.AddWithValue("@id_rol", obj.id_rol);
                        cmd.Parameters.AddWithValue("@nombre", obj.nombre);
                        cmd.Parameters.AddWithValue("@descripcion", obj.descripcion);
                        cmd.Parameters.AddWithValue("@estado", obj.estado);
                        cmd.Parameters.AddWithValue("@SolicitanteEsSuperadmin", solicitanteEsSuperadmin);

                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                        cmd.CommandType = CommandType.StoredProcedure;
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
        /*--eliminar rol sp
        create procedure [dbo].[sp_eliminar_rol]
            @id_rol int,
            @Resultado INT OUTPUT,
            @Mensaje VARCHAR(500) OUTPUT
        AS
        BEGIN
            SET NOCOUNT ON;
            SET @Resultado = 0;
            SET @Mensaje = '';
            IF EXISTS (SELECT 1 FROM [dbo].[rol] WHERE id_rol = @id_rol)
            BEGIN
                UPDATE [dbo].[rol]
                SET estado = 0
                WHERE id_rol = @id_rol;

                SET @Resultado = 1;
                SET @Mensaje = 'Rol eliminado correctamente.';
            END
            ELSE
                SET @Mensaje = 'No existe un rol con este ID.';
        END
        */
        public bool Eliminar(int id_rol, int idUsuario, bool solicitanteEsSuperadmin, out string Mensaje)
        {
            bool resultado = false;
            Mensaje = string.Empty;
            try
            {
                using (SqlConnection conexion = new SqlConnection(CD_Conexion.cn))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_eliminar_rol", conexion))
                    {
                        cmd.Parameters.AddWithValue("@id_rol", id_rol);
                        cmd.Parameters.AddWithValue("@SolicitanteEsSuperadmin", solicitanteEsSuperadmin);
                        cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                        cmd.Parameters.Add("@Resultado", SqlDbType.Int).Direction = ParameterDirection.Output;
                        cmd.CommandType = CommandType.StoredProcedure;
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
