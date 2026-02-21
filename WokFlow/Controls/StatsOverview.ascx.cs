using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WokFlow.Controls
{
    public class StatItemData
    {
        public string Icon { get; set; } 
        public string Label { get; set; } 
        public string Value { get; set; } 
        public string SubValue { get; set; }
    }

    public partial class StatsOverview : System.Web.UI.UserControl
    {
        public int Columns { get; set; } = 4;
        public List<StatItemData> Items { get; set; } = new List<StatItemData>();

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