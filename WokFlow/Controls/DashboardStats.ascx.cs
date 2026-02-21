using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WokFlow.Controls
{
    public partial class DashboardStats : System.Web.UI.UserControl
    {
        public string CssClass { get; set; } = "";

        public List<StatItemData> Items { get; set; } = new List<StatItemData>();

        public string GridColsClass
        {
            get
            {
                if (Items == null) return "md:grid-cols-3";
                switch (Items.Count)
                {
                    case 1: return "md:grid-cols-1";
                    case 2: return "md:grid-cols-2";
                    case 3: return "md:grid-cols-3";
                    case 4: return "md:grid-cols-4";
                    default: return "md:grid-cols-3";
                }
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Items != null && Items.Count > 0)
            {
                rptStats.DataSource = Items;
                rptStats.DataBind();
            }
        }
    }
}