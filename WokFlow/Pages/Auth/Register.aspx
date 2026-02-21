<%@ Page Language="C#" MasterPageFile="~/MinimalSite.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="WokFlow.Pages.Auth.Register" %>
<%@ Register Src="~/Controls/CountrySelector.ascx" TagPrefix="uc" TagName="CountrySelector" %>
<%@ Register Src="~/Controls/Calendar.ascx" TagPrefix="uc" TagName="Calendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <main class="flex-1 w-full max-w-[1000px] mx-auto px-6 md:px-12 pb-20 flex flex-col items-center mt-4">
        <div class="flex items-center gap-3 mb-8">
            <h1 class="text-4xl font-bold text-[#1A1A1A]">User Registration</h1>
        </div>

        <!-- Role Toggle -->
        <div class="w-full max-w-md border border-white/60 bg-white/40 backdrop-blur-md rounded-full p-1.5 flex mb-16 relative">
            <asp:LinkButton ID="btnLearner" runat="server" OnClick="btnLearner_Click"
                CssClass="flex-1 py-3 rounded-full text-sm font-medium transition-all relative z-10 text-center no-underline" />
            <asp:LinkButton ID="btnSharer" runat="server" OnClick="btnSharer_Click"
                CssClass="flex-1 py-3 rounded-full text-sm font-medium transition-all relative z-10 text-center no-underline" />
            <div id="roleSlider" runat="server"
                 class="absolute top-1.5 bottom-1.5 w-[calc(50%_-_6px)] bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] rounded-full transition-all duration-300 ease-in-out shadow-md"></div>
        </div>

        <!-- Form Grid -->
        <div class="w-full grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-8 mb-12">
            <div class="space-y-2">
                <label class="text-gray-700 font-medium">Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server"
                    CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
            </div>
            <div class="space-y-2">
                <label class="text-gray-700 font-medium">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                    CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
            </div>

            <div class="space-y-2">
                <label class="text-gray-700 font-medium">Birth Date</label>
                <uc:Calendar ID="calBirthDate" runat="server" />
            </div>
            <div class="space-y-2 relative">
                <label class="text-gray-700 font-medium">Country</label>
                <uc:CountrySelector ID="countrySelector" runat="server" />
            </div>

            <div class="space-y-2">
                <label class="text-gray-500 font-medium">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                    CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
            </div>
            <div class="space-y-2">
                <label class="text-gray-500 font-medium">Confirm Password</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                    CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
            </div>

            <!-- Sharer Only: Proof Upload -->
            <asp:Panel ID="pnlSharerUpload" runat="server" Visible="false" CssClass="md:col-span-2 space-y-2">
                <label class="text-[#1A1A1A] font-medium">Upload Proof of Skills</label>
                <div class="flex gap-4">
                    <asp:FileUpload ID="fuProofDocument" runat="server"
                        CssClass="flex-1 h-14 border-2 border-dashed border-[#FF8C66]/50 bg-orange-50/50 rounded-xl file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-[#FF8C66] file:text-white" />
                </div>
            </asp:Panel>
        </div>

        <!-- Error -->
        <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="w-full max-w-[600px] bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm mb-6">
            <asp:Label ID="lblError" runat="server" />
        </asp:Panel>

        <!-- Buttons -->
        <div class="flex gap-6 w-full max-w-[600px] mx-auto">
            <a href="<%: ResolveUrl("~/Pages/Auth/Login.aspx") %>"
               class="flex-1 h-14 border border-gray-400 rounded-full text-[#1A1A1A] font-medium hover:bg-white/50 transition-colors flex items-center justify-center no-underline">
                Back
            </a>
            <asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click"
                CssClass="flex-1 h-14 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] rounded-full text-white font-medium hover:shadow-orange-500/30 transition-all shadow-lg shadow-orange-500/20 cursor-pointer border-0" />
        </div>
    </main>

    <script>lucide.createIcons();</script>
</asp:Content>
