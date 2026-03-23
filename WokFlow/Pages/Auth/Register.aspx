<%@ Page Language="C#" MasterPageFile="~/MinimalSite.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="WokFlow.Pages.Auth.Register" %>
<%@ Register Src="~/Controls/CountrySelector.ascx" TagPrefix="uc" TagName="CountrySelector" %>
<%@ Register Src="~/Controls/Calendar.ascx" TagPrefix="uc" TagName="Calendar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <main class="flex-1 w-full max-w-[1000px] mx-auto px-6 md:px-12 pb-20 flex flex-col items-center mt-4">
        <div class="flex items-center gap-3 mb-8">
            <h1 class="text-4xl font-bold text-[#1A1A1A]"><asp:Literal ID="litPageTitle" runat="server" Text="User Registration" /></h1>
        </div>

        <!-- Role Toggle -->
        <asp:Panel ID="pnlRoleToggle" runat="server" CssClass="w-full max-w-md border border-white/60 bg-white/40 backdrop-blur-md rounded-full p-1.5 flex mb-16 relative">
            <asp:LinkButton ID="btnLearner" runat="server" OnClick="btnLearner_Click"
                CssClass="flex-1 py-3 rounded-full text-sm font-medium transition-all relative z-10 text-center no-underline" />
            <asp:LinkButton ID="btnSharer" runat="server" OnClick="btnSharer_Click"
                CssClass="flex-1 py-3 rounded-full text-sm font-medium transition-all relative z-10 text-center no-underline" />
            <div id="roleSlider" runat="server"
                 class="absolute top-1.5 bottom-1.5 w-[calc(50%_-_6px)] bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] rounded-full transition-all duration-300 ease-in-out shadow-md"></div>
        </asp:Panel>
        <asp:Panel ID="pnlResetRole" runat="server" Visible="false" CssClass="w-full max-w-md mb-16">
            <div class="w-full border border-white/60 bg-white/40 backdrop-blur-md rounded-full py-3 text-center text-sm font-semibold text-[#1A1A1A]">
                Role: <asp:Literal ID="litResetRole" runat="server" />
            </div>
        </asp:Panel>

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
                <asp:Panel ID="pnlBirthEdit" runat="server">
                    <uc:Calendar ID="calBirthDate" runat="server" />
                </asp:Panel>
                <asp:TextBox ID="txtBirthDateLocked" runat="server" Visible="false" ReadOnly="true"
                    CssClass="w-full h-12 px-4 bg-gray-100 border border-gray-200 rounded-xl text-gray-600 cursor-not-allowed" />
            </div>
            <div class="space-y-2 relative">
                <label class="text-gray-700 font-medium">Country</label>
                <asp:Panel ID="pnlCountryEdit" runat="server">
                    <uc:CountrySelector ID="countrySelector" runat="server" />
                </asp:Panel>
                <asp:TextBox ID="txtCountryLocked" runat="server" Visible="false" ReadOnly="true"
                    CssClass="w-full h-12 px-4 bg-gray-100 border border-gray-200 rounded-xl text-gray-600 cursor-not-allowed" />
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

    <!-- Email Verification Overlay -->
    <div id="verifyOverlay" class="hidden fixed inset-0 z-[80] bg-black/25 backdrop-blur-sm px-4">
        <div class="h-full flex items-center justify-center">
            <div class="w-full max-w-md rounded-2xl bg-white border border-orange-100 shadow-2xl overflow-hidden">
                <div class="px-5 py-4 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white">
                    <h3 class="text-lg font-semibold">Verify Your Email</h3>
                    <p class="text-sm text-white/90 mt-1">Enter the 6-digit code sent to <span id="verifyEmailText" class="font-semibold"></span></p>
                </div>
                <div class="px-5 py-5">
                    <div id="verifyInputs" class="flex justify-center gap-2 mb-4">
                        <input class="verify-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                        <input class="verify-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                        <input class="verify-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                        <input class="verify-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                        <input class="verify-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                        <input class="verify-digit w-11 h-12 text-center text-xl font-bold rounded-xl border border-orange-200 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30" maxlength="1" inputmode="numeric" />
                    </div>
                    <p id="verifyError" class="hidden text-sm text-red-600 text-center mb-3"></p>
                    <button id="btnSubmitVerify" type="button"
                        class="w-full h-11 rounded-xl bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white font-semibold">
                        Verify & Continue
                    </button>

                    <div id="verifySuccess" class="hidden py-6 text-center">
                        <div class="mx-auto w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mb-3">
                            <svg class="w-9 h-9 text-green-600 verify-tick" viewBox="0 0 52 52">
                                <path d="M14 27l8 8 16-16" fill="none" stroke="currentColor" stroke-width="5" stroke-linecap="round" stroke-linejoin="round" />
                            </svg>
                        </div>
                        <p class="text-green-700 font-semibold">Email verified!</p>
                        <p class="text-sm text-gray-500 mt-1">Signing you in...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        .verify-tick path {
            stroke-dasharray: 48;
            stroke-dashoffset: 48;
            animation: drawTick 0.9s ease forwards;
        }

        @keyframes drawTick {
            to { stroke-dashoffset: 0; }
        }
    </style>

    <script>
        lucide.createIcons();

        (function () {
            var overlay = document.getElementById('verifyOverlay');
            var emailText = document.getElementById('verifyEmailText');
            var inputs = Array.prototype.slice.call(document.querySelectorAll('.verify-digit'));
            var btnVerify = document.getElementById('btnSubmitVerify');
            var verifyError = document.getElementById('verifyError');
            var verifyInputs = document.getElementById('verifyInputs');
            var verifySuccess = document.getElementById('verifySuccess');

            function collectCode() {
                return inputs.map(function (el) { return (el.value || '').trim(); }).join('');
            }

            function clearError() {
                verifyError.classList.add('hidden');
                verifyError.textContent = '';
            }

            function showError(msg) {
                verifyError.textContent = msg || 'Verification failed.';
                verifyError.classList.remove('hidden');
            }

            function setBusy(busy) {
                btnVerify.disabled = !!busy;
                btnVerify.style.opacity = busy ? '0.7' : '1';
            }

            function focusFirst() {
                if (inputs.length > 0) inputs[0].focus();
            }

            function bindInputs() {
                inputs.forEach(function (input, idx) {
                    input.addEventListener('input', function () {
                        input.value = (input.value || '').replace(/\D/g, '').slice(0, 1);
                        clearError();
                        if (input.value && idx < inputs.length - 1) {
                            inputs[idx + 1].focus();
                        }
                    });

                    input.addEventListener('keydown', function (e) {
                        if (e.key === 'Backspace' && !input.value && idx > 0) {
                            inputs[idx - 1].focus();
                        }
                        if (e.key === 'Enter') {
                            e.preventDefault();
                            submitCode();
                        }
                    });
                });
            }

            function submitCode() {
                clearError();
                var code = collectCode();
                if (!/^\d{6}$/.test(code)) {
                    showError('Please enter the full 6-digit code.');
                    return;
                }

                setBusy(true);
                fetch('<%: ResolveUrl("~/Handlers/RegisterVerification.ashx") %>', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify({ code: code })
                })
                    .then(function (r) { return r.json(); })
                    .then(function (payload) {
                        var result = payload || {};
                        if (!result || !result.Success) {
                            showError(result && result.Message ? result.Message : 'Verification failed.');
                            setBusy(false);
                            return;
                        }

                        verifyInputs.classList.add('hidden');
                        btnVerify.classList.add('hidden');
                        clearError();
                        verifySuccess.classList.remove('hidden');

                        setTimeout(function () {
                            overlay.classList.add('hidden');
                            var redirectUrl = result.RedirectUrl || '<%: ResolveUrl("~/Pages/Learner/Dashboard.aspx") %>';
                            window.location.href = redirectUrl;
                        }, 1400);
                    })
                    .catch(function () {
                        showError('Could not verify code. Please try again.');
                        setBusy(false);
                    });
            }

            btnVerify.addEventListener('click', submitCode);
            bindInputs();

            window.openVerificationOverlay = function (email) {
                emailText.textContent = email || '';
                overlay.classList.remove('hidden');
                verifyInputs.classList.remove('hidden');
                btnVerify.classList.remove('hidden');
                verifySuccess.classList.add('hidden');
                clearError();
                setBusy(false);
                inputs.forEach(function (i) { i.value = ''; });
                setTimeout(focusFirst, 30);
            };
        })();
    </script>
</asp:Content>
