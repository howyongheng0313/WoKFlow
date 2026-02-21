using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.Entity;
using WokFlow.Models;


namespace WokFlow.Pages.Learner
{
    public partial class Dashboard : LearnerPage
    {
        private List<int> _enrolledCourseIds;

        private const int PageSize = 6;

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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCourses();
            }
        }

        private void BindCourses()
        {
            using (var db = new WokFlowContext())
            {
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
                if (!string.IsNullOrEmpty(diff))
                {
                    int difficulty = int.Parse(diff);
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

                var courses = sortedQuery
                    .Select(c => new
                    {
                        c.CourseId,
                        c.Title,
                        c.Description,
                        CuisineName = c.Cuisine.CuisineName,
                        c.Duration,
                        c.Difficulty,
                        c.ImageUrl
                    })
                    .Skip((CurrentPage - 1) * PageSize)
                    .Take(PageSize)
                    .ToList();

                // Cache enrolled course IDs
                _enrolledCourseIds = db.Enrollments
                    .Where(en => en.UserId == CurrentUserId)
                    .Select(en => en.CourseId)
                    .ToList();

                ViewState["EnrolledIds"] = _enrolledCourseIds;

                rptCourses.DataSource = courses;
                rptCourses.DataBind();

                BindPagination();
            }
        }

        private void BindPagination()
        {
            var pages = Enumerable.Range(1, TotalPages)
                .Select(i => new { PageNumber = i })
                .ToList();

            rptPages.DataSource = pages;
            rptPages.DataBind();

            btnPrev.Enabled = CurrentPage > 1;
            btnNext.Enabled = CurrentPage < TotalPages;
        }

        protected bool IsEnrolled(int courseId)
        {
            var ids = ViewState["EnrolledIds"] as List<int>;
            return ids != null && ids.Contains(courseId);
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Join")
            {
                int courseId = int.Parse(e.CommandArgument.ToString());

                using (var db = new WokFlowContext())
                {
                    // Check if already enrolled
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
                    Response.Redirect("../Pages/Shared/CourseDetail.aspx?id=" + courseId);
                }
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            CurrentPage = 1;
            BindCourses();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlCuisine.SelectedIndex = 0;
            ddlDifficulty.SelectedIndex = 0;
            ddlTimePosted.SelectedIndex = 0;
            CurrentPage = 1;
            BindCourses();
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                BindCourses();
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (CurrentPage < TotalPages)
            {
                CurrentPage++;
                BindCourses();
            }
        }

        protected void rptPages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Page")
            {
                int page = int.Parse(e.CommandArgument.ToString());
                if (page >= 1 && page <= TotalPages)
                {
                    CurrentPage = page;
                    BindCourses();
                }
            }
        }
    }
}