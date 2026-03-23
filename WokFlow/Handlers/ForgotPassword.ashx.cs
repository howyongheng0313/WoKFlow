using System;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WokFlow.Helpers;
using WokFlow.Models;

namespace WokFlow.Handlers
{
    public class ForgotPasswordHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            string action = (context.Request.QueryString["action"] ?? string.Empty).Trim().ToLowerInvariant();

            try
            {
                string body;
                using (var reader = new System.IO.StreamReader(context.Request.InputStream))
                {
                    body = reader.ReadToEnd();
                }
                var json = string.IsNullOrWhiteSpace(body) ? new JObject() : JObject.Parse(body);
                string email = (json["email"]?.ToString() ?? string.Empty).Trim();
                string code = (json["code"]?.ToString() ?? string.Empty).Trim();

                if (action == "request")
                {
                    HandleRequest(context, email);
                    return;
                }

                if (action == "verify")
                {
                    HandleVerify(context, email, code);
                    return;
                }

                WriteJson(context, new { success = false, message = "Unsupported action." });
            }
            catch (Exception ex)
            {
                WriteJson(context, new { success = false, message = "Forgot password error: " + ex.Message });
            }
        }

        private static void HandleRequest(HttpContext context, string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                WriteJson(context, new { success = false, emailExists = false, message = "Email is required." });
                return;
            }

            using (var db = new WokFlowContext())
            {
                var user = db.Users.FirstOrDefault(u => u.Email.ToLower() == email.ToLower());
                if (user == null)
                {
                    WriteJson(context, new { success = false, emailExists = false, message = "Email does not exist." });
                    return;
                }

                string code = new Random().Next(100000, 999999).ToString();
                context.Session["PwResetEmail"] = user.Email;
                context.Session["PwResetCode"] = code;
                context.Session["PwResetExpires"] = DateTime.UtcNow.AddMinutes(10);

                EmailHelper.SendPasswordResetCodeEmail(user.Email, user.Username, code);

                WriteJson(context, new { success = true, emailExists = true });
            }
        }

        private static void HandleVerify(HttpContext context, string email, string code)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(code))
            {
                WriteJson(context, new { success = false, message = "Email and code are required." });
                return;
            }

            var sessionEmail = context.Session["PwResetEmail"] as string;
            var sessionCode = context.Session["PwResetCode"] as string;
            var expiresObj = context.Session["PwResetExpires"] as DateTime?;
            DateTime expires = expiresObj ?? DateTime.MinValue;

            if (string.IsNullOrWhiteSpace(sessionEmail) || string.IsNullOrWhiteSpace(sessionCode))
            {
                WriteJson(context, new { success = false, message = "Reset session expired. Please request a new code." });
                return;
            }

            if (!string.Equals(sessionEmail, email, StringComparison.OrdinalIgnoreCase))
            {
                WriteJson(context, new { success = false, message = "Email does not match the requested reset email." });
                return;
            }

            if (DateTime.UtcNow > expires)
            {
                context.Session.Remove("PwResetEmail");
                context.Session.Remove("PwResetCode");
                context.Session.Remove("PwResetExpires");
                WriteJson(context, new { success = false, message = "Verification code has expired. Please request a new code." });
                return;
            }

            if (!string.Equals(sessionCode, code, StringComparison.Ordinal))
            {
                WriteJson(context, new { success = false, message = "Invalid verification code." });
                return;
            }

            context.Session["PasswordResetVerifiedEmail"] = sessionEmail;
            context.Session.Remove("PwResetCode");
            context.Session.Remove("PwResetExpires");

            WriteJson(context, new
            {
                success = true,
                redirectUrl = VirtualPathUtility.ToAbsolute("~/Pages/Auth/Register.aspx?mode=reset")
            });
        }

        private static void WriteJson(HttpContext context, object payload)
        {
            context.Response.Write(JsonConvert.SerializeObject(payload));
        }
    }
}
