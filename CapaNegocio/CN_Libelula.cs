using CapaModelo;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace CapaNegocio
{
    // Cliente HTTP de la pasarela Libelula (Manual de Integracion v2.145).
    // La configuracion (appkey, url base) la inyecta la capa de presentacion,
    // que es quien conoce Secrets.config.
    public class CN_Libelula
    {
        // Un solo HttpClient por proceso (evita agotar sockets)
        private static readonly HttpClient http = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(30)
        };

        private readonly string appKey;
        private readonly string urlBase;

        public CN_Libelula(string appKey, string urlBase)
        {
            if (string.IsNullOrWhiteSpace(appKey))
                throw new ArgumentException("Falta configurar Libelula.AppKey (Secrets.config).");
            if (string.IsNullOrWhiteSpace(urlBase))
                throw new ArgumentException("Falta configurar Libelula.UrlBase (Secrets.config).");
            this.appKey  = appKey;
            this.urlBase = urlBase.TrimEnd('/');
        }

        // POST /rest/deuda/registrar
        public CM_LibelulaDeudaResponse RegistrarDeuda(CM_LibelulaDeudaRequest solicitud)
        {
            solicitud.appkey = appKey;
            string json = Post("/rest/deuda/registrar", solicitud);
            var respuesta = JsonConvert.DeserializeObject<CM_LibelulaDeudaResponse>(json);
            if (respuesta == null)
                throw new InvalidOperationException("Respuesta vacia de Libelula al registrar la deuda.");
            return respuesta;
        }

        // POST /rest/deuda/consultar_deudas/por_identificador
        // Fuente de verdad para validar el callback: solo se aprueba si pagado = true.
        public CM_LibelulaDeudaEstado ConsultarDeudaPorIdentificador(string identificador)
        {
            string json = Post("/rest/deuda/consultar_deudas/por_identificador",
                               new { appkey = appKey, identificador });
            JObject raiz = JObject.Parse(json);
            JToken datos = raiz["datos"];

            // 'datos' puede venir como objeto o como array de un elemento
            JToken deuda = (datos is JArray arr) ? (arr.Count > 0 ? arr[0] : null) : datos;
            if (deuda == null || deuda.Type == JTokenType.Null)
                return null;
            return deuda.ToObject<CM_LibelulaDeudaEstado>();
        }

        // POST /rest/deuda/consultar_pagos (conciliacion por rango de fechas)
        public List<CM_LibelulaPagoConciliado> ConsultarPagos(DateTime fechaInicial, DateTime fechaFinal)
        {
            string json = Post("/rest/deuda/consultar_pagos", new
            {
                appkey        = appKey,
                fecha_inicial = fechaInicial.ToString("yyyy-MM-dd HH:mm:ss"),
                fecha_final   = fechaFinal.ToString("yyyy-MM-dd HH:mm:ss")
            });
            JObject raiz = JObject.Parse(json);
            var datos = raiz["datos"] as JArray;
            return datos == null
                ? new List<CM_LibelulaPagoConciliado>()
                : datos.ToObject<List<CM_LibelulaPagoConciliado>>();
        }

        private string Post(string ruta, object cuerpo)
        {
            string json = JsonConvert.SerializeObject(cuerpo, new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore
            });
            // Task.Run evita el deadlock del SynchronizationContext de ASP.NET
            // al consumir la API async desde codigo sincrono (MVC 5 clasico).
            return Task.Run(async () =>
            {
                using (var contenido = new StringContent(json, Encoding.UTF8, "application/json"))
                using (HttpResponseMessage respuesta =
                       await http.PostAsync(urlBase + ruta, contenido).ConfigureAwait(false))
                {
                    string cuerpoRespuesta =
                        await respuesta.Content.ReadAsStringAsync().ConfigureAwait(false);
                    if (!respuesta.IsSuccessStatusCode)
                        throw new HttpRequestException(
                            "Libelula respondio HTTP " + (int)respuesta.StatusCode + ": " + cuerpoRespuesta);
                    return cuerpoRespuesta;
                }
            }).GetAwaiter().GetResult();
        }
    }
}
