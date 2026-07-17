using CapaDato;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Linq;

namespace CapaNegocio
{
    public class CN_Pago
    {
        private readonly CD_Pago     cdPago     = new CD_Pago();
        private readonly CN_Bitacora cnBitacora = new CN_Bitacora();

        public CM_AvisoPorCobrarListado ListarAvisosPorCobrar(string busqueda, int pagina, int tamanoPagina)
        {
            return cdPago.ListarAvisosPorCobrar(busqueda, pagina, tamanoPagina);
        }

        public bool RegistrarPago(int idAviso, int idCaja, int idMetodoPago, decimal? montoRecibido,
                                  int idUsuario, string cajero, out int idPago, out string Mensaje)
        {
            Mensaje = string.Empty;
            idPago = 0;

            if (idAviso <= 0)      { Mensaje = "Debe seleccionar un aviso.";        return false; }
            if (idMetodoPago <= 0) { Mensaje = "Debe seleccionar un método de pago."; return false; }

            bool ok = cdPago.RegistrarPago(idAviso, idCaja, idMetodoPago, montoRecibido, cajero, out idPago, out Mensaje);
            if (ok)
                cnBitacora.Registrar("Cobró el aviso #" + idAviso + " (caja #" + idCaja + ")", idUsuario);
            return ok;
        }

        public List<CM_Pago> ListarPagosCaja(int idCaja)
        {
            return cdPago.ListarPagosCaja(idCaja);
        }

        // ---- Pago QR (pasarela Libelula) ------------------------------------

        // Registra la deuda en Libelula y guarda el pago PENDIENTE con su QR.
        // Si el aviso ya tiene un QR pendiente vigente, lo reutiliza (no duplica
        // deudas en la pasarela).
        public bool GenerarPagoQr(int idAviso, int? idCaja, string cajero, int idUsuario,
                                  CN_Libelula libelula, string callbackUrl,
                                  out CM_PagoQrPendiente qr, out string Mensaje)
        {
            qr = null;
            Mensaje = string.Empty;

            if (idAviso <= 0) { Mensaje = "Debe seleccionar un aviso."; return false; }

            var datos = cdPago.ObtenerDatosDeudaQr(idAviso);
            if (datos == null)               { Mensaje = "Aviso no encontrado.";      return false; }
            if (datos.estado == "PAGADO")    { Mensaje = "El aviso ya esta pagado.";  return false; }
            if (datos.estado == "ANULADO")   { Mensaje = "El aviso esta anulado.";    return false; }
            if (string.IsNullOrWhiteSpace(datos.email))
            {
                Mensaje = "El socio no tiene email registrado (requerido por la pasarela). " +
                          "Actualice el email del cliente e intente de nuevo.";
                return false;
            }

            if (datos.Pendiente != null)
            {
                qr = datos.Pendiente;
                Mensaje = "Ya existe un QR vigente para este aviso.";
                return true;
            }

            // Identificador unico por intento (Libelula no admite repetirlo)
            string identificador = string.Format("AVISO-{0}-{1:yyyyMMddHHmmss}", idAviso, DateTime.Now);

            var solicitud = new CM_LibelulaDeudaRequest
            {
                email_cliente  = datos.email,
                identificador  = identificador,
                descripcion    = "Aviso de cobranza #" + idAviso + " - " + datos.nombre_periodo,
                // La deuda caduca en Libelula al final del dia: un QR abandonado
                // (p.ej. el socio termino pagando en efectivo) no puede pagarse
                // dias despues y generar un doble cobro.
                fecha_vencimiento = DateTime.Now.ToString("yyyy-MM-dd") + " 23:59",
                callback_url   = callbackUrl,
                nombre_cliente = datos.nombre_socio,
                emite_factura  = false,
                lineas_detalle_deuda = datos.Detalles.Select(d => new CM_LibelulaLineaDetalle
                {
                    concepto       = d.concepto,
                    cantidad       = 1,
                    costo_unitario = d.subtotal
                }).ToList()
            };

            // La foto inmutable del aviso es total_aviso: si el detalle no suma
            // exacto (redondeos), se cobra en una sola linea por el total.
            if (solicitud.lineas_detalle_deuda.Count == 0 ||
                solicitud.lineas_detalle_deuda.Sum(l => l.costo_unitario) != datos.total_aviso)
            {
                solicitud.lineas_detalle_deuda = new List<CM_LibelulaLineaDetalle>
                {
                    new CM_LibelulaLineaDetalle
                    {
                        concepto       = "Aviso de cobranza " + datos.nombre_periodo,
                        cantidad       = 1,
                        costo_unitario = datos.total_aviso
                    }
                };
            }

            CM_LibelulaDeudaResponse respuesta;
            try
            {
                respuesta = libelula.RegistrarDeuda(solicitud);
            }
            catch (Exception ex)
            {
                Mensaje = "No se pudo comunicar con la pasarela: " + ex.Message;
                return false;
            }

            if (respuesta.error || string.IsNullOrWhiteSpace(respuesta.id_transaccion))
            {
                Mensaje = "La pasarela rechazo la deuda: " + (respuesta.mensaje ?? "sin detalle");
                return false;
            }

            bool ok = cdPago.RegistrarPagoQrPendiente(idAviso, idCaja, cajero,
                                                      identificador, respuesta.id_transaccion,
                                                      respuesta.url_pasarela_pagos, respuesta.qr_simple_url,
                                                      out int idPago, out Mensaje);
            if (!ok) return false;

            qr = new CM_PagoQrPendiente
            {
                id_pago        = idPago,
                id_transaccion = respuesta.id_transaccion,
                url_pasarela   = respuesta.url_pasarela_pagos,
                qr_url         = respuesta.qr_simple_url
            };
            cnBitacora.Registrar("Genero QR de cobro para el aviso #" + idAviso, idUsuario);
            return true;
        }

