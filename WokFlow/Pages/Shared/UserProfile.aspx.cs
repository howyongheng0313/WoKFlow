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
        private bool IsEditMode
        {
            get { return ViewState["IsEditMode"] as bool? ?? false; }
            set { ViewState["IsEditMode"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProfile();
                SetViewMode();
            }
        }

        private void LoadProfile()
        {
            litAvatar.Text = CurrentUserName.Length > 0 ? CurrentUserName[0].ToString().ToUpper() : "U";
            litUserName.Text = CurrentUserName;
            SetRoleBadge();

            using (var db = new WokFlowContext())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user == null) return;

                // View mode values
                litNameValue.Text = Server.HtmlEncode(user.Username);
                litEmailValue.Text = Server.HtmlEncode(user.Email);
                litBirthDateValue.Text = user.BirthDate.HasValue
                    ? user.BirthDate.Value.ToString("yyyy-MM-dd")
                    : "";
                litCountryValue.Text = Server.HtmlEncode(user.Country ?? "");

                // Edit mode values
                txtName.Text = user.Username;
                if (user.BirthDate.HasValue)
                    calBirthDate.SelectedDate = user.BirthDate.Value.ToString("yyyy-MM-dd");
                countrySelector.SelectedCountry = user.Country ?? "";

                // Upgrade section (Learner only)
                if (CurrentUserRole == "LEARNER")
                {
                    pnlUpgrade.Visible = true;
                    LoadUpgradeRequirements(db);
                }
            }
        }

        private void SetRoleBadge()
        {
            string badgeColor;
            string displayRole = CurrentUserRole;

            switch (CurrentUserRole)
            {
                case "LEARNER":
                    badgeColor = "bg-teal-50 text-teal-600 border-teal-200";
                    break;
                case "SHARER":
                    badgeColor = "bg-orange-50 text-orange-600 border-orange-200";
                    break;
                case "ADMIN":
                    displayRole = "ADMINISTRATOR";
                    badgeColor = "bg-orange-50 text-orange-600 border-orange-200";
                    break;
                default:
                    badgeColor = "bg-gray-50 text-gray-600 border-gray-200";
                    break;
            }

            litRoleBadge.Text = string.Format(
                "<span class=\"inline-block px-3 py-1 text-xs font-bold rounded-full border {0} mt-1\">{1}</span>",
                badgeColor, displayRole);
        }

        private void SetViewMode()
        {
            bool editing = IsEditMode;

            // Toggle view/edit panels
            pnlNameView.Visible = !editing;
            pnlNameEdit.Visible = editing;
            pnlBirthDateView.Visible = !editing;
            pnlBirthDateEdit.Visible = editing;
            pnlCountryView.Visible = !editing;
            pnlCountryEdit.Visible = editing;
            pnlSaveBtn.Visible = editing;

            // Edit button styling
            string cancelCss = "px-6 py-2 rounded-full font-bold cursor-pointer border border-gray-200 text-gray-600 text-sm transition-all hover:bg-gray-50 bg-white";
            string primaryCss = "px-6 py-2 rounded-full font-bold cursor-pointer border-0 text-sm transition-all bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white shadow-lg shadow-orange-500/20";
            string subtleCss = "px-6 py-2 rounded-full font-bold cursor-pointer border border-gray-300 text-gray-700 text-sm transition-all hover:bg-gray-50 bg-white";

            btnEdit.Text = editing ? "Cancel" : (CurrentUserRole == "LEARNER" ? "Edit" : "Edit Profile");
            if (editing)
                btnEdit.CssClass = cancelCss;
            else
                btnEdit.CssClass = CurrentUserRole == "SHARER" ? subtleCss : primaryCss;

            // Hide edit button when in edit mode, show save button instead
            btnEdit.Visible = !editing;
            btnSave.Visible = editing;
        }

        private void LoadUpgradeRequirements(WokFlowContext db)
        {
            // Requirement 1: Complete at least 3 courses
            int completedCourses = db.Enrollments
                .Count(en => en.UserId == CurrentUserId && en.Status == "Completed");
            bool req1Met = completedCourses >= 3;

            // Requirement 2: Maintain 80%+ quiz average
            var quizScores = db.QuizResults
                .Where(q => q.UserId == CurrentUserId)
                .Select(q => q.Score)
                .ToList();
            bool req2Met = quizScores.Count > 0 && quizScores.Average() >= 80;

            litReq1Icon.Text = req1Met ? GetCheckedIcon() : GetUncheckedIcon();
            litReq2Icon.Text = req2Met ? GetCheckedIcon() : GetUncheckedIcon();

            // Lock button if requirements not met, unlock if all met
            bool allRequirementsMet = req1Met && req2Met;
            if (!allRequirementsMet)
            {
                btnUpgrade.Enabled = false;
                btnUpgrade.Text = "Upgrade to Sharer";
                btnUpgrade.CssClass = "px-8 py-3 bg-gray-300 text-gray-500 rounded-full font-bold cursor-default border-0";
            }
        }

        private string GetCheckedIcon()
        {
            return "<div class=\"w-6 h-6 rounded-full bg-[#FF8C66] flex items-center justify-center flex-shrink-0\">"
                 + "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"14\" height=\"14\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"white\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polyline points=\"20 6 9 17 4 12\"/></svg>"
                 + "</div>";
        }

        private string GetUncheckedIcon()
        {
            return "<div class=\"w-6 h-6 rounded-full border-2 border-gray-300 flex-shrink-0\"></div>";
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            IsEditMode = !IsEditMode;
            if (IsEditMode)
            {
                // Populate edit fields with current values
                using (var db = new WokFlowContext())
                {
                    var user = db.Users.Find(CurrentUserId);
                    if (user != null)
                    {
                        txtName.Text = user.Username;
                        if (user.BirthDate.HasValue)
                            calBirthDate.SelectedDate = user.BirthDate.Value.ToString("yyyy-MM-dd");
                        countrySelector.SelectedCountry = user.Country ?? "";
                    }
                }
            }
            SetViewMode();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            IsEditMode = false;
            SetViewMode();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string newName = txtName.Text.Trim();
            if (string.IsNullOrWhiteSpace(newName)) return;

            using (var db = new WokFlowContext())
            {
                var user = db.Users.Find(CurrentUserId);
                if (user == null) return;

                user.Username = newName;
                user.Country = countrySelector.SelectedCountry;
                DateTime parsedBirthDate;
                if (DateTime.TryParse(calBirthDate.SelectedDate, out parsedBirthDate))
                    user.BirthDate = parsedBirthDate;
                else
                    user.BirthDate = null;
                user.UpdatedAt = DateTime.UtcNow;
                db.SaveChanges();

                Session["UserName"] = user.Username;
            }

            IsEditMode = false;
            LoadProfile();
            SetViewMode();
        }

        protected void btnUpgrade_Click(object sender, EventArgs e)
        {
            using (var db = new WokFlowContext())
            {
                // Verify requirements are still met before upgrading
                int completedCourses = db.Enrollments
                    .Count(en => en.UserId == CurrentUserId && en.Status == "Completed");
                var quizScores = db.QuizResults
                    .Where(q => q.UserId == CurrentUserId)
                    .Select(q => q.Score)
                    .ToList();
                bool allMet = completedCourses >= 3 && quizScores.Count > 0 && quizScores.Average() >= 80;

                if (!allMet) return;

                // Upgrade role to SHARER
                var user = db.Users.Find(CurrentUserId);
                if (user == null) return;
                user.Role = "SHARER";
                user.UpdatedAt = DateTime.UtcNow;
                db.SaveChanges();
            }

            // Logout and redirect to default page
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Default.aspx");
        }
    }
}