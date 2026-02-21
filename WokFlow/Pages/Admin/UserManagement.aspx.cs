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
    public partial class UserManagement : System.Web.UI.Page
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
                var query = db.Users.Where(u => u.Role != "ADMIN").AsQueryable();

                string search = txtSearch.Text.Trim();
                if (!string.IsNullOrEmpty(search))
                    query = query.Where(u => u.Username.Contains(search));

                string role = ddlRole.SelectedValue;
                if (!string.IsNullOrEmpty(role))
                    query = query.Where(u => u.Role == role);

                string status = ddlStatus.SelectedValue;
                if (!string.IsNullOrEmpty(status))
                    query = query.Where(u => u.Status == status);

                var users = query.OrderBy(u => u.Username).ToList();

                dashStats.Items = new List<StatItemData>
                {
                    new StatItemData { Icon = "users", Label = "Total Users", Value = db.Users.Count(u => u.Role != "ADMIN").ToString() },
                    new StatItemData { Icon = "user-plus", Label = "New Users", Value = db.Users.Count(u => u.JoinedDate >= DateTime.UtcNow.AddDays(-30)).ToString() },
                    new StatItemData { Icon = "clock", Label = "Pending Requests", Value = db.SharerRequests.Count(r => r.Status == "Pending").ToString() },
                    new StatItemData { Icon = "user-x", Label = "Banned", Value = db.Users.Count(u => u.Status == "Banned").ToString() }
                };

                rptUsers.DataSource = users;
                rptUsers.DataBind();
            }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int userId = int.Parse(e.CommandArgument.ToString());
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

        protected void Filter_Changed(object sender, EventArgs e) => BindData();

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlRole.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            BindData();
        }
    }
}