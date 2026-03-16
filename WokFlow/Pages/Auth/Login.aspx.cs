using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Models;

namespace WokFlow.Pages.Auth
{
    public partial class Login : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Clear cache
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));

            if (!IsPostBack && Request.QueryString["pending"] == "1")
            {
                ShowError("Your account has been created. Please wait for an admin to approve your sharer registration before logging in.");
            }
        }

        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // Basic validation (Email / Password)
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowError("Please enter both email and password");
                return;
            }

            // Authenticate user
            using (var db = new WokFlowContext())
            {
                // Find user by email
                var user = db.Users.FirstOrDefault(u =>
                    u.Email.ToLower() == email.ToLower());

                // Verify password
                if (user == null || !BCrypt.Net.BCrypt.Verify(password, user.PasswordHash))
                {
                    ShowError("Invalid email or password");
                    return;
                }

                // Check if user is banned
                if (user.Status == "Banned")
                {
                    ShowError("This account has been banned");
                    return;
                }

                // Block sharers with pending registration
                if (user.Role == "GUEST")
                {
                    ShowError("Your sharer registration is still pending approval. Please wait for an admin to review your application.");
                    return;
                }

                // Set session variables
                Session["UserId"] = user.UserId;
                Session["UserName"] = user.Username;
                Session["UserRole"] = user.Role;

                // Redirect based on role
                switch (user.Role)
                {
                    case "ADMIN":
                        Response.Redirect("~/Pages/Admin/UserManagement.aspx");
                        break;
                    default:
                        Response.Redirect("~/Pages/Learner/Dashboard.aspx");
                        break;
                }
            }
        }

        // Display error messages
        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblError.Text = message;
        }
    }
}