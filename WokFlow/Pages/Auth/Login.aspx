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
                    <button id="btnForgotPassword" type="button" class="text-sm font-bold text-gray-500 hover:text-[#1A1A1A] transition-colors bg-transparent border-0 cursor-pointer">Forget your password</button>
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

    <!-- Forgot Password Overlay -->
    <div id="forgotOverlay" class="hidden fixed inset-0 z-[80] bg-black/25 backdrop-blur-sm px-4">
        <div class="h-full flex items-center justify-center">
            <div id="forgotCard" class="w-full max-w-md rounded-2xl bg-white border border-orange-100 shadow-2xl overflow-hidden transition-all duration-300">
                <div class="px-5 py-4 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white">
                    <h3 class="text-lg font-semibold">Reset Your Password</h3>
                    <p id="forgotSubtitle" class="text-sm text-white/90 mt-1">Enter your account email address</p>
                </div>
                <div class="px-5 py-5">
                    <div id="forgotStepEmail">
                        <input id="forgotEmailInput" type="email" placeholder="you@example.com"
                            class="w-full h-12 px-4 rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" />
                        <p id="forgotEmailError" class="hidden text-sm text-red-600 mt-2">Email doesn't exist.</p>
                        <button id="btnForgotNext" type="button"
                            class="w-full h-11 mt-4 rounded-xl bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white font-semibold">
                            Next
                        </button>
                    </div>

                    <div id="forgotStepCode" class="hidden mt-1">
                        <div class="flex justify-center gap-2 mb-4">
                            <input class="forgot-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                            <input class="forgot-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                            <input class="forgot-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                            <input class="forgot-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                            <input class="forgot-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                            <input class="forgot-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                        </div>
                        <p id="forgotCodeError" class="hidden text-sm text-red-600 text-center mb-3"></p>
                        <button id="btnForgotVerify" type="button"
                            class="w-full h-11 rounded-xl bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white font-semibold">
                            Verify Code
                        </button>
                    </div>

                    <button id="btnForgotClose" type="button" class="w-full h-10 mt-3 rounded-xl border border-gray-300 text-gray-600 font-medium bg-white">Cancel</button>
                </div>
            </div>
        </div>
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

        (function () {
            var overlay = document.getElementById('forgotOverlay');
            var openBtn = document.getElementById('btnForgotPassword');
            var closeBtn = document.getElementById('btnForgotClose');
            var nextBtn = document.getElementById('btnForgotNext');
            var verifyBtn = document.getElementById('btnForgotVerify');
            var emailInput = document.getElementById('forgotEmailInput');
            var emailErr = document.getElementById('forgotEmailError');
            var codeErr = document.getElementById('forgotCodeError');
            var subtitle = document.getElementById('forgotSubtitle');
            var emailStep = document.getElementById('forgotStepEmail');
            var codeStep = document.getElementById('forgotStepCode');
            var digitInputs = Array.prototype.slice.call(document.querySelectorAll('.forgot-digit'));

            function showOverlay() {
                overlay.classList.remove('hidden');
                emailStep.classList.remove('hidden');
                codeStep.classList.add('hidden');
                subtitle.textContent = 'Enter your account email address';
                emailErr.classList.add('hidden');
                codeErr.classList.add('hidden');
                emailInput.focus();
            }

            function hideOverlay() {
                overlay.classList.add('hidden');
            }

            function collectCode() {
                return digitInputs.map(function (d) { return d.value || ''; }).join('');
            }

            function toCodeStep(email) {
                subtitle.textContent = 'Enter the 6-digit code sent to ' + email;
                emailStep.classList.add('hidden');
                codeStep.classList.remove('hidden');
                digitInputs.forEach(function (d) { d.value = ''; });
                if (digitInputs[0]) digitInputs[0].focus();
            }

            function requestCode() {
                var email = (emailInput.value || '').trim();
                emailErr.classList.add('hidden');
                if (!email) {
                    emailErr.textContent = "Email doesn't exist.";
                    emailErr.classList.remove('hidden');
                    return;
                }

                nextBtn.disabled = true;
                fetch('<%: ResolveUrl("~/Handlers/ForgotPassword.ashx?action=request") %>', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify({ email: email })
                })
                    .then(function (r) { return r.json(); })
                    .then(function (res) {
                        if (!res || !res.success) {
                            emailInput.value = '';
                            emailErr.textContent = "Email doesn't exist.";
                            emailErr.classList.remove('hidden');
                            return;
                        }
                        toCodeStep(email);
                    })
                    .finally(function () { nextBtn.disabled = false; });
            }

            function verifyCode() {
                var email = (emailInput.value || '').trim();
                var code = collectCode().trim();
                codeErr.classList.add('hidden');
                if (!/^\d{6}$/.test(code)) {
                    codeErr.textContent = 'Please enter the full 6-digit code.';
                    codeErr.classList.remove('hidden');
                    return;
                }

                verifyBtn.disabled = true;
                fetch('<%: ResolveUrl("~/Handlers/ForgotPassword.ashx?action=verify") %>', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify({ email: email, code: code })
                })
                    .then(function (r) { return r.json(); })
                    .then(function (res) {
                        if (!res || !res.success) {
                            codeErr.textContent = (res && res.message) ? res.message : 'Verification failed.';
                            codeErr.classList.remove('hidden');
                            return;
                        }
                        window.location.href = res.redirectUrl || '<%: ResolveUrl("~/Pages/Auth/Register.aspx?mode=reset") %>';
                    })
                    .finally(function () { verifyBtn.disabled = false; });
            }

            digitInputs.forEach(function (input, idx) {
                input.addEventListener('input', function () {
                    input.value = (input.value || '').replace(/\D/g, '').slice(0, 1);
                    if (input.value && idx < digitInputs.length - 1) {
                        digitInputs[idx + 1].focus();
                    }
                });
                input.addEventListener('keydown', function (e) {
                    if (e.key === 'Backspace' && !input.value && idx > 0) {
                        digitInputs[idx - 1].focus();
                    }
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        verifyCode();
                    }
                });
            });

            openBtn.addEventListener('click', showOverlay);
            closeBtn.addEventListener('click', hideOverlay);
            nextBtn.addEventListener('click', requestCode);
            verifyBtn.addEventListener('click', verifyCode);
        })();
    </script>
</asp:Content>
