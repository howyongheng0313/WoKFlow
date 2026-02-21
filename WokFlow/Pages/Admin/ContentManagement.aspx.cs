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
            if (!IsPostBack)
                BindData();
        }

        private void BindData()
        {
            using (var db = new WokFlowContext())
            {
                var query = db.ReportedContents.Include("Course").Include("Reporter").AsQueryable();

                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                    query = query.Where(r => r.Course.Title.Contains(search) || r.Reporter.Username.Contains(search));

                string status = ddlStatus.SelectedValue;
                if (!string.IsNullOrEmpty(status))
                    query = query.Where(r => r.Status == status);

                var allReports = db.ReportedContents.ToList();
                dashStats.Items = new List<StatItemData>
                {
                    new StatItemData { Icon = "flag", Label = "Total Reports", Value = allReports.Count.ToString() },
                    new StatItemData { Icon = "clock", Label = "Pending", Value = allReports.Count(r => r.Status == "Pending").ToString() },
                    new StatItemData { Icon = "ban", Label = "Banned", Value = allReports.Count(r => r.Status == "Banned").ToString() },
                    new StatItemData { Icon = "eye-off", Label = "Ignored", Value = allReports.Count(r => r.Status == "Ignored").ToString() }
                };

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

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            using (var db = new WokFlowContext())
            {
                var report = db.ReportedContents.Find(id);
                if (report == null) return;

                switch (e.CommandName)
                {
                    case "Ban":
                        report.Status = "Banned";
                        report.ReviewedBy = CurrentUserId;
                        report.ReviewedDate = DateTime.UtcNow;
                        var courseToBan = db.Courses.Find(report.CourseId);
                        if (courseToBan != null)
                        {
                            courseToBan.Status = "Deleted";
                            courseToBan.UpdatedAt = DateTime.UtcNow;
                        }
                        break;
                    case "Ignore":
                        report.Status = "Ignored";
                        report.ReviewedBy = CurrentUserId;
                        report.ReviewedDate = DateTime.UtcNow;
                        break;
                    case "Undo":
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

        protected string GetStatusCss(string status)
        {
            switch (status)
            {
                case "Banned": return "bg-red-100 text-red-700";
                case "Ignored": return "bg-gray-100 text-gray-700";
                default: return "bg-orange-100 text-[#FF8C66]";
            }
        }

        protected void Filter_Changed(object sender, EventArgs e) => BindData();

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatus.SelectedIndex = 0;
            BindData();
        }
    }
}