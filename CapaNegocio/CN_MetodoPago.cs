using CapaDato;
using CapaModelo;
using System;

namespace CapaNegocio
{
    public class CN_MetodoPago
    {
        private readonly CD_MetodoPago cdMetodoPago = new CD_MetodoPago();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public CM_MetodoPago_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            return cdMetodoPago.Listar(busqueda, pagina, tamanoPagina);
        }

        public CM_MetodoPago Obtener(int idMetodoPago)
        {
            return cdMetodoPago.Obtener(idMetodoPago);
        }

        public bool Registrar(CM_MetodoPago obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.metodo))
            {
                Mensaje = "El método de pago es obligatorio.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.referencia))
            {
                Mensaje = "La referencia es obligatoria.";
                return false;
            }

            bool resultado = cdMetodoPago.Registrar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Registró método de pago: " + obj.metodo, idUsuarioSesion);

            return resultado;
        }

        public bool Editar(CM_MetodoPago obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.id_metodo_pago <= 0)
            {
                Mensaje = "Método de pago no válido.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.metodo))
            {
                Mensaje = "El método de pago es obligatorio.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.referencia))
            {
                Mensaje = "La referencia es obligatoria.";
                return false;
            }

            bool resultado = cdMetodoPago.Editar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Editó método de pago ID: " + obj.id_metodo_pago, idUsuarioSesion);

            return resultado;
        }

        public bool Eliminar(int idMetodoPago, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (idMetodoPago <= 0)
            {
                Mensaje = "Método de pago no válido.";
                return false;
            }

            bool resultado = cdMetodoPago.Eliminar(idMetodoPago, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Eliminó método de pago ID: " + idMetodoPago, idUsuarioSesion);

            return resultado;
        }
    }
}
