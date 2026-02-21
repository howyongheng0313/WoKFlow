using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WokFlow.Controls
{
    public partial class Calendar : System.Web.UI.UserControl
    {
        public string SelectedDate
        {
            get { return hdnSelectedDate.Value; }
            set { hdnSelectedDate.Value = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}