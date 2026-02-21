using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WokFlow.Controls
{
    public partial class CountrySelector : System.Web.UI.UserControl
    {
        public string SelectedCountry
        {
            get { return hdnSelectedCountry.Value; }
            set { hdnSelectedCountry.Value = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
    }
}