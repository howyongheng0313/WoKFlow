
<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CreateCourse.aspx.cs" Inherits="WokFlow.Pages.Sharer.CreateCoursePage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1000px] mx-auto px-6 md:px-12 py-8 mt-4">
        <h1 class="text-3xl font-bold text-[#1A1A1A] mb-8"><%= IsEditing ? "Edit Course" : "Create Course" %></h1>

        <!-- Progress Steps -->
        <div class="flex items-center gap-4 mb-12">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white">1</div>
                <span class="text-sm font-medium text-[#1A1A1A]">Course Details</span>
            </div>
            <div class="h-px bg-gray-300 flex-1"></div>
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold <%= CurrentStep == 2 ? "bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white" : "bg-gray-200 text-gray-500" %>">2</div>
                <span class="text-sm font-medium <%= CurrentStep == 2 ? "text-[#1A1A1A]" : "text-gray-400" %>">Content & Quiz</span>
            </div>
        </div>

        <!-- ===== Step 1: Course Details ===== -->
        <asp:Panel ID="pnlStep1" runat="server">
            <div class="grid grid-cols-1 md:grid-cols-5 gap-8">
                <!-- Left Column: Form Fields (3/5) -->
                <div class="md:col-span-3 space-y-5">
                    <!-- Course Title -->
                    <div class="space-y-1.5">
                        <label class="text-sm text-gray-700 font-medium">Course title</label>
                        <asp:TextBox ID="txtTitle" runat="server" placeholder="Your course Title"
                            CssClass="w-full h-12 px-4 bg-white/60 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66] text-sm" />
                    </div>

                    <!-- Description -->
                    <div class="space-y-1.5">
                        <label class="text-sm text-gray-700 font-medium">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="SingleLine" placeholder="Course description"
                            CssClass="w-full h-12 px-4 bg-white/60 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66] text-sm" />
                    </div>

                    <!-- Cuisine Type -->
                    <div class="space-y-1.5">
                        <label class="text-sm text-gray-700 font-medium">Cuisine Type</label>
                        <asp:DropDownList ID="ddlCuisine" runat="server"
                            CssClass="w-full h-12 px-4 bg-white/60 border border-gray-200 rounded-xl text-sm appearance-none">
                            <asp:ListItem Text="Cuisine" Value="" />
                            <asp:ListItem Text="Chinese" Value="1" />
                            <asp:ListItem Text="Western" Value="2" />
                            <asp:ListItem Text="Japanese" Value="3" />
                            <asp:ListItem Text="Korean" Value="4" />
                        </asp:DropDownList>
                    </div>

                    <!-- Difficulty (Star Rating) -->
                    <div class="space-y-1.5">
                        <label class="text-sm text-gray-700 font-medium">Difficulty</label>
                        <asp:HiddenField ID="hdnDifficulty" runat="server" Value="1" />
                        <div id="starRating" class="flex items-center gap-1 py-2">
                            <span class="star-btn cursor-pointer text-2xl" data-value="1" onclick="setRating(1)">&#9733;</span>
                            <span class="star-btn cursor-pointer text-2xl" data-value="2" onclick="setRating(2)">&#9733;</span>
                            <span class="star-btn cursor-pointer text-2xl" data-value="3" onclick="setRating(3)">&#9733;</span>
                            <span class="star-btn cursor-pointer text-2xl" data-value="4" onclick="setRating(4)">&#9733;</span>
                            <span class="star-btn cursor-pointer text-2xl" data-value="5" onclick="setRating(5)">&#9733;</span>
                        </div>
                    </div>

                    <!-- Course Duration -->
                    <div class="space-y-1.5">
                        <label class="text-sm text-gray-700 font-medium">Course Duration</label>
                        <asp:TextBox ID="txtDuration" runat="server" placeholder="Course duration"
                            CssClass="w-full h-12 px-4 bg-white/60 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66] text-sm" />
                    </div>

                    <!-- Upload Course Image -->
                    <div class="space-y-1.5">
                        <label class="text-sm text-gray-700 font-medium">Upload Course Image</label>
                        <label for="<%= fuCourseImage.ClientID %>"
                            class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-gray-300 rounded-xl bg-white/40 cursor-pointer hover:border-[#FF8C66]/60 transition-colors">
                            <i data-lucide="upload" style="width:28px;height:28px;color:#9CA3AF;"></i>
                            <span class="text-xs text-gray-400 mt-2">Supports JPG, PNG (Max 10MB)</span>
                        </label>
                        <asp:FileUpload ID="fuCourseImage" runat="server" CssClass="hidden" />
                        <asp:Label ID="lblCurrentImage" runat="server" Visible="false"
                            CssClass="text-xs text-gray-500" />
                    </div>
                </div>

                <!-- Right Column: Preview Card (2/5) -->
                <div class="md:col-span-2 hidden md:flex items-start justify-center pt-4">
                    <div class="w-full rounded-2xl p-6 text-white" style="background: linear-gradient(135deg, #FF8C66, #FF6B4A);">
                        <div class="flex justify-center mb-4">
                            <i data-lucide="book-open" style="width:48px;height:48px;color:white;opacity:0.9;"></i>
                        </div>
                        <h3 class="text-lg font-bold text-center mb-2">Start Creating Your Course</h3>
                        <p class="text-sm text-white/80 text-center leading-relaxed">Fill in the basic details to get started. You'll be able to add chapters, videos, and quizzes in the next step.</p>
                    </div>
                </div>
            </div>

            <!-- Next Button -->
            <div class="flex justify-end mt-8">
                <asp:Button ID="btnNext" runat="server" Text="Next ›" OnClick="btnNext_Click"
                    CssClass="px-8 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full font-bold cursor-pointer border-0 shadow-lg shadow-orange-500/20" />
            </div>
        </asp:Panel>

        <!-- ===== Step 2: Content & Quiz ===== -->
        <asp:Panel ID="pnlStep2" runat="server" Visible="false">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">

                <!-- Left Column: Chapters -->
                <div class="space-y-5">
                    <!-- Chapter List Header -->
                    <h3 class="text-lg font-bold text-[#1A1A1A]">Chapters (<%= ChapterCount %>)</h3>

                    <!-- Existing Chapters -->
                    <asp:Repeater ID="rptChapters" runat="server">
                        <ItemTemplate>
                            <div class="border-2 border-[#FF8C66]/40 rounded-xl px-4 py-3 mb-2 bg-white/60">
                                <span class="text-sm font-medium text-[#1A1A1A]">&bull; <%# Eval("Title") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <!-- Add New Chapter Button -->
                    <asp:Button ID="btnShowAddChapter" runat="server" Text="+ Add New Chapter" OnClick="btnAddChapterPlaceholder_Click"
                        CssClass="w-full py-3 border-2 border-dashed border-gray-300 rounded-xl text-sm font-medium text-gray-500 bg-transparent cursor-pointer hover:border-[#FF8C66]/60 hover:text-[#FF8C66] transition-colors" />

                    <!-- Chapter Form -->
                    <div class="space-y-4 mt-4">
                        <div class="space-y-1.5">
                            <label class="text-sm text-gray-700 font-medium">Chapter Name</label>
                            <asp:TextBox ID="txtChapterTitle" runat="server" placeholder="e.g. Chapter 1: Introduction"
                                CssClass="w-full h-12 px-4 bg-white/60 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                        </div>
                        <div class="space-y-1.5">
                            <label class="text-sm text-gray-700 font-medium">Chapter Description</label>
                            <asp:TextBox ID="txtChapterDescription" runat="server" TextMode="MultiLine" Rows="3"
                                placeholder="Describe what students will learn..."
                                CssClass="w-full p-4 bg-white/60 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                        </div>
                        <div class="space-y-1.5">
                            <label class="text-sm text-gray-700 font-medium">Upload Video</label>
                            <label for="<%= fuChapterVideo.ClientID %>"
                                class="flex flex-col items-center justify-center w-full h-28 border-2 border-dashed border-gray-300 rounded-xl bg-white/40 cursor-pointer hover:border-[#FF8C66]/60 transition-colors">
                                <i data-lucide="upload" style="width:28px;height:28px;color:#9CA3AF;"></i>
                                <span class="text-xs text-gray-400 mt-2">Click to upload video</span>
                            </label>
                            <asp:FileUpload ID="fuChapterVideo" runat="server" CssClass="hidden" />
                            <!-- Fallback: video URL input -->
                            <asp:TextBox ID="txtVideoUrl" runat="server" placeholder="Or paste video URL (e.g. https://youtube.com/...)"
                                CssClass="w-full h-10 px-4 bg-white/60 border border-gray-200 rounded-xl text-xs mt-1 focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                        </div>
                    </div>
                </div>

                <!-- Right Column: Quiz -->
                <div class="space-y-5">
                    <!-- Quiz Header -->
                    <div class="flex items-center justify-between">
                        <h3 class="text-lg font-bold text-[#1A1A1A]">Create Quiz</h3>
                        <span class="text-xs text-gray-400">For: <asp:Label ID="lblQuizChapter" runat="server" Text="Untitled Chapter" CssClass="text-gray-400" /></span>
                    </div>

                    <!-- Chapter Selector for Quiz -->
                    <asp:DropDownList ID="ddlQuizChapter" runat="server"
                        CssClass="w-full h-12 px-4 bg-white/60 border border-gray-200 rounded-xl text-sm appearance-none"
                        AutoPostBack="false">
                        <asp:ListItem Text="Select chapter..." Value="" />
                    </asp:DropDownList>

                    <!-- Quiz Questions Area -->
                    <div class="border-2 border-dashed border-gray-200 rounded-xl p-8 flex flex-col items-center justify-center min-h-[160px] bg-white/30">
                        <asp:Panel ID="pnlNoQuestions" runat="server">
                            <div class="flex flex-col items-center gap-2">
                                <i data-lucide="help-circle" style="width:32px;height:32px;color:#D1D5DB;"></i>
                                <p class="text-sm text-gray-400 text-center">No questions added for this chapter yet.</p>
                            </div>
                        </asp:Panel>

                        <!-- Quiz question list (shown when questions exist) -->
                        <asp:Panel ID="pnlQuizQuestions" runat="server" Visible="false" CssClass="w-full space-y-3">
                            <asp:Repeater ID="rptQuizPreview" runat="server">
                                <ItemTemplate>
                                    <div class="bg-white/60 rounded-lg p-3 text-sm text-gray-700">
                                        <span class="font-medium">Q<%# Container.ItemIndex + 1 %>:</span> <%# Eval("QuestionText") %>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                    </div>

                    <!-- Add Question Form (collapsible) -->
                    <asp:Panel ID="pnlAddQuestion" runat="server" Visible="false" CssClass="space-y-3 border border-gray-200 rounded-xl p-4 bg-white/40">
                        <div class="space-y-1.5">
                            <label class="text-xs text-gray-700 font-medium">Question</label>
                            <asp:TextBox ID="txtQuestionText" runat="server" placeholder="Enter your quiz question"
                                CssClass="w-full h-10 px-4 bg-white/60 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                        </div>
                        <div class="grid grid-cols-2 gap-2">
                            <asp:TextBox ID="txtAnswer1" runat="server" placeholder="Answer option 1"
                                CssClass="h-10 px-3 bg-white/60 border border-gray-200 rounded-xl text-sm" />
                            <asp:TextBox ID="txtAnswer2" runat="server" placeholder="Answer option 2"
                                CssClass="h-10 px-3 bg-white/60 border border-gray-200 rounded-xl text-sm" />
                            <asp:TextBox ID="txtAnswer3" runat="server" placeholder="Answer option 3"
                                CssClass="h-10 px-3 bg-white/60 border border-gray-200 rounded-xl text-sm" />
                            <asp:TextBox ID="txtAnswer4" runat="server" placeholder="Answer option 4"
                                CssClass="h-10 px-3 bg-white/60 border border-gray-200 rounded-xl text-sm" />
                        </div>
                        <div class="flex items-center gap-3">
                            <label class="text-xs font-medium text-gray-700 shrink-0">Correct answer:</label>
                            <asp:DropDownList ID="ddlCorrectAnswer" runat="server"
                                CssClass="h-9 px-3 bg-white/60 border border-gray-200 rounded-xl text-xs">
                                <asp:ListItem Text="Answer 1" Value="1" />
                                <asp:ListItem Text="Answer 2" Value="2" />
                                <asp:ListItem Text="Answer 3" Value="3" />
                                <asp:ListItem Text="Answer 4" Value="4" />
                            </asp:DropDownList>
                        </div>
                    </asp:Panel>

                    <!-- Add Question Button -->
                    <asp:Button ID="btnToggleQuestion" runat="server" Text="+ Add Question" OnClick="btnToggleQuestion_Click"
                        CssClass="w-full py-3 border-2 border-dashed border-gray-300 rounded-xl text-sm font-medium text-gray-500 bg-transparent cursor-pointer hover:border-[#FF8C66]/60 hover:text-[#FF8C66] transition-colors" />
                </div>
            </div>

            <!-- Bottom Buttons -->
            <div class="flex justify-between mt-10">
                <asp:Button ID="btnBack" runat="server" Text="← Back" OnClick="btnBack_Click"
                    CssClass="px-8 py-3 border border-gray-300 rounded-full font-medium cursor-pointer bg-white text-gray-700 hover:bg-gray-50 transition-colors" />
                <asp:Button ID="btnSaveCourse" runat="server" Text="✓ Submit Course" OnClick="btnSaveCourse_Click"
                    CssClass="px-8 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full font-bold cursor-pointer border-0 shadow-lg shadow-orange-500/20" />
            </div>
        </asp:Panel>
    </div>

    <!-- Star Rating Script -->
    <script>
        function setRating(value) {
            var hidden = document.getElementById('<%= hdnDifficulty.ClientID %>');
            if (hidden) hidden.value = value;
            var stars = document.querySelectorAll('#starRating .star-btn');
            stars.forEach(function (star) {
                var sv = parseInt(star.getAttribute('data-value'));
                star.style.color = sv <= value ? '#FF8C66' : '#D1D5DB';
            });
        }
        // Initialize stars on page load
        document.addEventListener('DOMContentLoaded', function () {
            var hidden = document.getElementById('<%= hdnDifficulty.ClientID %>');
            if (hidden) {
                setRating(parseInt(hidden.value) || 1);
            }
        });
    </script>

    <script>lucide.createIcons();</script>
</asp:Content>
