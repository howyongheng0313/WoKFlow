using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Controls;
using WokFlow.Models;

namespace WokFlow.Pages.Admin
{
    public partial class PlatformAnalytics : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateYearFilters();
            BindData();
        }

        // Populates year filter dropdowns with distinct years from user and course data.
        private void PopulateYearFilters()
        {
            using (var db = new WokFlowContext())
            {
                // Gather all relevant years from data
                var userYears = db.Users.Select(u => u.JoinedDate.Year);
                var courseYears = db.Courses.Select(c => c.CreatedDate.Year);
                var allYears = userYears.Concat(courseYears).Distinct().ToList();

                // Always include current year, then sort descending
                allYears.Add(DateTime.Now.Year);
                var years = allYears.Distinct().OrderByDescending(y => y).ToList();

                foreach (var ddl in new[] { ddlCuisineYear, ddlRegYear, ddlRolesYear })
                {
                    ddl.Items.Clear();
                    ddl.Items.Add(new System.Web.UI.WebControls.ListItem("All Years", ""));
                    foreach (var y in years)
                        ddl.Items.Add(new System.Web.UI.WebControls.ListItem(y.ToString(), y.ToString()));
                }
            }
        }

        // Builds all chart datasets and serializes them as JSON for the front-end Chart.js rendering.
        private void BindData()
        {
            using (var db = new WokFlowContext())
            {
                // Stats
                statsOverview.Items = new List<StatItemData>
                {
                    new StatItemData { Icon = "flame",   Label = "Platform Users",    Value = db.Users.Count().ToString() },
                    new StatItemData { Icon = "slice",   Label = "Active Courses",    Value = db.Courses.Count(c => c.Status == "Active").ToString() },
                    new StatItemData { Icon = "fish",    Label = "Total Enrollments", Value = db.Enrollments.Count().ToString() },
                    new StatItemData { Icon = "droplet", Label = "Active Sharers",    Value = db.Users.Count(u => u.Role == "SHARER" && u.Status == "Active").ToString() }
                };

                // Registration Trend – count new user registrations per month
                string regYearVal = ddlRegYear.SelectedValue;
                var regUsersQuery = db.Users.AsQueryable();

                if (!string.IsNullOrEmpty(regYearVal) && int.TryParse(regYearVal, out int regYear))
                    regUsersQuery = regUsersQuery.Where(u => u.JoinedDate.Year == regYear);

                var regGrouped = regUsersQuery
                    .GroupBy(u => u.JoinedDate.Month)
                    .Select(g => new { Month = g.Key, Count = g.Count() })
                    .ToDictionary(g => g.Month, g => g.Count);
                var regData = Enumerable.Range(1, 12)
                    .Select(m => regGrouped.ContainsKey(m) ? regGrouped[m] : 0)
                    .ToList();

                // Cuisine Categories – count active courses per cuisine
                string cuisineYearVal = ddlCuisineYear.SelectedValue;
                var courseQuery = db.Courses.Where(co => co.Status == "Active");

                if (!string.IsNullOrEmpty(cuisineYearVal) && int.TryParse(cuisineYearVal, out int cuisineYear))
                    courseQuery = courseQuery.Where(co => co.CreatedDate.Year == cuisineYear);

                var courseCounts = courseQuery
                    .GroupBy(co => co.CuisineId)
                    .Select(g => new { CuisineId = g.Key, Count = g.Count() })
                    .ToDictionary(g => g.CuisineId, g => g.Count);

                var cuisines = db.Cuisines.OrderBy(c => c.CuisineName).ToList();
                var cuisineLabels = cuisines.Select(c => c.CuisineName.ToUpper()).ToList();
                var cuisineValues = cuisines.Select(c => courseCounts.ContainsKey(c.CuisineId) ? courseCounts[c.CuisineId] : 0).ToList();

                // User Role Breakdown – actual user counts
                string rolesYearVal = ddlRolesYear.SelectedValue;
                string rolesMonth = ddlRolesMonth.SelectedValue;
                var rolesQuery = db.Users.AsQueryable();

                if (!string.IsNullOrEmpty(rolesYearVal) && int.TryParse(rolesYearVal, out int rolesYear))
                    rolesQuery = rolesQuery.Where(u => u.JoinedDate.Year == rolesYear);

                if (rolesMonth != "All" && DateTime.TryParseExact(rolesMonth, "MMMM",
                    System.Globalization.CultureInfo.InvariantCulture,
                    System.Globalization.DateTimeStyles.None, out DateTime parsedMonth))
                {
                    int monthNum = parsedMonth.Month;
                    rolesQuery = rolesQuery.Where(u => u.JoinedDate.Month == monthNum);
                }

                var rolesLabels = new List<string> { "Learner", "Sharer", "Admin" };
                var rolesValues = new List<int>
                {
                    rolesQuery.Count(u => u.Role == "LEARNER"),
                    rolesQuery.Count(u => u.Role == "SHARER"),
                    rolesQuery.Count(u => u.Role == "ADMIN")
                };
                var rolesColors = new List<string> { "#FF8C66", "#FFB399", "#FCD5CE" };

                // Serialize to JSON for Chart.js
                var js = new JavaScriptSerializer();
                string json = js.Serialize(new
                {
                    registration = regData,
                    cuisineLabels,
                    cuisineValues,
                    rolesLabels,
                    rolesValues,
                    rolesColors
                });

                litChartData.Text = "<script>window.__platformData = " + json + ";</script>";
            }
        }

        // Re-binds chart data when any filter dropdown changes.
        protected void Filter_Changed(object sender, EventArgs e)
        {
            BindData();
        }
    }
}