<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="WokFlow.Pages.Learner.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <!-- Search and Filters -->
        <div class="flex flex-col md:flex-row gap-4 mb-8">
            <!-- Search -->
            <div class="relative flex-1 max-w-[300px]">
                <asp:TextBox ID="txtSearch" runat="server" placeholder="Search courses..."
                    CssClass="w-full h-11 pl-10 pr-4 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>

            <!-- Filters -->
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
                    <div class="glass-panel rounded-2xl overflow-hidden hover:shadow-lg transition-all">
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

    <script>lucide.createIcons();</script>
</asp:Content>