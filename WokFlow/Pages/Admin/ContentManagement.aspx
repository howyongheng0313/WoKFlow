<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ContentManagement.aspx.cs" Inherits="WokFlow.Pages.Admin.ContentManagement" %>
<%@ Register Src="~/Controls/DashboardStats.ascx" TagPrefix="uc" TagName="DashboardStats" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Overview Statistic -->
        <uc:DashboardStats ID="dashStats" runat="server" CssClass="mb-8" />

        <!-- Filters -->
        <div class="flex gap-3 mb-4">
            <div class="relative flex-1 max-w-[300px]">
                <!-- Search bar with icon-->
                <asp:TextBox ID="txtSearch" runat="server" placeholder="Search by course or reporter..."
                    CssClass="w-full h-11 pl-10 pr-4 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>
            <!-- Dropdown list (Status) -->
            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 cursor-pointer appearance-none">
                <asp:ListItem Text="Pending" Value="Pending" />
                <asp:ListItem Text="Ignored" Value="Ignored" />
                <asp:ListItem Text="Banned" Value="Banned" />
                <asp:ListItem Text="All Status" Value="" />
            </asp:DropDownList>
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="Filter_Changed"
                CssClass="hidden" />
        </div>

        <!-- Table -->
        <div class="bg-white rounded-2xl shadow-[0_2px_16px_rgba(0,0,0,0.06)] border border-gray-100/60 overflow-hidden">
            <table class="w-full">
                <thead>
                    <tr class="border-b border-gray-200">
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Course</th>
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Reporter</th>
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Reason</th>
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Date</th>
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Status</th>
                        <th class="py-4 px-4 text-sm font-bold text-gray-800"></th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
                        <ItemTemplate>
                            <tr class="border-b border-gray-100 hover:bg-[#FFF8F0] transition-colors">
                                <td class="py-5 px-8 text-sm font-medium text-[#1A1A1A]"><%# Eval("CourseTitle") %></td>
                                <td class="py-5 px-8 text-sm text-gray-500"><%# Eval("ReporterName") %></td>
                                <td class="py-5 px-8 text-sm text-gray-500 max-w-xs truncate"><%# Eval("Reason") %></td>
                                <td class="py-5 px-8 text-sm text-gray-500"><%# ((DateTime)Eval("ReportDate")).ToString("yyyy-MM-dd") %></td>
                                <td class="py-5 px-8 text-sm text-gray-500"><%# Eval("Status") %></td>
                                <td class="py-5 px-4">
                                    <div class="relative inline-block">
                                        <button type="button" onclick="openKebabMenu(event, this)"
                                            class="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="5" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="12" cy="19" r="1.5"/></svg>
                                        </button>
                                        <div class="kebab-menu hidden fixed z-50 w-36 bg-white rounded-xl shadow-lg border border-gray-100 py-1">
                                            <asp:LinkButton ID="lnkBan" runat="server" CommandName="Ban" CommandArgument='<%# Eval("ReportId") %>'
                                                Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                                CssClass="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors">Ban</asp:LinkButton>
                                            <asp:LinkButton ID="lnkIgnore" runat="server" CommandName="Ignore" CommandArgument='<%# Eval("ReportId") %>'
                                                Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                                CssClass="block w-full text-left px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 transition-colors">Ignore</asp:LinkButton>
                                            <asp:LinkButton ID="lnkUndo" runat="server" CommandName="Undo" CommandArgument='<%# Eval("ReportId") %>'
                                                Visible='<%# Eval("Status").ToString() != "Pending" %>'
                                                CssClass="block w-full text-left px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 transition-colors">Undo</asp:LinkButton>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function openKebabMenu(e, btn) {
            e.stopPropagation();
            var menu = btn.nextElementSibling;
            var wasHidden = menu.classList.contains('hidden');
            document.querySelectorAll('.kebab-menu').forEach(function (m) { m.classList.add('hidden'); });
            if (wasHidden) {
                var rect = btn.getBoundingClientRect();
                menu.style.top = (rect.bottom + 4) + 'px';
                menu.style.left = (rect.right - 144) + 'px';
                menu.classList.remove('hidden');
            }
        }
        document.addEventListener('click', function () {
            document.querySelectorAll('.kebab-menu').forEach(function (m) { m.classList.add('hidden'); });
        });
        lucide.createIcons();
    </script>
</asp:Content>