using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Models;

namespace WokFlow.Pages.Admin
{
    public partial class SharerRegistration : AdminPage
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
                var query = db.SharerRegistrations.Include("User").AsQueryable();

                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                    query = query.Where(r => r.User.Username.Contains(search));

                string status = ddlStatus.SelectedValue;
                if (!string.IsNullOrEmpty(status))
                    query = query.Where(r => r.Status == status);

                var data = query.OrderByDescending(r => r.RequestDate)
                    .Select(r => new
                    {
                        r.RegistrationId,
                        Username = r.User.Username,
                        r.RequestDate,
                        r.ProofDocument,
                        r.Status
                    }).ToList();

                rptRegistrations.DataSource = data;
                rptRegistrations.DataBind();
            }
        }

        protected void rptRegistrations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            using (var db = new WokFlowContext())
            {
                var reg = db.SharerRegistrations.Find(id);
                if (reg == null) return;

                switch (e.CommandName)
                {
                    case "Accept":
                        reg.Status = "Accepted";
                        reg.ReviewedBy = CurrentUserId;
                        reg.ReviewedDate = DateTime.UtcNow;
                        var userToPromote = db.Users.Find(reg.UserId);
                        if (userToPromote != null)
                        {
                            userToPromote.Role = "SHARER";
                            userToPromote.UpdatedAt = DateTime.UtcNow;
                        }
                        break;
                    case "Reject":
                        reg.Status = "Rejected";
                        reg.ReviewedBy = CurrentUserId;
                        reg.ReviewedDate = DateTime.UtcNow;
                        break;
                    case "Undo":
                        if (reg.Status == "Accepted")
                        {
                            var userToDemote = db.Users.Find(reg.UserId);
                            if (userToDemote != null)
                            {
                                userToDemote.Role = "LEARNER";
                                userToDemote.UpdatedAt = DateTime.UtcNow;
                            }
                        }
                        reg.Status = "Pending";
                        reg.ReviewedBy = null;
                        reg.ReviewedDate = null;
                        break;
                }
                reg.UpdatedAt = DateTime.UtcNow;
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