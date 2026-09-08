using CapaDato;
using CapaModelo;
using System;
using static CapaModelo.CM_Persona;

namespace CapaNegocio
{
    public class CN_Persona
    {
        private readonly CD_Persona cdPersona = new CD_Persona();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public CM_Persona_Paginado Listar(string busqueda, int pagina, int tamanoPagina)
        {
            return cdPersona.Listar(busqueda, pagina, tamanoPagina);
        }

        // Personas disponibles para asignar como socio (menos de 4 socios)
        public CM_Persona_Paginado ListarDisponiblesParaSocio(string busqueda, int pagina, int tamanoPagina)
        {
            return cdPersona.ListarDisponiblesParaSocio(busqueda, pagina, tamanoPagina);
        }

        public CM_Persona Obtener(int idPersona)
        {
            return cdPersona.Obtener(idPersona);
        }

        public bool Registrar(CM_Persona obj, int idUsuarioSesion, out string Mensaje)
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

            bool resultado = cdPersona.Registrar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Registró persona: " + obj.nombre_completo, idUsuarioSesion);

            return resultado;
        }

        public bool Editar(CM_Persona obj, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.id_persona <= 0)
            {
                Mensaje = "Persona no válida.";
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

            bool resultado = cdPersona.Editar(obj, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Editó persona ID: " + obj.id_persona, idUsuarioSesion);

            return resultado;
        }

        public bool CambiarEstado(int idPersona, int idUsuarioSesion, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (idPersona <= 0)
            {
                Mensaje = "Persona no válida.";
                return false;
            }

            bool resultado = cdPersona.CambiarEstado(idPersona, idUsuarioSesion, out Mensaje);

            if (resultado)
                cnBitacora.Registrar("Cambió estado de la persona ID: " + idPersona, idUsuarioSesion);

            return resultado;
        }
    }
}