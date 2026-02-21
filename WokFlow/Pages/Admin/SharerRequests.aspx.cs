using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Models;

namespace WokFlow.Pages.Admin
{
    public partial class SharerRequests : AdminPage
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
                var query = db.SharerRequests.Include("User").AsQueryable();

                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                    query = query.Where(r => r.User.Username.Contains(search));

                string status = ddlStatus.SelectedValue;
                if (!string.IsNullOrEmpty(status))
                    query = query.Where(r => r.Status == status);

                var data = query.OrderByDescending(r => r.RequestDate)
                    .Select(r => new
                    {
                        r.RequestId,
                        Username = r.User.Username,
                        r.RequestDate,
                        r.Status
                    }).ToList();

                rptRequests.DataSource = data;
                rptRequests.DataBind();
            }
        }

        protected void rptRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            using (var db = new WokFlowContext())
            {
                var req = db.SharerRequests.Find(id);
                if (req == null) return;

                switch (e.CommandName)
                {
                    case "Accept":
                        req.Status = "Accepted";
                        req.ReviewedBy = CurrentUserId;
                        req.ReviewedDate = DateTime.UtcNow;
                        var userToPromote = db.Users.Find(req.UserId);
                        if (userToPromote != null)
                        {
                            userToPromote.Role = "SHARER";
                            userToPromote.UpdatedAt = DateTime.UtcNow;
                        }
                        break;
                    case "Reject":
                        req.Status = "Rejected";
                        req.ReviewedBy = CurrentUserId;
                        req.ReviewedDate = DateTime.UtcNow;
                        break;
                    case "Undo":
                        if (req.Status == "Accepted")
                        {
                            var userToDemote = db.Users.Find(req.UserId);
                            if (userToDemote != null)
                            {
                                userToDemote.Role = "LEARNER";
                                userToDemote.UpdatedAt = DateTime.UtcNow;
                            }
                        }
                        req.Status = "Pending";
                        req.ReviewedBy = null;
                        req.ReviewedDate = null;
                        break;
                }
                req.UpdatedAt = DateTime.UtcNow;
                db.SaveChanges();
            }
            BindData();
        }

        protected string GetStatusCss(string status)
        {
            switch (status)
            {
                case "Accepted": return "bg-green-100 text-green-700";
                case "Rejected": return "bg-red-100 text-red-700";
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