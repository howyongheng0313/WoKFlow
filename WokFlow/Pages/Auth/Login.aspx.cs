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

        }

        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowError("Please enter both email and password");
                return;
            }

            using (var db = new WokFlowContext())
            {
                var user = db.Users.FirstOrDefault(u =>
                    u.Email.ToLower() == email.ToLower() &&
                    u.PasswordHash == password);

                if (user == null)
                {
                    ShowError("Invalid email or password");
                    return;
                }

                if (user.Status == "Banned")
                {
                    ShowError("This account has been banned");
                    return;
                }

                // Set session
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

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblError.Text = message;
        }
    }
}