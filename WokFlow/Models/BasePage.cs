using System;
using System.Web.UI;

namespace WokFlow.Models
{
    // Base page with shared utilities for all pages.
    public class BasePage : Page
    {
        protected int CurrentUserId
        {
            get { return Session["UserId"] != null ? (int)Session["UserId"] : 0; }
        }

        protected string CurrentUserName
        {
            get { return Session["UserName"] as string ?? ""; }
        }

        protected string CurrentUserRole
        {
            get { return Session["UserRole"] as string ?? ""; }
        }

        protected bool IsLoggedIn
        {
            get { return Session["UserId"] != null; }
        }
    }

    // Base page for authenticated pages. Redirects to Login if not logged in.
    public class AuthenticatedPage : BasePage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (!IsLoggedIn)
            {
                Response.Redirect("~/Pages/Login.aspx");
            }
        }
    }

    // Base page for learner/sharer pages. Redirects admins to their dashboard.
    public class LearnerPage : AuthenticatedPage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (CurrentUserRole == "ADMIN")
            {
                Response.Redirect("~/Pages/Admin/UserManagement.aspx");
            }
        }
    }

    // Base page for admin-only pages. Redirects if not ADMIN role.
    public class AdminPage : AuthenticatedPage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (CurrentUserRole != "ADMIN")
            {
                Response.Redirect("~/Pages/Learner/Dashboard.aspx");
            }
        }
    }

    // Base page for sharer-only pages. Redirects if not SHARER role.
    public class SharerPage : AuthenticatedPage
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (CurrentUserRole != "SHARER")
            {
                Response.Redirect("~/Pages/Learner/Dashboard.aspx");
            }
        }
    }
}
