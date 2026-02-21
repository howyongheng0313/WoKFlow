using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WokFlow
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadNavbar();
        }

        private void LoadNavbar()
        {
            string role = Session["UserRole"] as string;
            string currentPage = System.IO.Path.GetFileNameWithoutExtension(Page.AppRelativeVirtualPath) ?? "";

            if (string.IsNullOrEmpty(role) || role == "GUEST")
            {
                // Landing Navbar
                NavbarPlaceholder.Controls.Add(LoadControl("~/Controls/LandingNavbar.ascx"));
            }
            else if (role == "ADMIN")
            {
                // Admin Navbar
                var adminNav = (Controls.AdminNavbar)LoadControl("~/Controls/AdminNavbar.ascx");
                adminNav.CurrentPage = currentPage;
                NavbarPlaceholder.Controls.Add(adminNav);
            }
            else
            {
                // Authenticated Navbar (Learner/Sharer)
                var authNav = (Controls.AuthenticatedNavbar)LoadControl("~/Controls/AuthenticatedNavbar.ascx");
                authNav.UserRole = role;
                authNav.CurrentPage = currentPage;
                NavbarPlaceholder.Controls.Add(authNav);
            }
        }
    }
}