using CapaDato;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static CapaModelo.CM_Socio;

namespace CapaNegocio
{
    public class CN_Socio
    {
        private readonly CD_Socio cdSocio = new CD_Socio();
        private readonly CN_Bitacora cdBitacora = new CN_Bitacora();

        public CM_SocioListado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            return cdSocio.Listar(busqueda, pagina, tamanoPagina);
        }

        public CM_Socio Obtener(int idSocio)
        {
            return cdSocio.Obtener(idSocio);
        }

        public int Registrar(CM_Socio socio, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(socio.nombre_socio))
            {
                Mensaje = "El nombre del socio es obligatorio.";
                return 0;
            }
            if (socio.cliente_id_cliente <= 0)
            {
                Mensaje = "Debe seleccionar un cliente.";
                return 0;
            }
            if (socio.medidor_id_medidor <= 0)
            {
                Mensaje = "Debe seleccionar un medidor.";
                return 0;
            }
            if (socio.ruta_id_ruta <= 0)
            {
                Mensaje = "Debe seleccionar una ruta.";
                return 0;
            }
            if (socio.rol_socio_id_rol_socio <= 0)
            {
                Mensaje = "Debe seleccionar un rol de socio.";
                return 0;
            }
            if (string.IsNullOrWhiteSpace(socio.actividad))
            {
                Mensaje = "La actividad es obligatoria.";
                return 0;
            }
            if (string.IsNullOrWhiteSpace(socio.categoria))
            {
                Mensaje = "La categoría es obligatoria.";
                return 0;
            }
            if (socio.codigo_fijo <= 0)
            {
                Mensaje = "El código fijo es obligatorio.";
                return 0;
            }

            int idGenerado = cdSocio.Registrar(socio, idUsuarioSesion, out Mensaje);

            if (idGenerado > 0)
                cdBitacora.Registrar("Registro de nuevo socio: " + socio.nombre_socio, idUsuarioSesion);

            return idGenerado;
        }

        public bool Editar(CM_Socio socio, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(socio.nombre_socio))
            {
                Mensaje = "El nombre del socio es obligatorio.";
                return false;
            }
            if (socio.medidor_id_medidor <= 0)
            {
                Mensaje = "Debe seleccionar un medidor.";
                return false;
            }
            if (socio.ruta_id_ruta <= 0)
            {
                Mensaje = "Debe seleccionar una ruta.";
                return false;
            }
            if (socio.codigo_fijo <= 0)
            {
                Mensaje = "El código fijo es obligatorio.";
                return false;
            }

            bool resultado = cdSocio.Editar(socio, idUsuarioSesion, out Mensaje);

            if (resultado)
                cdBitacora.Registrar("Edición del socio: " + socio.nombre_socio, idUsuarioSesion);

            return resultado;
        }

        public bool Eliminar(int idSocio, int idUsuarioSesion, out string Mensaje)
        {
            bool resultado = cdSocio.Eliminar(idSocio, idUsuarioSesion, out Mensaje);

            if (resultado)
                cdBitacora.Registrar("Eliminación del socio con ID: " + idSocio, idUsuarioSesion);

            return resultado;
        }
    }
}
