using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Controls;
using WokFlow.Models;

namespace WokFlow.Pages.Sharer
{
    public partial class Analytics : SharerPage
    {
        private const int PageSize = 8;

        protected string ActiveTab
        {
            get { return Request.QueryString["tab"] ?? "performance"; }
        }

        private int QuizPage
        {
            get { return ViewState["QuizPage"] as int? ?? 1; }
            set { ViewState["QuizPage"] = value; }
        }

        private int QuizTotalPages
        {
            get { return ViewState["QuizTotalPages"] as int? ?? 1; }
            set { ViewState["QuizTotalPages"] = value; }
        }

        private int CommentPage
        {
            get { return ViewState["CommentPage"] as int? ?? 1; }
            set { ViewState["CommentPage"] = value; }
        }

        private int CommentTotalPages
        {
            get { return ViewState["CommentTotalPages"] as int? ?? 1; }
            set { ViewState["CommentTotalPages"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SetupTabs();
                PopulateFilterDropdowns();
            }
            PopulateChapterDropdown(ddlQuizCourse.SelectedValue);
            LoadTabData();
        }

        private void SetupTabs()
        {
            pnlPerformance.Visible = ActiveTab == "performance";
            pnlQuiz.Visible = ActiveTab == "quiz";
            pnlComments.Visible = ActiveTab == "comments";
        }

        private void PopulateFilterDropdowns()
        {
            using (var db = new WokFlowContext())
            {
                var courses = db.Courses
                    .Where(c => c.CreatorId == CurrentUserId && c.Status == "Active")
                    .OrderBy(c => c.Title)
                    .Select(c => new { c.CourseId, c.Title })
                    .ToList();

                ddlQuizCourse.Items.Clear();
                ddlQuizCourse.Items.Add(new ListItem("All Sections", ""));
                foreach (var c in courses)
                    ddlQuizCourse.Items.Add(new ListItem(c.Title, c.CourseId.ToString()));

                ddlCommentCourse.Items.Clear();
                ddlCommentCourse.Items.Add(new ListItem("All Courses", ""));
                foreach (var c in courses)
                    ddlCommentCourse.Items.Add(new ListItem(c.Title, c.CourseId.ToString()));

                var cuisines = db.Cuisines.OrderBy(c => c.CuisineName).ToList();
                ddlQuizCuisine.Items.Clear();
                ddlQuizCuisine.Items.Add(new ListItem("All Cuisine", ""));
                foreach (var c in cuisines)
                    ddlQuizCuisine.Items.Add(new ListItem(c.CuisineName, c.CuisineName));
            }
        }

        private void LoadTabData()
        {
            using (var db = new WokFlowContext())
            {
                var myCourseIds = db.Courses
                    .Where(c => c.CreatorId == CurrentUserId && c.Status == "Active")
                    .Select(c => c.CourseId)
                    .ToList();

                // Stats
                int totalStudents = db.Enrollments.Count(en => myCourseIds.Contains(en.CourseId));

                var ratingQuery = db.Comments.Where(c => myCourseIds.Contains(c.CourseId));
                string avgRating = ratingQuery.Any()
                    ? Math.Round(ratingQuery.Average(c => c.Rating), 1).ToString("0.0")
                    : "N/A";

                int totalEnrollments = db.Enrollments.Count(en => myCourseIds.Contains(en.CourseId));
                int completedHours = db.Enrollments.Count(en => myCourseIds.Contains(en.CourseId) && en.Status == "Completed");

                dashStats.Items = new List<StatItemData>
                {
                    new StatItemData { Icon = "eye",      Label = "Total Views",    Value = totalEnrollments.ToString() },
                    new StatItemData { Icon = "edit-3",    Label = "Average Rating", Value = avgRating },
                    new StatItemData { Icon = "users",     Label = "Students",       Value = totalStudents.ToString() },
                    new StatItemData { Icon = "clock",     Label = "Watch Time",     Value = completedHours.ToString(), SubValue = "h" }
                };

                if (ActiveTab == "performance")
                    LoadPerformance(db, myCourseIds);
                else if (ActiveTab == "quiz")
                    LoadQuizResults(db, myCourseIds);
                else if (ActiveTab == "comments")
                    LoadComments(db, myCourseIds);
            }
        }

        // Performance
        private void LoadPerformance(WokFlowContext db, List<int> myCourseIds)
        {
            DateTime? startDate = null;
            DateTime? endDate = null;

            if (!string.IsNullOrEmpty(txtStartDate.Text))
                startDate = DateTime.Parse(txtStartDate.Text);
            if (!string.IsNullOrEmpty(txtEndDate.Text))
                endDate = DateTime.Parse(txtEndDate.Text).AddDays(1);

            var courses = db.Courses
                .Where(c => myCourseIds.Contains(c.CourseId))
                .OrderBy(c => c.CreatedDate)
                .ToList();

            var labels = courses.Select(c =>
                c.Title.Length > 20 ? c.Title.Substring(0, 20) + "..." : c.Title).ToList();

            var data = courses.Select(c =>
            {
                var q = db.Enrollments.Where(en => en.CourseId == c.CourseId);
                if (startDate.HasValue) q = q.Where(en => en.EnrollmentDate >= startDate.Value);
                if (endDate.HasValue) q = q.Where(en => en.EnrollmentDate < endDate.Value);
                return q.Count();
            }).ToList();

            var serializer = new JavaScriptSerializer();
            performanceChart.Attributes["data-labels"] = serializer.Serialize(labels);
            performanceChart.Attributes["data-values"] = serializer.Serialize(data);
        }

        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            QuizPage = 1;
            CommentPage = 1;
        }

