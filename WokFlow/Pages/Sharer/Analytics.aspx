
<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="WokFlow.Pages.Sharer.Analytics" %>
<%@ Register Src="~/Controls/DashboardStats.ascx" TagPrefix="uc" TagName="DashboardStats" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Stats Overview -->
        <uc:DashboardStats ID="dashStats" runat="server" CssClass="mb-8" />

        <!-- Tab Navigation -->
        <div class="flex gap-4 mb-8">
            <a id="lnkPerformance" runat="server" href="?tab=performance">Performance</a>
            <a id="lnkQuiz" runat="server" href="?tab=quiz">Quiz Results</a>
            <a id="lnkComments" runat="server" href="?tab=comments">Comments</a>
        </div>

        <!-- ===== Performance Tab ===== -->
        <asp:Panel ID="pnlPerformance" runat="server">
            <div class="flex flex-col lg:flex-row gap-6">
                <!-- Date Filter -->
                <div class="glass-panel rounded-2xl p-6 lg:w-64 shrink-0 space-y-4">
                    <div>
                        <p class="text-sm font-bold text-[#1A1A1A] mb-2">Start Date</p>
                        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date"
                            CssClass="w-full h-10 px-3 bg-white/60 border border-white/60 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                    </div>
                    <div>
                        <p class="text-sm font-bold text-[#1A1A1A] mb-2">End Date</p>
                        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date"
                            CssClass="w-full h-10 px-3 bg-white/60 border border-white/60 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                    </div>
                    <div class="flex gap-2 pt-2">
                        <asp:Button ID="btnClearPerf" runat="server" Text="Clear" OnClick="btnClearPerf_Click"
                            CssClass="flex-1 h-10 border border-gray-300 rounded-full text-sm font-medium cursor-pointer bg-white" />
                        <asp:Button ID="btnApplyPerf" runat="server" Text="Apply" OnClick="btnApplyFilter_Click"
                            CssClass="flex-1 h-10 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full text-sm font-bold cursor-pointer border-0" />
                    </div>
                </div>
                <!-- Chart -->
                <div class="glass-panel rounded-2xl p-6 flex-1">
                    <h3 class="text-lg font-bold text-[#1A1A1A] mb-4">Course Participants</h3>
                    <canvas id="performanceChart" runat="server" height="300"></canvas>
                </div>
            </div>
        </asp:Panel>

        <!-- ===== Quiz Tab ===== -->
        <asp:Panel ID="pnlQuiz" runat="server" Visible="false">
            <div class="glass-panel rounded-2xl p-6">
                <h3 class="text-lg font-bold text-[#1A1A1A] mb-4">Quiz Score Dashboard</h3>
                <!-- Filters -->
                <div class="flex flex-wrap gap-3 mb-6">
                    <asp:DropDownList ID="ddlQuizCuisine" runat="server"
                        CssClass="h-10 px-4 bg-white border border-gray-200 rounded-full text-sm cursor-pointer">
                        <asp:ListItem Text="All Cuisine" Value="" />
                    </asp:DropDownList>
                    <asp:DropDownList ID="ddlQuizCourse" runat="server"
                        CssClass="h-10 px-4 bg-white border border-gray-200 rounded-full text-sm cursor-pointer">
                    </asp:DropDownList>
                    <asp:DropDownList ID="ddlQuizStatus" runat="server"
                        CssClass="h-10 px-4 bg-white border border-gray-200 rounded-full text-sm cursor-pointer">
                        <asp:ListItem Text="All Status" Value="" />
                        <asp:ListItem Text="Passed" Value="Passed" />
                        <asp:ListItem Text="Failed" Value="Failed" />
                    </asp:DropDownList>
                    <asp:Button ID="btnApplyQuiz" runat="server" Text="Apply" OnClick="btnApplyFilter_Click"
                        CssClass="h-10 px-6 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full text-sm font-bold cursor-pointer border-0" />
                </div>
                <!-- Table -->
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b border-gray-200">
                                <th class="text-left py-3 px-4 text-sm font-bold text-gray-600">Learner Name</th>
                                <th class="text-left py-3 px-4 text-sm font-bold text-gray-600">Date Completed</th>
                                <th class="text-left py-3 px-4 text-sm font-bold text-gray-600">Scores</th>
                                <th class="text-left py-3 px-4 text-sm font-bold text-gray-600">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptQuizResults" runat="server">
                                <ItemTemplate>
                                    <tr class="border-b border-gray-100">
                                        <td class="py-3 px-4 text-sm font-medium"><%# Eval("Username") %></td>
                                        <td class="py-3 px-4 text-sm text-gray-500"><%# ((DateTime)Eval("CompletedDate")).ToString("yyyy-MM-dd") %></td>
                                        <td class="py-3 px-4">
                                            <div class="flex items-center gap-3">
                                                <div class="w-32 h-2 bg-gray-200 rounded-full overflow-hidden">
                                                    <div class="h-full bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] rounded-full" <%# GetScoreWidth(Eval("Score")) %>></div>
                                                </div>
                                                <span class="text-sm font-bold text-gray-700"><%# Eval("Score") %> %</span>
                                            </div>
                                        </td>
                                        <td class="py-3 px-4">
                                            <span class="text-xs font-bold px-3 py-1 rounded-full <%# Eval("Status").ToString() == "Passed" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700" %>">
                                                <%# Eval("Status") %>
                                            </span>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <asp:Label ID="lblNoQuiz" runat="server" Visible="false"
                        Text="No quiz results found." CssClass="block text-center text-gray-400 py-8" />
                </div>
            </div>
        </asp:Panel>

        <!-- ===== Comments Tab ===== -->
        <asp:Panel ID="pnlComments" runat="server" Visible="false">
            <div class="glass-panel rounded-2xl p-6">
                <h3 class="text-lg font-bold text-[#1A1A1A] mb-4">Comment Dashboard</h3>
                <!-- Filter -->
                <div class="flex gap-3 mb-6">
                    <asp:DropDownList ID="ddlCommentCourse" runat="server"
                        CssClass="h-10 px-4 bg-white border border-gray-200 rounded-full text-sm cursor-pointer">
                    </asp:DropDownList>
                    <asp:Button ID="btnApplyComments" runat="server" Text="Apply" OnClick="btnApplyFilter_Click"
                        CssClass="h-10 px-6 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full text-sm font-bold cursor-pointer border-0" />
                </div>
                <!-- Table -->
                <table class="w-full">
                    <thead>
                        <tr class="border-b border-gray-200">
                            <th class="text-left py-3 px-4 text-sm font-bold text-gray-600">Learner Name</th>
                            <th class="text-left py-3 px-4 text-sm font-bold text-gray-600">Date</th>
                            <th class="text-left py-3 px-4 text-sm font-bold text-gray-600">Comment</th>
                            <th class="text-left py-3 px-4 text-sm font-bold text-gray-600">Rating</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptComments" runat="server">
                            <ItemTemplate>
                                <tr class="border-b border-gray-100">
                                    <td class="py-3 px-4 text-sm font-medium"><%# Eval("Username") %></td>
                                    <td class="py-3 px-4 text-sm text-gray-500"><%# ((DateTime)Eval("CreatedDate")).ToString("yyyy-MM-dd") %></td>
                                    <td class="py-3 px-4 text-sm text-gray-600 max-w-xs"><%# Eval("CommentText") %></td>
                                    <td class="py-3 px-4">
                                        <div class="flex items-center gap-1"><%# RenderStars((int)Eval("Rating")) %></div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
                <asp:Label ID="lblNoComments" runat="server" Visible="false"
                    Text="No comments found." CssClass="block text-center text-gray-400 py-8" />
            </div>
        </asp:Panel>
    </div>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script>
        lucide.createIcons();

        var ctx = document.getElementById('performanceChart');
        if (ctx) {
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: JSON.parse(ctx.getAttribute('data-labels') || '[]'),
                    datasets: [{
                        label: 'Participants',
                        data: JSON.parse(ctx.getAttribute('data-values') || '[]'),
                        backgroundColor: 'rgba(255, 140, 102, 0.6)',
                        borderColor: '#FF8C66',
                        borderWidth: 1,
                        borderRadius: 8
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: function (ctx) { return ctx.parsed.y + ' participants'; }
                            }
                        }
                    },
                    scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
                }
            });
        }
    </script>
</asp:Content>