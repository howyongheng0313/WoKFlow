using System;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Helpers;
using WokFlow.Models;

namespace WokFlow.Pages.Auth
{
    public partial class Register : BasePage
    {
        [Serializable]
        private sealed class PendingRegistration
        {
            public string FullName { get; set; }
            public string Email { get; set; }
            public string PasswordHash { get; set; }
            public string Role { get; set; }
            public string Country { get; set; }
            public DateTime? BirthDate { get; set; }
            public string ProofDocumentPath { get; set; }
            public string VerificationCode { get; set; }
            public DateTime ExpiresAtUtc { get; set; }
        }

        public sealed class VerificationResult
        {
            public bool Success { get; set; }
            public string Message { get; set; }
            public string RedirectUrl { get; set; }
        }

        private string SelectedRole
        {
            get { return ViewState["SelectedRole"] as string ?? "LEARNER"; }
            set { ViewState["SelectedRole"] = value; }
        }

        private bool IsResetMode
        {
            get { return string.Equals(Request.QueryString["mode"], "reset", StringComparison.OrdinalIgnoreCase); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsResetMode)
            {
                InitializeResetMode();
                return;
            }

            if (!IsPostBack)
            {
                SelectedRole = "LEARNER";
                UpdateRoleUI();
            }
        }

        protected void btnLearner_Click(object sender, EventArgs e)
        {
            SelectedRole = "LEARNER";
            UpdateRoleUI();
        }

        protected void btnSharer_Click(object sender, EventArgs e)
        {
            SelectedRole = "SHARER";
            UpdateRoleUI();
        }

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

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (IsResetMode)
            {
                HandlePasswordResetUpdate();
                return;
            }

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowError("Please fill in all required fields");
                return;
            }

            if (password != confirmPassword)
            {
                ShowError("Passwords do not match");
                return;
            }

            using (var db = new WokFlowContext())
            {
                if (db.Users.Any(u => u.Email.ToLower() == email.ToLower()))
                {
                    ShowError("An account with this email already exists");
                    return;
                }
            }

            string assignedRole = SelectedRole == "SHARER" ? "GUEST" : SelectedRole;

            DateTime parsedBirthDate;
            DateTime? birthDate = DateTime.TryParse(calBirthDate.SelectedDate, out parsedBirthDate)
                ? parsedBirthDate
                : (DateTime?)null;

            string proofPath = null;
            if (SelectedRole == "SHARER" && fuProofDocument.HasFile)
            {
                string uploadsDir = Server.MapPath("~/Uploads/ProofDocuments");
                if (!Directory.Exists(uploadsDir))
                {
                    Directory.CreateDirectory(uploadsDir);
                }

                string ext = Path.GetExtension(fuProofDocument.FileName);
                string fileName = "proof_" + Guid.NewGuid().ToString("N") + ext;
                string savePath = Path.Combine(uploadsDir, fileName);
                fuProofDocument.SaveAs(savePath);
                proofPath = "/Uploads/ProofDocuments/" + fileName;
            }

            string code = GenerateVerificationCode();
            Session["PendingRegistration"] = new PendingRegistration
            {
                FullName = fullName,
                Email = email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
                Role = assignedRole,
                Country = countrySelector.SelectedCountry,
                BirthDate = birthDate,
                ProofDocumentPath = proofPath,
                VerificationCode = code,
                ExpiresAtUtc = DateTime.UtcNow.AddMinutes(10)
            };

            try
            {
                EmailHelper.SendVerificationEmail(email, fullName, code);
            }
            catch (InvalidOperationException ex)
            {
                ShowError(ex.Message);
                return;
            }
            catch (SmtpException ex)
            {
                ShowError("SMTP failed (" + ex.StatusCode + "): " + ex.Message);
                return;
            }
            catch
            {
                ShowError("Failed to send verification email. Please check SMTP settings and try again.");
                return;
            }

