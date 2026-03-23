using System;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WokFlow.Pages.Auth;

namespace WokFlow.Handlers
{
    public class RegisterVerificationHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                string body;
                using (var reader = new System.IO.StreamReader(context.Request.InputStream))
                {
                    body = reader.ReadToEnd();
                }

                var json = string.IsNullOrWhiteSpace(body) ? new JObject() : JObject.Parse(body);
                string code = (json["code"]?.ToString() ?? string.Empty).Trim();

                Register.VerificationResult result = Register.VerifyEmailCode(code);
                context.Response.Write(JsonConvert.SerializeObject(result));
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    Success = false,
                    Message = "Verification handler error: " + ex.Message
                }));
            }
        }
    }
}
