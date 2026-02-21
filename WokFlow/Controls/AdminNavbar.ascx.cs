using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WokFlow.Controls
{
    public partial class AdminNavbar : System.Web.UI.UserControl
    {
        public string CurrentPage { get; set; }

        public bool IsUserManagementActive
        {
            get
            {
                return (CurrentPage == "UserManagement" || CurrentPage == "SharerRequests" || CurrentPage == "SharerRegistration" );
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}