        // Confirma un pago QR notificado por el callback de Libelula.
        // Antes de aprobar, verifica contra la pasarela que la deuda este pagada
        // (el callback GET no viene firmado). Idempotente.
        public bool ConfirmarPagoQr(string transactionId, CN_Libelula libelula, out string Mensaje)
        {
            Mensaje = string.Empty;

            if (string.IsNullOrWhiteSpace(transactionId))
            { Mensaje = "Falta el identificador de la transaccion."; return false; }

            var pago = cdPago.ObtenerPagoQrPorTransaccion(transactionId);
            if (pago == null) { Mensaje = "Transaccion no registrada en el sistema."; return false; }
            if (pago.estado_pago == "APROBADO") { Mensaje = "El pago ya estaba confirmado."; return true; }

            CM_LibelulaDeudaEstado estado;
            try
            {
                estado = libelula.ConsultarDeudaPorIdentificador(pago.identificador_deuda);
            }
            catch (Exception ex)
            {
                Mensaje = "No se pudo verificar el pago con la pasarela: " + ex.Message;
                return false;
            }

            if (estado == null || !estado.pagado)
            { Mensaje = "La pasarela no confirma el pago de esta deuda."; return false; }

            return cdPago.ConfirmarPagoQr(transactionId, estado.forma_pago, estado.codigo_recaudacion,
                                          out _, out Mensaje);
        }

        // Estado actual de un pago (polling de la pantalla de cobro)
        public string ObtenerEstadoPago(int idPago)
        {
            return cdPago.ObtenerEstadoPago(idPago);
        }

        // Cruza los pagos QR PENDIENTES contra Libelula y confirma los ya pagados.
        public int ConciliarPagosQr(CN_Libelula libelula, int idUsuario, out string Mensaje)
        {
            Mensaje = string.Empty;
            var pendientes = cdPago.ListarPagosQrPendientes();
            if (pendientes == null) { Mensaje = "Error al listar los pagos pendientes."; return 0; }
            if (pendientes.Count == 0) { Mensaje = "No hay pagos QR pendientes."; return 0; }

            int confirmados = 0;
            var errores = new List<string>();
            foreach (var p in pendientes)
            {
                if (ConfirmarPagoQr(p.id_transaccion, libelula, out string msg))
                    confirmados++;
                else if (!msg.StartsWith("La pasarela no confirma"))
                    errores.Add("Pago #" + p.id_pago + ": " + msg);
            }

            Mensaje = confirmados + " de " + pendientes.Count + " pagos confirmados."
                      + (errores.Count > 0 ? " Errores: " + string.Join(" | ", errores) : "");
            if (confirmados > 0)
                cnBitacora.Registrar("Concilio pagos QR con la pasarela (" + confirmados + " confirmados)", idUsuario);
            return confirmados;
        }

        public CM_ReciboPago ObtenerReciboPago(int idPago)
        {
            return cdPago.ObtenerReciboPago(idPago);
        }

        public CM_ReciboPago ObtenerReciboInscripcion(int idPago)
        {
            return cdPago.ObtenerReciboInscripcion(idPago);
        }
    }
}
