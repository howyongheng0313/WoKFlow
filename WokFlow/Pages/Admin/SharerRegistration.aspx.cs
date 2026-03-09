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
            BindData();
        }

        // Loads the filtered list of sharer registrations into the repeater.
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

        // Handles Accept, Reject, and Undo commands for a sharer registration.
        protected void rptRegistrations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int id)) return;
            using (var db = new WokFlowContext())
            {
                var reg = db.SharerRegistrations.Find(id);
                if (reg == null) return;

                switch (e.CommandName)
                {
                    case "Accept":
                        // Approve registration and promote user to SHARER
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
                        // Reject registration (user remains GUEST)
                        reg.Status = "Rejected";
                        reg.ReviewedBy = CurrentUserId;
                        reg.ReviewedDate = DateTime.UtcNow;
                        break;

                    case "Undo":
                        // Revert to Pending; demote user back to GUEST if previously accepted
                        if (reg.Status == "Accepted")
                        {
                            var userToDemote = db.Users.Find(reg.UserId);
                            if (userToDemote != null)
                            {
                                userToDemote.Role = "GUEST";
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

        // Re-binds data when any filter dropdown or search box changes.
        protected void Filter_Changed(object sender, EventArgs e) => BindData();
    }
}