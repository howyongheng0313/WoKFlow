
<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CreateCourse.aspx.cs" Inherits="WokFlow.Pages.Sharer.CreateCoursePage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1000px] mx-auto px-6 md:px-12 py-8 mt-4">
        <h1 class="text-3xl font-bold text-[#1A1A1A] mb-8"><%= IsEditing ? "Edit Course" : "Create Course" %></h1>

        <!-- Progress Steps -->
        <div class="flex items-center gap-4 mb-12">
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold <%= CurrentStep == 1 ? "bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white" : "bg-gray-200 text-gray-500" %>">1</div>
                <span class="text-sm font-medium <%= CurrentStep == 1 ? "text-[#1A1A1A]" : "text-gray-400" %>">Course Details</span>
            </div>
            <div class="h-px bg-gray-300 flex-1"></div>
            <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold <%= CurrentStep == 2 ? "bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white" : "bg-gray-200 text-gray-500" %>">2</div>
                <span class="text-sm font-medium <%= CurrentStep == 2 ? "text-[#1A1A1A]" : "text-gray-400" %>">Content & Quiz</span>
            </div>
        </div>

        <!-- ===== Step 1: Course Details ===== -->
        <asp:Panel ID="pnlStep1" runat="server">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div class="space-y-6">
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium">Course Title</label>
                        <asp:TextBox ID="txtTitle" runat="server"
                            CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                    </div>
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4"
                            CssClass="w-full p-4 bg-white/60 border border-white/60 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                    </div>
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium">Cuisine Type</label>
                        <asp:DropDownList ID="ddlCuisine" runat="server"
                            CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl">
                            <asp:ListItem Text="Chinese" Value="1" />
                            <asp:ListItem Text="Western" Value="2" />
                            <asp:ListItem Text="Japanese" Value="3" />
                            <asp:ListItem Text="Korean" Value="4" />
                        </asp:DropDownList>
                    </div>
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium">Difficulty (1-5)</label>
                        <asp:DropDownList ID="ddlDifficulty" runat="server"
                            CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl">
                            <asp:ListItem Text="1 - Beginner" Value="1" />
                            <asp:ListItem Text="2 - Easy" Value="2" />
                            <asp:ListItem Text="3 - Intermediate" Value="3" />
                            <asp:ListItem Text="4 - Advanced" Value="4" />
                            <asp:ListItem Text="5 - Expert" Value="5" />
                        </asp:DropDownList>
                    </div>
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium">Duration</label>
                        <asp:TextBox ID="txtDuration" runat="server" placeholder="e.g. 45 mins"
                            CssClass="w-full h-14 px-4 bg-white/60 border border-white/60 rounded-xl" />
                    </div>
                    <div class="space-y-2">
                        <label class="text-gray-700 font-medium">Course Image</label>
                        <asp:FileUpload ID="fuCourseImage" runat="server"
                            CssClass="w-full h-14 border-2 border-dashed border-[#FF8C66]/50 bg-orange-50/50 rounded-xl p-2" />
                        <asp:Label ID="lblCurrentImage" runat="server" Visible="false"
                            CssClass="text-xs text-gray-500" />
                    </div>
                </div>
                <div class="hidden md:flex items-center justify-center">
                    <div class="w-64 h-64 bg-gradient-to-br from-[#FF8C66]/20 to-[#FFB399]/10 rounded-2xl flex items-center justify-center">
                        <i data-lucide="chef-hat" style="width:64px;height:64px;color:#FF8C66;opacity:0.5;"></i>
                    </div>
                </div>
            </div>
            <div class="flex justify-end mt-8">
                <asp:Button ID="btnNext" runat="server" Text="Next: Content & Quiz" OnClick="btnNext_Click"
                    CssClass="px-8 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full font-bold cursor-pointer border-0 shadow-lg shadow-orange-500/20" />
            </div>
        </asp:Panel>

        <!-- ===== Step 2: Content & Quiz ===== -->
        <asp:Panel ID="pnlStep2" runat="server" Visible="false">

            <!-- Add Chapter Form -->
            <div class="glass-panel rounded-2xl p-6 mb-6">
                <h3 class="text-lg font-bold text-[#1A1A1A] mb-4">Add Chapter</h3>

                <!-- Chapter Info -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <asp:TextBox ID="txtChapterTitle" runat="server" placeholder="Chapter title"
                        CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
                    <asp:TextBox ID="txtChapterDescription" runat="server" placeholder="Chapter description"
                        CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
                </div>
                <div class="mb-4">
                    <asp:TextBox ID="txtVideoUrl" runat="server" placeholder="Video URL (e.g. https://www.youtube.com/watch?v=...)"
                        CssClass="w-full h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
                </div>

                <!-- Quiz Section -->
                <div class="border-t border-white/40 pt-4 mt-2 space-y-3">
                    <p class="text-sm font-bold text-gray-700">Chapter Quiz Question</p>
                    <asp:TextBox ID="txtQuestionText" runat="server" placeholder="Quiz question for this chapter"
                        CssClass="w-full h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <asp:TextBox ID="txtAnswer1" runat="server" placeholder="Answer option 1"
                            CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
                        <asp:TextBox ID="txtAnswer2" runat="server" placeholder="Answer option 2"
                            CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
                        <asp:TextBox ID="txtAnswer3" runat="server" placeholder="Answer option 3"
                            CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
                        <asp:TextBox ID="txtAnswer4" runat="server" placeholder="Answer option 4"
                            CssClass="h-12 px-4 bg-white/60 border border-white/60 rounded-xl" />
                    </div>

                    <div class="flex items-center gap-3">
                        <label class="text-sm font-medium text-gray-700 shrink-0">Correct answer:</label>
                        <asp:DropDownList ID="ddlCorrectAnswer" runat="server"
                            CssClass="h-10 px-4 bg-white/60 border border-white/60 rounded-xl text-sm">
                            <asp:ListItem Text="Answer 1" Value="1" />
                            <asp:ListItem Text="Answer 2" Value="2" />
                            <asp:ListItem Text="Answer 3" Value="3" />
                            <asp:ListItem Text="Answer 4" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>

                <asp:Button ID="btnAddChapter" runat="server" Text="+ Add Chapter" OnClick="btnAddChapter_Click"
                    CssClass="mt-4 px-6 py-2 border border-[#FF8C66] text-[#FF8C66] rounded-full font-medium cursor-pointer bg-transparent" />

                <!-- Chapter List -->
                <asp:Repeater ID="rptChapters" runat="server">
                    <ItemTemplate>
                        <div class="mt-3 bg-white/60 rounded-xl p-4 space-y-1">
                            <div class="flex items-center justify-between">
                                <span class="text-sm font-bold text-[#1A1A1A]">Chapter <%# Container.ItemIndex + 1 %>: <%# Eval("Title") %></span>
                            </div>
                            <p class="text-xs text-gray-500"><%# Eval("Description") %></p>
                            <p class="text-xs text-gray-400">
                                <span class="font-medium">Video:</span>
                                <%# string.IsNullOrEmpty(Eval("VideoUrl") as string) ? "<em>No video</em>" : Eval("VideoUrl") %>
                            </p>
                            <p class="text-xs"><%# GetQuizPreview(Eval("Question")) %></p>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div class="flex justify-between mt-8">
                <asp:Button ID="btnBack" runat="server" Text="Back" OnClick="btnBack_Click"
                    CssClass="px-8 py-3 border border-gray-400 rounded-full font-medium cursor-pointer bg-white" />
                <asp:Button ID="btnSaveCourse" runat="server" Text="Save Course" OnClick="btnSaveCourse_Click"
                    CssClass="px-8 py-3 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white rounded-full font-bold cursor-pointer border-0 shadow-lg shadow-orange-500/20" />
            </div>
        </asp:Panel>
    </div>

    <script>lucide.createIcons();</script>
</asp:Content>
