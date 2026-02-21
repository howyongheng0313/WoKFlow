<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PlatformAnalytics.aspx.cs" Inherits="WokFlow.Pages.Admin.PlatformAnalytics" %>
<%@ Register Src="~/Controls/StatsOverview.ascx" TagPrefix="uc" TagName="StatsOverview" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <main class="flex-1 w-full max-w-[1400px] mx-auto px-6 md:px-12 pb-20 mt-6">

        <!-- Top Stats Banner -->
        <uc:StatsOverview ID="statsOverview" runat="server" Columns="4" />

        <!-- Content Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 auto-rows-fr">

            <!-- Left Column - Spanning 2 Rows - Cuisine Bar Chart -->
            <div class="lg:row-span-2 glass-panel p-6 rounded-2xl flex flex-col h-full">
                <div class="flex justify-between items-start mb-6">
                    <h3 class="text-lg font-bold text-[#1A1A1A]">Cuisine Categories</h3>
                    <div class="relative w-[120px]">
                        <asp:DropDownList ID="ddlCuisineYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                            CssClass="w-full h-10 pl-3 pr-8 bg-white/60 backdrop-blur-md border border-white/60 rounded-lg appearance-none text-gray-700 font-medium hover:border-[#FF8C66] text-xs cursor-pointer transition-all shadow-sm">
                            <asp:ListItem Text="2026" Value="2026" />
                            <asp:ListItem Text="2025" Value="2025" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="flex-1 w-full min-h-0 relative" style="min-height:300px;">
                    <canvas id="cuisineChart"></canvas>
                </div>
            </div>

            <!-- Right Column Top - Registration Line Chart -->
            <div class="glass-panel p-6 rounded-2xl flex flex-col">
                <div class="flex justify-between items-start mb-6">
                    <h3 class="text-lg font-bold text-[#1A1A1A]">User Registration Trend</h3>
                    <div class="relative w-[120px]">
                        <asp:DropDownList ID="ddlRegYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                            CssClass="w-full h-10 pl-3 pr-8 bg-white/60 backdrop-blur-md border border-white/60 rounded-lg appearance-none text-gray-700 font-medium hover:border-[#FF8C66] text-xs cursor-pointer transition-all shadow-sm">
                            <asp:ListItem Text="2026" Value="2026" />
                            <asp:ListItem Text="2025" Value="2025" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="flex-1 w-full min-h-0" style="min-height:200px;">
                    <canvas id="registrationChart"></canvas>
                </div>
            </div>

            <!-- Right Column Bottom - Roles Donut Chart -->
            <div class="glass-panel p-6 rounded-2xl flex flex-col">
                <div class="flex justify-between items-start mb-6">
                    <h3 class="text-lg font-bold text-[#1A1A1A]">User Role Breakdown</h3>
                    <div class="flex gap-2">
                        <div class="relative w-[100px]">
                            <asp:DropDownList ID="ddlRolesYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                                CssClass="w-full h-10 pl-3 pr-8 bg-white/60 backdrop-blur-md border border-white/60 rounded-lg appearance-none text-gray-700 font-medium hover:border-[#FF8C66] text-xs cursor-pointer transition-all shadow-sm">
                                <asp:ListItem Text="2026" Value="2026" />
                                <asp:ListItem Text="2025" Value="2025" />
                            </asp:DropDownList>
                        </div>
                        <div class="relative w-[100px]">
                            <asp:DropDownList ID="ddlRolesMonth" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                                CssClass="w-full h-10 pl-3 pr-8 bg-white/60 backdrop-blur-md border border-white/60 rounded-lg appearance-none text-gray-700 font-medium hover:border-[#FF8C66] text-xs cursor-pointer transition-all shadow-sm">
                                <asp:ListItem Text="All Mo" Value="All" />
                                <asp:ListItem Text="Jan" Value="January" />
                                <asp:ListItem Text="Feb" Value="February" />
                                <asp:ListItem Text="Mar" Value="March" />
                                <asp:ListItem Text="Apr" Value="April" />
                                <asp:ListItem Text="May" Value="May" />
                                <asp:ListItem Text="Jun" Value="June" />
                                <asp:ListItem Text="Jul" Value="July" />
                                <asp:ListItem Text="Aug" Value="August" />
                                <asp:ListItem Text="Sep" Value="September" />
                                <asp:ListItem Text="Oct" Value="October" />
                                <asp:ListItem Text="Nov" Value="November" />
                                <asp:ListItem Text="Dec" Value="December" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                <div class="flex-1 w-full min-h-0 flex items-center justify-center" style="min-height:250px;">
                    <canvas id="rolesChart" style="max-width:200px;max-height:200px;"></canvas>
                    <div id="rolesLegend" class="space-y-3 ml-8"></div>
                </div>
            </div>

        </div>
    </main>

    <asp:Literal ID="litChartData" runat="server" />

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            if (typeof lucide !== 'undefined') lucide.createIcons();

            var data = window.__platformData;
            if (!data) return;

            // Registration Trend - Line Chart
            new Chart(document.getElementById('registrationChart'), {
                type: 'line',
                data: {
                    labels: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
                    datasets: [{
                        data: data.registration,
                        borderColor: '#FF8C66',
                        backgroundColor: 'rgba(255,140,102,0.1)',
                        borderWidth: 3,
                        pointRadius: 0,
                        tension: 0.3,
                        fill: true
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { grid: { display: false }, ticks: { font: { size: 10 }, color: '#9CA3AF' } },
                        y: { grid: { color: '#E5E7EB', drawBorder: false }, ticks: { font: { size: 10 }, color: '#9CA3AF' } }
                    }
                }
            });

            // Cuisine Categories - Bar Chart
            new Chart(document.getElementById('cuisineChart'), {
                type: 'bar',
                data: {
                    labels: data.cuisineLabels,
                    datasets: [{
                        data: data.cuisineValues,
                        backgroundColor: function(ctx) {
                            var g = ctx.chart.ctx.createLinearGradient(0, 0, 0, 300);
                            g.addColorStop(0, '#FF8C66'); g.addColorStop(1, '#FFB399');
                            return g;
                        },
                        borderRadius: 8,
                        barPercentage: 0.6
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: { callbacks: { label: function(c) { return c.raw.toLocaleString() + ' Users'; } } } },
                    scales: {
                        x: { grid: { display: false }, ticks: { font: { size: 10, weight: 'bold' }, color: '#6B7280' } },
                        y: { grid: { color: '#F3F4F6' }, ticks: { font: { size: 10 }, color: '#9CA3AF' } }
                    }
                }
            });

            // User Roles - Donut Chart
            var rolesChart = new Chart(document.getElementById('rolesChart'), {
                type: 'doughnut',
                data: {
                    labels: data.rolesLabels,
                    datasets: [{
                        data: data.rolesValues,
                        backgroundColor: data.rolesColors,
                        borderWidth: 0,
                        cutout: '60%'
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: true,
                    plugins: { legend: { display: false } }
                }
            });

            // Build legend
            var legendEl = document.getElementById('rolesLegend');
            if (legendEl) {
                legendEl.innerHTML = '';
                data.rolesLabels.forEach(function(label, i) {
                    legendEl.innerHTML += '<div class="flex items-center gap-3">' +
                        '<div class="w-4 h-4 rounded-full shadow-sm" style="background-color:' + data.rolesColors[i] + '"></div>' +
                        '<span class="text-sm font-medium text-gray-700">' + label + ' (' + data.rolesValues[i] + ')</span></div>';
                });
            }
        });
    </script>
</asp:Content>
