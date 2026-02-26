
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
                        <label id="lblImageDropZone" for="<%= fuCourseImage.ClientID %>"
                            class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-gray-300 rounded-xl bg-white/40 cursor-pointer hover:border-[#FF8C66]/60 transition-colors">
                            <div id="imageUploadDefault" class="flex flex-col items-center">
                                <i data-lucide="upload" style="width:28px;height:28px;color:#9CA3AF;"></i>
                                <span class="text-xs text-gray-400 mt-2">Supports JPG, PNG (Max 10MB)</span>
                            </div>
                            <div id="imageUploadPreview" class="hidden flex-col items-center justify-center gap-2 w-full h-full px-4">
                                <img id="imagePreviewThumb" src="" alt="Preview" class="max-h-16 max-w-[120px] rounded-lg object-cover" />
                                <span id="imageFileName" class="text-xs text-gray-600 font-medium truncate max-w-full"></span>
                            </div>
                        </label>
                        <button type="button" id="btnClearImage" class="hidden mt-1 text-xs text-red-400 hover:text-red-600 transition-colors cursor-pointer bg-transparent border-0 underline">Remove image</button>
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

            <!-- Validation Error -->
            <asp:Label ID="lblStep1Error" runat="server" Visible="false"
                CssClass="block mt-6 p-4 bg-red-50 border border-red-200 rounded-xl text-sm text-red-600" />

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

                    <!-- Chapter Cards (clickable, with selection state) -->
                    <asp:Repeater ID="rptChapters" runat="server" OnItemCommand="rptChapters_ItemCommand">
                        <ItemTemplate>
                            <div class="mb-2">
                                <asp:Button ID="btnSelectChapter" runat="server"
                                    CommandName="SelectChapter"
                                    CommandArgument='<%# Eval("Index") %>'
                                    Text='<%# "● " + Eval("Title") %>'
                                    CssClass='<%# (bool)Eval("IsSelected")
                                        ? "w-full text-left px-4 py-3 border-2 border-[#FF8C66] rounded-xl bg-white/80 text-sm font-semibold text-[#FF6B4A] cursor-pointer"
                                        : "w-full text-left px-4 py-3 border-2 border-gray-200 rounded-xl bg-white/60 text-sm font-medium text-[#1A1A1A] cursor-pointer hover:border-[#FF8C66]/50 transition-colors" %>'
                                    UseSubmitBehavior="false" />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <!-- Add New Chapter Button -->
                    <asp:Button ID="btnAddChapterNew" runat="server" Text="+ Add New Chapter" OnClick="btnAddChapter_Click"
                        CssClass="w-full py-3 border-2 border-dashed border-gray-300 rounded-xl text-sm font-medium text-gray-500 bg-transparent cursor-pointer hover:border-[#FF8C66]/60 hover:text-[#FF8C66] transition-colors" />

                    <!-- Chapter Form (always visible, edits the selected chapter) -->
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
                            <label id="lblVideoDropZone" for="<%= fuChapterVideo.ClientID %>"
                                class="flex flex-col items-center justify-center w-full h-28 border-2 border-dashed border-gray-300 rounded-xl bg-white/40 cursor-pointer hover:border-[#FF8C66]/60 transition-colors">
                                <div id="videoUploadDefault" class="flex flex-col items-center">
                                    <i data-lucide="upload" style="width:28px;height:28px;color:#9CA3AF;"></i>
                                    <span class="text-xs text-gray-400 mt-2">Supports MP4 (Max 50MB)</span>
                                </div>
                                <div id="videoUploadPreview" class="hidden flex-col items-center justify-center gap-1">
                                    <i data-lucide="film" style="width:28px;height:28px;color:#FF8C66;"></i>
                                    <span id="videoFileName" class="text-xs text-gray-600 font-medium truncate max-w-full"></span>
                                    <span id="videoFileSize" class="text-xs text-gray-400"></span>
                                </div>
                            </label>
                            <asp:FileUpload ID="fuChapterVideo" runat="server" CssClass="hidden" accept=".mp4" />
                            <button type="button" id="btnClearVideo" class="hidden mt-1 text-xs text-red-400 hover:text-red-600 transition-colors cursor-pointer bg-transparent border-0 underline">Remove video</button>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Quiz -->
                <div class="space-y-5">
                    <!-- Quiz Header -->
                    <div class="flex items-center justify-between">
                        <h3 class="text-lg font-bold text-[#1A1A1A]">Create Quiz</h3>
                        <span class="text-xs text-gray-400 px-3 py-1 bg-white/60 rounded-full border border-gray-200">
                            For: <asp:Label ID="lblQuizChapter" runat="server" Text="Untitled Chapter" CssClass="font-medium text-gray-600" />
                        </span>
                    </div>

                    <!-- Question Pagination -->
                    <asp:Panel ID="pnlQuizPagination" runat="server" Visible="false">
                        <div class="flex items-center justify-between bg-white/60 border border-gray-200 rounded-xl px-4 py-2">
                            <asp:Button ID="btnPrevQuestion" runat="server" Text="‹"
                                OnClick="btnPrevQuestion_Click"
                                CssClass="w-8 h-8 rounded-lg text-gray-500 hover:bg-gray-100 disabled:opacity-30 border-0 bg-transparent cursor-pointer font-bold text-lg"
                                UseSubmitBehavior="false" />
                            <asp:Label ID="lblQuestionPager" runat="server" Text="Question 1 of 1"
                                CssClass="text-sm font-medium text-gray-600" />
                            <div class="flex items-center gap-1">
                                <asp:Button ID="btnNextQuestion" runat="server" Text="›"
                                    OnClick="btnNextQuestion_Click"
                                    CssClass="w-8 h-8 rounded-lg text-gray-500 hover:bg-gray-100 disabled:opacity-30 border-0 bg-transparent cursor-pointer font-bold text-lg"
                                    UseSubmitBehavior="false" />
                                <asp:Button ID="btnDeleteQuestion" runat="server" Text="✕"
                                    OnClick="btnDeleteQuestion_Click"
                                    CssClass="w-8 h-8 rounded-lg text-red-400 hover:bg-red-50 border-0 bg-transparent cursor-pointer text-sm"
                                    UseSubmitBehavior="false"
                                    OnClientClick="return confirm('Delete this question?');" />
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- No Questions Placeholder -->
                    <asp:Panel ID="pnlNoQuestions" runat="server">
                        <div class="border-2 border-dashed border-gray-200 rounded-xl p-8 flex flex-col items-center justify-center min-h-[120px] bg-white/30">
                            <i data-lucide="help-circle" style="width:28px;height:28px;color:#D1D5DB;"></i>
                            <p class="text-sm text-gray-400 mt-2 text-center">No questions yet. Click "+ Add Question" below.</p>
                        </div>
                    </asp:Panel>

                    <!-- Question Edit Form (visible when questions exist) -->
                    <asp:Panel ID="pnlQuizQuestions" runat="server" Visible="false"
                        CssClass="space-y-3 border border-gray-200 rounded-xl p-4 bg-white/40">
                        <asp:HiddenField ID="hdnCorrectAnswer" runat="server" Value="0" />

                        <div class="space-y-1.5">
                            <label class="text-xs text-gray-700 font-medium">Question</label>
                            <asp:TextBox ID="txtQuestionText" runat="server" placeholder="Type your question here..."
                                CssClass="w-full h-10 px-4 bg-white/60 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                        </div>

                        <div class="space-y-2">
                            <label class="text-xs text-gray-700 font-medium uppercase tracking-wide">Answers</label>

                            <div class="flex items-center gap-2">
                                <input type="radio" name="correctAnswer" value="0" class="correct-radio w-4 h-4 accent-[#FF8C66] cursor-pointer"
                                    onclick="setCorrectAnswer(0)" />
                                <asp:TextBox ID="txtAnswer1" runat="server" placeholder="Answer option 1"
                                    CssClass="flex-1 h-10 px-3 bg-white/60 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                            </div>
                            <div class="flex items-center gap-2">
                                <input type="radio" name="correctAnswer" value="1" class="correct-radio w-4 h-4 accent-[#FF8C66] cursor-pointer"
                                    onclick="setCorrectAnswer(1)" />
                                <asp:TextBox ID="txtAnswer2" runat="server" placeholder="Answer option 2"
                                    CssClass="flex-1 h-10 px-3 bg-white/60 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                            </div>
                            <div class="flex items-center gap-2">
                                <input type="radio" name="correctAnswer" value="2" class="correct-radio w-4 h-4 accent-[#FF8C66] cursor-pointer"
                                    onclick="setCorrectAnswer(2)" />
                                <asp:TextBox ID="txtAnswer3" runat="server" placeholder="Answer option 3"
                                    CssClass="flex-1 h-10 px-3 bg-white/60 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                            </div>
                            <div class="flex items-center gap-2">
                                <input type="radio" name="correctAnswer" value="3" class="correct-radio w-4 h-4 accent-[#FF8C66] cursor-pointer"
                                    onclick="setCorrectAnswer(3)" />
                                <asp:TextBox ID="txtAnswer4" runat="server" placeholder="Answer option 4"
                                    CssClass="flex-1 h-10 px-3 bg-white/60 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- Add Question Button -->
                    <asp:Button ID="btnAddQuestion" runat="server" Text="+ Add Question" OnClick="btnAddQuestion_Click"
                        CssClass="w-full py-3 border-2 border-dashed border-[#FF8C66]/40 rounded-xl text-sm font-medium text-[#FF8C66] bg-transparent cursor-pointer hover:border-[#FF8C66] hover:bg-[#FF8C66]/5 transition-colors" />
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

    <!-- Star Rating Script (Step 1) -->
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

        // Radio button correct-answer sync (Step 2)
        function setCorrectAnswer(index) {
            var hidden = document.getElementById('<%= hdnCorrectAnswer.ClientID %>');
            if (hidden) hidden.value = index;
        }

        function initCorrectAnswerRadios() {
            var hidden = document.getElementById('<%= hdnCorrectAnswer.ClientID %>');
            if (!hidden) return;
            var correctIdx = parseInt(hidden.value, 10) || 0;
            var radios = document.querySelectorAll('input.correct-radio');
            radios.forEach(function (r) {
                r.checked = (parseInt(r.value, 10) === correctIdx);
            });
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function () {
            // Star rating init
            var diffHidden = document.getElementById('<%= hdnDifficulty.ClientID %>');
            if (diffHidden) {
                setRating(parseInt(diffHidden.value) || 1);
            }
            // Radio button init
            initCorrectAnswerRadios();
        });
    </script>

    <!-- File Upload Preview & Drag-and-Drop -->
    <script>
    (function () {
        var imageInputId = '<%= fuCourseImage.ClientID %>';
        var videoInputId = '<%= fuChapterVideo.ClientID %>';

        var imageInput = document.getElementById(imageInputId);
        var videoInput = document.getElementById(videoInputId);

        var imageDropZone = document.getElementById('lblImageDropZone');
        var videoDropZone = document.getElementById('lblVideoDropZone');

        var imageDefault = document.getElementById('imageUploadDefault');
        var imagePreview = document.getElementById('imageUploadPreview');
        var imageThumb = document.getElementById('imagePreviewThumb');
        var imageNameSpan = document.getElementById('imageFileName');
        var btnClearImage = document.getElementById('btnClearImage');

        var videoDefault = document.getElementById('videoUploadDefault');
        var videoPreview = document.getElementById('videoUploadPreview');
        var videoNameSpan = document.getElementById('videoFileName');
        var videoSizeSpan = document.getElementById('videoFileSize');
        var btnClearVideo = document.getElementById('btnClearVideo');

        function formatSize(bytes) {
            if (bytes < 1024) return bytes + ' B';
            if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
            return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
        }

        // Course Image: onchange
        if (imageInput) {
            imageInput.addEventListener('change', function () {
                if (this.files && this.files[0]) {
                    var file = this.files[0];
                    imageNameSpan.textContent = file.name;

                    var reader = new FileReader();
                    reader.onload = function (e) {
                        imageThumb.src = e.target.result;
                    };
                    reader.readAsDataURL(file);

                    imageDefault.classList.add('hidden');
                    imagePreview.classList.remove('hidden');
                    imagePreview.style.display = 'flex';
                    btnClearImage.classList.remove('hidden');

                    imageDropZone.classList.remove('border-gray-300');
                    imageDropZone.classList.add('border-[#FF8C66]');
                }
            });
        }

        // Chapter Video: onchange
        if (videoInput) {
            videoInput.addEventListener('change', function () {
                if (this.files && this.files[0]) {
                    var file = this.files[0];
                    videoNameSpan.textContent = file.name;
                    videoSizeSpan.textContent = formatSize(file.size);

                    videoDefault.classList.add('hidden');
                    videoPreview.classList.remove('hidden');
                    videoPreview.style.display = 'flex';
                    btnClearVideo.classList.remove('hidden');

                    videoDropZone.classList.remove('border-gray-300');
                    videoDropZone.classList.add('border-[#FF8C66]');

                    if (typeof lucide !== 'undefined') lucide.createIcons();
                }
            });
        }

        // Clear handlers
        if (btnClearImage) {
            btnClearImage.addEventListener('click', function (e) {
                e.preventDefault();
                imageInput.value = '';
                imageThumb.src = '';
                imageNameSpan.textContent = '';
                imageDefault.classList.remove('hidden');
                imagePreview.classList.add('hidden');
                imagePreview.style.display = '';
                btnClearImage.classList.add('hidden');
                imageDropZone.classList.add('border-gray-300');
                imageDropZone.classList.remove('border-[#FF8C66]');
            });
        }

        if (btnClearVideo) {
            btnClearVideo.addEventListener('click', function (e) {
                e.preventDefault();
                videoInput.value = '';
                videoNameSpan.textContent = '';
                videoSizeSpan.textContent = '';
                videoDefault.classList.remove('hidden');
                videoPreview.classList.add('hidden');
                videoPreview.style.display = '';
                btnClearVideo.classList.add('hidden');
                videoDropZone.classList.add('border-gray-300');
                videoDropZone.classList.remove('border-[#FF8C66]');
            });
        }

        // Drag-and-drop
        function setupDragDrop(dropZone, fileInput) {
            if (!dropZone || !fileInput) return;

            ['dragenter', 'dragover'].forEach(function (evt) {
                dropZone.addEventListener(evt, function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    dropZone.classList.add('border-[#FF8C66]', 'bg-[#FF8C66]/5');
                });
            });

            ['dragleave', 'drop'].forEach(function (evt) {
                dropZone.addEventListener(evt, function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    dropZone.classList.remove('bg-[#FF8C66]/5');
                    if (evt === 'dragleave') {
                        dropZone.classList.remove('border-[#FF8C66]');
                        dropZone.classList.add('border-gray-300');
                    }
                });
            });

            dropZone.addEventListener('drop', function (e) {
                var files = e.dataTransfer.files;
                if (files.length > 0) {
                    try {
                        var dt = new DataTransfer();
                        dt.items.add(files[0]);
                        fileInput.files = dt.files;
                    } catch (err) {
                        fileInput.files = files;
                    }
                    fileInput.dispatchEvent(new Event('change', { bubbles: true }));
                }
            });
        }

        setupDragDrop(imageDropZone, imageInput);
        setupDragDrop(videoDropZone, videoInput);
    })();
    </script>

    <script>lucide.createIcons();</script>
</asp:Content>