        protected void btnClearPerf_Click(object sender, EventArgs e)
        {
            txtStartDate.Text = "";
            txtEndDate.Text = "";
        }

        private void PopulateChapterDropdown(string courseId)
        {
            string previouslySelected = ddlQuizChapter.SelectedValue;

            ddlQuizChapter.Items.Clear();
            ddlQuizChapter.Items.Add(new ListItem("All Chapters", ""));

            if (string.IsNullOrEmpty(courseId))
            {
                ddlQuizChapter.Enabled = false;
                return;
            }

            using (var db = new WokFlowContext())
            {
                int cId = int.Parse(courseId);
                var chapters = db.Chapters
                    .Where(ch => ch.CourseId == cId)
                    .OrderBy(ch => ch.ChapterOrder)
                    .Select(ch => new { ch.ChapterId, ch.ChapterOrder, ch.Title })
                    .ToList();

                foreach (var ch in chapters)
                    ddlQuizChapter.Items.Add(new ListItem($"Chapter {ch.ChapterOrder} - {ch.Title}", ch.ChapterId.ToString()));
            }

            var existingItem = ddlQuizChapter.Items.FindByValue(previouslySelected);
            if (existingItem != null)
                ddlQuizChapter.SelectedValue = previouslySelected;

            ddlQuizChapter.Enabled = true;
        }

