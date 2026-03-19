using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Controls;
using WokFlow.Models;

namespace WokFlow.Pages.Admin
{
    public partial class ContentManagement : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            BindData();
        }

        private void BindData()
        {
            using (var db = new WokFlowContext())
            {
                var query = db.ReportedContents.Include("Course").Include("Reporter").AsQueryable();

                // Apply search filter (matches course title or reporter username)
                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search)) 
                    query = query.Where(r => r.Course.Title.Contains(search) || r.Reporter.Username.Contains(search));

                // Apply status filter
                string status = ddlStatus.SelectedValue;
                if (!string.IsNullOrEmpty(status))
                    query = query.Where(r => r.Status == status);

                // Dashboard stats (global, unaffected by filters)
                dashStats.Items = new List<StatItemData>
                {
                    new StatItemData { Icon = "flag", Label = "Total Reports", Value = db.ReportedContents.Count().ToString() },
                    new StatItemData { Icon = "clock", Label = "Pending", Value = db.ReportedContents.Count(r => r.Status == "Pending").ToString() },
                    new StatItemData { Icon = "ban", Label = "Banned", Value = db.ReportedContents.Count(r => r.Status == "Banned").ToString() },
                    new StatItemData { Icon = "eye-off", Label = "Ignored", Value = db.ReportedContents.Count(r => r.Status == "Ignored").ToString() }
                };

                // Bind filtered reports to repeater
                var data = query.OrderByDescending(r => r.ReportDate)
                    .Select(r => new
                    {
                        r.ReportId,
                        CourseTitle = r.Course.Title,
                        ReporterName = r.Reporter.Username,
                        r.Reason,
                        r.ReportDate,
                        r.Status
                    }).ToList();

                rptReports.DataSource = data;
                rptReports.DataBind();
            }
        }

        // Handles Ban, Ignore, and Undo commands on a reported content item.
        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int id)) return;
            using (var db = new WokFlowContext())
            {
                var report = db.ReportedContents.Find(id);
                if (report == null) return;

                switch (e.CommandName)
                {
                    case "Ban":
                        // Mark report as banned and also ban the associated cours
                        report.Status = "Banned";
                        report.ReviewedBy = CurrentUserId;
                        report.ReviewedDate = DateTime.UtcNow;
                        var courseToBan = db.Courses.Find(report.CourseId);
                        if (courseToBan != null)
                        {
                            courseToBan.Status = "Banned";
                            courseToBan.UpdatedAt = DateTime.UtcNow;
                        }
                        break;

                    case "Ignore":
                        // Dismiss the report without affecting the cours
                        report.Status = "Ignored";
                        report.ReviewedBy = CurrentUserId;
                        report.ReviewedDate = DateTime.UtcNow;
                        break;

                    case "Undo":
                        // Revert to Pending; restore the course if it was banned
                        if (report.Status == "Banned")
                        {
                            var courseToRestore = db.Courses.Find(report.CourseId);
                            if (courseToRestore != null)
                            {
                                courseToRestore.Status = "Active";
                                courseToRestore.UpdatedAt = DateTime.UtcNow;
                            }
                        }
                        report.Status = "Pending";
                        report.ReviewedBy = null;
                        report.ReviewedDate = null;
                        break;
                }
                report.UpdatedAt = DateTime.UtcNow;
                db.SaveChanges();
            }
            BindData();
        }

        // Re-binds data when any filter dropdown or search box changes.
        protected void Filter_Changed(object sender, EventArgs e) => BindData();
    }
}