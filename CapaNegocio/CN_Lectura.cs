using CapaDato;
using CapaModelo;
using System;
using System.Collections.Generic;
using static CapaModelo.CM_Lectura;

namespace CapaNegocio
{
    public class CN_Lectura
    {
        private readonly CD_Lectura cdLectura   = new CD_Lectura();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public List<CM_MedidorParaLectura> ListarMedidoresParaLectura(int idRuta, int idPeriodo)
        {
            return cdLectura.ListarMedidoresParaLectura(idRuta, idPeriodo);
        }

        public int Registrar(CM_Lectura obj, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (obj.medidor_id_medidor <= 0)
            {
                Mensaje = "Medidor no válido.";
                return 0;
            }
            if (obj.periodo_id_periodo <= 0)
            {
                Mensaje = "Debe seleccionar un período.";
                return 0;
            }
            if (obj.ruta_id_ruta <= 0)
            {
                Mensaje = "Debe seleccionar una ruta.";
                return 0;
            }
            if (obj.lectura_actual < 0)
            {
                Mensaje = "La lectura actual no puede ser negativa.";
                return 0;
            }

            int idGenerado = cdLectura.Registrar(obj, idUsuario, out Mensaje);

            if (idGenerado > 0)
                cnBitacora.Registrar("Registró lectura del medidor " + obj.serie_medidor + " (Período: " + obj.periodo_id_periodo + ")", idUsuario);

            return idGenerado;
        }

        public CM_LecturaListado Listar(int? idPeriodo, int? idRuta, string busqueda, int pagina, int tamanoPagina)
        {
            return cdLectura.Listar(idPeriodo, idRuta, busqueda, pagina, tamanoPagina);
        }

        // Genera mes actual + 12 anteriores como "MM/YYYY" y los auto-crea en BD
        public List<CM_Periodo> ListarPeriodosAutomaticos()
        {
            var lista = new List<CM_Periodo>();
            var ahora = DateTime.Today;

            for (int i = 0; i < 13; i++)
            {
                var fecha  = ahora.AddMonths(-i);
                var nombre = fecha.Month.ToString("D2") + "/" + fecha.Year;
                int id     = cdLectura.ObtenerOCrearPeriodo(nombre);

                if (id > 0)
                    lista.Add(new CM_Periodo { id_periodo = id, periodo = nombre });
            }

            return lista;
        }
    }
}
