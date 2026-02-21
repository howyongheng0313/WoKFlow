<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LandingNavbar.ascx.cs" Inherits="WokFlow.Controls.LandingNavbar" %>

<nav class="w-full max-w-7xl mx-auto px-6 py-4 md:px-12 fixed top-0 left-0 right-0 z-50">
    <div class="glass-panel rounded-full px-6 py-3 flex items-center justify-between relative">
        <!-- Logo -->
        <a href="<%: ResolveUrl("~/Pages/Default.aspx") %>" class="flex items-center gap-2 no-underline">
            <div class="bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white p-1.5 rounded-lg shadow-lg shadow-orange-500/20">
                <i data-lucide="chef-hat" style="width:20px;height:20px;"></i>
            </div>
            <span class="text-xl font-bold tracking-tight text-[#1A1A1A] hidden sm:block">WokFlow</span>
        </a>

        <!-- Center Navigation -->
        <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
            <a href="<%: ResolveUrl("~/Pages/Public/About.aspx") %>"
               class="text-sm font-bold text-gray-600 hover:text-[#FF8C66] transition-colors py-2 px-4 rounded-full hover:bg-orange-50 no-underline">
                About
            </a>
        </div>

        <!-- Sign In Button -->
        <div>
            <a href="<%: ResolveUrl("~/Pages/Auth/Login.aspx") %>"
               class="bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white px-6 py-2 rounded-full text-sm font-bold shadow-lg shadow-orange-500/20 hover:shadow-orange-500/30 transition-all transform hover:-translate-y-0.5 no-underline inline-block">
                Sign In
            </a>
        </div>
    </div>
</nav>

<script>lucide.createIcons();</script>