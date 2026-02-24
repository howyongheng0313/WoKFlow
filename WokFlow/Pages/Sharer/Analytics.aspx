
<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="WokFlow.Pages.Sharer.Analytics" %>
<%@ Register Src="~/Controls/DashboardStats.ascx" TagPrefix="uc" TagName="DashboardStats" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Stats Overview -->
        <uc:DashboardStats ID="dashStats" runat="server" CssClass="mb-8" />

        <!-- ===== Performance Tab ===== -->
        <asp:Panel ID="pnlPerformance" runat="server">
            <div class="flex flex-col lg:flex-row gap-6">
                <!-- Date Filter Card -->
                <div class="bg-white rounded-2xl p-6 lg:w-72 shrink-0 space-y-4 shadow-[0_2px_16px_rgba(0,0,0,0.06)] border border-gray-100/60">
                    <div>
                        <p class="text-sm font-bold text-[#1A1A1A] mb-2">Start Date</p>
                        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date"
                            CssClass="w-full h-11 px-3 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                    </div>
                    <div>
                        <p class="text-sm font-bold text-[#1A1A1A] mb-2">End Date</p>
                        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date"
                            CssClass="w-full h-11 px-3 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                    </div>
                    <div class="flex gap-2 pt-2">
                        <asp:Button ID="btnClearPerf" runat="server" Text="Clear" OnClick="btnClearPerf_Click"
                            CssClass="flex-1 h-10 border border-gray-300 rounded-full text-sm font-medium cursor-pointer bg-white" />
                        <asp:Button ID="btnApplyPerf" runat="server" Text="Apply" OnClick="btnApplyFilter_Click"
                            CssClass="flex-1 h-10 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full text-sm font-bold cursor-pointer border-0" />
                    </div>
                </div>
                <!-- Chart Card -->
                <div class="bg-white rounded-2xl p-6 flex-1 shadow-[0_2px_16px_rgba(0,0,0,0.06)] border border-gray-100/60">
                    <h3 class="text-lg font-bold text-[#1A1A1A] mb-4">Course Participants</h3>
                    <canvas id="performanceChart" runat="server" height="300"></canvas>
                </div>
            </div>
        </asp:Panel>

        <!-- ===== Quiz Tab ===== -->
        <asp:Panel ID="pnlQuiz" runat="server" Visible="false">
            <!-- Title outside card -->
            <h2 class="text-xl font-bold text-[#1A1A1A] mb-4">Quiz Score Dashboard</h2>

            <!-- Filters outside card -->
            <div class="flex flex-wrap items-center gap-3 mb-4">
                <asp:DropDownList ID="ddlQuizCuisine" runat="server" AutoPostBack="true" OnSelectedIndexChanged="btnApplyFilter_Click"
                    CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 cursor-pointer appearance-none">
                    <asp:ListItem Text="All Cuisine" Value="" />
                </asp:DropDownList>

                <asp:DropDownList ID="ddlQuizCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="btnApplyFilter_Click"
                    CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 cursor-pointer appearance-none">
                </asp:DropDownList>

                <asp:DropDownList ID="ddlQuizStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="btnApplyFilter_Click"
                    CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 cursor-pointer appearance-none">
                    <asp:ListItem Text="All Status" Value="" />
                    <asp:ListItem Text="Passed" Value="Passed" />
                    <asp:ListItem Text="Failed" Value="Failed" />
                </asp:DropDownList>
            </div>

            <!-- Table Card -->
            <div class="bg-white rounded-2xl shadow-[0_2px_16px_rgba(0,0,0,0.06)] border border-gray-100/60">
                <!-- Column Headers -->
                <div class="flex items-center gap-4 px-8 py-4 border-b border-gray-200">
                    <span class="w-4 shrink-0"></span>
                    <span class="flex-1 min-w-0 text-sm font-bold text-gray-800">Learner Name</span>
                    <span class="shrink-0 w-32 text-sm font-bold text-gray-800">Date Completed</span>
                    <span class="shrink-0 w-48 text-sm font-bold text-gray-800">Scores</span>
                    <span class="shrink-0 w-20 text-sm font-bold text-gray-800">Status</span>
                    <span class="w-8 shrink-0"></span>
                </div>

                <asp:Repeater ID="rptQuizResults" runat="server">
                    <ItemTemplate>
                        <div class="flex items-center gap-4 py-5 border-b border-gray-100 hover:bg-[#FFF8F0] transition-colors px-8">
                            <div class="w-4 h-4 rounded border border-gray-300 shrink-0"></div>
                            <span class="flex-1 min-w-0 text-sm font-medium text-[#1A1A1A] truncate"><%# Eval("Username") %></span>
                            <span class="shrink-0 w-32 text-sm text-gray-500"><%# ((DateTime)Eval("CompletedDate")).ToString("yyyy-MM-d") %></span>
                            <div class="shrink-0 w-48 flex items-center gap-3">
                                <div class="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
                                    <div class="h-full bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] rounded-full" <%# GetScoreWidth(Eval("Score")) %>></div>
                                </div>
                                <span class="text-sm font-bold text-gray-700 w-12 text-right"><%# Eval("Score") %> %</span>
                            </div>
                            <span class="shrink-0 w-20 text-sm text-gray-600"><%# Eval("Status") %></span>
                            <div class="w-8 shrink-0 flex items-center justify-center text-gray-400 text-lg leading-none">&#8942;</div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Label ID="lblNoQuiz" runat="server" Visible="false"
                    Text="No quiz results found." CssClass="block text-center text-gray-400 py-8" />

                <!-- Pagination -->
                <div class="flex items-center justify-between px-8 py-4 border-t border-gray-100">
                    <asp:Label ID="lblQuizShowing" runat="server" CssClass="text-sm text-gray-500" />
                    <div class="flex gap-6">
                        <asp:Button ID="btnQuizPrev" runat="server" Text="Previous" OnClick="btnQuizPrev_Click"
                            CssClass="text-sm text-gray-600 bg-transparent border-0 cursor-pointer hover:text-[#FF8C66] transition-colors" />
                        <asp:Button ID="btnQuizNext" runat="server" Text="Next" OnClick="btnQuizNext_Click"
                            CssClass="text-sm text-gray-600 bg-transparent border-0 cursor-pointer hover:text-[#FF8C66] transition-colors" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- ===== Comments Tab ===== -->
        <asp:Panel ID="pnlComments" runat="server" Visible="false">
            <!-- Title outside card -->
            <h2 class="text-xl font-bold text-[#1A1A1A] mb-4">Comment Dashboard</h2>

            <!-- Filter outside card -->
            <div class="flex items-center gap-3 mb-4">
                <asp:DropDownList ID="ddlCommentCourse" runat="server" AutoPostBack="true" OnSelectedIndexChanged="btnApplyFilter_Click"
                    CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 cursor-pointer appearance-none">
                </asp:DropDownList>
            </div>

            <!-- Table Card -->
            <div class="bg-white rounded-2xl shadow-[0_2px_16px_rgba(0,0,0,0.06)] border border-gray-100/60">
                <!-- Column Headers -->
                <div class="flex items-center gap-4 px-8 py-4 border-b border-gray-200">
                    <span class="w-4 shrink-0"></span>
                    <span class="w-44 shrink-0 text-sm font-bold text-gray-800">Learner Name</span>
                    <span class="shrink-0 w-28 text-sm font-bold text-gray-800">Date</span>
                    <span class="flex-1 min-w-0 text-sm font-bold text-gray-800">Comment</span>
                    <span class="shrink-0 w-28 text-sm font-bold text-gray-800 text-right">Rating</span>
                </div>

                <asp:Repeater ID="rptComments" runat="server">
                    <ItemTemplate>
                        <div class="flex items-center gap-4 py-5 border-b border-gray-100 hover:bg-[#FFF8F0] transition-colors px-8">
                            <div class="w-4 h-4 rounded border border-gray-300 shrink-0"></div>
                            <span class="w-44 shrink-0 text-sm font-medium text-[#1A1A1A] truncate"><%# Eval("Username") %></span>
                            <span class="shrink-0 w-28 text-sm text-gray-500"><%# ((DateTime)Eval("CreatedDate")).ToString("yyyy-MM-d") %></span>
                            <span class="flex-1 min-w-0 text-sm text-gray-600"><%# Eval("CommentText") %></span>
                            <div class="shrink-0 w-28 flex items-center justify-end gap-0.5"><%# RenderStars((int)Eval("Rating")) %></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Label ID="lblNoComments" runat="server" Visible="false"
                    Text="No comments found." CssClass="block text-center text-gray-400 py-8" />

                <!-- Pagination -->
                <div class="flex items-center justify-between px-8 py-4 border-t border-gray-100">
                    <asp:Label ID="lblCommentShowing" runat="server" CssClass="text-sm text-gray-500" />
                    <div class="flex gap-6">
                        <asp:Button ID="btnCommentPrev" runat="server" Text="Previous" OnClick="btnCommentPrev_Click"
                            CssClass="text-sm text-gray-600 bg-transparent border-0 cursor-pointer hover:text-[#FF8C66] transition-colors" />
                        <asp:Button ID="btnCommentNext" runat="server" Text="Next" OnClick="btnCommentNext_Click"
                            CssClass="text-sm text-gray-600 bg-transparent border-0 cursor-pointer hover:text-[#FF8C66] transition-colors" />
                    </div>
                </div>
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
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: { stepSize: 20 },
                            grid: { color: 'rgba(0,0,0,0.06)', drawBorder: false, borderDash: [4, 4] }
                        },
                        x: {
                            grid: { display: false }
                        }
                    }
                }
            });
        }
    </script>
</asp:Content>