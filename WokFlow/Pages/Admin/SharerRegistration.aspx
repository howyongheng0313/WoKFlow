<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SharerRegistration.aspx.cs" Inherits="WokFlow.Pages.Admin.SharerRegistration" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <h1 class="text-2xl font-bold text-[#1A1A1A] mb-8">Sharer Registration</h1>

        <!-- Filters -->
        <div class="flex gap-4 mb-6">
            <asp:TextBox ID="txtSearch" runat="server" placeholder="Search by username..."
                CssClass="flex-1 h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl">
                <asp:ListItem Text="All Status" Value="" />
                <asp:ListItem Text="Pending" Value="Pending" />
                <asp:ListItem Text="Accepted" Value="Accepted" />
                <asp:ListItem Text="Rejected" Value="Rejected" />
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
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Username</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Register Date</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Proof of Skills</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Status</th>
                        <th class="text-left py-4 px-6 text-sm font-bold text-gray-600">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptRegistrations" runat="server" OnItemCommand="rptRegistrations_ItemCommand">
                        <ItemTemplate>
                            <tr class="border-b border-gray-100 hover:bg-white/40">
                                <td class="py-4 px-6 text-sm font-medium"><%# Eval("Username") %></td>
                                <td class="py-4 px-6 text-sm text-gray-500"><%# ((DateTime)Eval("RequestDate")).ToString("yyyy-MM-dd") %></td>
                                <td class="py-4 px-6 text-sm text-[#FF8C66] font-medium"><%# Eval("ProofDocument") %></td>
                                <td class="py-4 px-6">
                                    <span class="text-xs font-bold px-3 py-1 rounded-full <%# GetStatusCss(Eval("Status").ToString()) %>"><%# Eval("Status") %></span>
                                </td>
                                <td class="py-4 px-6">
                                    <asp:Button ID="btnAccept" runat="server" CommandName="Accept" CommandArgument='<%# Eval("RegistrationId") %>'
                                        Text="Accept" Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                        CssClass="px-3 py-1.5 text-xs font-bold bg-green-50 text-green-600 border border-green-200 rounded-lg cursor-pointer mr-1" />
                                    <asp:Button ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("RegistrationId") %>'
                                        Text="Reject" Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                        CssClass="px-3 py-1.5 text-xs font-bold bg-red-50 text-red-600 border border-red-200 rounded-lg cursor-pointer" />
                                    <asp:Button ID="btnUndo" runat="server" CommandName="Undo" CommandArgument='<%# Eval("RegistrationId") %>'
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