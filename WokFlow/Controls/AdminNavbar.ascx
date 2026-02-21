<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdminNavbar.ascx.cs" Inherits="WokFlow.Controls.AdminNavbar" %>

<header class="flex items-center justify-between px-6 py-4 md:px-12 max-w-[1400px] mx-auto w-full relative z-20">
    <div class="glass-panel rounded-full px-6 py-3 w-full flex items-center justify-between">
        <!-- Logo -->
        <a href="~/Pages/Admin/UserManagement.aspx" class="flex items-center gap-2 no-underline">
            <div class="bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white p-1.5 rounded-lg shadow-lg shadow-orange-500/20">
                <i data-lucide="chef-hat" style="width:20px;height:20px;"></i>
            </div>
            <span class="text-xl font-bold tracking-tight text-[#1A1A1A]">WokFlow</span>
        </a>

        <!-- Navigation -->
        <nav class="hidden md:flex items-center gap-10">
            <!-- User Management Dropdown -->
            <div class="relative" id="adminUserDropdown">
                <button onclick="toggleAdminDropdown('adminUserMenu')"
                    class="text-sm font-bold transition-all px-4 py-2 rounded-full flex items-center gap-2 <%= IsUserManagementActive ? "nav-active" : "text-gray-500 hover:text-[#FF8C66]" %>">
                    User Management
                    <i data-lucide="chevron-down" style="width:14px;height:14px;"></i>
                </button>
                <div id="adminUserMenu" class="hidden absolute top-full left-0 mt-2 w-56 bg-white/90 backdrop-blur-xl border border-white/60 shadow-xl rounded-2xl p-2 z-50 dropdown-menu flex flex-col gap-1">
                    <!--Manage Users-->
                    <a href=<% ResolveUrl("~/Pages/Admin/UserManagement.aspx"); %>
                        class="block w-full text-left px-4 py-3 rounded-xl text-sm font-medium transition-colors no-underline <%= CurrentPage == "UserManagement" ? "bg-gray-100 text-gray-900" : "text-gray-700 hover:bg-gray-50" %>">
                        User Control Panel
                    </a>
                    <!--Sharer Request-->
                    <a href=<% ResolveUrl("~/Pages/Admin/SharerRequests.aspx"); %>
                        class="block w-full text-left px-4 py-3 rounded-xl text-sm font-medium transition-colors no-underline <%= CurrentPage == "SharerRequests" ? "bg-gray-100 text-gray-900" : "text-gray-700 hover:bg-gray-50" %>">
                        Sharer Requests
                    </a>
                    <!--Sharer Registration-->
                    <a href=<% ResolveUrl("~/Pages/Admin/SharerRegistration.aspx"); %>
                        class="block w-full text-left px-4 py-3 rounded-xl text-sm font-medium transition-colors no-underline <%= CurrentPage == "SharerRegistration" ? "bg-gray-100 text-gray-900" : "text-gray-700 hover:bg-gray-50" %>">
                        Sharer Registration
                    </a>
                </div>
            </div>

            <!-- Content Management -->
            <a href=<% ResolveUrl("~/Pages/Admin/ContentManagement.aspx"); %>
                class="text-sm font-bold transition-all px-4 py-2 rounded-full no-underline <%= CurrentPage == "ContentManagement" ? "nav-active" : "text-gray-500 hover:text-[#FF8C66]" %>">
                Content Management
            </a>

            <!-- Platform Analytics -->
            <a href=<% ResolveUrl("~/Pages/Admin/PlatformAnalytics.aspx"); %>
                class="text-sm font-bold transition-all px-4 py-2 rounded-full no-underline <%= CurrentPage == "PlatformAnalytics" ? "nav-active" : "text-gray-500 hover:text-[#FF8C66]" %>">
                Platform Analytics
            </a>
        </nav>

        <!-- User Profile -->
        <div class="flex items-center gap-4">
            <a href=<% ResolveUrl("~/Pages/UserProfile.aspx"); %>
                class="p-2 rounded-full transition-colors no-underline <%= CurrentPage == "UserProfile" ? "bg-orange-100 text-[#FF8C66]" : "hover:bg-white/50 text-gray-500" %>">
                <i data-lucide="user" style="width:24px;height:24px;stroke-width:1.5;"></i>
            </a>
        </div>
    </div>
</header>

<!-- Dropdown Menu Styles -->
<script>
    lucide.createIcons();

    function toggleAdminDropdown(menuId) {
        var menu = document.getElementById(menuId);
        menu.classList.toggle('hidden');
    }

    document.addEventListener('click', function (e) {
        if (!e.target.closest('#adminUserDropdown')) {
            var m = document.getElementById('adminUserMenu');
            if (m) m.classList.add('hidden');
        }
    });
</script>