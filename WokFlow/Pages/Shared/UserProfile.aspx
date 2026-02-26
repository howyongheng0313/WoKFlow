<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserProfile.aspx.cs" Inherits="WokFlow.Pages.Shared.UserProfile" %>
<%@ Register Src="~/Controls/CountrySelector.ascx" TagPrefix="uc" TagName="CountrySelector" %>
<%@ Register Src="~/Controls/Calendar.ascx" TagPrefix="uc" TagName="Calendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[800px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Profile Header with Banner -->
        <div class="glass-panel rounded-2xl mb-8">
            <!-- Dark Banner -->
            <div class="h-[160px] bg-gradient-to-r from-[#1a1a2e] to-[#16213e] relative overflow-hidden rounded-t-2xl">
                </div>

            <!-- Avatar overlapping banner -->
            <div class="relative px-8 pb-8">
                <div class="-mt-12 mb-4">
                    <div class="w-24 h-24 bg-gray-200 rounded-full border-4 border-white shadow-md flex items-center justify-center text-gray-400 text-3xl font-bold overflow-hidden">
                        <asp:Literal ID="litAvatar" runat="server" />
                    </div>
                </div>

                <!-- Name, Role Badge, and Edit Button -->
                <div class="flex items-start justify-between mb-8">
                    <div>
                        <h1 class="text-2xl font-bold text-[#1A1A1A]"><asp:Literal ID="litUserName" runat="server" /></h1>
                        <asp:Literal ID="litRoleBadge" runat="server" />
                    </div>
                    <asp:Button ID="btnEdit" runat="server" OnClick="btnEdit_Click"
                        CssClass="px-6 py-2 rounded-full font-bold cursor-pointer border-0 text-sm transition-all" />
                    <asp:Button ID="btnSave" runat="server" Text="Save Changes" OnClick="btnSave_Click" Visible="false"
                        CssClass="px-8 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full font-bold cursor-pointer border-0 shadow-lg shadow-orange-500/20 transition-all hover:shadow-xl" />
                </div>

                <!-- Profile Fields -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium text-sm">Full Name</label>
                        <!-- View Mode -->
                        <asp:Panel ID="pnlNameView" runat="server">
                            <div class="w-full h-14 px-4 bg-gray-50 border border-gray-100 rounded-xl flex items-center text-gray-700">
                                <asp:Literal ID="litNameValue" runat="server" />
                            </div>
                        </asp:Panel>
                        <!-- Edit Mode -->
                        <asp:Panel ID="pnlNameEdit" runat="server" Visible="false">
                            <asp:TextBox ID="txtName" runat="server"
                                CssClass="w-full h-14 px-4 bg-white border border-gray-200 rounded-xl focus:border-[#FF8C66] focus:outline-none transition-colors" />
                        </asp:Panel>
                    </div>
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium text-sm">Email Address</label>
                        <div class="w-full h-14 px-4 bg-gray-50 border border-gray-100 rounded-xl flex items-center text-gray-500">
                            <asp:Literal ID="litEmailValue" runat="server" />
                        </div>
                    </div>
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium text-sm">Birth Date</label>
                        <!-- View Mode -->
                        <asp:Panel ID="pnlBirthDateView" runat="server">
                            <div class="w-full h-14 px-4 bg-gray-50 border border-gray-100 rounded-xl flex items-center text-gray-700">
                                <asp:Literal ID="litBirthDateValue" runat="server" />
                            </div>
                        </asp:Panel>
                        <!-- Edit Mode -->
                        <asp:Panel ID="pnlBirthDateEdit" runat="server" Visible="false">
                            <uc:Calendar ID="calBirthDate" runat="server" />
                        </asp:Panel>
                    </div>
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium text-sm">Country</label>
                        <!-- View Mode -->
                        <asp:Panel ID="pnlCountryView" runat="server">
                            <div class="w-full h-14 px-4 bg-gray-50 border border-gray-100 rounded-xl flex items-center text-gray-700">
                                <asp:Literal ID="litCountryValue" runat="server" />
                            </div>
                        </asp:Panel>
                        <!-- Edit Mode -->
                        <asp:Panel ID="pnlCountryEdit" runat="server" Visible="false">
                            <uc:CountrySelector ID="countrySelector" runat="server" />
                        </asp:Panel>
                    </div>
                </div>

                <!-- Save Button (Edit Mode only) -->
                <asp:Panel ID="pnlSaveBtn" runat="server" Visible="false">
                    <div class="flex gap-4 mt-8">
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click"
                            CssClass="px-8 py-3 bg-white border border-gray-200 text-gray-600 rounded-full font-bold cursor-pointer transition-all hover:bg-gray-50" />
                    </div>
                </asp:Panel>
            </div>
        </div>

        <!-- Upgrade Section (Learner only) -->
        <asp:Panel ID="pnlUpgrade" runat="server" Visible="false">
            <div class="glass-panel rounded-2xl p-8 mb-8">
                <h2 class="text-xl font-bold text-[#1A1A1A] mb-2">Upgrade to Sharer</h2>
                <p class="text-gray-500 text-sm mb-6">Requirements to become a Professional Sharer:</p>

                <div class="space-y-4 mb-8">
                    <!-- Requirement 1: Complete 10 courses -->
                    <div class="flex items-center gap-3">
                        <asp:Literal ID="litReq1Icon" runat="server" />
                        <span class="text-gray-700 text-sm">Complete at least 3 courses</span>
                    </div>
                    <!-- Requirement 2: 80%+ quiz average -->
                    <div class="flex items-center gap-3">
                        <asp:Literal ID="litReq2Icon" runat="server" />
                        <span class="text-gray-700 text-sm">Maintain 80% + quiz average</span>
                    </div>
                </div>

                <div class="flex justify-end">
                    <asp:Button ID="btnUpgrade" runat="server" Text="Upgrade to Sharer" OnClick="btnUpgrade_Click"
                        CssClass="px-8 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full font-bold cursor-pointer border-0 shadow-lg shadow-orange-500/20 transition-all hover:shadow-xl" />
                </div>
            </div>
        </asp:Panel>

        <!-- Logout -->
        <div class="mt-8 flex justify-end">
            <a href="<%: ResolveUrl("~/Pages/Auth/Logout.aspx") %>"
               class="inline-flex items-center gap-2 px-6 py-3 border border-[#FF8C66]/30 text-[#FF6B4A] rounded-full font-bold hover:bg-[#FF8C66]/5 transition-all no-underline text-sm">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                Logout
            </a>
        </div>
    </div>
</asp:Content>