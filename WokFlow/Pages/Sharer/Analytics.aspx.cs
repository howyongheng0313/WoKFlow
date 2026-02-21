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
        protected string ActiveTab
        {
            get { return Request.QueryString["tab"] ?? "performance"; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SetupTabs();
                PopulateFilterDropdowns();
            }
            LoadTabData();
        }

        private void SetupTabs()
        {
            pnlPerformance.Visible = ActiveTab == "performance";
            pnlQuiz.Visible = ActiveTab == "quiz";
            pnlComments.Visible = ActiveTab == "comments";

            string activeClass = "nav-active px-6 py-2 rounded-full text-sm font-bold no-underline";
            string inactiveClass = "bg-white/60 text-gray-600 px-6 py-2 rounded-full text-sm font-bold no-underline";
            lnkPerformance.Attributes["class"] = ActiveTab == "performance" ? activeClass : inactiveClass;
            lnkQuiz.Attributes["class"] = ActiveTab == "quiz" ? activeClass : inactiveClass;
            lnkComments.Attributes["class"] = ActiveTab == "comments" ? activeClass : inactiveClass;
        }

        private void PopulateFilterDropdowns()
        {
            using (var db = new WokFlowContext())
            {
                var courses = db.Courses
                    .Where(c => c.CreatorId == CurrentUserId && c.Status != "Deleted")
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
                    .Where(c => c.CreatorId == CurrentUserId && c.Status != "Deleted")
                    .Select(c => c.CourseId)
                    .ToList();

                // Stats: all real values from DB
                int activeCourses = db.Courses.Count(c => c.CreatorId == CurrentUserId && c.Status == "Active");
                int totalStudents = db.Enrollments.Count(en => myCourseIds.Contains(en.CourseId));
                int completed = db.Enrollments.Count(en => myCourseIds.Contains(en.CourseId) && en.Status == "Completed");

                var ratingQuery = db.Comments.Where(c => myCourseIds.Contains(c.CourseId));
                string avgRating = ratingQuery.Any()
                    ? Math.Round(ratingQuery.Average(c => c.Rating), 1).ToString("0.0")
                    : "N/A";

                dashStats.Items = new List<StatItemData>
                {
                    new StatItemData { Icon = "book-open",    Label = "Active Courses",  Value = activeCourses.ToString() },
                    new StatItemData { Icon = "star",         Label = "Average Rating",  Value = avgRating },
                    new StatItemData { Icon = "users",        Label = "Total Students",  Value = totalStudents.ToString() },
                    new StatItemData { Icon = "check-circle", Label = "Completed",       Value = completed.ToString() }
                };

                if (ActiveTab == "performance")
                    LoadPerformance(db, myCourseIds);
                else if (ActiveTab == "quiz")
                    LoadQuizResults(db, myCourseIds);
                else if (ActiveTab == "comments")
                    LoadComments(db, myCourseIds);
            }
        }

        // ── Performance ────────────────────────────────────────────────────────
        private void LoadPerformance(WokFlowContext db, List<int> myCourseIds)
        {
            DateTime? startDate = null;
            DateTime? endDate = null;

            if (!string.IsNullOrEmpty(txtStartDate.Text))
                startDate = DateTime.Parse(txtStartDate.Text);
            if (!string.IsNullOrEmpty(txtEndDate.Text))
                endDate = DateTime.Parse(txtEndDate.Text).AddDays(1); // include full end day

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
            // Page_Load already calls LoadTabData with the current filter values.
        }

        protected void btnClearPerf_Click(object sender, EventArgs e)
        {
            txtStartDate.Text = "";
            txtEndDate.Text = "";
        }

        // ── Quiz Results ───────────────────────────────────────────────────────
        private void LoadQuizResults(WokFlowContext db, List<int> myCourseIds)
        {
            string cuisineFilter = ddlQuizCuisine.SelectedValue;
            string courseFilter = ddlQuizCourse.SelectedValue;
            string statusFilter = ddlQuizStatus.SelectedValue;

            // Build filtered course ID list
            var courseQuery = db.Courses
                .Where(c => myCourseIds.Contains(c.CourseId))
                .Include("Cuisine");

            if (!string.IsNullOrEmpty(cuisineFilter))
                courseQuery = courseQuery.Where(c => c.Cuisine.CuisineName == cuisineFilter);
            if (!string.IsNullOrEmpty(courseFilter))
            {
                int cId = int.Parse(courseFilter);
                courseQuery = courseQuery.Where(c => c.CourseId == cId);
            }

            var filteredCourseIds = courseQuery.Select(c => c.CourseId).ToList();
            var chapterIds = db.Chapters
                .Where(ch => filteredCourseIds.Contains(ch.CourseId))
                .Select(ch => ch.ChapterId)
                .ToList();

            var query = db.QuizResults
                .Where(q => chapterIds.Contains(q.ChapterId))
                .Include("User");

            if (!string.IsNullOrEmpty(statusFilter))
                query = query.Where(q => q.Status == statusFilter);

            var results = query
                .OrderByDescending(q => q.CompletedDate)
                .Select(q => new
                {
                    Username = q.User.Username,
                    q.CompletedDate,
                    q.Score,
                    q.Status
                }).ToList();

            lblNoQuiz.Visible = results.Count == 0;
            rptQuizResults.DataSource = results;
            rptQuizResults.DataBind();
        }

        // ── Comments ───────────────────────────────────────────────────────────
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

            var comments = db.Comments
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

            lblNoComments.Visible = comments.Count == 0;
            rptComments.DataSource = comments;
            rptComments.DataBind();
        }

        // ── Helpers ────────────────────────────────────────────────────────────
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