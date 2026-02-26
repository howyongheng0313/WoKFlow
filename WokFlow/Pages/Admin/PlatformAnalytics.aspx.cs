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
            if (!IsPostBack) PopulateYearFilters();
            BindData();
        }

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
                    {
                        ddl.Items.Add(new System.Web.UI.WebControls.ListItem(y.ToString(), y.ToString()));
                    }
                       
                }
            }
        }

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
                if (!string.IsNullOrEmpty(regYearVal))
                {
                    int regYear = int.Parse(regYearVal);
                    regUsersQuery = regUsersQuery.Where(u => u.JoinedDate.Year == regYear);
                }
                var regUsers = regUsersQuery.ToList();
                var regData = Enumerable.Range(1, 12)
                    .Select(m => regUsers.Count(u => u.JoinedDate.Month == m))
                    .ToList();

                // Cuisine Categories – count active courses per cuisine
                string cuisineYearVal = ddlCuisineYear.SelectedValue;
                var cuisines = db.Cuisines.ToList();
                var cuisineLabels = new List<string>();
                var cuisineValues = new List<int>();
                foreach (var c in cuisines)
                {
                    cuisineLabels.Add(c.CuisineName.ToUpper());
                    var courseQuery = db.Courses.Where(co =>
                        co.CuisineId == c.CuisineId && co.Status == "Active");
                    if (!string.IsNullOrEmpty(cuisineYearVal))
                    {
                        int cuisineYear = int.Parse(cuisineYearVal);
                        courseQuery = courseQuery.Where(co => co.CreatedDate.Year == cuisineYear);
                    }
                    cuisineValues.Add(courseQuery.Count());
                }

                // User Role Breakdown – actual user counts
                string rolesYearVal = ddlRolesYear.SelectedValue;
                string rolesMonth = ddlRolesMonth.SelectedValue;
                var rolesQuery = db.Users.AsQueryable();
                if (!string.IsNullOrEmpty(rolesYearVal))
                {
                    int rolesYear = int.Parse(rolesYearVal);
                    rolesQuery = rolesQuery.Where(u => u.JoinedDate.Year == rolesYear);
                }
                if (rolesMonth != "All")
                {
                    int monthNum = DateTime.ParseExact(rolesMonth, "MMMM",
                        System.Globalization.CultureInfo.InvariantCulture).Month;
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

        protected void Filter_Changed(object sender, EventArgs e)
        {
            BindData();
        }
    }
}