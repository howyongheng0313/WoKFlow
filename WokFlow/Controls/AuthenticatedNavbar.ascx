<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AuthenticatedNavbar.ascx.cs" Inherits="WokFlow.Controls.AuthenticatedNavbar" %>

<header class="flex items-center justify-between px-6 py-4 md:px-12 max-w-[1400px] mx-auto w-full relative z-20">
    <div class="glass-panel rounded-full px-6 py-3 w-full flex items-center justify-between">
        <!-- Logo -->
        <a href="<%: ResolveUrl("~/Pages/Learner/Dashboard.aspx") %>" class="flex items-center gap-2 no-underline">
            <div class="bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white p-1.5 rounded-lg shadow-lg shadow-orange-500/20">
                <i data-lucide="chef-hat" style="width:20px;height:20px;"></i>
            </div>
            <span class="text-xl font-bold tracking-tight text-[#1A1A1A]">WokFlow</span>
        </a>

        <!-- Navigation -->
        <nav class="hidden md:flex items-center gap-10">
            <!-- Homepage -->
            <a href="<%: ResolveUrl("~/Pages/Learner/Dashboard.aspx") %>"
               class="text-sm font-bold transition-all px-4 py-2 rounded-full no-underline <%= CurrentPage == "Dashboard" ? "nav-active" : "text-gray-500 hover:text-[#FF8C66]" %>">
                Homepage
            </a>

            <% if (UserRole == "SHARER") { %>
                <!-- My Courses Dropdown (Sharer) -->
                <div class="relative" id="myCoursesDropdown">
                    <button onclick="toggleDropdown('myCoursesMenu', 'analyticsMenu')"
                        class="text-sm font-bold transition-all px-4 py-2 rounded-full flex items-center gap-1 <%= CurrentPage == "MyCourses" ? "nav-active" : "text-gray-500 hover:text-[#FF8C66]" %>">
                        My Courses
                        <i data-lucide="chevron-down" style="width:16px;height:16px;"></i>
                    </button>
                    <div id="myCoursesMenu" class="hidden absolute top-full left-0 mt-2 w-48 bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden z-50 dropdown-menu">
                        <a href="<%: ResolveUrl("~/Pages/Shared/MyCourses.aspx?tab=created") %>"
                            class="block w-full px-4 py-3 text-left text-sm font-medium text-gray-700 hover:bg-gray-50 no-underline">
                            Created Courses
                        </a>
                        <a href="<%: ResolveUrl("~/Pages/Shared/MyCourses.aspx?tab=joined") %>"
                           class="block w-full px-4 py-3 text-left text-sm font-medium text-gray-700 hover:bg-gray-50 no-underline">
                            Joined Courses
                        </a>
                    </div>
                </div>

                <!-- Analytics Dropdown -->
                <div class="relative" id="analyticsDropdown">
                    <button onclick="toggleDropdown('analyticsMenu', 'myCoursesMenu')"
                            class="text-sm font-bold transition-all px-4 py-2 rounded-full flex items-center gap-1 <%= CurrentPage == "Analytics" ? "nav-active" : "text-gray-500 hover:text-[#FF8C66]" %>">
                        Analytics
                        <i data-lucide="chevron-down" style="width:16px;height:16px;"></i>
                    </button>
                    <div id="analyticsMenu" class="hidden absolute top-full left-0 mt-2 w-48 bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden z-50 dropdown-menu">
                        <a href="<%: ResolveUrl("~/Pages/Sharer/Analytics.aspx?tab=performance") %>"
                           class="block w-full px-4 py-3 text-left text-sm font-medium text-gray-700 hover:bg-gray-50 no-underline">
                            Course Performance
                        </a>
                        <a href="<%: ResolveUrl("~/Pages/Sharer/Analytics.aspx?tab=quiz") %>"
                           class="block w-full px-4 py-3 text-left text-sm font-medium text-gray-700 hover:bg-gray-50 no-underline">
                            Quiz Performance
                        </a>
                        <a href="<%: ResolveUrl("~/Pages/Sharer/Analytics.aspx?tab=comments") %>"
                           class="block w-full px-4 py-3 text-left text-sm font-medium text-gray-700 hover:bg-gray-50 no-underline">
                            Comments Dashboard
                        </a>
                    </div>
                </div>

                <!-- Create Course -->
                <a href="<%: ResolveUrl("~/Pages/Sharer/CreateCourse.aspx") %>"
                   class="text-sm font-bold transition-all px-4 py-2 rounded-full no-underline <%= CurrentPage == "CreateCourse" ? "nav-active" : "text-gray-500 hover:text-[#FF8C66]" %>">
                    Create Course
                </a>
            <% } else { %>
                <!-- My Courses (Learner - simple link) -->
                <a href="<%: ResolveUrl("~/Pages/Shared/MyCourses.aspx?tab=joined") %>"
                   class="text-sm font-bold transition-all px-4 py-2 rounded-full no-underline <%= CurrentPage == "MyCourses" ? "nav-active" : "text-gray-500 hover:text-[#FF8C66]" %>">
                    My Courses
                </a>
            <% } %>
        </nav>

        <!-- User Profile -->
        <div class="flex items-center gap-4">
            <a href="<%: ResolveUrl("~/Pages/Shared/UserProfile.aspx") %>"
               class="p-2 rounded-full transition-colors no-underline <%= CurrentPage == "UserProfile" ? "bg-orange-100 text-[#FF8C66]" : "hover:bg-white/50 text-gray-500" %>">
                <i data-lucide="user" style="width:24px;height:24px;stroke-width:1.5;"></i>
            </a>
        </div>
    </div>
</header>

<script>
    lucide.createIcons();

    function toggleDropdown(menuId, otherMenuId) {
        var menu = document.getElementById(menuId);
        var other = document.getElementById(otherMenuId);
        if (other) other.classList.add('hidden');
        menu.classList.toggle('hidden');
    }

    document.addEventListener('click', function (e) {
        if (!e.target.closest('#myCoursesDropdown')) {
            var m = document.getElementById('myCoursesMenu');
            if (m) m.classList.add('hidden');
        }
        if (!e.target.closest('#analyticsDropdown')) {
            var m = document.getElementById('analyticsMenu');
            if (m) m.classList.add('hidden');
        }
    });
</script>
