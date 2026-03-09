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
        private const int PageSize = 6;

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
    }
}