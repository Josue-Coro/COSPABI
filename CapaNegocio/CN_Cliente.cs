using CapaDato;
using CapaModelo;
using System;
using static CapaModelo.CM_Cliente;

namespace CapaNegocio
{
    public class CN_Cliente
    {
        private readonly CD_Cliente cdCliente = new CD_Cliente();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public CM_Cliente_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            return cdCliente.Listar(busqueda, pagina, tamanoPagina);
        }

        public CM_Cliente Obtener(int idCliente)
        {
            return cdCliente.Obtener(idCliente);
        }

        public bool Registrar(CM_Cliente obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.nombre_completo))
            {
                Mensaje = "El nombre completo es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsNombreValido(obj.nombre_completo))
            {
                Mensaje = "El nombre completo solo puede contener letras y espacios (sin números).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.ci))
            {
                Mensaje = "El CI es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsNumerico(obj.ci, 4, 10))
            {
                Mensaje = "El CI debe contener solo números (entre 4 y 10 dígitos).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.genero))
            {
                Mensaje = "El género es obligatorio.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.email))
            {
                Mensaje = "El email es obligatorio (requerido para pagos por QR).";
                return false;
            }
            if (!CN_Recursos.EsEmailValido(obj.email))
            {
                Mensaje = "El email no tiene un formato válido.";
                return false;
            }
            if (obj.fecha_nacimiento == DateTime.MinValue)
            {
                Mensaje = "La fecha de nacimiento es obligatoria.";
                return false;
            }
            if (obj.fecha_nacimiento > DateTime.Today)
            {
                Mensaje = "La fecha de nacimiento no puede ser futura.";
                return false;
            }
            if (obj.fecha_nacimiento < DateTime.Today.AddYears(-120))
            {
                Mensaje = "La fecha de nacimiento no es válida.";
                return false;
            }

            bool resultado = cdCliente.Registrar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Registró cliente: " + obj.nombre_completo, idUsuarioSesion);

            return resultado;
        }

        public bool Editar(CM_Cliente obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.id_cliente <= 0)
            {
                Mensaje = "Cliente no válido.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.nombre_completo))
            {
                Mensaje = "El nombre completo es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsNombreValido(obj.nombre_completo))
            {
                Mensaje = "El nombre completo solo puede contener letras y espacios (sin números).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.ci))
            {
                Mensaje = "El CI es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsNumerico(obj.ci, 4, 10))
            {
                Mensaje = "El CI debe contener solo números (entre 4 y 10 dígitos).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.genero))
            {
                Mensaje = "El género es obligatorio.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.email))
            {
                Mensaje = "El email es obligatorio (requerido para pagos por QR).";
                return false;
            }
            if (!CN_Recursos.EsEmailValido(obj.email))
            {
                Mensaje = "El email no tiene un formato válido.";
                return false;
            }
            if (obj.fecha_nacimiento == DateTime.MinValue)
            {
                Mensaje = "La fecha de nacimiento es obligatoria.";
                return false;
            }
            if (obj.fecha_nacimiento > DateTime.Today)
            {
                Mensaje = "La fecha de nacimiento no puede ser futura.";
                return false;
            }
            if (obj.fecha_nacimiento < DateTime.Today.AddYears(-120))
            {
                Mensaje = "La fecha de nacimiento no es válida.";
                return false;
            }

            bool resultado = cdCliente.Editar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Editó cliente ID: " + obj.id_cliente, idUsuarioSesion);

            return resultado;
        }

        public bool CambiarEstado(int idCliente, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (idCliente <= 0)
            {
                Mensaje = "Cliente no válido.";
                return false;
            }

            bool resultado = cdCliente.CambiarEstado(idCliente, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Cambió estado del cliente ID: " + idCliente, idUsuarioSesion);

            return resultado;
        }
    }
}