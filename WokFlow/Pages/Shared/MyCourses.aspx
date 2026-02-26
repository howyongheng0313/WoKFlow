<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyCourses.aspx.cs" Inherits="WokFlow.Pages.Shared.MyCourses" %>
<%@ Register Src="~/Controls/DashboardStats.ascx" TagPrefix="uc" TagName="DashboardStats" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">

        <!-- Page Heading -->
        <h1 class="text-2xl font-bold text-[#1A1A1A] mb-6">
            <asp:Literal ID="litPageTitle" runat="server" />
        </h1>

        <!-- Stats Banner -->
        <uc:DashboardStats ID="dashStats" runat="server" CssClass="mb-6" />

        <!-- Search + Filter Bar (OUTSIDE the card) -->
        <div class="flex items-center gap-3 mb-4">
            <div class="relative flex-1 max-w-[300px]">
                <asp:TextBox ID="txtSearch" runat="server"
                    CssClass="w-full h-11 pl-10 pr-4 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>
            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="btnSearch_Click"
                CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 appearance-none pr-8 cursor-pointer" />
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click"
                CssClass="hidden" />
            <!-- Create Course button (Sharer Created tab only) -->
            <asp:Panel ID="pnlCreateBtn" runat="server" Visible="false" CssClass="ml-auto">
                <a href="<%: ResolveUrl("~/Pages/Sharer/CreateCourse.aspx") %>"
                   class="inline-flex items-center gap-2 h-11 px-6 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-xl text-sm font-bold no-underline shadow-lg shadow-orange-500/20 hover:shadow-xl transition-all">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Create Course
                </a>
            </asp:Panel>
        </div>

        <!-- White card wrapper for table -->
        <div class="bg-white rounded-2xl shadow-[0_2px_16px_rgba(0,0,0,0.06)] border border-gray-100/60">

            <!-- Created Courses Table (Sharer tab) -->
            <asp:Panel ID="pnlCreated" runat="server">
                <!-- Column Headers -->
                <div class="flex items-center gap-4 px-8 py-4 border-b border-gray-200 text-sm font-bold text-gray-800">
                    <span class="w-4 shrink-0"></span>
                    <span class="flex-1 min-w-0">Course Name</span>
                    <span class="shrink-0 w-28">Date</span>
                    <span class="shrink-0 w-20 text-right">Status</span>
                    <span class="w-8 shrink-0"></span>
                </div>

                <asp:Repeater ID="rptCreatedCourses" runat="server" OnItemCommand="rptCreatedCourses_ItemCommand">
                    <ItemTemplate>
                        <div class="flex items-center gap-4 py-5 border-b border-gray-100 hover:bg-[#FFF8F0] transition-colors px-8">
                            <div class="w-4 h-4 rounded border border-gray-300 shrink-0"></div>
                            <span class="font-bold text-[#1A1A1A] flex-1 min-w-0 truncate"><%# Eval("Title") %></span>
                            <span class="text-sm text-gray-400 shrink-0 w-28"><%# ((DateTime)Eval("CreatedDate")).ToString("yyyy-MM-dd") %></span>
                            <span class="text-sm shrink-0 w-20 text-right <%# Eval("Status").ToString() == "Active" ? "text-gray-700" : Eval("Status").ToString() == "Banned" ? "text-red-600 font-bold" : "text-gray-400" %>">
                                <%# Eval("Status") %>
                            </span>
                            <div class="relative shrink-0" style='<%# Eval("Status").ToString() == "Banned" ? "visibility:hidden" : "" %>'>
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

            <!-- Enrolled Courses Table (Joined tab / Learner default) -->
            <asp:Panel ID="pnlJoined" runat="server">
                <!-- Column Headers -->
                <div class="flex items-center gap-4 px-8 py-4 border-b border-gray-200 text-sm font-bold text-gray-800">
                    <span class="w-4 shrink-0"></span>
                    <span class="flex-1 min-w-0">Course Name</span>
                    <span class="shrink-0 w-28">Date</span>
                    <span class="shrink-0 w-48 text-right">Progress</span>
                    <span class="w-8 shrink-0"></span>
                </div>

                <asp:Repeater ID="rptEnrolledCourses" runat="server" OnItemCommand="rptEnrolledCourses_ItemCommand">
                    <ItemTemplate>
                        <div class="flex items-center gap-4 py-5 border-b border-gray-100 <%# Eval("CourseStatus").ToString() == "Banned" ? "bg-red-50/50" : "hover:bg-[#FFF8F0] cursor-pointer" %> transition-colors px-8"
                            onclick="<%# Eval("CourseStatus").ToString() == "Banned" ? "" : "navigateToCourse(event, '" + Eval("CourseId") + "')" %>">
                            <div class="w-4 h-4 rounded border border-gray-300 shrink-0"></div>
                            <span class="font-bold <%# Eval("CourseStatus").ToString() == "Banned" ? "text-gray-400" : "text-[#1A1A1A]" %> flex-1 min-w-0 truncate"><%# Eval("CourseTitle") %><%# Eval("CourseStatus").ToString() == "Banned" ? " <span class='ml-2 text-xs font-bold text-red-600 bg-red-100 px-2 py-0.5 rounded-full'>Banned</span>" : "" %></span>
                            <span class="text-sm text-gray-400 shrink-0 w-28"><%# ((DateTime)Eval("EnrollmentDate")).ToString("yyyy-MM-dd") %></span>
                            <div class="flex items-center gap-2 w-48 shrink-0 justify-end">
                                <div class="flex-1 h-1.5 bg-gray-200 rounded-full overflow-hidden max-w-[120px]">
                                    <div class="h-full bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] rounded-full" <%# GetProgressWidth(Eval("Progress")) %>></div>
                                </div>
                                <span class="text-sm font-bold text-gray-600 w-10 text-right"><%# Eval("Progress") %> %</span>
                            </div>
                            <div class="relative shrink-0" onclick="event.stopPropagation();">
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

            <!-- Pagination Footer -->
            <div class="flex items-center justify-between px-8 py-4 border-t border-gray-100">
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

        function navigateToCourse(event, courseId) {
            window.location.href = '<%= ResolveUrl("~/Pages/Shared/CourseDetail.aspx") %>?id=' + courseId;
        }
    </script>
</asp:Content>
