using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;

namespace CapaNegocio
{
    public class CN_Recursos
    {
        // ==================== Validaciones de formato (compartidas por los CN) ====================

        // Nombres de personas/roles: solo letras (incluye acentos y ñ), espacios y . ' - (ej: "Ma. Elena", "D'Alessandro")
        public static bool EsNombreValido(string texto)
        {
            return !string.IsNullOrWhiteSpace(texto)
                && Regex.IsMatch(texto.Trim(), @"^[\p{L}][\p{L} .'\-]*$");
        }

        // Solo dígitos, con longitud entre min y max (ej: CI)
        public static bool EsNumerico(string texto, int min, int max)
        {
            return !string.IsNullOrWhiteSpace(texto)
                && Regex.IsMatch(texto.Trim(), @"^\d{" + min + "," + max + "}$");
        }

        // Email con formato básico correcto (algo@dominio.ext)
        public static bool EsEmailValido(string email)
        {
            return !string.IsNullOrWhiteSpace(email)
                && Regex.IsMatch(email.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]{2,}$");
        }

        // Nombre de usuario: letras, números y . _ - (3 a 30 caracteres, sin espacios)
        public static bool EsUsuarioValido(string usuario)
        {
            return !string.IsNullOrWhiteSpace(usuario)
                && Regex.IsMatch(usuario.Trim(), @"^[a-zA-Z0-9._\-]{3,30}$");
        }

        // Serie de medidor: letras, números y guiones (sin espacios)
        public static bool EsSerieValida(string serie)
        {
            return !string.IsNullOrWhiteSpace(serie)
                && Regex.IsMatch(serie.Trim(), @"^[a-zA-Z0-9\-]+$");
        }

        public string ConvertirSha256(string texto)
        {
            StringBuilder Sb = new StringBuilder();

            using (SHA256 hash = SHA256Managed.Create())
            {
                Encoding enc = Encoding.UTF8;
                byte[] result = hash.ComputeHash(enc.GetBytes(texto));

                foreach (byte b in result)
                    Sb.Append(b.ToString("x2"));

            }
            return Sb.ToString();
        }

        public bool EnviarCorreo(string correo, string asunto, string mensaje)
        {
            bool resultado = false;
            try
            {
                MailMessage mail = new MailMessage();
                mail.To.Add(correo);
                mail.From = new MailAddress("example@gmail.com");
                mail.Subject = asunto;
                mail.Body = mensaje;
                mail.IsBodyHtml = true;

                var smtp = new SmtpClient()
                {
                    Credentials = new NetworkCredential("example@gmail.com", "pvsvxzhphibhdzjh"),
                    Host = "smtp.gmail.com",
                    Port = 587,
                    EnableSsl = true
                };
                smtp.Send(mail);
                resultado = true;

            }
            catch (Exception)
            {
                resultado = false;
            }
            return resultado;
        }
    }
}
