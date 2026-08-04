using System;
using System.Collections.Generic;

namespace CapaModelo
{
    public class CM_Aviso
    {
        public int      id_aviso                       { get; set; }
        public DateTime fecha_emision                  { get; set; }
        public DateTime fecha_vencimiento              { get; set; }
        public decimal  total_consumo                  { get; set; }
        public decimal  total_aviso                    { get; set; }
        public decimal  deuda_actual                   { get; set; }
        public string   estado                         { get; set; }
        public int      estado_id_estado               { get; set; }
        public int      socio_id_socio                 { get; set; }
        public int      periodo_id_periodo             { get; set; }
        public int?     cargo_extra_id_carga_extra     { get; set; }
        public int?     credito_inscripcion_id_credito { get; set; }
        public int?     lectura_id_lectura             { get; set; }
        public int?     caja_id_caja                   { get; set; }

        // Campos de display (vienen de JOINs en los SPs)
        public string nombre_socio      { get; set; }
        public int    codigo_fijo       { get; set; }
        public string nombre_periodo    { get; set; }
        public string nombre_ruta       { get; set; }
        public string nombre_estado     { get; set; }
        public bool   tiene_cargo_extra { get; set; }
        public bool   tiene_credito     { get; set; }

        public class CM_AvisoListado
        {
            public int            TotalRegistros { get; set; }
            public List<CM_Aviso> Avisos         { get; set; }
        }
    }

    public class CM_Estado
    {
        public int    id_estado { get; set; }
        public string estado    { get; set; }
    }

    public class CM_AvisoDetalle
    {
        public int      id_aviso                { get; set; }
        public DateTime fecha_emision           { get; set; }
        public DateTime fecha_vencimiento       { get; set; }
        public decimal  total_consumo           { get; set; }
        public decimal  total_aviso             { get; set; }
        public decimal  deuda_actual            { get; set; }
        public string   nombre_estado           { get; set; }
        // Socio
        public string   nombre_socio            { get; set; }
        public int      codigo_fijo             { get; set; }
        // Ruta / Período
        public string   nombre_ruta             { get; set; }
        public string   nombre_periodo          { get; set; }
        // Medidor / Lectura
        public string   serie_medidor           { get; set; }
        public decimal  lectura_anterior        { get; set; }
        public decimal  lectura_actual          { get; set; }
        public decimal  consumo_m3              { get; set; }
        public int      dias_lectura            { get; set; }
        // Tarifa
        public string   nombre_rol              { get; set; }
        public decimal  monto_minimo            { get; set; }
        public decimal  consumo_minimo_m3       { get; set; }
        public decimal  precio_m3               { get; set; }
        // Cargos extra estampados en el aviso (1:N)
        public decimal             total_cargos { get; set; }
        public List<CM_CargoExtra> cargos       { get; set; }
        // Crédito de inscripción (0..1) — suma al total
        public decimal? monto_credito           { get; set; }
    }

    // ---- HU22: Reporte de Morosidad ----

    public class CM_MorosidadFila
    {
        public int      id_socio          { get; set; }
        public string   nombre_socio      { get; set; }
        public int      codigo_fijo       { get; set; }
        public string   nombre_ruta       { get; set; }
        public string   nombre_periodo    { get; set; }
        public int      id_aviso          { get; set; }
        public DateTime fecha_emision     { get; set; }
        public DateTime fecha_vencimiento { get; set; }
        public decimal  monto_adeudado    { get; set; }
        public int      dias_mora         { get; set; }
    }

    public class CM_ReporteMorosidad
    {
        public List<CM_MorosidadFila> Avisos         { get; set; }
        public int                    CantidadSocios { get; set; }
        public int                    CantidadAvisos { get; set; }
        public decimal                TotalAdeudado  { get; set; }
    }
}
