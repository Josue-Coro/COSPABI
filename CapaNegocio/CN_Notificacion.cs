using CapaDato;
using CapaModelo;
using System;

namespace CapaNegocio
{
    public class CN_Notificacion
    {
        private readonly CD_Notificacion cdNotificacion = new CD_Notificacion();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public CM_Notificacion_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            return cdNotificacion.Listar(busqueda, pagina, tamanoPagina);
        }

        public CM_Notificacion Obtener(int idNotificacion)
        {
            return cdNotificacion.Obtener(idNotificacion);
        }

        public bool Registrar(CM_Notificacion obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.titulo))
            {
                Mensaje = "El título es obligatorio.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.mensaje))
            {
                Mensaje = "El mensaje es obligatorio.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.tipo))
            {
                Mensaje = "El tipo de notificación es obligatorio.";
                return false;
            }

            bool resultado = cdNotificacion.Registrar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Registró notificación: " + obj.titulo, idUsuarioSesion);

            return resultado;
        }

        public bool Editar(CM_Notificacion obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.id_notificacion <= 0)
            {
                Mensaje = "Notificación no válida.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.titulo))
            {
                Mensaje = "El título es obligatorio.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.mensaje))
            {
                Mensaje = "El mensaje es obligatorio.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.tipo))
            {
                Mensaje = "El tipo de notificación es obligatorio.";
                return false;
            }

            bool resultado = cdNotificacion.Editar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Editó notificación ID: " + obj.id_notificacion, idUsuarioSesion);

            return resultado;
        }

        public bool Eliminar(int idNotificacion, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (idNotificacion <= 0)
            {
                Mensaje = "Notificación no válida.";
                return false;
            }

            bool resultado = cdNotificacion.Eliminar(idNotificacion, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Eliminó notificación ID: " + idNotificacion, idUsuarioSesion);

            return resultado;
        }

        public System.Collections.Generic.List<CM_NotificacionSocioItem> ListarSociosAsignados(int idNotificacion)
        {
            return cdNotificacion.ListarSociosAsignados(idNotificacion);
        }
    }
}
