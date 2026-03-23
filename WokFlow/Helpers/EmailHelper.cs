using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;
using System.Web;

namespace WokFlow.Helpers
{
    public static class EmailHelper
    {
        public static void SendVerificationEmail(string toEmail, string fullName, string code)
        {
            SendCodeEmail(
                toEmail,
                fullName,
                code,
                "WokFlow Email Verification Code",
                "Verify Your WokFlow Account",
                "Use this verification code to complete your registration:");
        }

        public static void SendPasswordResetCodeEmail(string toEmail, string fullName, string code)
        {
            SendCodeEmail(
                toEmail,
                fullName,
                code,
                "WokFlow Password Reset Code",
                "Reset Your WokFlow Password",
                "Use this verification code to reset your password:");
        }

        private static void SendCodeEmail(string toEmail, string fullName, string code, string subject, string heading, string message)
        {
            string host = GetSetting("SmtpHost");
            string portRaw = GetSetting("SmtpPort");
            string user = GetSetting("SmtpUser");
            string pass = GetSetting("SmtpPass");
            string from = GetSetting("SmtpFrom");
            string sslRaw = GetSetting("SmtpEnableSsl");

            EnsureRequired("SmtpHost", host);
            EnsureRequired("SmtpUser", user);
            EnsureRequired("SmtpPass", pass);
            EnsureRequired("SmtpFrom", from);

            int port = 587;
            int.TryParse(portRaw, out port);
            bool enableSsl = true;
            bool.TryParse(sslRaw, out enableSsl);

            var mail = new MailMessage
            {
                From = new MailAddress(from),
                Subject = subject,
                IsBodyHtml = true,
                Body =
                    "<div style='font-family:Segoe UI,Arial,sans-serif;max-width:560px;margin:0 auto;padding:24px;background:#fff7f3;border:1px solid #ffd5c7;border-radius:14px;'>" +
                    "<h2 style='margin:0 0 12px;color:#1A1A1A;'>" + HttpUtility.HtmlEncode(heading) + "</h2>" +
                    "<p style='color:#333;margin:0 0 12px;'>Hi " + HttpUtility.HtmlEncode(fullName) + ",</p>" +
                    "<p style='color:#333;margin:0 0 18px;'>" + HttpUtility.HtmlEncode(message) + "</p>" +
                    "<div style='font-size:32px;letter-spacing:6px;font-weight:700;color:#FF6B4A;background:#fff;padding:14px 18px;border-radius:12px;display:inline-block;border:1px solid #ffd5c7;'>" + HttpUtility.HtmlEncode(code) + "</div>" +
                    "<p style='color:#666;margin-top:18px;font-size:13px;'>This code expires in 10 minutes.</p>" +
                    "</div>"
            };
            mail.To.Add(toEmail);

            var client = new SmtpClient
            {
                Host = host,
                Port = port,
                EnableSsl = enableSsl,
                UseDefaultCredentials = false,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                Timeout = 15000,
                Credentials = new NetworkCredential(user, pass)
            };
            client.Send(mail);
        }

        private static void EnsureRequired(string key, string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                throw new InvalidOperationException("Missing SMTP setting: " + key);
            }
        }

        private static string GetSetting(string key)
        {
            string value = ConfigurationManager.AppSettings[key];
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }
            return Environment.GetEnvironmentVariable(key) ?? string.Empty;
        }
    }
}
