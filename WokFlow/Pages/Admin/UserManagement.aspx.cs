using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Controls;
using WokFlow.Models;

namespace WokFlow.Pages.Admin
{
    public partial class UserManagement : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            BindData();
        }

        // Loads dashboard statistic and filtered user list into page controls
        private void BindData()
        {
            using (var db = new WokFlowContext())
            {
                // Base query excludes ADMIN from the management list
                var query = db.Users.Where(u => u.Role != "ADMIN").AsQueryable();

                // Apply search filter (matches username)
                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                    query = query.Where(u => u.Username.Contains(search));

                // Apply role filter
                string role = ddlRole.SelectedValue;
                if (!string.IsNullOrEmpty(role))
                    query = query.Where(u => u.Role == role);

                // Apply status filter
                string status = ddlStatus.SelectedValue;
                if (!string.IsNullOrEmpty(status))
                    query = query.Where(u => u.Status == status);

                var users = query.OrderBy(u => u.Username).ToList();

                // Dashboard statistic (global, unaffected by filters)
                var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);
                dashStats.Items = new List<StatItemData>
                {
                    new StatItemData { Icon = "users", Label = "Total Users", Value = db.Users.Count(u => u.Role != "ADMIN").ToString() },
                    new StatItemData { Icon = "user-plus", Label = "New Users", Value = db.Users.Count(u => u.JoinedDate >= thirtyDaysAgo).ToString() },
                    new StatItemData { Icon = "user-x", Label = "Banned", Value = db.Users.Count(u => u.Status == "Banned").ToString() }
                };

                rptUsers.DataSource = users;
                rptUsers.DataBind();
            }
        }

        // Handles Ban and Recover actions on a user account.
        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int userId)) return;
            using (var db = new WokFlowContext())
            {
                var user = db.Users.Find(userId);
                if (user == null) return;

                user.Status = e.CommandName == "Ban" ? "Banned" : "Active";
                user.UpdatedAt = DateTime.UtcNow;
                db.SaveChanges();
            }
            BindData();
        }

        // Re-binds data when any filter dropdown or search box changes.
        protected void Filter_Changed(object sender, EventArgs e) => BindData();
    }
}