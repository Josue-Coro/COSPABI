using CapaDato;
using CapaModelo;
using System;

namespace CapaNegocio
{
    public class CN_CuentaSocio
    {
        private readonly CD_CuentaSocio cdCuenta = new CD_CuentaSocio();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public CM_CuentaSocio_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            return cdCuenta.Listar(busqueda, pagina, tamanoPagina);
        }

        public CM_CuentaSocio Obtener(int idCuentaSocio)
        {
            return cdCuenta.Obtener(idCuentaSocio);
        }

        public bool Registrar(CM_CuentaSocio obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(obj.usuario))
            {
                Mensaje = "El usuario es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsUsuarioValido(obj.usuario))
            {
                Mensaje = "El usuario debe tener de 3 a 30 caracteres, sin espacios (solo letras, números, punto, guion y guion bajo).";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.contrasena))
            {
                Mensaje = "La contraseña es obligatoria.";
                return false;
            }
            if (obj.contrasena.Length < 6)
            {
                Mensaje = "La contraseña debe tener al menos 6 caracteres.";
                return false;
            }
            if (obj.socio_id_socio <= 0)
            {
                Mensaje = "Debe seleccionar un socio válido.";
                return false;
            }

            bool resultado = cdCuenta.Registrar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Registró cuenta de socio: " + obj.usuario, idUsuarioSesion);

            return resultado;
        }

        public bool Editar(CM_CuentaSocio obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.id_cuenta_socio <= 0)
            {
                Mensaje = "Cuenta no válida.";
                return false;
            }
            if (string.IsNullOrWhiteSpace(obj.usuario))
            {
                Mensaje = "El usuario es obligatorio.";
                return false;
            }
            if (!CN_Recursos.EsUsuarioValido(obj.usuario))
            {
                Mensaje = "El usuario debe tener de 3 a 30 caracteres, sin espacios (solo letras, números, punto, guion y guion bajo).";
                return false;
            }
            // Contraseña opcional al editar — solo valida longitud si viene con valor
            if (!string.IsNullOrWhiteSpace(obj.contrasena) && obj.contrasena.Length < 6)
            {
                Mensaje = "La contraseña debe tener al menos 6 caracteres.";
                return false;
            }
            if (obj.socio_id_socio <= 0)
            {
                Mensaje = "Debe seleccionar un socio válido.";
                return false;
            }

            bool resultado = cdCuenta.Editar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Editó cuenta de socio ID: " + obj.id_cuenta_socio, idUsuarioSesion);

            return resultado;
        }

        public bool CambiarEstado(int idCuentaSocio, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (idCuentaSocio <= 0)
            {
                Mensaje = "Cuenta no válida.";
                return false;
            }

            bool resultado = cdCuenta.CambiarEstado(idCuentaSocio, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Cambió estado de la cuenta de socio ID: " + idCuentaSocio, idUsuarioSesion);

            return resultado;
        }
    }
}
