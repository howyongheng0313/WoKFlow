<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseDetail.aspx.cs" Inherits="WokFlow.Pages.Shared.CourseDetail" %>
<%@ Register Src="~/Controls/ScoreModal.ascx" TagPrefix="uc" TagName="ScoreModal" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

            <!-- Main Content -->
            <div class="lg:col-span-2">

                <!-- Video Player -->
                <div class="glass-panel rounded-2xl overflow-hidden mb-8">
                    <% if (IsEmbeddable(CurrentVideoUrl)) { %>
                        <div class="aspect-video relative">
                            <iframe src="<%= GetEmbedUrl(CurrentVideoUrl) %>"
                                class="w-full h-full" frameborder="0"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowfullscreen></iframe>
                            <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent px-6 pb-5 pt-10">
                                <h2 class="text-white font-bold text-lg leading-tight"><%= CurrentChapterTitle %></h2>
                                <p class="text-white/70 text-sm mt-1 line-clamp-2"><%= CurrentChapterDescription %></p>
                            </div>
                        </div>
                    <% } else if (!string.IsNullOrEmpty(CurrentVideoUrl)) { %>
                        <div class="aspect-video bg-black relative">
                            <video class="w-full h-full" controls>
                                <source src="<%= CurrentVideoUrl %>" />
                                Your browser does not support the video tag.
                            </video>
                            <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent px-6 pb-5 pt-10">
                                <h2 class="text-white font-bold text-lg leading-tight"><%= CurrentChapterTitle %></h2>
                                <p class="text-white/70 text-sm mt-1 line-clamp-2"><%= CurrentChapterDescription %></p>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="aspect-video bg-gradient-to-br from-[#FF8C66]/20 to-[#FFB399]/10 flex items-center justify-center relative">
                            <div class="text-center">
                                <div class="w-16 h-16 bg-white/80 rounded-full flex items-center justify-center mx-auto mb-3">
                                    <i data-lucide="play" style="width:32px;height:32px;color:#FF8C66;margin-left:4px;"></i>
                                </div>
                                <p class="text-sm text-gray-400">No video available for this chapter</p>
                            </div>
                            <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/50 to-transparent px-6 pb-5 pt-10">
                                <h2 class="text-white font-bold text-lg leading-tight"><%= CurrentChapterTitle %></h2>
                                <p class="text-white/70 text-sm mt-1 line-clamp-2"><%= CurrentChapterDescription %></p>
                            </div>
                        </div>
                    <% } %>
                </div>

                <!-- Course Info -->
                <div class="glass-panel rounded-2xl p-6 mb-8">
                    <div class="flex items-start justify-between mb-2">
                        <h1 class="text-xl font-bold text-[#1A1A1A] flex-1"><asp:Literal ID="litTitle" runat="server" /></h1>
                        <asp:Button ID="btnReport" runat="server" Text="Report &#9651;" OnClick="btnReport_Click"
                            CssClass="text-sm text-gray-400 bg-transparent border-0 cursor-pointer hover:text-red-400 transition-colors shrink-0 ml-4" />
                    </div>
                    <div class="flex items-center gap-4 mb-4 text-sm text-gray-500">
                        <span class="flex items-center gap-1.5">
                            <i data-lucide="circle-dot" class="w-4 h-4"></i>
                            Difficulty: <asp:Literal ID="litDifficulty" runat="server" />/5
                        </span>
                        <span class="flex items-center gap-1.5">
                            <i data-lucide="clock" class="w-4 h-4"></i>
                            <asp:Literal ID="litDuration" runat="server" />
                        </span>
                    </div>
                    <p class="text-gray-600 leading-relaxed"><asp:Literal ID="litDescription" runat="server" /></p>
                    <asp:Panel ID="pnlUnlockAlert" runat="server" Visible="false"
                        CssClass="flex items-center gap-2 p-3 bg-orange-50 border border-orange-200 rounded-xl mt-4 text-sm text-[#FF8C66] font-medium">
                        <i data-lucide="alert-triangle" class="w-4 h-4 shrink-0"></i>
                        Complete the quiz to unlock the next chapter
                    </asp:Panel>
                </div>

                <!-- Comments Section (always visible) -->
                <asp:Panel ID="pnlComments" runat="server">
                    <div class="glass-panel rounded-2xl p-6 mb-6">
                        <div class="flex items-center gap-2 mb-5">
                            <i data-lucide="message-square" class="w-5 h-5 text-gray-400"></i>
                            <h3 class="text-base font-bold text-[#1A1A1A]">Comments (<asp:Literal ID="litCommentCount" runat="server" />)</h3>
                        </div>
                        <div class="flex gap-4">
                            <div class="w-10 h-10 rounded-full bg-[#FF8C66] flex items-center justify-center text-white font-bold text-sm shrink-0">
                                <%= CurrentUserName != null && CurrentUserName.Length > 0 ? CurrentUserName[0].ToString().ToUpper() : "?" %>
                            </div>
                            <div class="flex-1">
                                <asp:HiddenField ID="hdnRating" runat="server" Value="0" />
                                <div class="flex gap-1 mb-3" id="starRating">
                                    <span class="star text-2xl cursor-pointer" data-value="1">&#9733;</span>
                                    <span class="star text-2xl cursor-pointer" data-value="2">&#9733;</span>
                                    <span class="star text-2xl cursor-pointer" data-value="3">&#9733;</span>
                                    <span class="star text-2xl cursor-pointer" data-value="4">&#9733;</span>
                                    <span class="star text-2xl cursor-pointer" data-value="5">&#9733;</span>
                                </div>
                                <asp:TextBox ID="txtComment" runat="server" TextMode="MultiLine" Rows="3"
                                    CssClass="w-full p-4 bg-gray-50 border border-gray-200 rounded-xl mb-3 text-sm resize-none focus:outline-none focus:border-[#FF8C66]"
                                    placeholder="Share your thoughts on this course..." />
                                <div class="flex justify-end">
                                    <asp:Button ID="btnAddComment" runat="server" Text="Post Comment &#10148;" OnClick="btnAddComment_Click"
                                        CssClass="px-6 py-2.5 bg-[#2D2D2D] text-white rounded-full text-sm font-bold cursor-pointer border-0" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Comment List -->
                    <asp:Repeater ID="rptComments" runat="server">
                        <ItemTemplate>
                            <div class="flex gap-3 mb-6">
                                <div class="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 text-sm font-bold shrink-0">
                                    <%# Eval("Username").ToString().Length > 0 ? Eval("Username").ToString()[0].ToString().ToUpper() : "?" %>
                                </div>
                                <div class="flex-1">
                                    <div class="flex items-center justify-between mb-1">
                                        <span class="font-bold text-sm text-[#1A1A1A]"><%# Eval("Username") %></span>
                                        <span class="text-xs text-gray-400"><%# ((DateTime)Eval("CreatedDate")).ToString("yyyy-MM-dd") %></span>
                                    </div>
                                    <div class="flex gap-0.5 mb-2"><%# RenderStars((int)Eval("Rating")) %></div>
                                    <p class="text-sm text-gray-600"><%# Server.HtmlEncode(Eval("CommentText").ToString()) %></p>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

            </div>

            <!-- Sidebar -->
            <div class="lg:col-span-1">

                <!-- Overview / Quiz tabs -->
                <div class="flex gap-2 mb-4">
                    <a href="?id=<%= CourseId %>&ch=<%= SelectedChapterId %>&tab=info"
                        class="<%= ActiveTab != "quiz" ? "bg-white shadow-sm text-[#FF8C66] border border-orange-200" : "text-gray-500 hover:text-gray-700" %> flex items-center gap-1.5 px-4 py-2 rounded-xl text-sm font-medium no-underline transition-all">
                        <i data-lucide="layout-list" class="w-4 h-4"></i> Overview
                    </a>
                    <a href="?id=<%= CourseId %>&ch=<%= SelectedChapterId %>&tab=quiz"
                        class="<%= ActiveTab == "quiz" ? "bg-white shadow-sm text-[#FF8C66] border border-orange-200" : "text-gray-500 hover:text-gray-700" %> flex items-center gap-1.5 px-4 py-2 rounded-xl text-sm font-medium no-underline transition-all">
                        <i data-lucide="help-circle" class="w-4 h-4"></i> Quiz
                    </a>
                </div>

                <!-- Overview Panel: Course Content + Chapters -->
                <asp:Panel ID="pnlSidebarOverview" runat="server"
                    CssClass="bg-white rounded-2xl p-6 shadow-sm">
                    <h3 class="text-base font-bold text-[#1A1A1A] mb-4">Course Content</h3>
                    <asp:Repeater ID="rptChapters" runat="server">
                        <ItemTemplate>
                            <a href='<%# GetChapterHref(Container.DataItem) %>'
                               class="block p-3 rounded-xl mb-2 transition-all no-underline <%# GetChapterCss(Container.DataItem) %>">
                                <div class="flex items-center gap-3">
                                    <div class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold shrink-0 <%# GetChapterBadgeCss(Container.DataItem) %>">
                                        <%# GetChapterBadgeContent(Container.DataItem) %>
                                    </div>
                                    <div class="min-w-0">
                                        <div class="text-sm font-medium <%# GetChapterTitleCss(Container.DataItem) %>">
                                            <%# Eval("Title") %>
                                        </div>
                                        <div class="text-xs text-gray-400 mt-0.5 line-clamp-2"><%# Eval("Description") %></div>
                                    </div>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

                <!-- Quiz Panel (sidebar) -->
                <asp:Panel ID="pnlSidebarQuiz" runat="server" Visible="false"
                    CssClass="bg-white rounded-2xl p-6 shadow-sm">
                    <div class="flex items-center justify-between mb-5">
                        <h3 class="text-base font-bold text-[#1A1A1A]">Chapter Quiz</h3>
                        <asp:Panel ID="pnlQuizCounter" runat="server"
                            CssClass="px-3 py-1 bg-orange-50 text-[#FF8C66] text-sm font-bold rounded-full">
                            Q<%= CurrentQuestionIndex + 1 %>/<%= TotalQuestions %>
                        </asp:Panel>
                    </div>
                    <asp:Panel ID="pnlNoQuiz" runat="server">
                        <p class="text-gray-500 text-sm">No quiz questions available for this chapter yet.</p>
                    </asp:Panel>
                    <asp:Panel ID="pnlQuizContent" runat="server" Visible="false">
                        <p class="text-sm font-bold text-[#1A1A1A] mb-4"><asp:Literal ID="litQuizQuestion" runat="server" /></p>
                        <asp:HiddenField ID="hdnSelectedAnswer" runat="server" />
                        <asp:Repeater ID="rptQuizAnswers" runat="server">
                            <ItemTemplate>
                                <div onclick='selectAnswer(this, <%# Eval("AnswerId") %>)'
                                     class="quiz-answer flex items-center gap-3 p-4 mb-3 rounded-xl border border-gray-200 cursor-pointer hover:border-[#FF8C66] transition-all select-none">
                                    <div class="w-5 h-5 rounded-full border-2 border-gray-300 shrink-0 answer-radio flex items-center justify-center"></div>
                                    <span class="text-sm text-gray-700"><%# Eval("AnswerText") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlQuizResult" runat="server" Visible="false" CssClass="mt-3 p-4 rounded-xl text-sm">
                            <asp:Literal ID="litQuizResult" runat="server" />
                        </asp:Panel>
                        <div class="flex items-center justify-between mt-5">
                            <asp:Button ID="btnPrevQuestion" runat="server" Text="Previous" OnClick="btnPrevQuestion_Click"
                                CssClass="px-5 py-2.5 rounded-xl text-sm font-medium text-gray-500 border border-gray-200 bg-white cursor-pointer" />
                            <asp:Button ID="btnNextQuestion" runat="server" Text="Next Question" OnClick="btnNextQuestion_Click"
                                CssClass="px-6 py-2.5 rounded-xl text-sm font-bold bg-[#1A1A1A] text-white cursor-pointer border-0" />
                        </div>
                    </asp:Panel>
                </asp:Panel>

            </div>
        </div>
        <uc:ScoreModal ID="scoreModal" runat="server" />
    </div>

    <script>lucide.createIcons();</script>
    <script>
        // Answer pill selection
        function selectAnswer(el, answerId) {
            document.querySelectorAll('.quiz-answer').forEach(function (a) {
                a.classList.remove('border-[#FF8C66]', 'bg-orange-50');
                var radio = a.querySelector('.answer-radio');
                if (radio) { radio.style.backgroundColor = ''; radio.style.borderColor = ''; }
            });
            el.classList.add('border-[#FF8C66]', 'bg-orange-50');
            var radio = el.querySelector('.answer-radio');
            if (radio) { radio.style.backgroundColor = '#FF8C66'; radio.style.borderColor = '#FF8C66'; }
            var hdn = document.getElementById('<%= hdnSelectedAnswer.ClientID %>');
            if (hdn) hdn.value = answerId;
        }

        // Star rating
        (function () {
            var stars = document.querySelectorAll('#starRating .star');
            var hdnRating = document.getElementById('<%= hdnRating.ClientID %>');
            function setRating(val) {
                if (hdnRating) hdnRating.value = val;
                stars.forEach(function (s) {
                    s.style.color = parseInt(s.getAttribute('data-value')) <= val ? '#FF8C66' : '#D1D5DB';
                });
            }
            setRating(0);
            stars.forEach(function (s) {
                s.addEventListener('click', function () { setRating(parseInt(this.getAttribute('data-value'))); });
            });
        })();
    </script>
</asp:Content>