<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="StatsOverview.ascx.cs" Inherits="WokFlow.Controls.StatsOverview" %>

<div class="w-full bg-gradient-to-br from-[#FF8C66] to-[#FFB399] rounded-[2rem] p-8 md:p-10 text-white shadow-xl shadow-orange-200/50 mb-12 relative overflow-hidden">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-<%= Columns %> gap-8 relative z-10">
        <asp:Repeater ID="rptStats" runat="server">
            <ItemTemplate>
                <div class="flex items-center gap-6">
                    <div class="w-16 h-16 bg-white/20 rounded-2xl flex items-center justify-center text-white shadow-sm backdrop-blur-sm shrink-0">
                        <i data-lucide='<%# Eval("Icon") %>' class="w-7 h-7"></i>
                    </div>
                    <div>
                        <div class="text-sm font-medium text-white/80 mb-1"><%# Eval("Label") %></div>
                        <div class="text-3xl font-bold flex items-baseline gap-1">
                            <%# Eval("Value") %>
                            <asp:PlaceHolder runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("SubValue")?.ToString()) %>'>
                                <span class="text-lg font-normal opacity-80"><%# Eval("SubValue") %></span>
                            </asp:PlaceHolder>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</div>