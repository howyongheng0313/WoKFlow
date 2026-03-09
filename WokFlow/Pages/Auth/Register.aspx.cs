using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Models;

namespace WokFlow.Pages.Auth
{
    public partial class Register : BasePage
    {
        // Store selected role in ViewState to persist across postbacks
        private string SelectedRole
        {
            get { return ViewState["SelectedRole"] as string ?? "LEARNER"; }
            set { ViewState["SelectedRole"] = value; }
        }

        // Initialize page with default role as LEARNER
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SelectedRole = "LEARNER";
                UpdateRoleUI();
            }
        }

        // Set role to LEARNER and update UI
        protected void btnLearner_Click(object sender, EventArgs e)
        {
            SelectedRole = "LEARNER";
            UpdateRoleUI();
        }

        // Set role to SHARER and update UI
        protected void btnSharer_Click(object sender, EventArgs e)
        {
            SelectedRole = "SHARER";
            UpdateRoleUI();
        }

        // Update the UI to reflect the selected role
        private void UpdateRoleUI()
        {
            bool isLearner = SelectedRole == "LEARNER";

            btnLearner.Text = "Learner";
            btnSharer.Text = "Sharer";
            btnLearner.CssClass = "flex-1 py-3 rounded-full text-sm font-medium transition-all relative z-10 text-center no-underline " + (isLearner ? "text-white" : "text-[#1A1A1A]");
            btnSharer.CssClass = "flex-1 py-3 rounded-full text-sm font-medium transition-all relative z-10 text-center no-underline " + (!isLearner ? "text-white" : "text-[#1A1A1A]");
            roleSlider.Attributes["class"] = "absolute top-1.5 bottom-1.5 w-[calc(50%_-_6px)] bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] rounded-full transition-all duration-300 ease-in-out shadow-md " + (isLearner ? "left-1.5" : "left-[calc(50%_+_3px)]");
            pnlSharerUpload.Visible = !isLearner;
        }

        // Registration logic
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            // Basic validation (Full Name / Email / Password)
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowError("Please fill in all required fields");
                return;
            }

            // Validate email format
            if (password != confirmPassword)
            {
                ShowError("Passwords do not match");
                return;
            }

            // Check if email already exists
            using (var db = new WokFlowContext())
            {
                // Check if email already exists (case-insensitive)
                if (db.Users.Any(u => u.Email.ToLower() == email.ToLower()))
                {
                    ShowError("An account with this email already exists");
                    return;
                }

                string assignedRole = SelectedRole == "SHARER" ? "GUEST" : SelectedRole;

                // Create new user
                var user = new User
                {
                    Username = fullName,
                    Email = email,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
                    Role = assignedRole,
                    Status = "Active",
                    Country = countrySelector.SelectedCountry,
                    JoinedDate = DateTime.UtcNow,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                // Parse and set birth date if provided
                DateTime parsedBirthDate;
                if (DateTime.TryParse(calBirthDate.SelectedDate, out parsedBirthDate))
                    user.BirthDate = parsedBirthDate;

                db.Users.Add(user);
                db.SaveChanges();

                // Handle proof document upload for SHARER role
                if (SelectedRole == "SHARER" && fuProofDocument.HasFile)
                {
                    // Save proof document to Uploads folder
                    string uploadsDir = Server.MapPath("~/Uploads/ProofDocuments");

                    // Ensure the directory exists
                    if (!Directory.Exists(uploadsDir))
                        Directory.CreateDirectory(uploadsDir);

                    string fileName = fuProofDocument.FileName;
                    string savePath = Path.Combine(uploadsDir, fileName);
                    fuProofDocument.SaveAs(savePath);

                    // Create sharer registration record
                    var registration = new SharerRegistration
                    {
                        UserId = user.UserId,
                        RequestDate = DateTime.UtcNow,
                        ProofDocument = "/Uploads/ProofDocuments/" + fileName,
                        Status = "Pending",
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };
                    db.SharerRegistrations.Add(registration);
                    db.SaveChanges();
                }

                // Set session and redirect based on role
                Session["UserId"] = user.UserId;
                Session["UserName"] = user.Username;
                Session["UserRole"] = user.Role;

                // Redirect to appropriate dashboard based on role
                if (user.Role == "GUEST")
                    Response.Redirect("~/Pages/Default.aspx");
                else
                    Response.Redirect("~/Pages/Learner/Dashboard.aspx");
            }
        }

        // Display error message
        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblError.Text = message;
        }
    }
}