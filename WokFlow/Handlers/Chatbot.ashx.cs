using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.SessionState;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace WokFlow.Handlers
{
    public class ChatbotHandler : IHttpHandler, IRequiresSessionState
    {
        private static readonly HttpClient GeminiClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(20)
        };

        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            string action = (context.Request.QueryString["action"] ?? string.Empty).Trim().ToLowerInvariant();
            if (string.IsNullOrEmpty(action))
            {
                WriteJson(context, new { ok = false, reply = "Missing action." });
                return;
            }

            if (context.Session == null || context.Session["UserId"] == null)
            {
                WriteJson(context, new { ok = false, reply = "Please log in to use the assistant.", showContact = false });
                return;
            }

            try
            {
                if (action == "history")
                {
                    HandleHistory(context);
                    return;
                }

                if (action == "chat")
                {
                    HandleChat(context);
                    return;
                }

                if (action == "clear")
                {
                    context.Session["WfChatHistory"] = new List<ChatTurn>();
                    WriteJson(context, new { ok = true });
                    return;
                }

                WriteJson(context, new { ok = false, reply = "Unsupported action." });
            }
            catch (Exception ex)
            {
                WriteJson(context, new { ok = false, reply = "Assistant error: " + ex.Message, showContact = true });
            }
        }

        private static void HandleHistory(HttpContext context)
        {
            var history = context.Session["WfChatHistory"] as List<ChatTurn> ?? new List<ChatTurn>();
            WriteJson(context, new { ok = true, history });
        }

        private static void HandleChat(HttpContext context)
        {
            string body = ReadBody(context);
            var input = string.IsNullOrWhiteSpace(body) ? new JObject() : JObject.Parse(body);
            string message = (input["message"]?.ToString() ?? string.Empty).Trim();

            if (string.IsNullOrEmpty(message))
            {
                WriteJson(context, new { ok = false, reply = "Please enter a question about WokFlow.", showContact = false });
                return;
            }

            if (!IsRelevantToWokFlow(message))
            {
                WriteJson(context, new
                {
                    ok = true,
                    reply = "Sorry, I can only answer questions about WokFlow features, courses, and learning.",
                    showContact = false
                });
                return;
            }

            if (IsRejectionQuestion(message))
            {
                WriteJson(context, new
                {
                    ok = true,
                    reply = "Higher authorization is needed to view specific account rejection details. Please contact support for more information regarding your application status.",
                    showContact = true
                });
                return;
            }

            string role = (context.Session["UserRole"] as string ?? string.Empty).ToUpperInvariant();
            if (RequiresHigherAuthorization(message, role))
            {
                string authReply = "That action requires higher authorization. ";
                if (message.ToLowerInvariant().Contains("create course") && role != "SHARER" && role != "ADMIN")
                {
                    authReply += "Upgrade to Sharer first, then you can create and publish courses.";
                }
                else
                {
                    authReply += "Please contact support for help.";
                }

                WriteJson(context, new
                {
                    ok = true,
                    reply = authReply,
                    showContact = true
                });
                return;
            }

            string apiKey = GetConfig("GeminiApiKey");
            if (string.IsNullOrWhiteSpace(apiKey))
            {
                WriteJson(context, new
                {
                    ok = false,
                    reply = "GeminiApiKey is missing. Add it to AppSettings.Local.config or environment variable GeminiApiKey.",
                    showContact = true
                });
                return;
            }

            string model = GetConfig("GeminiModel");
            if (string.IsNullOrWhiteSpace(model)) model = "gemini-3-flash-preview";
            string fallbackModel = GetConfig("GeminiFallbackModel");
            if (string.IsNullOrWhiteSpace(fallbackModel)) fallbackModel = "gemini-3.1-flash-lite";

            // Provide deterministic, immediate guidance for common onboarding asks.
            if (IsHowToUseQuestion(message))
            {
                WriteJson(context, new
                {
                    ok = true,
                    reply = BuildHowToUseReply(role),
                    showContact = false
                });
                return;
            }

            var history = context.Session["WfChatHistory"] as List<ChatTurn> ?? new List<ChatTurn>();
            history.Add(new ChatTurn { role = "user", text = message });

            string reply;
            try
            {
                reply = CallGeminiWithFallback(apiKey, history, model, fallbackModel, "gemini-2.5-flash-lite");
            }
            catch (Exception ex)
            {
                WriteJson(context, new
                {
                    ok = false,
                    reply = "I couldn't complete that request right now. Please try again in a moment.",
                    showContact = false
                });
                return;
            }

            if (string.IsNullOrWhiteSpace(reply))
            {
                reply = "I could not generate a response for that request.";
            }

            history.Add(new ChatTurn { role = "model", text = reply });
            context.Session["WfChatHistory"] = history;

            WriteJson(context, new { ok = true, reply, showContact = false });
        }

        private static string CallGeminiWithFallback(string apiKey, List<ChatTurn> history, params string[] models)
        {
            var candidates = models
                .Where(m => !string.IsNullOrWhiteSpace(m))
                .Select(m => m.Trim())
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

            Exception lastError = null;
            foreach (var model in candidates)
            {
                try
                {
                    return CallGemini(apiKey, model, history);
                }
                catch (Exception ex)
                {
                    lastError = ex;
                }
            }

            throw new InvalidOperationException("All configured Gemini models failed.", lastError);
        }

        private static string CallGemini(string apiKey, string model, List<ChatTurn> history)
        {
            var contents = new List<object>
            {
                new
                {
                    role = "user",
                    parts = new[] { new { text = BuildSystemPrompt() } }
                }
            };

            // Keep context bounded so requests don't time out as chat gets longer.
            var trimmedHistory = TrimHistory(history);
            foreach (var turn in trimmedHistory.Where(t => t != null && !string.IsNullOrWhiteSpace(t.text)))
            {
                string role = (turn.role ?? "user").ToLowerInvariant() == "model" ? "model" : "user";
                contents.Add(new
                {
                    role,
                    parts = new[] { new { text = turn.text } }
                });
            }

            var payload = new
            {
                contents,
                generationConfig = new
                {
                    temperature = 0.2,
                    topP = 0.9,
                    maxOutputTokens = 1024
                }
            };

            string url = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent";
            var request = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json")
            };
            request.Headers.Add("x-goog-api-key", apiKey);

            var response = GeminiClient.SendAsync(request).GetAwaiter().GetResult();
            string body = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();

            if (!response.IsSuccessStatusCode)
            {
                throw new InvalidOperationException("HTTP " + (int)response.StatusCode + " from Gemini. " + body);
            }

            var root = JObject.Parse(body);
            string text = root["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.ToString();
            if (!string.IsNullOrWhiteSpace(text))
            {
                return text;
            }

            string blockReason = root["promptFeedback"]?["blockReason"]?.ToString();
            if (!string.IsNullOrWhiteSpace(blockReason))
            {
                return "Your request was blocked by model safety filters (" + blockReason + ").";
            }

            return string.Empty;
        }

        private static string GetConfig(string key)
        {
            string value = ConfigurationManager.AppSettings[key];
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }

            // Allow environment variable fallback for local/dev and CI.
            return Environment.GetEnvironmentVariable(key)
                ?? Environment.GetEnvironmentVariable(key.ToUpperInvariant());
        }

        private static List<ChatTurn> TrimHistory(List<ChatTurn> history)
        {
            if (history == null || history.Count == 0)
            {
                return new List<ChatTurn>();
            }

            const int maxTurns = 10;
            const int maxChars = 3500;
            var filtered = history
                .Where(h => h != null && !string.IsNullOrWhiteSpace(h.text))
                .ToList();
            int skip = Math.Max(0, filtered.Count - maxTurns);
            var recent = filtered.Skip(skip).ToList();

            int total = 0;
            var result = new List<ChatTurn>();
            for (int i = recent.Count - 1; i >= 0; i--)
            {
                var turn = recent[i];
                int len = turn.text.Length;
                if (total + len > maxChars && result.Count > 0)
                {
                    break;
                }
                result.Insert(0, turn);
                total += len;
            }
            return result;
        }

        private static bool IsRelevantToWokFlow(string message)
        {
            string text = message.ToLowerInvariant();
            string[] quickOk = { "hi", "hello", "hey", "help", "support", "wokflow" };
            if (quickOk.Any(text.Contains)) return true;

            string[] keywords =
            {
                "course", "courses", "chapter", "chapters", "lesson", "lessons", "recipe", "cuisine",
                "difficulty", "duration", "enroll", "enrollment", "join", "dashboard", "search", "filter",
                "progress", "quiz", "question", "answer", "comment", "profile", "my courses", "rating",
                "stars", "sharer", "learner", "admin", "analytics", "create course", "content", "registration",
                "upgrade", "report", "reported", "certificate", "system", "use the system", "how to use"
            };
            return keywords.Any(text.Contains);
        }

        private static bool RequiresHigherAuthorization(string message, string role)
        {
            string text = message.ToLowerInvariant();
            string[] adminOnly =
            {
                "user management", "manage users", "platform analytics", "content management",
                "reported content", "approve sharer", "reject sharer", "admin dashboard", "ban user", "delete user"
            };
            string[] sharerOnly =
            {
                "create course", "edit course", "delete course", "publish course", "sharer analytics",
                "manage chapters", "upload recipe"
            };

            bool asksAdmin = adminOnly.Any(text.Contains);
            bool asksSharer = sharerOnly.Any(text.Contains);
            bool askingToBecomeSharer = text.Contains("become a sharer") || text.Contains("upgrade to sharer") || text.Contains("sharer registration");

            if (askingToBecomeSharer) return false;
            if (asksAdmin && role != "ADMIN") return true;
            if (asksSharer && role != "SHARER" && role != "ADMIN") return true;
            return false;
        }

        private static bool IsRejectionQuestion(string message)
        {
            string text = message.ToLowerInvariant();
            return text.Contains("reject")
                || text.Contains("rejected")
                || text.Contains("rejection")
                || text.Contains("application status")
                || text.Contains("upgrade status");
        }

        private static bool IsHowToUseQuestion(string message)
        {
            string text = message.ToLowerInvariant();
            return text.Contains("how to use")
                || text.Contains("use the system")
                || text.Contains("how does this system work")
                || text.Contains("how to use the system");
        }

        private static string BuildHowToUseReply(string role)
        {
            var sb = new StringBuilder();
            sb.AppendLine("Use WokFlow like this:");
            sb.AppendLine("1. Find courses from the dashboard using Search, Cuisine, Difficulty, and Time Posted filters.");
            sb.AppendLine("2. Click Join on a course, then open it to start learning chapter by chapter.");
            sb.AppendLine("3. Complete quizzes to unlock progress and add comments for feedback.");
            sb.AppendLine("4. Track everything in My Courses and your profile progress.");

            if (role == "SHARER" || role == "ADMIN")
            {
                sb.AppendLine("5. As a Sharer, create and manage courses from the Sharer pages.");
            }
            else
            {
                sb.AppendLine("5. To create courses, upgrade to Sharer from your profile and wait for approval.");
            }

            return sb.ToString().Trim();
        }

        private static string BuildSystemPrompt()
        {
            return "You are the WokFlow Assistant, introduce yourself as WokAI. WokFlow is a cooking education platform where sharers create courses and recipes, and learners join courses to learn chapter by chapter. " +
                   "Key features: course search and filters (cuisine, difficulty, time posted), join courses, view course details, track progress per chapter, quizzes, comments, and My Courses. " +
                   "Learners can upgrade to sharer by submitting sharer registration with proof. Sharers create/edit courses and view analytics. " +
                   "Admins manage users, content, and sharer registrations, and view platform analytics. " +
                   "Only answer questions about WokFlow features and usage. If unrelated, reply with refusal. " +
                   "If higher authorization is required, reply that higher authorization is needed and contact support. " +
                   "Keep responses concise and do not invent data.";
        }

        private static string ReadBody(HttpContext context)
        {
            if (context.Request.InputStream == null)
            {
                return string.Empty;
            }
            context.Request.InputStream.Position = 0;
            using (var reader = new System.IO.StreamReader(context.Request.InputStream, Encoding.UTF8))
            {
                return reader.ReadToEnd();
            }
        }

        private static void WriteJson(HttpContext context, object payload)
        {
            context.Response.Write(JsonConvert.SerializeObject(payload));
        }

        private sealed class ChatTurn
        {
            public string role { get; set; }
            public string text { get; set; }
        }
    }
}
