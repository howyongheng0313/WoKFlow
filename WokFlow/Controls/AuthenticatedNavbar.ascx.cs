using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WokFlow.Controls
{
    public partial class AuthenticatedNavbar : System.Web.UI.UserControl
    {
        public string UserRole { get; set; }
        public string CurrentPage { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}