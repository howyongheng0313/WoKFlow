<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="WokFlow.Pages.Learner.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Search and Filters -->
        <div class="flex flex-col md:flex-row gap-4 mb-8">
            <div class="relative flex-1 max-w-[300px]">
                <asp:TextBox ID="txtSearch" runat="server" placeholder="Search courses..."
                    CssClass="w-full h-11 pl-10 pr-4 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>

            <asp:DropDownList ID="ddlCuisine" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 appearance-none pr-8 cursor-pointer">
                <asp:ListItem Text="All Cuisines" Value="" />
                <asp:ListItem Text="Chinese" Value="Chinese" />
                <asp:ListItem Text="Western" Value="Western" />
                <asp:ListItem Text="Japanese" Value="Japanese" />
                <asp:ListItem Text="Korean" Value="Korean" />
            </asp:DropDownList>

            <asp:DropDownList ID="ddlDifficulty" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 appearance-none pr-8 cursor-pointer">
                <asp:ListItem Text="All Difficulties" Value="" />
                <asp:ListItem Text="1 Star" Value="1" />
                <asp:ListItem Text="2 Stars" Value="2" />
                <asp:ListItem Text="3 Stars" Value="3" />
                <asp:ListItem Text="4 Stars" Value="4" />
                <asp:ListItem Text="5 Stars" Value="5" />
            </asp:DropDownList>

            <asp:DropDownList ID="ddlTimePosted" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 appearance-none pr-8 cursor-pointer">
                <asp:ListItem Text="Time Posted" Value="" />
                <asp:ListItem Text="Newest First" Value="newest" />
                <asp:ListItem Text="Oldest First" Value="oldest" />
            </asp:DropDownList>

            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="Filter_Changed"
                CssClass="hidden" />
        </div>

        <!-- Course Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
                <ItemTemplate>
                    <div class='<%# GetCardClass((int)Eval("CourseId")) %>' data-href='<%# GetCardHref((int)Eval("CourseId")) %>'>
                        <div class="h-48 bg-gradient-to-br from-[#FF8C66]/20 to-[#FFB399]/10 flex items-center justify-center overflow-hidden relative">
                            <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("Title") %>'
                                class="w-full h-full object-cover absolute inset-0"
                                onerror="this.remove()" />
                            <i data-lucide="chef-hat" style="width:48px;height:48px;color:#FF8C66;opacity:0.5;"></i>
                        </div>
                        <div class="p-6">
                            <div class="flex items-start justify-between gap-3 mb-2">
                                <h3 class="text-lg font-bold text-[#1A1A1A] flex-1"><%# Eval("Title") %></h3>
                                <asp:Button ID="btnJoin" runat="server" CommandName="Join" CommandArgument='<%# Eval("CourseId") %>'
                                    Text='<%# IsEnrolled((int)Eval("CourseId")) ? "Joined" : "Join" %>'
                                    Enabled='<%# !IsEnrolled((int)Eval("CourseId")) %>'
                                    CssClass='<%# IsEnrolled((int)Eval("CourseId"))
                                        ? "px-6 py-2 rounded-full text-sm font-bold bg-gray-200 text-gray-500 border-0 cursor-default shrink-0"
                                        : "px-6 py-2 rounded-full text-sm font-bold bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white shadow-lg shadow-orange-500/20 cursor-pointer border-0 shrink-0" %>' />
                            </div>
                            <p class="text-sm text-gray-500 mb-4 line-clamp-2"><%# Eval("Description") %></p>
                            <div class="flex items-center gap-3 text-sm text-gray-500">
                                <span>&#9679; <%# Eval("CuisineName") %></span>
                                <span>&#9679; <%# Eval("Difficulty") %> Stars</span>
                                <span>&#9679; <%# Eval("Duration") %></span>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- Pagination -->
        <div class="flex items-center justify-center gap-2 mt-8">
            <asp:Button ID="btnPrev" runat="server" Text="&#8249;" OnClick="btnPrev_Click"
                CssClass="w-10 h-10 flex items-center justify-center rounded-xl border border-gray-300 bg-white text-gray-600 font-bold cursor-pointer hover:border-[#FF8C66] hover:text-[#FF8C66] transition-colors" />

            <asp:Repeater ID="rptPages" runat="server" OnItemCommand="rptPages_ItemCommand">
                <ItemTemplate>
                    <asp:LinkButton ID="lnkPage" runat="server"
                        CommandName="Page"
                        CommandArgument='<%# Eval("PageNumber") %>'
                        Text='<%# Eval("PageNumber") %>'
                        CssClass='<%# (int)Eval("PageNumber") == CurrentPage
                            ? "w-10 h-10 inline-flex items-center justify-center rounded-xl text-sm font-bold text-white bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] shadow-md border-0"
                            : "w-10 h-10 inline-flex items-center justify-center rounded-xl text-sm font-medium text-gray-600 border border-gray-300 bg-white hover:border-[#FF8C66] hover:text-[#FF8C66] transition-colors" %>' />
                </ItemTemplate>
            </asp:Repeater>

            <asp:Button ID="btnNext" runat="server" Text="&#8250;" OnClick="btnNext_Click"
                CssClass="w-10 h-10 flex items-center justify-center rounded-xl border border-gray-300 bg-white text-gray-600 font-bold cursor-pointer hover:border-[#FF8C66] hover:text-[#FF8C66] transition-colors" />
        </div>
    </div>

    <!-- WokFlow AI Chatbot -->
    <div id="wfChatbot" class="fixed bottom-6 right-6 z-50">
        <button id="wfChatToggle" type="button"
            class="w-14 h-14 rounded-full bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white shadow-lg shadow-orange-500/30 flex items-center justify-center hover:scale-105 transition-transform">
            <i data-lucide="bot" class="w-6 h-6"></i>
        </button>

        <div id="wfChatPanel"
            class="hidden mt-3 w-[380px] max-w-[92vw] bg-white rounded-2xl shadow-2xl border border-gray-100 overflow-hidden relative flex flex-col"
            style="height: 520px;">
            <div id="wfChatHeader" class="px-4 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white flex items-center justify-between cursor-ns-resize select-none">
                <div class="flex items-center gap-2">
                    <i data-lucide="bot" class="w-4 h-4"></i>
                    <span class="text-sm font-semibold">WokAI</span>
                </div>
                <div class="flex items-center gap-2">
                    <button id="wfClearChatBtn" type="button" class="px-2.5 py-1 rounded-lg bg-white/20 text-xs font-semibold hover:bg-white/30 transition-colors">
                        Clear Chat
                    </button>
                    <button id="wfChatClose" type="button" class="text-white/90 hover:text-white">
                        <i data-lucide="x" class="w-4 h-4"></i>
                    </button>
                </div>
            </div>

            <div id="wfChatMessages" class="px-4 py-3 overflow-y-auto space-y-3 bg-[#FFF9F6] flex-1 min-h-0"></div>

            <div class="px-4 pb-2 pt-2 bg-white border-t border-gray-100 shrink-0">
                <div class="flex items-center gap-2">
                    <input id="wfChatInput" type="text" placeholder="Ask about WokFlow..."
                        class="flex-1 h-10 px-3 rounded-xl border border-gray-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/30 focus:border-[#FF8C66]" />
                    <button id="wfChatSend" type="button"
                        class="h-10 px-4 rounded-xl bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white text-sm font-semibold shadow">
                        Send
                    </button>
                </div>
                <p class="text-[11px] text-gray-400 mt-2">Only questions about WokFlow features can be answered.</p>
            </div>

            <div id="wfClearConfirm" class="hidden absolute inset-0 z-20 bg-black/25 backdrop-blur-[2px]">
                <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[88%] rounded-2xl bg-white border border-orange-100 shadow-2xl overflow-hidden">
                    <div class="px-5 py-4 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white font-semibold">Heads Up</div>
                    <div class="px-5 py-4">
                        <p class="text-sm font-semibold text-[#1A1A1A]">Are you sure to clear the chat?</p>
                        <p class="text-xs text-gray-500 mt-1">Messages cannot be recovered after this.</p>
                    </div>
                    <div class="px-5 pb-5 flex justify-end gap-2">
                        <button id="wfCancelClearBtn" type="button" class="px-4 py-2 rounded-xl border border-gray-300 text-sm text-gray-600 hover:bg-gray-50">Cancel</button>
                        <button id="wfConfirmClearBtn" type="button" class="px-4 py-2 rounded-xl bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-sm text-white font-semibold">Yes, Clear</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        #wfChatbot.open #wfChatToggle {
            display: none;
        }

        .wf-md p {
            margin: 0 0 8px 0;
            line-height: 1.45;
        }

        .wf-md p:last-child {
            margin-bottom: 0;
        }

        .wf-md ul,
        .wf-md ol {
            margin: 0 0 8px 18px;
            line-height: 1.45;
        }

        .wf-thinking-dot {
            display: inline-block;
            width: 6px;
            height: 6px;
            border-radius: 9999px;
            background: #FF8C66;
            margin-left: 3px;
            animation: wfBounce 1s infinite ease-in-out;
        }

        .wf-thinking-dot:nth-child(2) {
            animation-delay: 0.15s;
        }

        .wf-thinking-dot:nth-child(3) {
            animation-delay: 0.3s;
        }

        @keyframes wfBounce {
            0%, 80%, 100% { transform: scale(0.7); opacity: 0.45; }
            40% { transform: scale(1); opacity: 1; }
        }
    </style>

    <script>
        lucide.createIcons();
        document.querySelectorAll('[data-href]').forEach(function (card) {
            card.addEventListener('click', function (e) {
                if (e.target.tagName === 'INPUT' || e.target.tagName === 'BUTTON') return;
                var href = card.getAttribute('data-href');
                if (href) window.location = href;
            });
        });

        (function () {
            var chatRoot = document.getElementById('wfChatbot');
            var toggle = document.getElementById('wfChatToggle');
            var panel = document.getElementById('wfChatPanel');
            var header = document.getElementById('wfChatHeader');
            var closeBtn = document.getElementById('wfChatClose');
            var clearBtn = document.getElementById('wfClearChatBtn');
            var clearConfirm = document.getElementById('wfClearConfirm');
            var cancelClearBtn = document.getElementById('wfCancelClearBtn');
            var confirmClearBtn = document.getElementById('wfConfirmClearBtn');
            var sendBtn = document.getElementById('wfChatSend');
            var input = document.getElementById('wfChatInput');
            var messages = document.getElementById('wfChatMessages');

            var contactUrl = '<%= System.Web.HttpUtility.JavaScriptStringEncode(System.Configuration.ConfigurationManager.AppSettings["ContactUsUrl"] ?? "mailto:support@wokflow.com?subject=WokFlow%20Support%20Request") %>';

            var history = [];
            var historyLoaded = false;
            var defaultHeight = 520;
            var minPanelHeight = 420;
            var maxPanelHeightPadding = 96;
            var resizing = false;
            var startY = 0;
            var startHeight = defaultHeight;

            function openPanel() {
                panel.classList.remove('hidden');
                chatRoot.classList.add('open');
                panel.style.height = panel.style.height || (defaultHeight + 'px');
                if (!historyLoaded) {
                    loadHistory();
                } else if (!messages.dataset.greeted && history.length === 0) {
                    showStarterMessage();
                }
                input.focus();
            }

            function closePanel() {
                panel.classList.add('hidden');
                chatRoot.classList.remove('open');
                clearConfirm.classList.add('hidden');
            }

            function showStarterMessage() {
                appendMessage('model', 'Hi! I can answer questions about WokFlow courses, learning progress, and how the platform works.');
                messages.dataset.greeted = '1';
            }

            function escapeHtml(text) {
                return (text || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
            }

            function formatInline(text) {
                var safe = escapeHtml(text);
                return safe.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
            }

            function formatReplyToHtml(text) {
                var source = (text || '')
                    .replace(/\r/g, '')
                    .replace(/\s\*\s(?=[A-Za-z*])/g, '\n* ');

                var lines = source.split('\n');
                var html = [];
                var inUl = false;
                var inOl = false;

                function closeLists() {
                    if (inUl) { html.push('</ul>'); inUl = false; }
                    if (inOl) { html.push('</ol>'); inOl = false; }
                }

                for (var i = 0; i < lines.length; i++) {
                    var raw = lines[i] || '';
                    var line = raw.trim();
                    if (!line) {
                        closeLists();
                        continue;
                    }
                    if (line === '*' || line === '-' || line === '_') {
                        continue;
                    }

                    var ulMatch = line.match(/^[-*]\s+(.+)$/);
                    var olMatch = line.match(/^\d+\.\s+(.+)$/);
                    if (ulMatch) {
                        if (!inUl) { closeLists(); html.push('<ul>'); inUl = true; }
                        html.push('<li>' + formatInline(ulMatch[1]) + '</li>');
                        continue;
                    }
                    if (olMatch) {
                        if (!inOl) { closeLists(); html.push('<ol>'); inOl = true; }
                        html.push('<li>' + formatInline(olMatch[1]) + '</li>');
                        continue;
                    }

                    closeLists();
                    html.push('<p>' + formatInline(line) + '</p>');
                }
                closeLists();
                return html.join('');
            }

            function appendMessage(role, text) {
                var wrap = document.createElement('div');
                wrap.className = role === 'user'
                    ? 'flex justify-end'
                    : 'flex justify-start';

                var bubble = document.createElement('div');
                bubble.className = role === 'user'
                    ? 'max-w-[80%] px-3 py-2 rounded-2xl bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white text-sm shadow'
                    : 'max-w-[86%] px-3 py-2 rounded-2xl bg-white text-gray-700 text-sm shadow border border-gray-100 wf-md';

                if (role === 'model') {
                    bubble.innerHTML = formatReplyToHtml(text);
                } else {
                    bubble.textContent = text;
                }

                wrap.appendChild(bubble);
                messages.appendChild(wrap);
                messages.scrollTop = messages.scrollHeight;
            }

            function removeInlineContactCards() {
                var cards = messages.querySelectorAll('.wf-contact-card');
                cards.forEach(function (c) { c.remove(); });
            }

            function appendContactCard() {
                removeInlineContactCards();
                var wrap = document.createElement('div');
                wrap.className = 'flex justify-start wf-contact-card';
                var button = document.createElement('button');
                button.type = 'button';
                button.className = 'px-4 py-2 rounded-xl bg-gray-900 text-white text-sm font-semibold hover:bg-black transition-colors';
                button.textContent = 'Contact Us';
                button.addEventListener('click', function () { window.location.href = contactUrl; });
                wrap.appendChild(button);
                messages.appendChild(wrap);
                messages.scrollTop = messages.scrollHeight;
            }

            function createThinkingBubble() {
                var wrap = document.createElement('div');
                wrap.className = 'flex justify-start wf-thinking-wrap';
                var bubble = document.createElement('div');
                bubble.className = 'max-w-[86%] px-3 py-2 rounded-2xl bg-white text-gray-700 text-sm shadow border border-gray-100';
                bubble.innerHTML = '<span class="font-semibold text-[#FF6B4A]">WokAI is thinking</span>' +
                    '<span class="wf-thinking-dot"></span><span class="wf-thinking-dot"></span><span class="wf-thinking-dot"></span>';
                wrap.appendChild(bubble);
                messages.appendChild(wrap);
                messages.scrollTop = messages.scrollHeight;
                return wrap;
            }

            function sendMessage() {
                var text = (input.value || '').trim();
                if (!text) return;
                input.value = '';

                appendMessage('user', text);
                history.push({ role: 'user', text: text });
                removeInlineContactCards();
                var thinkingBubble = createThinkingBubble();

                var payload = {
                    message: text
                };

                fetch('<%: ResolveUrl("~/Handlers/Chatbot.ashx?action=chat") %>', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: JSON.stringify(payload)
                })
                    .then(function (r) { return r.json(); })
                    .then(function (data) {
                        if (thinkingBubble && thinkingBubble.parentNode) {
                            thinkingBubble.parentNode.removeChild(thinkingBubble);
                        }
                        var result = data || {};
                        var reply = result.reply || 'Sorry, something went wrong.';
                        appendMessage('model', reply);
                        history.push({ role: 'model', text: reply });
                        if (result.showContact) {
                            appendContactCard();
                        } else {
                            removeInlineContactCards();
                        }
                    })
                    .catch(function () {
                        if (thinkingBubble && thinkingBubble.parentNode) {
                            thinkingBubble.parentNode.removeChild(thinkingBubble);
                        }
                        appendMessage('model', 'Sorry, I could not reach the assistant service.');
                    });
            }

            function loadHistory() {
                fetch('<%: ResolveUrl("~/Handlers/Chatbot.ashx?action=history") %>', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: '{}'
                })
                    .then(function (r) { return r.json(); })
                    .then(function (data) {
                        var list = data && data.history ? data.history : [];
                        history = Array.isArray(list) ? list : [];
                        messages.innerHTML = '';
                        if (history.length === 0) {
                            showStarterMessage();
                        } else {
                            history.forEach(function (t) {
                                appendMessage(t.role === 'user' ? 'user' : 'model', t.text || '');
                            });
                        }
                        historyLoaded = true;
                    })
                    .catch(function () {
                        historyLoaded = true;
                    });
            }

            function clearChat() {
                fetch('<%: ResolveUrl("~/Handlers/Chatbot.ashx?action=clear") %>', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=utf-8' },
                    body: '{}'
                })
                    .then(function (r) { return r.json(); })
                    .then(function () {
                        history = [];
                        messages.innerHTML = '';
                        removeInlineContactCards();
                        showStarterMessage();
                        clearConfirm.classList.add('hidden');
                    });
            }

            function updatePanelHeight(newHeight) {
                var maxHeight = Math.min(window.innerHeight - maxPanelHeightPadding, 680);
                var clamped = Math.max(minPanelHeight, Math.min(maxHeight, newHeight));
                panel.style.height = clamped + 'px';
            }

            function beginResize(e) {
                var target = e.target;
                if (target === closeBtn || target === clearBtn || target.closest('#wfChatClose') || target.closest('#wfClearChatBtn')) {
                    return;
                }
                resizing = true;
                startY = e.clientY;
                startHeight = panel.getBoundingClientRect().height;
                document.body.style.userSelect = 'none';
            }

            function onResize(e) {
                if (!resizing) return;
                var dy = startY - e.clientY;
                updatePanelHeight(startHeight + dy);
            }

            function stopResize() {
                if (!resizing) return;
                resizing = false;
                document.body.style.userSelect = '';
            }

            toggle.addEventListener('click', openPanel);
            closeBtn.addEventListener('click', closePanel);
            clearBtn.addEventListener('click', function () {
                clearConfirm.classList.remove('hidden');
            });
            cancelClearBtn.addEventListener('click', function () {
                clearConfirm.classList.add('hidden');
            });
            confirmClearBtn.addEventListener('click', clearChat);
            sendBtn.addEventListener('click', sendMessage);
            input.addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    sendMessage();
                }
            });
            header.addEventListener('mousedown', beginResize);
            document.addEventListener('mousemove', onResize);
            document.addEventListener('mouseup', stopResize);
            window.addEventListener('resize', function () {
                if (!panel.classList.contains('hidden')) {
                    updatePanelHeight(panel.getBoundingClientRect().height);
                }
            });
        })();
    </script>
</asp:Content>
