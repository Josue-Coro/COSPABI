using CapaDato;
using CapaModelo;
using System;
using System.Collections.Generic;

namespace CapaNegocio
{
    public class CN_Bitacora
    {
        private readonly CD_Bitacora cdBitacora = new CD_Bitacora();

        public void Registrar(string accion, int idUsuario)
        {
            cdBitacora.Registrar(accion, idUsuario);
        }

        public List<CM_Bitacora> Listar(string fechaInicio, string fechaFin, int idUsuario)
        {
            DateTime? dInicio = null;
            DateTime? dFin = null;

            if (!string.IsNullOrWhiteSpace(fechaInicio) &&
                DateTime.TryParse(fechaInicio, out DateTime fi))
                dInicio = fi;

            if (!string.IsNullOrWhiteSpace(fechaFin) &&
                DateTime.TryParse(fechaFin, out DateTime ff))
                dFin = ff;

            // Si ambas fechas vienen y fin es menor que inicio, invertir silenciosamente
            if (dInicio.HasValue && dFin.HasValue && dFin < dInicio)
            {
                DateTime temp = dInicio.Value;
                dInicio = dFin;
                dFin = temp;
            }

            return cdBitacora.Listar(dInicio, dFin, idUsuario > 0 ? idUsuario : (int?)null);
        }
    }
}