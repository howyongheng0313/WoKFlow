<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SharerRegistration.aspx.cs" Inherits="WokFlow.Pages.Admin.SharerRegistration" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-[1400px] mx-auto px-6 md:px-12 py-8 mt-4">
        <h1 class="text-2xl font-bold text-[#1A1A1A] mb-6">Sharer Registration</h1>

        <!-- Filters -->
        <div class="flex gap-3 mb-4">
            <div class="relative flex-1 max-w-[300px]">
                <asp:TextBox ID="txtSearch" runat="server" placeholder="Search by username..."
                    CssClass="w-full h-11 pl-10 pr-4 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#FF8C66]/20 focus:border-[#FF8C66]" />
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </div>
            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"
                CssClass="h-11 px-4 bg-white border border-gray-200 rounded-xl text-sm text-gray-600 cursor-pointer appearance-none">
                <asp:ListItem Text="Pending" Value="Pending" />
                <asp:ListItem Text="Accepted" Value="Accepted" />
                <asp:ListItem Text="Rejected" Value="Rejected" />
                <asp:ListItem Text="All Status" Value="" />
            </asp:DropDownList>
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="Filter_Changed"
                CssClass="hidden" />
        </div>

        <!-- Table -->
        <div class="bg-white rounded-2xl shadow-[0_2px_16px_rgba(0,0,0,0.06)] border border-gray-100/60 overflow-hidden">
            <table class="w-full">
                <thead>
                    <tr class="border-b border-gray-200">
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Username</th>
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Register Date</th>
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Proof of Skills</th>
                        <th class="text-left py-4 px-8 text-sm font-bold text-gray-800">Status</th>
                        <th class="py-4 px-4 text-sm font-bold text-gray-800"></th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptRegistrations" runat="server" OnItemCommand="rptRegistrations_ItemCommand">
                        <ItemTemplate>
                            <tr class="border-b border-gray-100 hover:bg-[#FFF8F0] transition-colors">
                                <td class="py-5 px-8 text-sm font-medium text-[#1A1A1A]"><%# Eval("Username") %></td>
                                <td class="py-5 px-8 text-sm text-gray-500"><%# ((DateTime)Eval("RequestDate")).ToString("yyyy-MM-dd") %></td>
                                <td class="py-5 px-8 text-sm text-[#FF8C66] font-medium">
                                    <a href="javascript:void(0)" onclick="openPdfViewer('<%# Eval("ProofDocument") %>')" class="hover:underline cursor-pointer"><%# System.IO.Path.GetFileName(Eval("ProofDocument").ToString()) %></a>
                                </td>
                                <td class="py-5 px-8 text-sm text-gray-500"><%# Eval("Status") %></td>
                                <td class="py-5 px-4">
                                    <div class="relative inline-block">
                                        <button type="button" onclick="openKebabMenu(event, this)"
                                            class="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="5" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="12" cy="19" r="1.5"/></svg>
                                        </button>
                                        <div class="kebab-menu hidden fixed z-50 w-36 bg-white rounded-xl shadow-lg border border-gray-100 py-1">
                                            <asp:LinkButton ID="lnkAccept" runat="server" CommandName="Accept" CommandArgument='<%# Eval("RegistrationId") %>'
                                                Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                                CssClass="block w-full text-left px-4 py-2 text-sm text-green-600 hover:bg-green-50 transition-colors">Accept</asp:LinkButton>
                                            <asp:LinkButton ID="lnkReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("RegistrationId") %>'
                                                Visible='<%# Eval("Status").ToString() == "Pending" %>'
                                                CssClass="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors">Reject</asp:LinkButton>
                                            <asp:LinkButton ID="lnkUndo" runat="server" CommandName="Undo" CommandArgument='<%# Eval("RegistrationId") %>'
                                                Visible='<%# Eval("Status").ToString() != "Pending" %>'
                                                CssClass="block w-full text-left px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 transition-colors">Undo</asp:LinkButton>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <!-- PDF Viewer Modal -->
    <div id="pdfModal" class="fixed inset-0 z-[100] hidden">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" onclick="closePdfViewer()"></div>
        <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[90vw] max-w-[900px] h-[85vh] bg-white rounded-2xl shadow-2xl flex flex-col overflow-hidden">
            <div class="flex items-center justify-between px-6 py-4 border-b border-gray-200">
                <h3 id="pdfModalTitle" class="text-lg font-semibold text-[#1A1A1A]">Proof of Skills</h3>
                <button onclick="closePdfViewer()" class="w-9 h-9 flex items-center justify-center rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
                </button>
            </div>
            <div class="flex-1 p-2">
                <iframe id="pdfFrame" class="w-full h-full rounded-lg border border-gray-100" src=""></iframe>
            </div>
        </div>
    </div>

    <script>
        function openKebabMenu(e, btn) {
            e.stopPropagation();
            var menu = btn.nextElementSibling;
            var wasHidden = menu.classList.contains('hidden');
            document.querySelectorAll('.kebab-menu').forEach(function (m) { m.classList.add('hidden'); });
            if (wasHidden) {
                var rect = btn.getBoundingClientRect();
                menu.style.top = (rect.bottom + 4) + 'px';
                menu.style.left = (rect.right - 144) + 'px';
                menu.classList.remove('hidden');
            }
        }
        document.addEventListener('click', function () {
            document.querySelectorAll('.kebab-menu').forEach(function (m) { m.classList.add('hidden'); });
        });

        function openPdfViewer(fileName) {
            var modal = document.getElementById('pdfModal');
            var frame = document.getElementById('pdfFrame');
            var title = document.getElementById('pdfModalTitle');
            title.textContent = fileName.split('/').pop();
            frame.src = fileName;
            modal.classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closePdfViewer() {
            var modal = document.getElementById('pdfModal');
            var frame = document.getElementById('pdfFrame');
            modal.classList.add('hidden');
            frame.src = '';
            document.body.style.overflow = '';
        }

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closePdfViewer();
        });
    </script>
</asp:Content>
