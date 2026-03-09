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
    public partial class MyCourses : LearnerPage
    {
        private const int PageSize = 8;

        // Store current page and total pages in ViewState for pagination
        protected int CurrentPage
        {
            get { return ViewState["CurrentPage"] != null ? (int)ViewState["CurrentPage"] : 1; }
            set { ViewState["CurrentPage"] = value; }
        }

        // Store total pages in ViewState for pagination
        private int TotalPages
        {
            get { return ViewState["TotalPages"] != null ? (int)ViewState["TotalPages"] : 1; }
            set { ViewState["TotalPages"] = value; }
        }

        // Determine active tab based on query string or default based on role
        protected string ActiveTab
        {
            get { return Request.QueryString["tab"] ?? (IsSharer ? "created" : "joined"); }
        }

        // Check if current user is a sharer based on role
        protected bool IsSharer
        {
            get { return CurrentUserRole == "SHARER"; }
        }

        // Page Load 
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SetupPage();
                BindData();
            }
        }

        // Setup page elements based on active tab and user role
        private void SetupPage()
        {
            // Dynamic page title
            if (IsSharer && ActiveTab == "created")
            {
                litPageTitle.Text = "Created Courses";
                pnlCreateBtn.Visible = true;
                txtSearch.Attributes["placeholder"] = "Search created courses...";

                // Status options for Created tab
                ddlStatus.Items.Clear();
                ddlStatus.Items.Add(new ListItem("All Status", ""));
                ddlStatus.Items.Add(new ListItem("Active", "Active"));
                ddlStatus.Items.Add(new ListItem("Deleted", "Deleted"));
                ddlStatus.Items.Add(new ListItem("Banned", "Banned"));
            }
            else
            {
                litPageTitle.Text = "Joined Courses";
                pnlCreateBtn.Visible = false;
                txtSearch.Attributes["placeholder"] = "Search joined courses...";

                // Status options for Joined tab
                ddlStatus.Items.Clear();
                ddlStatus.Items.Add(new ListItem("All Status", ""));
                ddlStatus.Items.Add(new ListItem("In Progress", "In Progress"));
                ddlStatus.Items.Add(new ListItem("Completed", "Completed"));
            }
        }

        // Bind data to repeaters based on active tab and apply search/status filters
        private void BindData()
        {
            using (var db = new WokFlowContext())
            {
                // Show courses created by SHARER
                if (IsSharer && ActiveTab == "created")
                {
                    pnlCreated.Visible = true;
                    pnlJoined.Visible = false;

                    // Get all courses created by user
                    var courses = db.Courses
                        .Where(c => c.CreatorId == CurrentUserId)
                        .OrderByDescending(c => c.CreatedDate)
                        .ToList();

                    // Apply search filter
                    string search = txtSearch.Text.Trim();
                    if (!string.IsNullOrEmpty(search))
                        courses = courses.Where(c => c.Title.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0).ToList();

                    // Apply status filter
                    string statusFilter = ddlStatus.SelectedValue;
                    if (!string.IsNullOrEmpty(statusFilter))
                        courses = courses.Where(c => c.Status == statusFilter).ToList();

                    // Calculate stats for dashboard
                    var allCourseIds = db.Courses
                        .Where(c => c.CreatorId == CurrentUserId)
                        .Select(c => c.CourseId)
                        .ToList();
                    int totalStudents = db.Enrollments
                        .Count(en => allCourseIds.Contains(en.CourseId));
                    int totalCreated = db.Courses.Count(c => c.CreatorId == CurrentUserId);
                    int activeCourses = db.Courses.Count(c => c.CreatorId == CurrentUserId && c.Status == "Active");

                    // Set stats for dashboard
                    dashStats.Items = new List<StatItemData>
                    {
                        new StatItemData { Icon = "edit-3", Label = "Total Created", Value = totalCreated.ToString() },
                        new StatItemData { Icon = "zap", Label = "Active Courses", Value = activeCourses.ToString() },
                        new StatItemData { Icon = "users", Label = "Total Students", Value = totalStudents.ToString("N0") }
                    };

                    // Pagination
                    int total = courses.Count;
                    TotalPages = total == 0 ? 1 : (int)Math.Ceiling(total / (double)PageSize);
                    if (CurrentPage > TotalPages) 
                        CurrentPage = TotalPages;
                    if (CurrentPage < 1) 
                        CurrentPage = 1;

                    lblShowing.Text = string.Format("Showing {0} item{1}", total, total == 1 ? "" : "s");
                    btnPrev.Enabled = CurrentPage > 1;
                    btnNext.Enabled = CurrentPage < TotalPages;

                    // Get only the courses for the current page
                    courses = courses
                        .Skip((CurrentPage - 1) * PageSize)
                        .Take(PageSize)
                        .ToList();

                    rptCreatedCourses.DataSource = courses;
                    rptCreatedCourses.DataBind();
                }
                else
                {
                    pnlCreated.Visible = false;
                    pnlJoined.Visible = true;

                    // Get all courses the user is enrolled in
                    var enrollments = db.Enrollments
                        .Where(en => en.UserId == CurrentUserId)
                        .OrderByDescending(en => en.EnrollmentDate)
                        .Select(en => new
                        {
                            en.EnrollmentId,
                            en.CourseId,
                            CourseTitle = en.Course.Title,
                            CourseStatus = en.Course.Status,
                            en.Progress,
                            en.Status,
                            en.EnrollmentDate
                        }).ToList();

                    // Apply search filter
                    string search = txtSearch.Text.Trim();
                    if (!string.IsNullOrEmpty(search))
                        enrollments = enrollments.Where(en => en.CourseTitle.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0).ToList();

                    // Apply status filter
                    string statusFilter = ddlStatus.SelectedValue;
                    if (!string.IsNullOrEmpty(statusFilter))
                        enrollments = enrollments.Where(en => en.Status == statusFilter).ToList();

                    // Calculate stats for dashboard
                    int totalEnrolled = db.Enrollments.Count(en => en.UserId == CurrentUserId);
                    int completed = db.Enrollments.Count(en => en.UserId == CurrentUserId && en.Status == "Completed");
                    var allProgress = db.Enrollments
                        .Where(en => en.UserId == CurrentUserId)
                        .Select(en => en.Progress)
                        .ToList();
                    string avgProgress = allProgress.Any()
                        ? Math.Round(allProgress.Average(p => (double)p)).ToString()
                        : "0";

                    // Set stats for dashboard
                    dashStats.Items = new List<StatItemData>
                    {
                        new StatItemData { Icon = "book-open", Label = "Enrolled Courses", Value = totalEnrolled.ToString() },
                        new StatItemData { Icon = "check-circle", Label = "Completed", Value = completed.ToString() },
                        new StatItemData { Icon = "trending-up", Label = "Average Progress", Value = avgProgress, SubValue = "%" }
                    };

                    // Pagination
                    int total = enrollments.Count;
                    TotalPages = total == 0 ? 1 : (int)Math.Ceiling(total / (double)PageSize);
                    if (CurrentPage > TotalPages) CurrentPage = TotalPages;
                    if (CurrentPage < 1) CurrentPage = 1;

                    lblShowing.Text = string.Format("Showing {0} item{1}", total, total == 1 ? "" : "s");
                    btnPrev.Enabled = CurrentPage > 1;
                    btnNext.Enabled = CurrentPage < TotalPages;

                    // Get only the enrollments for the current page
                    enrollments = enrollments
                        .Skip((CurrentPage - 1) * PageSize)
                        .Take(PageSize)
                        .ToList();

                    rptEnrolledCourses.DataSource = enrollments;
                    rptEnrolledCourses.DataBind();
                }
            }
        }

        // Event handlers for search, pagination, and item commands
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            BindData();
        }

        // Previous page button click
        protected void btnPrev_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1) { CurrentPage--; BindData(); }
        }

        // Next page button click
        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (CurrentPage < TotalPages) { CurrentPage++; BindData(); }
        }

        // Handle commands for created courses (Edit, Delete, Recover)
        protected void rptCreatedCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int courseId;

            // Ensure the command argument is a valid integer course ID
            if (!int.TryParse(e.CommandArgument.ToString(), out courseId))
                return;

            // Verify the course exists and belongs to the current user before performing any actions
            using (var db = new WokFlowContext())
            {
                var course = db.Courses.Find(courseId);

                // If course doesn't exist or doesn't belong to the current user, do nothing
                if (course == null || course.CreatorId != CurrentUserId) return;

                switch (e.CommandName)
                {
                    case "Edit":
                        // Redirect to edit page with course ID as query parameter
                        Response.Redirect("~/Pages/Sharer/CreateCourse.aspx?editId=" + courseId);
                        break;

                    case "Delete":
                        // Soft delete by updating status to "Deleted" and setting UpdatedAt timestamp
                        course.Status = "Deleted";
                        course.UpdatedAt = DateTime.UtcNow;
                        db.SaveChanges();
                        break;

                    case "Recover":
                        // Recover by updating status back to "Active" and setting UpdatedAt timestamp
                        if (course.Status == "Deleted")
                        {
                            course.Status = "Active";
                            course.UpdatedAt = DateTime.UtcNow;
                            db.SaveChanges();
                        }
                        break;
                }
            }
            BindData();
        }

        // Get progress bar width style based on progress percentage
        protected string GetProgressWidth(object progress) => $"style=\"width:{progress}%\"";

        // Handle commands for enrolled courses (Unenroll)
        protected void rptEnrolledCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Only handle Unenroll command for enrolled courses
            if (e.CommandName == "Unenroll")
            {
                int enrollmentId;

                // Ensure the command argument is a valid integer enrollment ID
                if (!int.TryParse(e.CommandArgument.ToString(), out enrollmentId))
                    return;

                // Verify the enrollment exists and belongs to the current user before performing any actions
                using (var db = new WokFlowContext())
                {
                    var enrollment = db.Enrollments.Find(enrollmentId);

                    // If enrollment doesn't exist or doesn't belong to the current user, do nothing
                    if (enrollment != null && enrollment.UserId == CurrentUserId)
                    {
                        // Remove quiz results for this user's chapters in this course
                        var courseChapterIds = db.Chapters
                            .Where(ch => ch.CourseId == enrollment.CourseId)
                            .Select(ch => ch.ChapterId)
                            .ToList();

                        // Remove quiz results for this user and the chapters of the course they are unenrolling from
                        var quizResults = db.QuizResults.Where(qr =>
                            qr.UserId == CurrentUserId &&
                            courseChapterIds.Contains(qr.ChapterId));
                        db.QuizResults.RemoveRange(quizResults);

                        // Remove chapter progress
                        var progress = db.UserChapterProgress.Where(p => p.EnrollmentId == enrollmentId);
                        db.UserChapterProgress.RemoveRange(progress);
                        db.Enrollments.Remove(enrollment);
                        db.SaveChanges();
                    }
                }
                BindData();
            }
        }
    }
}