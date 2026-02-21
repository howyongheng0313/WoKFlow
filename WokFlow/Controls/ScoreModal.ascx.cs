using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WokFlow.Controls
{
    public class ScoreEntry
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Date { get; set; }
        public int Score { get; set; }
        public string Status { get; set; }
    }

    public partial class ScoreModal : System.Web.UI.UserControl
    {
        public string Title
        {
            get { return litModalTitle.Text; }
            set { litModalTitle.Text = value; }
        }

        public List<ScoreEntry> Scores { get; set; } = new List<ScoreEntry>();

        protected string GetScoreWidth(object score) => $"style=\"width:{score}%\"";

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Scores != null && Scores.Count > 0)
            {
                rptScores.DataSource = Scores;
                rptScores.DataBind();
                litPagination.Text = string.Format("1 - {0} of {0} items", Scores.Count);
            }
        }
    }
}