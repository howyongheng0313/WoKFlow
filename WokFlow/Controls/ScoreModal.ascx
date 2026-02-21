<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ScoreModal.ascx.cs" Inherits="WokFlow.Controls.ScoreModal" %>

<div id="scoreModal_<%= ClientID %>" class="fixed inset-0 z-50 flex items-center justify-center bg-black/20 backdrop-blur-sm p-4" style="display:none;">
    <div class="bg-white/90 backdrop-blur-xl rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] flex flex-col overflow-hidden border border-white/60">
        <div class="p-8 border-b border-gray-100 flex justify-between items-center">
            <h2 class="text-2xl font-bold text-[#1A1A1A]">
                <asp:Literal ID="litModalTitle" runat="server" Text="Quiz Score Details" />
            </h2>
            <button type="button" onclick="closeScoreModal_<%= ClientID %>()" class="text-gray-400 hover:text-[#1A1A1A]">
                <i data-lucide="chevron-up" class="w-6 h-6"></i>
            </button>
        </div>

        <div class="overflow-auto flex-1 p-8">
            <div class="grid grid-cols-12 text-sm font-medium text-gray-500 mb-6 px-4">
                <div class="col-span-3">Sections</div>
                <div class="col-span-3">Date Completed</div>
                <div class="col-span-4">Scores</div>
                <div class="col-span-2 text-right">Status</div>
            </div>

            <div class="space-y-2">
                <asp:Repeater ID="rptScores" runat="server">
                    <ItemTemplate>
                        <div class="grid grid-cols-12 items-center py-5 px-4 bg-white/50 border border-white/60 rounded-xl hover:shadow-sm transition-shadow">
                            <div class="col-span-3 flex items-center gap-3">
                                <span class="font-semibold text-[#1A1A1A] pl-2"><%# Eval("Name") %></span>
                            </div>
                            <div class="col-span-3 text-gray-500 font-medium"><%# Eval("Date") %></div>
                            <div class="col-span-4 flex items-center gap-4">
                                <div class="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden">
                                    <div class="h-full bg-gradient-to-r from-[#FF8C66] to-[#FFB399] rounded-full" <%# GetScoreWidth(Eval("Score")) %>></div>
                                </div>
                                <span class="text-sm font-bold text-[#1A1A1A] min-w-[3rem]"><%# Eval("Score") %>%</span>
                            </div>
                            <div class="col-span-2 text-right">
                                <span class="text-sm font-medium text-gray-500 mr-4"><%# Eval("Status") %></span>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <div class="p-6 border-t border-gray-100 flex items-center justify-between">
            <span class="text-sm text-gray-500 font-medium">
                <asp:Literal ID="litPagination" runat="server" Text="1 - 8 of 40 items" />
            </span>
            <div class="flex gap-3">
                <button type="button" class="px-4 py-2 rounded-lg border border-gray-200 text-sm font-medium text-gray-600 hover:bg-white">Previous</button>
                <button type="button" class="px-4 py-2 rounded-lg border border-gray-200 text-sm font-medium text-gray-600 hover:bg-white">Next</button>
            </div>
        </div>
    </div>
</div>

<script>
function openScoreModal_<%= ClientID %>() {
    document.getElementById('scoreModal_<%= ClientID %>').style.display = '';
    if (typeof lucide !== 'undefined') lucide.createIcons();
}
function closeScoreModal_<%= ClientID %>() {
    document.getElementById('scoreModal_<%= ClientID %>').style.display = 'none';
    }
</script>