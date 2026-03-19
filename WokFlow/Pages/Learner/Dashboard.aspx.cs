using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.Entity;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Web.Script.Services;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WokFlow.Models;


namespace WokFlow.Pages.Learner
{
    public partial class Dashboard : LearnerPage
    {
        private const int PageSize = 6;
        private static readonly HttpClient GeminiClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(20)
        };

        // Store current page and total pages in ViewState for pagination
        protected int CurrentPage
        {
            get { return ViewState["CurrentPage"] != null ? (int)ViewState["CurrentPage"] : 1; }
            set { ViewState["CurrentPage"] = value; }
        }

        // Calculate total pages based on total course count and page size
        private int TotalPages
        {
            get { return ViewState["TotalPages"] != null ? (int)ViewState["TotalPages"] : 1; }
            set { ViewState["TotalPages"] = value; }
        }

        // Page Load
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCourses();
            }
        }

        // Main method to bind courses based on filters, sorting, and pagination
        private void BindCourses()
        {
            using (var db = new WokFlowContext())
            {
                // Base query for active courses with cuisine data
                var query = db.Courses
                    .Where(c => c.Status == "Active")
                    .Include("Cuisine")
                    .AsQueryable();

                // Search filter
                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                    query = query.Where(c => c.Title.Contains(search));

                // Cuisine filter
                string cuisine = ddlCuisine.SelectedValue;
                if (!string.IsNullOrEmpty(cuisine))
                    query = query.Where(c => c.Cuisine.CuisineName == cuisine);

                // Difficulty filter
                string diff = ddlDifficulty.SelectedValue;
                int difficulty;
                if (!string.IsNullOrEmpty(diff) && int.TryParse(diff, out difficulty))
                {
                    query = query.Where(c => c.Difficulty == difficulty);
                }

                // Time Posted sort
                string timeSort = ddlTimePosted.SelectedValue;
                IQueryable<Course> sortedQuery = timeSort == "oldest"
                    ? query.OrderBy(c => c.CreatedDate)
                    : query.OrderByDescending(c => c.CreatedDate);

                // Pagination
                int totalCount = sortedQuery.Count();
                TotalPages = totalCount == 0 ? 1 : (int)Math.Ceiling(totalCount / (double)PageSize);
                if (CurrentPage > TotalPages) CurrentPage = TotalPages;
                if (CurrentPage < 1) CurrentPage = 1;

                // Select only necessary fields for display
                var courses = sortedQuery
                    .Select(c => new
                    {
                        c.CourseId,
                        c.Title,
                        c.Description,
                        CuisineName = c.Cuisine != null ? c.Cuisine.CuisineName : "Unknown",
                        c.Duration,
                        c.Difficulty,
                        c.ImageUrl
                    })
                    .Skip((CurrentPage - 1) * PageSize)
                    .Take(PageSize)
                    .ToList();

                // Get enrolled course IDs for current user
                ViewState["EnrolledIds"] = db.Enrollments
                    .Where(en => en.UserId == CurrentUserId)
                    .Select(en => en.CourseId)
                    .ToList();

                rptCourses.DataSource = courses;
                rptCourses.DataBind();

                BindPagination();
            }
        }

        // Bind pagination controls based on total pages and current page
        private void BindPagination()
        {
            // Generate page numbers for pagination
            var pages = Enumerable.Range(1, TotalPages)
                .Select(i => new { PageNumber = i })
                .ToList();

            rptPages.DataSource = pages;
            rptPages.DataBind();

            btnPrev.Enabled = CurrentPage > 1;
            btnNext.Enabled = CurrentPage < TotalPages;
        }

        // Check user enrollment status
        protected bool IsEnrolled(int courseId)
        {
            var ids = ViewState["EnrolledIds"] as List<int>;
            return ids != null && ids.Contains(courseId);
        }

        // Get CSS class for course card based on enrollment status
        protected string GetCardClass(int courseId)
        {
            string baseClass = "glass-panel rounded-2xl overflow-hidden hover:shadow-lg transition-all";
            return IsEnrolled(courseId) ? baseClass + " cursor-pointer" : baseClass;
        }

        // Get hyperlink for course card based on enrollment status
        protected string GetCardHref(int courseId)
        {
            if (!IsEnrolled(courseId)) return "";
            return ResolveUrl("~/Pages/Shared/CourseDetail.aspx?id=" + courseId);
        }

        // Handle Join button click to enroll user in course
        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Only handle Join command
            if (e.CommandName == "Join")
            {
                int courseId;

                // Validate course ID from command argument
                if (!int.TryParse(e.CommandArgument.ToString(), out courseId))
                    return;

                using (var db = new WokFlowContext())
                {
                    // Check if user is already enrolled in the course
                    bool alreadyEnrolled = db.Enrollments.Any(en =>
                        en.UserId == CurrentUserId && en.CourseId == courseId);

                    if (!alreadyEnrolled)
                    {
                        // Create enrollment
                        var enrollment = new Enrollment
                        {
                            UserId = CurrentUserId,
                            CourseId = courseId,
                            EnrollmentDate = DateTime.UtcNow,
                            Progress = 0,
                            Status = "In Progress",
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };
                        db.Enrollments.Add(enrollment);
                        db.SaveChanges();

                        // Unlock first chapter
                        var firstChapter = db.Chapters
                            .Where(ch => ch.CourseId == courseId)
                            .OrderBy(ch => ch.ChapterOrder)
                            .FirstOrDefault();

                        if (firstChapter != null)
                        {
                            // Create progress record for the first chapter
                            var progress = new UserChapterProgress
                            {
                                UserId = CurrentUserId,
                                EnrollmentId = enrollment.EnrollmentId,
                                ChapterId = firstChapter.ChapterId,
                                IsCompleted = false,
                                CreatedAt = DateTime.UtcNow,
                                UpdatedAt = DateTime.UtcNow
                            };
                            db.UserChapterProgress.Add(progress);
                            db.SaveChanges();
                        }
                    }

                    // Redirect to course detail
                    Response.Redirect("~/Pages/Shared/CourseDetail.aspx?id=" + courseId);
                }
            }
        }

        // Handle filter changes to reset to first page and rebind courses
        protected void Filter_Changed(object sender, EventArgs e)
        {
            CurrentPage = 1;
            BindCourses();
        }

        // Handle pagination button clicks to navigate between pages
        protected void btnPrev_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                BindCourses();
            }
        }

        // Handle pagination button clicks to navigate between pages
        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (CurrentPage < TotalPages)
            {
                CurrentPage++;
                BindCourses();
            }
        }

        // Handle page number clicks in pagination to navigate to specific page
        protected void rptPages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Only handle Page command
            if (e.CommandName == "Page")
            {
                int page;

                // Validate page number from command argument
                if (!int.TryParse(e.CommandArgument.ToString(), out page))
                    return;

                // Ensure page number is within valid range before navigating
                if (page >= 1 && page <= TotalPages)
                {
                    CurrentPage = page;
                    BindCourses();
                }
            }
        }

        public class ChatTurn
        {
            public string Role { get; set; }
            public string Text { get; set; }
        }

        public class ChatResponse
        {
            public string Reply { get; set; }
            public bool ShowContact { get; set; }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static ChatResponse Chat(string message)
        {
            var context = HttpContext.Current;
            if (context == null || context.Session == null || context.Session["UserId"] == null)
            {
                return new ChatResponse { Reply = "Please log in to use the assistant.", ShowContact = false };
            }

            string text = (message ?? string.Empty).Trim();
            if (string.IsNullOrEmpty(text))
            {
                return new ChatResponse { Reply = "Please enter a question about WokFlow.", ShowContact = false };
            }

            if (!IsRelevantToWokFlow(text))
            {
                return new ChatResponse
                {
                    Reply = "Sorry, I can only answer questions about WokFlow features, courses, and learning.",
                    ShowContact = false
                };
            }

            string role = (context.Session["UserRole"] as string ?? string.Empty).ToUpperInvariant();
            if (RequiresHigherAuthorization(text, role))
            {
                return new ChatResponse
                {
                    Reply = "That request needs higher authorization. Please contact support for help.",
                    ShowContact = true
                };
            }

            string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
            if (string.IsNullOrWhiteSpace(apiKey))
            {
                return new ChatResponse
                {
                    Reply = "The assistant is not configured. Please contact support.",
                    ShowContact = true
                };
            }

            string model = ConfigurationManager.AppSettings["GeminiModel"];
            if (string.IsNullOrWhiteSpace(model))
            {
                model = "gemini-2.5-flash";
            }

            try
            {
                var sessionHistory = context.Session["WfChatHistory"] as List<ChatTurn>;
                if (sessionHistory == null)
                {
                    sessionHistory = new List<ChatTurn>();
                }

                sessionHistory.Add(new ChatTurn { Role = "user", Text = text });

                string reply = CallGemini(apiKey, model, text, sessionHistory);
                if (string.IsNullOrWhiteSpace(reply))
                {
                    reply = "Sorry, I could not generate a response. Please try again.";
                }

                sessionHistory.Add(new ChatTurn { Role = "model", Text = reply });
                context.Session["WfChatHistory"] = sessionHistory;

                return new ChatResponse { Reply = reply, ShowContact = false };
            }
            catch
            {
                return new ChatResponse
                {
                    Reply = "Sorry, I could not reach the assistant service right now.",
                    ShowContact = true
                };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<ChatTurn> GetChatHistory()
        {
            var context = HttpContext.Current;
            if (context == null || context.Session == null || context.Session["UserId"] == null)
            {
                return new List<ChatTurn>();
            }

            var sessionHistory = context.Session["WfChatHistory"] as List<ChatTurn>;
            return sessionHistory ?? new List<ChatTurn>();
        }

        private static bool IsRelevantToWokFlow(string message)
        {
            string text = message.ToLowerInvariant();

            string[] quickOk =
            {
                "hi", "hello", "hey", "help", "support", "wokflow"
            };
            if (quickOk.Any(text.Contains)) return true;

            string[] keywords =
            {
                "course", "courses", "chapter", "chapters", "lesson", "lessons",
                "recipe", "cuisine", "difficulty", "duration", "enroll", "enrollment",
                "join", "dashboard", "search", "filter", "progress", "quiz", "question",
                "answer", "comment", "profile", "my courses", "rating", "stars",
                "sharer", "learner", "admin", "analytics", "create course", "content",
                "registration", "upgrade", "report", "reported", "certificate",
                "system", "use the system", "how to use"
            };

            return keywords.Any(text.Contains);
        }

        private static bool RequiresHigherAuthorization(string message, string role)
        {
            string text = message.ToLowerInvariant();

            string[] adminOnly =
            {
                "user management", "manage users", "platform analytics",
                "content management", "reported content", "approve sharer",
                "reject sharer", "admin dashboard", "ban user", "delete user"
            };

            string[] sharerOnly =
            {
                "create course", "edit course", "delete course", "publish course",
                "sharer analytics", "manage chapters", "upload recipe"
            };

            bool asksAdmin = adminOnly.Any(text.Contains);
            bool asksSharer = sharerOnly.Any(text.Contains);
            bool askingToBecomeSharer = text.Contains("become a sharer") || text.Contains("upgrade to sharer") || text.Contains("sharer registration");

            if (askingToBecomeSharer) return false;

            if (asksAdmin && role != "ADMIN") return true;
            if (asksSharer && role != "SHARER" && role != "ADMIN") return true;

            return false;
        }

        private static string CallGemini(string apiKey, string model, string message, List<ChatTurn> history)
        {
            var contents = new List<object>();

            string systemPrompt = BuildSystemPrompt();
            contents.Add(new
            {
                role = "user",
                parts = new[] { new { text = systemPrompt } }
            });

            bool appendedFromHistory = false;
            if (history != null)
            {
                foreach (var turn in history.Where(t => t != null && !string.IsNullOrWhiteSpace(t.Text)))
                {
                    string role = (turn.Role ?? "user").ToLowerInvariant();
                    role = role == "model" ? "model" : "user";
                    contents.Add(new
                    {
                        role,
                        parts = new[] { new { text = turn.Text } }
                    });
                    appendedFromHistory = true;
                }
            }

            bool lastIsSame = false;
            if (history != null && history.Count > 0)
            {
                var last = history[history.Count - 1];
                if (last != null && string.Equals(last.Text, message, StringComparison.Ordinal) && string.Equals(last.Role, "user", StringComparison.OrdinalIgnoreCase))
                {
                    lastIsSame = true;
                }
            }

            if (!appendedFromHistory || !lastIsSame)
            {
                contents.Add(new
                {
                    role = "user",
                    parts = new[] { new { text = message } }
                });
            }

            var payload = new
            {
                contents,
                generationConfig = new
                {
                    temperature = 0.2,
                    maxOutputTokens = 512,
                    topP = 0.9
                }
            };

            string url = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent";
            string json = JsonConvert.SerializeObject(payload);

            var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Headers.Add("x-goog-api-key", apiKey);
            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = GeminiClient.SendAsync(request).GetAwaiter().GetResult();
            string body = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();

            if (!response.IsSuccessStatusCode)
            {
                return string.Empty;
            }

            var root = JObject.Parse(body);
            return root["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.ToString() ?? string.Empty;
        }

        private static string BuildSystemPrompt()
        {
            return "You are the WokFlow Assistant. WokFlow is a cooking education platform where sharers " +
                   "create courses and recipes, and learners join courses to learn chapter by chapter. " +
                   "Key features: course search and filters (cuisine, difficulty, time posted), join courses, " +
                   "view course details, track progress per chapter, quizzes, comments, and a My Courses page " +
                   "for joined or created courses. Learners can upgrade to sharer by submitting a sharer " +
                   "registration with proof. Sharers can create/edit courses and view their analytics. " +
                   "Admins manage users, content, and sharer registrations, and view platform analytics. " +
                   "Rules: only answer questions about WokFlow features and usage. If a question is unrelated, " +
                   "respond: \"Sorry, I can only answer questions about WokFlow features, courses, and learning.\" " +
                   "If the request requires higher authorization, respond: \"That request needs higher authorization. " +
                   "Please contact support for help.\" Keep answers concise, actionable, and do not invent data.";
        }
    }
}
