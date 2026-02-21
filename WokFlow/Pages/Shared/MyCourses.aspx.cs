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

        protected int CurrentPage
        {
            get { return ViewState["CurrentPage"] != null ? (int)ViewState["CurrentPage"] : 1; }
            set { ViewState["CurrentPage"] = value; }
        }

        private int TotalPages
        {
            get { return ViewState["TotalPages"] != null ? (int)ViewState["TotalPages"] : 1; }
            set { ViewState["TotalPages"] = value; }
        }

        protected string ActiveTab
        {
            get { return Request.QueryString["tab"] ?? (IsSharer ? "created" : "joined"); }
        }

        protected bool IsSharer
        {
            get { return CurrentUserRole == "SHARER"; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlSharerTabs.Visible = IsSharer;
                BindData();
            }
        }

        private void BindData()
        {
            using (var db = new WokFlowContext())
            {
                if (IsSharer && ActiveTab == "created")
                {
                    pnlCreated.Visible = true;
                    pnlJoined.Visible = false;

                    var courses = db.Courses
                        .Where(c => c.CreatorId == CurrentUserId)
                        .OrderByDescending(c => c.CreatedDate)
                        .ToList();

                    string search = txtSearch.Text.Trim();
                    if (!string.IsNullOrEmpty(search))
                        courses = courses.Where(c => c.Title.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0).ToList();

                    var courseIds = courses.Select(c => c.CourseId).ToList();
                    var learnerEnrollments = db.Enrollments
                        .Where(en => courseIds.Contains(en.CourseId))
                        .ToList();
                    string avgProgress = learnerEnrollments.Any()
                        ? Math.Round(learnerEnrollments.Average(en => en.Progress)).ToString() + "%"
                        : "N/A";

                    dashStats.Items = new List<StatItemData>
                    {
                        new StatItemData { Icon = "book-open", Label = "Created Courses", Value = courses.Count.ToString() },
                        new StatItemData { Icon = "check-circle", Label = "Active", Value = courses.Count(c => c.Status == "Active").ToString() },
                        new StatItemData { Icon = "trending-up", Label = "Average Progress", Value = avgProgress }
                    };

                    // Pagination
                    int total = courses.Count;
                    TotalPages = total == 0 ? 1 : (int)Math.Ceiling(total / (double)PageSize);
                    if (CurrentPage > TotalPages) CurrentPage = TotalPages;
                    if (CurrentPage < 1) CurrentPage = 1;

                    lblShowing.Text = string.Format("Showing {0} item{1}", total, total == 1 ? "" : "s");
                    btnPrev.Enabled = CurrentPage > 1;
                    btnNext.Enabled = CurrentPage < TotalPages;

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

                    var enrollments = db.Enrollments
                        .Where(en => en.UserId == CurrentUserId)
                        .Include("Course")
                        .OrderByDescending(en => en.EnrollmentDate)
                        .Select(en => new
                        {
                            en.EnrollmentId,
                            en.CourseId,
                            CourseTitle = en.Course.Title,
                            en.Progress,
                            en.Status,
                            en.EnrollmentDate
                        }).ToList();

                    string search = txtSearch.Text.Trim();
                    if (!string.IsNullOrEmpty(search))
                        enrollments = enrollments.Where(en => en.CourseTitle.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0).ToList();

                    string statusFilter = ddlStatus.SelectedValue;
                    if (!string.IsNullOrEmpty(statusFilter))
                        enrollments = enrollments.Where(en => en.Status == statusFilter).ToList();

                    dashStats.Items = new List<StatItemData>
                    {
                        new StatItemData { Icon = "book-open", Label = "Enrolled Courses", Value = enrollments.Count.ToString() },
                        new StatItemData { Icon = "check-circle", Label = "Completed", Value = enrollments.Count(en => en.Status == "Completed").ToString() },
                        new StatItemData { Icon = "trending-up", Label = "Average Progress", Value = enrollments.Any() ? Math.Round(enrollments.Average(en => en.Progress)).ToString() + "%" : "0%" }
                    };

                    // Pagination
                    int total = enrollments.Count;
                    TotalPages = total == 0 ? 1 : (int)Math.Ceiling(total / (double)PageSize);
                    if (CurrentPage > TotalPages) CurrentPage = TotalPages;
                    if (CurrentPage < 1) CurrentPage = 1;

                    lblShowing.Text = string.Format("Showing {0} item{1}", total, total == 1 ? "" : "s");
                    btnPrev.Enabled = CurrentPage > 1;
                    btnNext.Enabled = CurrentPage < TotalPages;

                    enrollments = enrollments
                        .Skip((CurrentPage - 1) * PageSize)
                        .Take(PageSize)
                        .ToList();

                    rptEnrolledCourses.DataSource = enrollments;
                    rptEnrolledCourses.DataBind();
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            BindData();
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1) { CurrentPage--; BindData(); }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (CurrentPage < TotalPages) { CurrentPage++; BindData(); }
        }

        protected void rptCreatedCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int courseId = int.Parse(e.CommandArgument.ToString());
            using (var db = new WokFlowContext())
            {
                var course = db.Courses.Find(courseId);
                if (course == null || course.CreatorId != CurrentUserId) return;

                switch (e.CommandName)
                {
                    case "Edit":
                        Response.Redirect("~/Pages/Sharer/CreateCourse.aspx?editId=" + courseId);
                        break;
                    case "Delete":
                        course.Status = "Deleted";
                        course.UpdatedAt = DateTime.UtcNow;
                        db.SaveChanges();
                        break;
                    case "Recover":
                        course.Status = "Active";
                        course.UpdatedAt = DateTime.UtcNow;
                        db.SaveChanges();
                        break;
                }
            }
            BindData();
        }

        protected string GetProgressWidth(object progress) => $"style=\"width:{progress}%\"";

        protected void rptEnrolledCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Unenroll")
            {
                int enrollmentId = int.Parse(e.CommandArgument.ToString());
                using (var db = new WokFlowContext())
                {
                    var enrollment = db.Enrollments.Find(enrollmentId);
                    if (enrollment != null && enrollment.UserId == CurrentUserId)
                    {
                        // Remove quiz results for this user's chapters in this course
                        var courseChapterIds = db.Chapters
                            .Where(ch => ch.CourseId == enrollment.CourseId)
                            .Select(ch => ch.ChapterId)
                            .ToList();
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