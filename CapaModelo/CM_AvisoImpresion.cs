using System;
using System.Collections.Generic;

namespace CapaModelo
{
    // Datos completos para imprimir un "Aviso de Cobranza" (media carta).
    // Lo llena CD_Aviso.ObtenerParaImpresion a partir de sp_imprimir_aviso (3 result sets).
    public class CM_AvisoImpresion
    {
        // Aviso
        public int      id_aviso          { get; set; }
        public DateTime fecha_emision     { get; set; }
        public DateTime fecha_vencimiento { get; set; }
        public decimal  total_consumo     { get; set; }
        public decimal  total_aviso       { get; set; }
        public decimal  deuda_actual      { get; set; }
        public string   estado            { get; set; }
        public string   nombre_estado     { get; set; }

        // Socio
        public int    id_socio     { get; set; }
        public int    codigo_fijo  { get; set; }
        public string nombre_socio { get; set; }
        public int?   ubicacion    { get; set; }   // COD. UB
        public int?   num_casa     { get; set; }
        public string categoria    { get; set; }
        public string actividad    { get; set; }

        // Ruta / Período
        public string nombre_ruta    { get; set; }
        public string nombre_periodo { get; set; }

        // Medidor / Lectura
        public string    serie_medidor          { get; set; }
        public decimal   lectura_anterior       { get; set; }
        public decimal   lectura_actual         { get; set; }
        public decimal   consumo_m3             { get; set; }
        public int       dias_lectura           { get; set; }
        public DateTime  fecha_lectura_actual   { get; set; }
        public DateTime? fecha_lectura_anterior { get; set; }

        // Tarifa
        public string  nombre_rol        { get; set; }
        public decimal monto_minimo      { get; set; }
        public decimal consumo_minimo_m3 { get; set; }
        public decimal precio_m3         { get; set; }

        // Totales auxiliares
        public decimal  total_cargos  { get; set; }
        public decimal? monto_credito { get; set; }

        // Detalle (Datos Facturados) e Histórico
        public List<CM_CargoExtra>    cargos    { get; set; } = new List<CM_CargoExtra>();
        public List<CM_AvisoHistorico> historico { get; set; } = new List<CM_AvisoHistorico>();
    }

    // Una fila del histórico de avisos del socio (para el recibo).
    public class CM_AvisoHistorico
    {
        public int       id_aviso          { get; set; }
        public string    nombre_periodo    { get; set; }
        public decimal   consumo_m3        { get; set; }
        public decimal   total_aviso       { get; set; }
        public DateTime? fecha_pago        { get; set; }
        public string    estado_pago_label { get; set; }  // 'Pag.' / 'Imp.'
        public string    estado            { get; set; }
    }
}
