using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Controls;
using WokFlow.Models;

namespace WokFlow.Pages.Shared
{
    public partial class CourseDetail : LearnerPage
    {
        protected int CourseId
        {
            get
            {
                int id;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        protected int SelectedChapterId
        {
            get
            {
                int id;
                int.TryParse(Request.QueryString["ch"], out id);
                return id;
            }
        }

        protected string ActiveTab
        {
            get { return Request.QueryString["tab"] ?? "info"; }
        }

        private Dictionary<int, bool> _chapterUnlocked = new Dictionary<int, bool>();

        protected string CurrentVideoUrl { get; private set; } = "";
        protected string CurrentChapterTitle { get; private set; } = "";
        protected string CurrentChapterDescription { get; private set; } = "";
        protected int ActiveChapterId { get; private set; }

        protected int CurrentQuestionIndex
        {
            get { return ViewState["QIdx"] != null ? (int)ViewState["QIdx"] : 0; }
            set { ViewState["QIdx"] = value; }
        }

        protected int TotalQuestions
        {
            get { return ViewState["QTotal"] != null ? (int)ViewState["QTotal"] : 0; }
            set { ViewState["QTotal"] = value; }
        }

        private Dictionary<int, int> StoredAnswers
        {
            get { return ViewState["QAnswers"] as Dictionary<int, int> ?? new Dictionary<int, int>(); }
            set { ViewState["QAnswers"] = value; }
        }

        protected string GetEmbedUrl(string url)
        {
            if (string.IsNullOrEmpty(url)) return "";

            if (url.Contains("youtube.com/watch"))
            {
                var uri = new Uri(url);
                var query = System.Web.HttpUtility.ParseQueryString(uri.Query);
                string videoId = query["v"];
                if (!string.IsNullOrEmpty(videoId))
                    return "https://www.youtube.com/embed/" + videoId;
            }
            if (url.Contains("youtu.be/"))
            {
                string videoId = url.Substring(url.LastIndexOf('/') + 1).Split('?')[0];
                return "https://www.youtube.com/embed/" + videoId;
            }
            if (url.Contains("vimeo.com/"))
            {
                string videoId = url.Substring(url.LastIndexOf('/') + 1).Split('?')[0];
                return "https://player.vimeo.com/video/" + videoId;
            }
            return url;
        }

        protected bool IsEmbeddable(string url)
        {
            return !string.IsNullOrEmpty(url) &&
                   (url.Contains("youtube.com") || url.Contains("youtu.be") || url.Contains("vimeo.com"));
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CourseId == 0)
            {
                Response.Redirect("~/Pages/Learner/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCourse();
            }
        }

        private void LoadCourse()
        {
            using (var db = new WokFlowContext())
            {
                var course = db.Courses.Include("Cuisine").FirstOrDefault(c => c.CourseId == CourseId);
                if (course == null)
                {
                    Response.Redirect("~/Pages/Learner/Dashboard.aspx");
                    return;
                }

                litTitle.Text = course.Title;
                litDuration.Text = course.Duration;
                litDifficulty.Text = course.Difficulty.ToString();
                litDescription.Text = course.Description;

                var chapters = db.Chapters
                    .Where(ch => ch.CourseId == CourseId)
                    .OrderBy(ch => ch.ChapterOrder)
                    .ToList();

                var chapterIds = chapters.Select(c => c.ChapterId).ToList();
                var userProgress = db.UserChapterProgress
                    .Where(p => p.UserId == CurrentUserId && chapterIds.Contains(p.ChapterId))
                    .ToList();

                // Build chapter unlock map
                _chapterUnlocked.Clear();
                var enrollment = db.Enrollments.FirstOrDefault(en => en.UserId == CurrentUserId && en.CourseId == CourseId);
                foreach (var ch in chapters)
                {
                    if (ch.ChapterOrder == 1)
                        _chapterUnlocked[ch.ChapterId] = enrollment != null;
                    else
                    {
                        var prevChapter = chapters.FirstOrDefault(c => c.ChapterOrder == ch.ChapterOrder - 1);
                        bool prevCompleted = prevChapter != null && userProgress.Any(p => p.ChapterId == prevChapter.ChapterId && p.IsCompleted);
                        _chapterUnlocked[ch.ChapterId] = prevCompleted;
                    }
                }
                ViewState["ChapterUnlocked"] = _chapterUnlocked;

                // Resolve selected chapter
                var selectedChapter = SelectedChapterId > 0
                    ? chapters.FirstOrDefault(ch => ch.ChapterId == SelectedChapterId)
                    : chapters.FirstOrDefault();

                CurrentVideoUrl = selectedChapter?.VideoUrl ?? "";
                CurrentChapterTitle = selectedChapter?.Title ?? "";
                CurrentChapterDescription = selectedChapter?.Description ?? "";
                ActiveChapterId = selectedChapter?.ChapterId ?? 0;

                // Quiz unlock alert: shown when chapter is unlocked but not completed and a next chapter exists
                bool showAlert = false;
                if (selectedChapter != null
                    && _chapterUnlocked.ContainsKey(selectedChapter.ChapterId)
                    && _chapterUnlocked[selectedChapter.ChapterId])
                {
                    bool isCompleted = userProgress.Any(p => p.ChapterId == selectedChapter.ChapterId && p.IsCompleted);
                    bool hasNext = chapters.Any(ch => ch.ChapterOrder == selectedChapter.ChapterOrder + 1);
                    showAlert = !isCompleted && hasNext;
                }
                pnlUnlockAlert.Visible = showAlert;

                // Chapter list with description
                var chapterData = chapters.Select(ch => new ChapterListItem
                {
                    ChapterId = ch.ChapterId,
                    ChapterOrder = ch.ChapterOrder,
                    Title = ch.Title,
                    Description = ch.Description,
                    IsCompleted = userProgress.Any(p => p.ChapterId == ch.ChapterId && p.IsCompleted)
                }).ToList();

                rptChapters.DataSource = chapterData;
                rptChapters.DataBind();

                // Sidebar tab visibility
                pnlSidebarOverview.Visible = ActiveTab != "quiz";
                pnlSidebarQuiz.Visible = ActiveTab == "quiz";

                // Comments always visible
                pnlComments.Visible = true;
                LoadComments(db);

                if (ActiveTab == "quiz" && selectedChapter != null)
                    LoadQuiz(selectedChapter.ChapterId);

                LoadScores(db, chapters);
            }
        }

        private void LoadScores(WokFlowContext db, List<Chapter> chapters)
        {
            var chapterMap = chapters.ToDictionary(ch => ch.ChapterId, ch => ch.Title);
            var chapterIds = chapterMap.Keys.ToList();

            var scores = db.QuizResults
                .Where(q => q.UserId == CurrentUserId && chapterIds.Contains(q.ChapterId))
                .OrderBy(q => q.ChapterId)
                .ToList()
                .Select(q => new ScoreEntry
                {
                    Id = q.ChapterId,
                    Name = chapterMap.ContainsKey(q.ChapterId) ? chapterMap[q.ChapterId] : "Chapter",
                    Date = q.CompletedDate.ToString("MMM dd, yyyy"),
                    Score = q.Score,
                    Status = q.Status
                }).ToList();

            scoreModal.Title = "My Quiz Scores";
            scoreModal.Scores = scores;
        }

        private void LoadComments(WokFlowContext db)
        {
            var comments = db.Comments
                .Where(c => c.CourseId == CourseId)
                .Include("User")
                .OrderByDescending(c => c.CreatedDate)
                .Select(c => new CommentListItem
                {
                    CommentId = c.CommentId,
                    Username = c.User.Username,
                    CommentText = c.CommentText,
                    Rating = c.Rating,
                    CreatedDate = c.CreatedDate
                }).ToList();

            litCommentCount.Text = comments.Count.ToString();
            rptComments.DataSource = comments;
            rptComments.DataBind();
        }

        private void LoadQuiz(int chapterId)
        {
            using (var db = new WokFlowContext())
            {
                var questions = db.Questions
                    .Where(qtn => qtn.ChapterId == chapterId)
                    .Include("Answers")
                    .OrderBy(qtn => qtn.QuestionOrder)
                    .ToList();

                TotalQuestions = questions.Count;

                if (TotalQuestions == 0)
                {
                    pnlNoQuiz.Visible = true;
                    pnlQuizContent.Visible = false;
                    return;
                }

                pnlNoQuiz.Visible = false;
                pnlQuizContent.Visible = true;

                int idx = Math.Min(CurrentQuestionIndex, TotalQuestions - 1);
                CurrentQuestionIndex = idx;
                var q = questions[idx];

                litQuizQuestion.Text = Server.HtmlEncode(q.QuestionText);
                rptQuizAnswers.DataSource = q.Answers.OrderBy(a => a.AnswerOrder).ToList();
                rptQuizAnswers.DataBind();

                btnPrevQuestion.Enabled = idx > 0;
                btnNextQuestion.Text = (idx == TotalQuestions - 1) ? "Submit Quiz" : "Next Question";
                btnNextQuestion.Visible = true;
                pnlQuizResult.Visible = false;
            }
        }

        protected bool IsChapterUnlocked(int chapterId)
        {
            var map = ViewState["ChapterUnlocked"] as Dictionary<int, bool>;
            if (map == null) return _chapterUnlocked.ContainsKey(chapterId) && _chapterUnlocked[chapterId];
            return map.ContainsKey(chapterId) && map[chapterId];
        }

        protected string GetChapterCss(int chapterId, bool isCompleted)
        {
            if (chapterId == ActiveChapterId && IsChapterUnlocked(chapterId))
                return "bg-orange-50 border border-orange-100 cursor-pointer";
            if (isCompleted) return "bg-green-50 border border-green-200";
            if (IsChapterUnlocked(chapterId)) return "bg-white/60 hover:bg-orange-50 cursor-pointer";
            return "bg-gray-50 opacity-60 cursor-not-allowed";
        }

        protected string RenderStars(int rating)
        {
            string stars = "";
            for (int i = 1; i <= 5; i++)
            {
                stars += i <= rating
                    ? "<span style='color:#FF8C66;font-size:14px;'>&#9733;</span>"
                    : "<span style='color:#D1D5DB;font-size:14px;'>&#9733;</span>";
            }
            return stars;
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            string reason = hdnReportReason.Value?.Trim();
            if (string.IsNullOrEmpty(reason))
            {
                LoadCourse();
                return;
            }

            using (var db = new WokFlowContext())
            {
                var report = new ReportedContent
                {
                    CourseId = CourseId,
                    ReporterId = CurrentUserId,
                    Reason = reason,
                    ReportDate = DateTime.UtcNow,
                    Status = "Pending",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                db.ReportedContents.Add(report);
                db.SaveChanges();
            }

            hdnReportReason.Value = "";
            LoadCourse();

            // Show success feedback in the modal
            lblReportMsg.Text = "Your report has been submitted. Thank you.";
            lblReportMsg.CssClass = "block text-sm mt-3 font-medium text-green-600";
            lblReportMsg.Visible = true;

            // Re-open the modal so the user sees the confirmation
            ScriptManager.RegisterStartupScript(this, GetType(), "showReportSuccess",
                "document.getElementById('reportModal').style.display='';if(typeof lucide!=='undefined')lucide.createIcons();", true);
        }

        protected void btnAddComment_Click(object sender, EventArgs e)
        {
            string text = txtComment.Text.Trim();
            if (string.IsNullOrEmpty(text)) return;

            int rating = 5;
            int.TryParse(hdnRating.Value, out rating);
            if (rating < 1 || rating > 5) rating = 5;

            using (var db = new WokFlowContext())
            {
                var comment = new Comment
                {
                    CourseId = CourseId,
                    UserId = CurrentUserId,
                    CommentText = text,
                    Rating = rating,
                    CreatedDate = DateTime.UtcNow,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                db.Comments.Add(comment);
                db.SaveChanges();
            }

            txtComment.Text = "";
            LoadCourse();
        }

        protected void btnPrevQuestion_Click(object sender, EventArgs e)
        {
            if (CurrentQuestionIndex > 0) CurrentQuestionIndex--;
            hdnSelectedAnswer.Value = "";
            LoadCourse();
        }

        protected void btnNextQuestion_Click(object sender, EventArgs e)
        {
            int chapterId = SelectedChapterId;

            int selectedAnswerId;
            int.TryParse(hdnSelectedAnswer.Value, out selectedAnswerId);

            using (var db = new WokFlowContext())
            {
                if (chapterId == 0)
                    chapterId = db.Chapters
                        .Where(ch => ch.CourseId == CourseId)
                        .OrderBy(ch => ch.ChapterOrder)
                        .Select(ch => ch.ChapterId)
                        .FirstOrDefault();

                if (chapterId == 0) return;

                var questions = db.Questions
                    .Where(q => q.ChapterId == chapterId)
                    .Include("Answers")
                    .OrderBy(q => q.QuestionOrder)
                    .ToList();

                // Store answer for current question
                if (selectedAnswerId > 0 && CurrentQuestionIndex < questions.Count)
                {
                    var answers = StoredAnswers;
                    answers[questions[CurrentQuestionIndex].QuestionId] = selectedAnswerId;
                    StoredAnswers = answers;
                }

                bool isLast = TotalQuestions > 0 && CurrentQuestionIndex == TotalQuestions - 1;

                if (isLast)
                {
                    // Calculate score across all stored answers
                    var stored = StoredAnswers;
                    int correct = 0;
                    foreach (var q in questions)
                    {
                        int aId;
                        if (stored.TryGetValue(q.QuestionId, out aId))
                        {
                            var ans = q.Answers.FirstOrDefault(a => a.AnswerId == aId);
                            if (ans != null && ans.IsCorrect) correct++;
                        }
                    }
                    int score = questions.Count > 0 ? (int)Math.Round(correct * 100.0 / questions.Count) : 0;
                    bool passed = score >= 60;

                    SaveQuizResult(db, chapterId, score, passed);
                    StoredAnswers = new Dictionary<int, int>();

                    // Reload page state (updates chapter unlock, comments, etc.)
                    LoadCourse();

                    // Override quiz result UI after reload
                    pnlQuizResult.Visible = true;
                    pnlQuizResult.CssClass = passed
                        ? "mt-3 p-4 rounded-xl bg-green-50 text-green-700 text-sm font-medium"
                        : "mt-3 p-4 rounded-xl bg-red-50 text-red-600 text-sm font-medium";
                    litQuizResult.Text = passed
                        ? "&#127881; You passed! Score: " + score + "%"
                        : "Score: " + score + "%. You need 60% to pass. Try again!";
                    btnNextQuestion.Visible = false;
                }
                else
                {
                    CurrentQuestionIndex++;
                    hdnSelectedAnswer.Value = "";
                    LoadCourse();
                }
            }
        }

        private void SaveQuizResult(WokFlowContext db, int chapterId, int score, bool passed)
        {
            var result = new QuizResult
            {
                UserId = CurrentUserId,
                ChapterId = chapterId,
                Score = score,
                Status = passed ? "Passed" : "Failed",
                CompletedDate = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow
            };
            db.QuizResults.Add(result);

            if (passed)
                CompleteChapter(db, chapterId);

            db.SaveChanges();
        }

        private void CompleteChapter(WokFlowContext db, int chapterId)
        {
            var progress = db.UserChapterProgress
                .FirstOrDefault(p => p.UserId == CurrentUserId && p.ChapterId == chapterId);

            if (progress != null)
            {
                progress.IsCompleted = true;
                progress.CompletedDate = DateTime.UtcNow;
                progress.UpdatedAt = DateTime.UtcNow;
            }

            var currentChapter = db.Chapters.Find(chapterId);
            if (currentChapter != null)
            {
                var nextChapter = db.Chapters
                    .Where(ch => ch.CourseId == currentChapter.CourseId && ch.ChapterOrder == currentChapter.ChapterOrder + 1)
                    .FirstOrDefault();

                if (nextChapter != null)
                {
                    bool exists = db.UserChapterProgress
                        .Any(p => p.UserId == CurrentUserId && p.ChapterId == nextChapter.ChapterId);

                    if (!exists)
                    {
                        var enroll = db.Enrollments
                            .FirstOrDefault(en => en.UserId == CurrentUserId && en.CourseId == currentChapter.CourseId);

                        if (enroll != null)
                        {
                            db.UserChapterProgress.Add(new UserChapterProgress
                            {
                                UserId = CurrentUserId,
                                EnrollmentId = enroll.EnrollmentId,
                                ChapterId = nextChapter.ChapterId,
                                IsCompleted = false,
                                CreatedAt = DateTime.UtcNow,
                                UpdatedAt = DateTime.UtcNow
                            });
                        }
                    }
                }

                UpdateCourseProgress(db, currentChapter.CourseId);
            }
        }

        private void UpdateCourseProgress(WokFlowContext db, int courseId)
        {
            var enroll = db.Enrollments
                .FirstOrDefault(en => en.UserId == CurrentUserId && en.CourseId == courseId);
            if (enroll == null) return;

            int totalChapters = db.Chapters.Count(ch => ch.CourseId == courseId);
            if (totalChapters == 0) return;

            var chapterIds = db.Chapters.Where(ch => ch.CourseId == courseId).Select(ch => ch.ChapterId).ToList();
            int completed = db.UserChapterProgress
                .Count(p => p.UserId == CurrentUserId && chapterIds.Contains(p.ChapterId) && p.IsCompleted);

            enroll.Progress = (int)Math.Round((double)completed / totalChapters * 100);
            enroll.Status = enroll.Progress == 100 ? "Completed" : "In Progress";
            enroll.UpdatedAt = DateTime.UtcNow;
        }

        protected string GetChapterHref(object dataItem)
        {
            int chapterId = (int)DataBinder.Eval(dataItem, "ChapterId");
            return IsChapterUnlocked(chapterId)
                ? "?id=" + CourseId + "&ch=" + chapterId + "&tab=" + ActiveTab
                : "#";
        }

        protected string GetChapterCss(object dataItem)
        {
            return GetChapterCss(
                (int)DataBinder.Eval(dataItem, "ChapterId"),
                (bool)DataBinder.Eval(dataItem, "IsCompleted"));
        }

        protected string GetChapterBadgeCss(object dataItem)
        {
            int chapterId = (int)DataBinder.Eval(dataItem, "ChapterId");
            bool isCompleted = (bool)DataBinder.Eval(dataItem, "IsCompleted");
            if (isCompleted) return "bg-green-100 text-green-700";
            if (IsChapterUnlocked(chapterId)) return "bg-orange-100 text-[#FF8C66]";
            return "bg-gray-100 text-gray-400";
        }

        protected string GetChapterBadgeContent(object dataItem)
        {
            int chapterId = (int)DataBinder.Eval(dataItem, "ChapterId");
            int order = (int)DataBinder.Eval(dataItem, "ChapterOrder");
            bool isCompleted = (bool)DataBinder.Eval(dataItem, "IsCompleted");
            if (isCompleted) return "&#10003;";
            if (IsChapterUnlocked(chapterId)) return order.ToString();
            return "&#128274;";
        }

        protected string GetChapterTitleCss(object dataItem)
        {
            int chapterId = (int)DataBinder.Eval(dataItem, "ChapterId");
            if (chapterId == ActiveChapterId && IsChapterUnlocked(chapterId))
                return "text-[#FF8C66] font-semibold";
            return IsChapterUnlocked(chapterId) ? "text-[#1A1A1A]" : "text-gray-400";
        }
    }

    public class ChapterListItem
    {
        public int ChapterId { get; set; }
        public int ChapterOrder { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public bool IsCompleted { get; set; }
    }

    public class CommentListItem
    {
        public int CommentId { get; set; }
        public string Username { get; set; }
        public string CommentText { get; set; }
        public int Rating { get; set; }
        public DateTime CreatedDate { get; set; }
    }
}