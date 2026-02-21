<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserProfile.aspx.cs" Inherits="WokFlow.Pages.Shared.UserProfile" %>
<%@ Register Src="~/Controls/CountrySelector.ascx" TagPrefix="uc" TagName="CountrySelector" %>
<%@ Register Src="~/Controls/Calendar.ascx" TagPrefix="uc" TagName="Calendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[800px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Profile Header -->
        <div class="glass-panel rounded-2xl p-8 mb-8">
            <div class="flex items-center gap-6 mb-8">
                <div class="w-20 h-20 bg-gradient-to-br from-[#FF8C66] to-[#FFB399] rounded-full flex items-center justify-center text-white text-2xl font-bold">
                    <asp:Literal ID="litAvatar" runat="server" />
                </div>
                <div>
                    <h1 class="text-2xl font-bold text-[#1A1A1A]"><asp:Literal ID="litUserName" runat="server" /></h1>
                    <span class="text-sm text-gray-500"><asp:Literal ID="litUserRole" runat="server" /></span>
                </div>
            </div>

            <!-- Profile Form -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="space-y-2">
                    <label class="text-gray-700 font-medium">Name</label>
                    <asp:TextBox ID="txtName" runat="server"
                        CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl" />
                </div>
                <div class="space-y-2">
                    <label class="text-gray-700 font-medium">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" ReadOnly="true"
                        CssClass="w-full h-14 px-4 bg-gray-100 border border-white/60 rounded-xl text-gray-500" />
                </div>
                <div class="space-y-2">
                    <label class="text-gray-700 font-medium">Birth Date</label>
                    <uc:Calendar ID="calBirthDate" runat="server" />
                </div>
                <div class="space-y-2">
                    <label class="text-gray-700 font-medium">Country</label>
                    <uc:CountrySelector ID="countrySelector" runat="server" />
                </div>
            </div>

            <div class="flex gap-4 mt-8">
                <asp:Button ID="btnSave" runat="server" Text="Save Changes" OnClick="btnSave_Click"
                    CssClass="px-8 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full font-bold cursor-pointer border-0 shadow-lg shadow-orange-500/20" />
            </div>
        </div>

        <!-- Upgrade Section (Learner only) -->
        <asp:Panel ID="pnlUpgrade" runat="server" Visible="false">
            <div class="glass-panel rounded-2xl p-8">
                <h2 class="text-xl font-bold text-[#1A1A1A] mb-4">Upgrade to Sharer</h2>
                <p class="text-gray-600 mb-6">Become a sharer and start creating your own culinary courses!</p>
                <asp:Button ID="btnUpgrade" runat="server" Text="Request Upgrade" OnClick="btnUpgrade_Click"
                    CssClass="px-8 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full font-bold cursor-pointer border-0 shadow-lg shadow-orange-500/20" />
                <asp:Label ID="lblUpgradeStatus" runat="server" CssClass="block mt-4 text-sm" />
            </div>
        </asp:Panel>

        <!-- Logout -->
        <div class="mt-8 text-center">
            <a href="<% ResolveUrl("~/Pages/Auth/Logout.aspx"); %>"
               class="text-red-500 font-bold hover:text-red-700 transition-colors no-underline">
                Sign Out
            </a>
        </div>
    </div>
</asp:Content>
