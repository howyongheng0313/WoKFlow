<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DashboardStats.ascx.cs" Inherits="WokFlow.Controls.DashboardStats" %>

<div class="w-full bg-gradient-to-r from-[#FF8C66] to-[#FFB399] rounded-[2rem] p-8 shadow-xl shadow-orange-500/10 <%= CssClass %>">
    <div class="grid grid-cols-1 <%= GridColsClass %> gap-8 divide-y md:divide-y-0 md:divide-x divide-white/20">
        <asp:Repeater ID="rptStats" runat="server">
            <ItemTemplate>
                <div class='<%# Container.ItemIndex > 0 ? "flex items-center gap-6 pt-6 md:pt-0 md:pl-8" : "flex items-center gap-6" %>'>
                    <div class="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center text-white shadow-inner shadow-white/10 shrink-0">
                        <i data-lucide='<%# Eval("Icon") %>' class="w-8 h-8" style="stroke-width:1.5"></i>
                    </div>
                    <div class="flex flex-col text-white">
                        <span class="text-sm font-medium opacity-90 mb-1"><%# Eval("Label") %></span>
                        <div class="flex items-baseline gap-1">
                            <span class="text-4xl font-bold tracking-tight"><%# Eval("Value") %></span>
                            <asp:PlaceHolder runat="server" Visible='<%# !string.IsNullOrEmpty(Convert.ToString(Eval("SubValue"))) %>'>
                                <span class="text-xl font-medium opacity-80"><%# Eval("SubValue") %></span>
                            </asp:PlaceHolder>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</div>
