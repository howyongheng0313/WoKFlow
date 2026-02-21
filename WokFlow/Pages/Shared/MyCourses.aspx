<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="WokFlow.Pages.Shared.MyCourses" %>
<%@ Register Src="~/Controls/DashboardStats.ascx" TagPrefix="uc" TagName="DashboardStats" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">

        <!-- Page Heading -->
        <h1 class="text-2xl font-bold text-[#1A1A1A] mb-6">My Courses</h1>

        <!-- Stats Banner -->
        <uc:DashboardStats ID="dashStats" runat="server" CssClass="mb-6" />

        <!-- Tab Navigation (Sharer only) -->
        <asp:Panel ID="pnlSharerTabs" runat="server" Visible="false" CssClass="flex gap-4 mb-6">
            <a href="?tab=created" class="<%= ActiveTab == "created" ? "bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white shadow-lg shadow-orange-500/20" : "bg-white/60 text-gray-600" %> px-6 py-2 rounded-full text-sm font-bold no-underline transition-all">
                Created Courses
            </a>
            <a href="?tab=joined" class="<%= ActiveTab == "joined" ? "bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white shadow-lg shadow-orange-500/20" : "bg-white/60 text-gray-600" %> px-6 py-2 rounded-full text-sm font-bold no-underline transition-all">
                Joined Courses
            </a>
        </asp:Panel>

        <!-- White card wrapper -->
        <div class="bg-white rounded-2xl shadow-sm">

            <!-- Search + Filter Bar -->
            <div class="p-6 border-b border-gray-100">
                <div class="flex gap-4">
                    <asp:TextBox ID="txtSearch" runat="server" placeholder="Search courses..."
                        CssClass="flex-1 h-10 px-4 bg-gray-50 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                    <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="btnSearch_Click"
                        CssClass="h-10 px-4 bg-gray-50 border border-gray-200 rounded-xl text-sm text-gray-500">
                        <asp:ListItem Text="All Status" Value="" />
                        <asp:ListItem Text="In Progress" Value="In Progress" />
                        <asp:ListItem Text="Completed" Value="Completed" />
                    </asp:DropDownList>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"
                        CssClass="h-10 px-5 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-xl text-sm font-bold cursor-pointer border-0" />
                </div>
            </div>

            <!-- Course Lists -->
            <div class="px-6">

                <!-- Created Courses (Sharer tab) -->
                <asp:Panel ID="pnlCreated" runat="server">
                    <asp:Repeater ID="rptCreatedCourses" runat="server" OnItemCommand="rptCreatedCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="flex items-center gap-4 py-4 border-b border-gray-100 hover:bg-gray-50 transition-colors rounded-lg px-2">
                                <div class="w-4 h-4 rounded border border-gray-300 shrink-0"></div>
                                <span class="font-bold text-[#1A1A1A] flex-1 min-w-0 truncate"><%# Eval("Title") %></span>
                                <span class="text-sm text-gray-400 shrink-0 w-28"><%# ((DateTime)Eval("CreatedDate")).ToString("yyyy-MM-dd") %></span>
                                <span class="text-xs font-bold px-3 py-1 rounded-full shrink-0 <%# Eval("Status").ToString() == "Active" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700" %>">
                                    <%# Eval("Status") %>
                                </span>
                                <div class="relative shrink-0">
                                    <button type="button" onclick="toggleMenu(this)"
                                        class="w-8 h-8 flex items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-gray-600 transition-colors font-bold text-lg leading-none">&#8942;</button>
                                    <div class="menu-dropdown hidden absolute right-0 top-9 bg-white border border-gray-100 rounded-xl shadow-lg z-10 min-w-[130px] py-1">
                                        <asp:Button ID="btnEdit" runat="server" CommandName="Edit" CommandArgument='<%# Eval("CourseId") %>' Text="Edit"
                                            CssClass="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 border-0 bg-transparent cursor-pointer" />
                                        <asp:Button ID="btnToggle" runat="server"
                                            CommandName='<%# Eval("Status").ToString() == "Active" ? "Delete" : "Recover" %>'
                                            CommandArgument='<%# Eval("CourseId") %>'
                                            Text='<%# Eval("Status").ToString() == "Active" ? "Delete" : "Recover" %>'
                                            CssClass='<%# Eval("Status").ToString() == "Active"
                                                ? "w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 border-0 bg-transparent cursor-pointer"
                                                : "w-full text-left px-4 py-2 text-sm text-green-600 hover:bg-green-50 border-0 bg-transparent cursor-pointer" %>' />
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

                <!-- Enrolled Courses (Joined tab / Learner default) -->
                <asp:Panel ID="pnlJoined" runat="server">
                    <asp:Repeater ID="rptEnrolledCourses" runat="server" OnItemCommand="rptEnrolledCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="flex items-center gap-4 py-4 border-b border-gray-100 hover:bg-gray-50 transition-colors rounded-lg px-2">
                                <div class="w-4 h-4 rounded border border-gray-300 shrink-0"></div>
                                <span class="font-bold text-[#1A1A1A] flex-1 min-w-0 truncate"><%# Eval("CourseTitle") %></span>
                                <span class="text-sm text-gray-400 shrink-0 w-28"><%# ((DateTime)Eval("EnrollmentDate")).ToString("yyyy-MM-dd") %></span>
                                <div class="flex items-center gap-2 w-48 shrink-0">
                                    <div class="flex-1 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                                        <div class="h-full bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] rounded-full" <%# GetProgressWidth(Eval("Progress")) %>></div>
                                    </div>
                                    <span class="text-sm font-bold text-gray-600 w-10 text-right"><%# Eval("Progress") %> %</span>
                                </div>
                                <div class="relative shrink-0">
                                    <button type="button" onclick="toggleMenu(this)"
                                        class="w-8 h-8 flex items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-gray-600 transition-colors font-bold text-lg leading-none">&#8942;</button>
                                    <div class="menu-dropdown hidden absolute right-0 top-9 bg-white border border-gray-100 rounded-xl shadow-lg z-10 min-w-[120px] py-1">
                                        <asp:Button ID="btnUnenroll" runat="server" CommandName="Unenroll"
                                            CommandArgument='<%# Eval("EnrollmentId") %>'
                                            Text="Unenroll"
                                            CssClass="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 border-0 bg-transparent cursor-pointer" />
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

            </div>

            <!-- Pagination Footer -->
            <div class="flex items-center justify-between p-6 border-t border-gray-100">
                <asp:Label ID="lblShowing" runat="server" CssClass="text-sm text-gray-500" />
                <div class="flex gap-6">
                    <asp:Button ID="btnPrev" runat="server" Text="Previous" OnClick="btnPrev_Click"
                        CssClass="text-sm text-gray-600 bg-transparent border-0 cursor-pointer hover:text-[#FF8C66] transition-colors" />
                    <asp:Button ID="btnNext" runat="server" Text="Next" OnClick="btnNext_Click"
                        CssClass="text-sm text-gray-600 bg-transparent border-0 cursor-pointer hover:text-[#FF8C66] transition-colors" />
                </div>
            </div>

        </div>
    </div>

    <script>lucide.createIcons();</script>
    <script>
        function toggleMenu(btn) {
            var menu = btn.nextElementSibling;
            document.querySelectorAll('.menu-dropdown').forEach(function (m) {
                if (m !== menu) m.classList.add('hidden');
            });
            menu.classList.toggle('hidden');
        }
        document.addEventListener('click', function (e) {
            if (!e.target.closest('.relative')) {
                document.querySelectorAll('.menu-dropdown').forEach(function (m) {
                    m.classList.add('hidden');
                });
            }
        });
    </script>
</asp:Content>