<%@ Page Language="C#" MasterPageFile="~/MinimalSite.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="WokFlow.Pages.Auth.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="flex-1 flex flex-col items-center justify-center px-4 pb-20 mt-8">
        <!-- Icon -->
        <div class="w-16 h-16 bg-gradient-to-br from-[#FF8C66] to-[#FFB399] rounded-full mb-8 shadow-lg shadow-orange-500/20"></div>

        <h1 class="text-3xl font-bold text-[#1A1A1A] mb-8">Sign in</h1>

        <div class="w-full max-w-[500px] glass-panel rounded-[2.5rem] p-8 md:p-12 mb-6">
            <div class="space-y-6">
                <!-- Email -->
                <div class="space-y-2">
                    <label class="text-sm font-bold text-gray-700">Email or mobile phone number</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66] transition-all" />
                </div>

                <!-- Password -->
                <div class="space-y-2">
                    <div class="flex justify-between items-center">
                        <label class="text-sm font-bold text-gray-700">Your password</label>
                        <button type="button" onclick="togglePassword()" class="text-[#1A1A1A] font-bold text-sm flex items-center gap-2 focus:outline-none">
                            <i data-lucide="eye-off" id="eyeIcon" style="width:18px;height:18px;"></i>
                            <span id="eyeText">Hide</span>
                        </button>
                    </div>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66] transition-all" />
                </div>

                <!-- Error Message -->
                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm">
                    <asp:Label ID="lblError" runat="server" />
                </asp:Panel>

                <!-- Sign In Button -->
                <asp:Button ID="btnSignIn" runat="server" Text="Sign In" OnClick="btnSignIn_Click"
                    CssClass="w-full h-14 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-xl font-bold text-base hover:shadow-orange-500/30 transition-all shadow-lg shadow-orange-500/20 mt-2 cursor-pointer border-0" />

                <p class="text-xs text-gray-500 text-center leading-relaxed">
                    By continuing, you agree to the <span class="font-bold text-gray-700">Terms of use</span> and <span class="font-bold text-gray-700">Privacy Policy</span>.
                </p>

                <div class="flex justify-between items-center pt-2">
                    <span class="text-sm font-medium text-[#1A1A1A]">Other issue with sign in</span>
                    <span class="text-sm font-bold text-gray-500">Forget your password</span>
                </div>
            </div>
        </div>

        <div class="w-full max-w-[600px] flex items-center gap-4 mb-8">
            <div class="h-px bg-gray-300 flex-1"></div>
            <span class="text-gray-500 font-medium">New to our community</span>
            <div class="h-px bg-gray-300 flex-1"></div>
        </div>

        <a href="<%: ResolveUrl("~/Pages/Auth/Register.aspx") %>" class="text-[#1A1A1A] font-bold hover:text-gray-600 transition-colors no-underline">
            Create an account
        </a>
    </div>

    <script>
        lucide.createIcons();

        function togglePassword() {
            var input = document.getElementById('<%= txtPassword.ClientID %>');
            var icon = document.getElementById('eyeIcon');
            var text = document.getElementById('eyeText');
            if (input.type === 'password') {
                input.type = 'text';
                icon.setAttribute('data-lucide', 'eye');
                text.textContent = 'Show';
            } else {
                input.type = 'password';
                icon.setAttribute('data-lucide', 'eye-off');
                text.textContent = 'Hide';
            }
            lucide.createIcons();
        }
    </script>
</asp:Content>