        // Quiz Results
        private void LoadQuizResults(WokFlowContext db, List<int> myCourseIds)
        {
            string cuisineFilter = ddlQuizCuisine.SelectedValue;
            string courseFilter = ddlQuizCourse.SelectedValue;
            string chapterFilter = ddlQuizChapter.SelectedValue;
            string statusFilter = ddlQuizStatus.SelectedValue;

            var courseQuery = db.Courses
                .Where(c => myCourseIds.Contains(c.CourseId))
                .Include("Cuisine");

            if (!string.IsNullOrEmpty(cuisineFilter))
            {
                courseQuery = courseQuery.Where(c => c.Cuisine.CuisineName == cuisineFilter);
            }
               
            if (!string.IsNullOrEmpty(courseFilter))
            {
                int cId = int.Parse(courseFilter);
                courseQuery = courseQuery.Where(c => c.CourseId == cId);
            }

            var filteredCourseIds = courseQuery.Select(c => c.CourseId).ToList();
            var chapterQuery = db.Chapters.Where(ch => filteredCourseIds.Contains(ch.CourseId));

            if (!string.IsNullOrEmpty(chapterFilter))
            {
                int chId = int.Parse(chapterFilter);
                chapterQuery = chapterQuery.Where(ch => ch.ChapterId == chId);
            }

            var chapterIds = chapterQuery.Select(ch => ch.ChapterId).ToList();

            var query = db.QuizResults
                .Where(q => chapterIds.Contains(q.ChapterId))
                .Include("User");

            if (!string.IsNullOrEmpty(statusFilter))
            {
                query = query.Where(q => q.Status == statusFilter);
            }

            var allResults = query
                .OrderByDescending(q => q.CompletedDate)
                .Select(q => new
                {
                    Username = q.User.Username,
                    q.CompletedDate,
                    q.Score,
                    q.Status
                }).ToList();

            int total = allResults.Count;
            QuizTotalPages = total == 0 ? 1 : (int)Math.Ceiling(total / (double)PageSize);
            if (QuizPage > QuizTotalPages) QuizPage = QuizTotalPages;
            if (QuizPage < 1) QuizPage = 1;

            int startIdx = (QuizPage - 1) * PageSize;
            int endIdx = Math.Min(startIdx + PageSize, total);
            lblQuizShowing.Text = total == 0
                ? "0 items"
                : string.Format("{0} - {1} of {2} items", startIdx + 1, endIdx, total);
            btnQuizPrev.Enabled = QuizPage > 1;
            btnQuizNext.Enabled = QuizPage < QuizTotalPages;

            var paged = allResults.Skip(startIdx).Take(PageSize).ToList();

            lblNoQuiz.Visible = total == 0;
            rptQuizResults.DataSource = paged;
            rptQuizResults.DataBind();
        }

        protected void btnQuizPrev_Click(object sender, EventArgs e)
        {
            if (QuizPage > 1) QuizPage--;
        }

        protected void btnQuizNext_Click(object sender, EventArgs e)
        {
            if (QuizPage < QuizTotalPages) QuizPage++;
        }

        // Comments
        private void LoadComments(WokFlowContext db, List<int> myCourseIds)
        {
            string courseFilter = ddlCommentCourse.SelectedValue;

            List<int> filteredIds;
            if (!string.IsNullOrEmpty(courseFilter))
            {
                int cId = int.Parse(courseFilter);
                filteredIds = myCourseIds.Where(id => id == cId).ToList();
            }
            else
            {
                filteredIds = myCourseIds;
            }

            var allComments = db.Comments
                .Where(c => filteredIds.Contains(c.CourseId))
                .Include("User")
                .OrderByDescending(c => c.CreatedDate)
                .Select(c => new
                {
                    Username = c.User.Username,
                    c.CommentText,
                    c.Rating,
                    c.CreatedDate
                }).ToList();

            int total = allComments.Count;
            CommentTotalPages = total == 0 ? 1 : (int)Math.Ceiling(total / (double)PageSize);
            if (CommentPage > CommentTotalPages) CommentPage = CommentTotalPages;
            if (CommentPage < 1) CommentPage = 1;

            int startIdx = (CommentPage - 1) * PageSize;
            int endIdx = Math.Min(startIdx + PageSize, total);
            lblCommentShowing.Text = total == 0
                ? "0 items"
                : string.Format("{0} - {1} of {2} items", startIdx + 1, endIdx, total);
            btnCommentPrev.Enabled = CommentPage > 1;
            btnCommentNext.Enabled = CommentPage < CommentTotalPages;

            var paged = allComments.Skip(startIdx).Take(PageSize).ToList();

            lblNoComments.Visible = total == 0;
            rptComments.DataSource = paged;
            rptComments.DataBind();
        }

        protected void btnCommentPrev_Click(object sender, EventArgs e)
        {
            if (CommentPage > 1) CommentPage--;
        }

        protected void btnCommentNext_Click(object sender, EventArgs e)
        {
            if (CommentPage < CommentTotalPages) CommentPage++;
        }

        // Helpers
        protected string GetScoreWidth(object score) => $"style=\"width:{score}%\"";

        protected string RenderStars(int rating)
        {
            string stars = "";
            for (int i = 0; i < 5; i++)
                stars += i < rating
                    ? "<span class='text-[#FF8C66]'>&#9733;</span>"
                    : "<span class='text-gray-300'>&#9733;</span>";
            return stars;
        }
    }
        
}