            ScriptManager.RegisterStartupScript(
                this,
                GetType(),
                "openVerificationOverlay",
                "openVerificationOverlay(" + SerializeJsString(email) + ");",
                true
            );
        }

        private void InitializeResetMode()
        {
            string resetEmail = Session["PasswordResetVerifiedEmail"] as string;
            if (string.IsNullOrWhiteSpace(resetEmail))
            {
                Response.Redirect("~/Pages/Auth/Login.aspx");
                return;
            }

            using (var db = new WokFlowContext())
            {
                var user = db.Users.FirstOrDefault(u => u.Email.ToLower() == resetEmail.ToLower());
                if (user == null)
                {
                    Session.Remove("PasswordResetVerifiedEmail");
                    Response.Redirect("~/Pages/Auth/Login.aspx");
                    return;
                }

                litPageTitle.Text = "Change a New Password";
                btnRegister.Text = "Update";
                pnlRoleToggle.Visible = false;
                pnlResetRole.Visible = true;
                litResetRole.Text = user.Role;

                txtFullName.Text = user.Username;
                txtEmail.Text = user.Email;
                txtFullName.ReadOnly = true;
                txtEmail.ReadOnly = true;
                txtFullName.CssClass += " bg-gray-100 border-gray-200 text-gray-600 cursor-not-allowed";
                txtEmail.CssClass += " bg-gray-100 border-gray-200 text-gray-600 cursor-not-allowed";

                pnlBirthEdit.Visible = false;
                txtBirthDateLocked.Visible = true;
                txtBirthDateLocked.Text = user.BirthDate.HasValue ? user.BirthDate.Value.ToString("yyyy-MM-dd") : "-";

                pnlCountryEdit.Visible = false;
                txtCountryLocked.Visible = true;
                txtCountryLocked.Text = string.IsNullOrWhiteSpace(user.Country) ? "-" : user.Country;

                pnlSharerUpload.Visible = false;
                btnLearner.Enabled = false;
                btnSharer.Enabled = false;
            }
        }

        private void HandlePasswordResetUpdate()
        {
            string resetEmail = Session["PasswordResetVerifiedEmail"] as string;
            if (string.IsNullOrWhiteSpace(resetEmail))
            {
                ShowError("Reset session expired. Please request forgot password again.");
                return;
            }

            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;
            if (string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(confirmPassword))
            {
                ShowError("Please fill in password and confirm password.");
                return;
            }
            if (password != confirmPassword)
            {
                ShowError("Passwords do not match");
                return;
            }

            using (var db = new WokFlowContext())
            {
                var user = db.Users.FirstOrDefault(u => u.Email.ToLower() == resetEmail.ToLower());
                if (user == null)
                {
                    ShowError("User not found for password reset.");
                    return;
                }

                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(password);
                user.UpdatedAt = DateTime.UtcNow;
                db.SaveChanges();

                Session.Remove("PasswordResetVerifiedEmail");
                Session["UserId"] = user.UserId;
                Session["UserName"] = user.Username;
                Session["UserRole"] = user.Role;

                Response.Redirect("~/Pages/Learner/Dashboard.aspx");
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static VerificationResult VerifyEmailCode(string code)
        {
            var ctx = HttpContext.Current;
            if (ctx == null || ctx.Session == null)
            {
                return new VerificationResult { Success = false, Message = "Session expired. Please register again." };
            }

            var pending = ctx.Session["PendingRegistration"] as PendingRegistration;
            if (pending == null)
            {
                return new VerificationResult { Success = false, Message = "No pending registration found. Please register again." };
            }

            string normalized = (code ?? string.Empty).Trim();
            if (!Regex.IsMatch(normalized, @"^\d{6}$"))
            {
                return new VerificationResult { Success = false, Message = "Please enter a valid 6-digit verification code." };
            }

            if (DateTime.UtcNow > pending.ExpiresAtUtc)
            {
                ctx.Session.Remove("PendingRegistration");
                return new VerificationResult { Success = false, Message = "Verification code has expired. Please register again." };
            }

            if (!string.Equals(normalized, pending.VerificationCode, StringComparison.Ordinal))
            {
                return new VerificationResult { Success = false, Message = "Invalid verification code." };
            }

            using (var db = new WokFlowContext())
            {
                if (db.Users.Any(u => u.Email.ToLower() == pending.Email.ToLower()))
                {
                    ctx.Session.Remove("PendingRegistration");
                    return new VerificationResult { Success = false, Message = "This email is already registered. Please login." };
                }

                var user = new User
                {
                    Username = pending.FullName,
                    Email = pending.Email,
                    PasswordHash = pending.PasswordHash,
                    Role = pending.Role,
                    Status = "Active",
                    Country = pending.Country,
                    BirthDate = pending.BirthDate,
                    JoinedDate = DateTime.UtcNow,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                db.Users.Add(user);
                db.SaveChanges();

                if (pending.Role == "GUEST" && !string.IsNullOrWhiteSpace(pending.ProofDocumentPath))
                {
                    db.SharerRegistrations.Add(new SharerRegistration
                    {
                        UserId = user.UserId,
                        RequestDate = DateTime.UtcNow,
                        ProofDocument = pending.ProofDocumentPath,
                        Status = "Pending",
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    });
                    db.SaveChanges();
                }

                ctx.Session.Remove("PendingRegistration");

                if (user.Role == "GUEST")
                {
                    return new VerificationResult
                    {
                        Success = true,
                        RedirectUrl = VirtualPathUtility.ToAbsolute("~/Pages/Auth/Login.aspx?pending=1")
                    };
                }

                ctx.Session["UserId"] = user.UserId;
                ctx.Session["UserName"] = user.Username;
                ctx.Session["UserRole"] = user.Role;

                return new VerificationResult
                {
                    Success = true,
                    RedirectUrl = VirtualPathUtility.ToAbsolute("~/Pages/Learner/Dashboard.aspx")
                };
            }
        }

        private static string GenerateVerificationCode()
        {
            return new Random().Next(100000, 999999).ToString();
        }

        private static string SerializeJsString(string value)
        {
            return "'" + HttpUtility.JavaScriptStringEncode(value ?? string.Empty) + "'";
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblError.Text = message;
        }
    }
}
