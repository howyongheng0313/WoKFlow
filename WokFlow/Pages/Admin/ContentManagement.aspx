<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ContentManagement.aspx.cs" Inherits="WokFlow.Pages.Admin.ContentManagement" %>
<%@ Register Src="~/Controls/DashboardStats.ascx" TagPrefix="uc" TagName="DashboardStats" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Stats -->
        <uc:DashboardStats ID="dashStats" runat="server" CssClass="mb-8" />

        <!-- Filters -->
        <div class="flex gap-4 mb-6">
            <asp:TextBox ID="txtSearch" runat="server" placeholder="Search by course or reporter..."
                CssClass="flex-1 h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl">
                <asp:ListItem Text="All Status" Value="" />
                <asp:ListItem Text="Pending" Value="Pending" />
                <asp:ListItem Text="Ignored" Value="Ignored" />
                <asp:ListItem Text="Banned" Value="Banned" />
            </asp:DropDownList>
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="Filter_Changed"
                CssClass="h-12 px-6 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-xl font-bold cursor-pointer border-0" />
            <asp:Button ID="btnReset" runat="server" Text="Reset" OnClick="btnReset_Click"
                CssClass="h-12 px-6 border border-gray-300 rounded-xl font-medium cursor-pointer bg-white" />
        </div>

        <!-- Table -->
        <div class="glass-panel rounded-2xl overflow-hidden">
            <table class="w-full">
                <thead>
                    <tr class="border-b border-gray-200 bg-white/40">
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Course</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Reporter</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Reason</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Date</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Status</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptReports" runat="server" OnItemCommand="rptReports_ItemCommand">
                        <ItemTemplate>
                            <tr class="border-b border-gray-100 hover:bg-white/40">
                                <td class="py-4 px-6 text-sm font-medium"><%# Eval("CourseTitle") %></td>
                                <td class="py-4 px-6 text-sm text-gray-500"><%# Eval("ReporterName") %></td>
                                <td class="py-4 px-6 text-sm text-gray-500 max-w-xs truncate"><%# Eval("Reason") %></td>
                                <td class="py-4 px-6 text-sm text-gray-500"><%# ((DateTime)Eval("ReportDate")).ToString("yyyy-MM-dd") %></td>
                                <td class="py-4 px-6">
                                    <span class="text-xs font-bold px-3 py-1 rounded-full <%GetStatusCss(Eval("Status").ToString()); %>"><%# Eval("Status") %></span>
                                </td>
                                <td class="py-4 px-6">
                                    <asp:Button ID="btnBan" runat="server" CommandName="Ban" CommandArgument='<%# Eval("ReportId") %>'
                                        Text="Ban" Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                        CssClass="px-3 py-1.5 text-xs font-bold bg-red-50 text-red-600 border border-red-200 rounded-lg cursor-pointer mr-1" />
                                    <asp:Button ID="btnIgnore" runat="server" CommandName="Ignore" CommandArgument='<%# Eval("ReportId") %>'
                                        Text="Ignore" Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                        CssClass="px-3 py-1.5 text-xs font-bold bg-gray-50 text-gray-600 border border-gray-200 rounded-lg cursor-pointer" />
                                    <asp:Button ID="btnUndo" runat="server" CommandName="Undo" CommandArgument='<%# Eval("ReportId") %>'
                                        Text="Undo" Visible='<%# Eval("Status").ToString() != "Pending" %>'
                                        CssClass="px-3 py-1.5 text-xs font-bold bg-gray-50 text-gray-600 border border-gray-200 rounded-lg cursor-pointer" />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
