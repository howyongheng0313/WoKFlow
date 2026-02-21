<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserManagement.aspx.cs" Inherits="WokFlow.Pages.Admin.UserManagement" %>
<%@ Register Src="~/Controls/DashboardStats.ascx" TagPrefix="uc" TagName="DashboardStats" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Stats -->
        <uc:DashboardStats ID="dashStats" runat="server" CssClass="mb-8" />

        <!-- Filters -->
        <div class="flex flex-col md:flex-row gap-4 mb-6">
            <asp:TextBox ID="txtSearch" runat="server" placeholder="Search by username..."
                CssClass="flex-1 h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
            <asp:DropDownList ID="ddlRole" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl">
                <asp:ListItem Text="All Roles" Value="" />
                <asp:ListItem Text="Learner" Value="LEARNER" />
                <asp:ListItem Text="Sharer" Value="SHARER" />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl">
                <asp:ListItem Text="All Status" Value="" />
                <asp:ListItem Text="Active" Value="Active" />
                <asp:ListItem Text="Banned" Value="Banned" />
            </asp:DropDownList>
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="Filter_Changed"
                CssClass="h-12 px-6 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-xl font-bold cursor-pointer border-0" />
            <asp:Button ID="btnReset" runat="server" Text="Reset" OnClick="btnReset_Click"
                CssClass="h-12 px-6 border border-gray-300 rounded-xl font-medium cursor-pointer bg-white" />
        </div>

        <!-- User Table -->
        <div class="glass-panel rounded-2xl overflow-hidden">
            <table class="w-full">
                <thead>
                    <tr class="border-b border-gray-200 bg-white/40">
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Username</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Role</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Joined Date</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Status</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                        <ItemTemplate>
                            <tr class="border-b border-gray-100 hover:bg-white/40 transition-colors">
                                <td class="py-4 px-6 text-sm font-medium"><%# Eval("Username") %></td>
                                <td class="py-4 px-6 text-sm text-gray-500"><%# Eval("Role") %></td>
                                <td class="py-4 px-6 text-sm text-gray-500"><%# ((DateTime)Eval("JoinedDate")).ToString("yyyy-MM-dd") %></td>
                                <td class="py-4 px-6">
                                    <span class="text-xs font-bold px-3 py-1 rounded-full <%# Eval("Status").ToString() == "Active" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700" %>">
                                        <%# Eval("Status") %>
                                    </span>
                                </td>
                                <td class="py-4 px-6">
                                    <asp:Button ID="btnAction" runat="server"
                                        CommandName='<%# Eval("Status").ToString() == "Active" ? "Ban" : "Recover" %>'
                                        CommandArgument='<%# Eval("UserId") %>'
                                        Text='<%# Eval("Status").ToString() == "Active" ? "Ban" : "Recover" %>'
                                        CssClass='<%# Eval("Status").ToString() == "Active"
                                            ? "px-4 py-1.5 text-xs font-bold bg-red-50 text-red-600 border border-red-200 rounded-lg cursor-pointer"
                                            : "px-4 py-1.5 text-xs font-bold bg-green-50 text-green-600 border border-green-200 rounded-lg cursor-pointer" %>' />
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <script>lucide.createIcons();</script>
</asp:Content>

