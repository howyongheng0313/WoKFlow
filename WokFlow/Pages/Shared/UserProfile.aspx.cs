using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Models;

namespace WokFlow.Pages.Shared
{
    public partial class UserProfile : AuthenticatedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProfile();
                pnlUpgrade.Visible = CurrentUserRole == "LEARNER";
            }
        }

        private void LoadProfile()
        {
            litAvatar.Text = CurrentUserName.Length > 0 ? CurrentUserName[0].ToString().ToUpper() : "U";
            litUserName.Text = CurrentUserName;
            litUserRole.Text = CurrentUserRole;

            using (var db = new WokFlowContext())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user == null) return;

                txtName.Text = user.Username;
                txtEmail.Text = user.Email;

                if (user.BirthDate.HasValue)
                {
                    calBirthDate.SelectedDate = user.BirthDate.Value.ToString("yyyy-MM-dd");
                }
                countrySelector.SelectedCountry = user.Country ?? "";

                // Check existing upgrade request
                if (CurrentUserRole == "LEARNER")
                {
                    var request = db.SharerRequests
                        .Where(r => r.UserId == CurrentUserId)
                        .OrderByDescending(r => r.RequestDate)
                        .FirstOrDefault();

                    if (request != null)
                    {
                        lblUpgradeStatus.Text = "Upgrade request status: " + request.Status;
                        lblUpgradeStatus.CssClass = request.Status == "Accepted"
                            ? "block mt-4 text-sm text-green-600 font-bold"
                            : request.Status == "Rejected"
                                ? "block mt-4 text-sm text-red-600 font-bold"
                                : "block mt-4 text-sm text-orange-600 font-bold";

                        if (request.Status == "Pending")
                        {
                            btnUpgrade.Enabled = false;
                            btnUpgrade.Text = "Request Pending";
                            btnUpgrade.CssClass = "px-8 py-3 bg-gray-300 text-gray-500 rounded-full font-bold cursor-default border-0";
                        }
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (var db = new WokFlowContext())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user == null) return;

                user.Username = txtName.Text.Trim();
                user.Country = countrySelector.SelectedCountry;
                DateTime parsedBirthDate;

                if (DateTime.TryParse(calBirthDate.SelectedDate, out parsedBirthDate))
                {
                    user.BirthDate = parsedBirthDate;
                } 
                else
                {
                    user.BirthDate = null;
                }   
                user.UpdatedAt = DateTime.UtcNow;
                db.SaveChanges();

                Session["UserName"] = user.Username;
            }
        }

        protected void btnUpgrade_Click(object sender, EventArgs e)
        {
            using (var db = new WokFlowContext())
            {
                var request = new SharerRequest
                {
                    UserId = CurrentUserId,
                    RequestDate = DateTime.UtcNow,
                    Status = "Pending",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                db.SharerRequests.Add(request);
                db.SaveChanges();
            }

            LoadProfile();
        }
    }
}