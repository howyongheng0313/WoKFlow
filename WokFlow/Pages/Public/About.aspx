<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="WokFlow.Pages.Public.About" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hero Section: Meet the Innovators with Particles -->
    <section class="relative flex flex-col items-center justify-center overflow-hidden" style="min-height: calc(100vh - 80px);">
        <canvas id="aboutParticles" class="absolute inset-0 w-full h-full" style="z-index: 0;"></canvas>
        <div class="relative z-10 text-center px-6">
            <h1 class="text-6xl md:text-7xl font-extrabold text-[#1A1A1A] mb-4 leading-tight">
                Meet the <span style="color:#FF8C66; text-decoration: underline; text-decoration-color: #FF8C66;">Innovators</span>
            </h1>
            <p class="text-lg text-gray-500 mt-4">The visionary minds reshaping the future of culinary education.</p>
        </div>
        <!-- Scroll Down Indicator -->
        <div class="absolute bottom-10 left-1/2 flex flex-col items-center gap-2 text-gray-400 z-10" style="transform: translateX(-50%);">
            <i data-lucide="arrow-down" class="w-5 h-5" id="scrollArrow"></i>
            <span class="text-xs font-semibold tracking-widest uppercase">Scroll Down</span>
        </div>
    </section>

    <!-- Scroll Stack: Founders -->
    <section class="py-20 px-6 max-w-5xl mx-auto">
        <div id="scrollStackContainer">



            <!-- Founder 1: How Yong Heng -->
            <div class="scroll-stack-card rounded-3xl overflow-hidden mb-10 shadow-xl h-[700px]" style="background: linear-gradient(135deg, #fff5f2 0%, #ffe8df 100%);">
                <div class="flex flex-col md:flex-row h-full">
                    <div class="flex-1 p-12 flex flex-col justify-center h-full">
                        <span class="inline-block text-white text-xs font-bold uppercase tracking-widest px-4 py-1.5 rounded-full mb-6 self-start"
                              style="background: linear-gradient(to right, #FF8C66, #FF6B4A);">Co-Founder</span>
                        <h2 class="text-4xl font-extrabold text-[#1A1A1A] mb-4">How Yong Heng</h2>
                        <p class="text-gray-500 text-base leading-relaxed" style="max-width: 360px;">
                            <strong>Creative Director & UI Lead.</strong> A dedicated perfectionist with an 
                            unwavering obsession for design. He ensures that every pixel at WokFlow is 
                            not just functional, but a masterpiece of culinary art.
                        </p>
                    </div>
                    <div class="flex-1 h-full overflow-hidden">
                        <img src=<%: ResolveUrl("~/Content/Images/yongheng.jpeg") %> 
                             alt="How Yong Heng" 
                             class="w-full h-full object-cover" 
                             style="object-position: center top;"> 
                    </div>
                 </div>
            </div>

            <!-- Founder 2: Leong Yu Hang -->
            <div class="scroll-stack-card rounded-3xl overflow-hidden mb-10 shadow-xl h-[700px]" style="background: linear-gradient(135deg, #fff5f2 0%, #ffe8df 100%);">
                <div class="flex flex-col md:flex-row h-full">
                    <div class="flex-1 p-12 flex flex-col justify-center h-full">
                        <span class="inline-block text-white text-xs font-bold uppercase tracking-widest px-4 py-1.5 rounded-full mb-6 self-start"
                              style="background: linear-gradient(to right, #FF8C66, #FF6B4A);">Co-Founder</span>
                        <h2 class="text-4xl font-extrabold text-[#1A1A1A] mb-4">Leong Yu Hang</h2>
                        <p class="text-gray-500 text-base leading-relaxed" style="max-width: 360px;">
                            <strong>Architecture Director.</strong> The "big brother" and steady heart of the team. 
                            He balances complex system design with a grounding presence, ensuring 
                            technical stability and team morale never waver.
                        </p>
                    </div>
                    <div class="flex-1 h-full overflow-hidden">
                        <img src=<%: ResolveUrl("~/Content/Images/yuhang.jpeg") %> 
                             alt="Leong Yu Hang" 
                             class="w-full h-full object-cover" 
                             style="object-position: center top;"> 
                    </div>
                 </div>
            </div>

            <!-- Founder 3: Randy Chee Yee Kae -->
            <div class="scroll-stack-card rounded-3xl overflow-hidden mb-10 shadow-xl h-[700px]" style="background: linear-gradient(135deg, #fff5f2 0%, #ffe8df 100%);">
                <div class="flex flex-col md:flex-row h-full">
                    <div class="flex-1 p-12 flex flex-col justify-center h-full">
                        <span class="inline-block text-white text-xs font-bold uppercase tracking-widest px-4 py-1.5 rounded-full mb-6 self-start"
                              style="background: linear-gradient(to right, #FF8C66, #FF6B4A);">Co-Founder</span>
                        <h2 class="text-4xl font-extrabold text-[#1A1A1A] mb-4">Randy Chee Yee Kae</h2>
                        <p class="text-gray-500 text-base leading-relaxed" style="max-width: 360px;">
                            <strong>Database Director.</strong> Known for his unflappable composure and 
                            keen eye for elegance. He crafts resilient data structures with a calm logic, 
                            always finding the beauty in organized complexity.
                        </p>
                    </div>
                    <div class="flex-1 h-full overflow-hidden">
                        <img src=<%: ResolveUrl("~/Content/Images/randy.jpeg") %> 
                             alt="Randy Chee" 
                             class="w-full h-full object-cover" 
                             style="object-position: center top;"> 
                    </div>
                 </div>
            </div>

            <!-- Founder 4: Kuek Zheng Yu -->
            <div class="scroll-stack-card rounded-3xl overflow-hidden mb-10 shadow-xl h-[700px]" style="background: linear-gradient(135deg, #fff5f2 0%, #ffe8df 100%);">
                <div class="flex flex-col md:flex-row h-full">
                    <div class="flex-1 p-12 flex flex-col justify-center h-full">
                        <span class="inline-block text-white text-xs font-bold uppercase tracking-widest px-4 py-1.5 rounded-full mb-6 self-start"
                              style="background: linear-gradient(to right, #FF8C66, #FF6B4A);">Co-Founder</span>
                        <h2 class="text-4xl font-extrabold text-[#1A1A1A] mb-4">Kuek Zheng Yu</h2>
                        <p class="text-gray-500 text-base leading-relaxed" style="max-width: 360px;">
                            <strong>Backend Director.</strong> A quiet strategist with a razor-sharp mind. 
                            He translates vision into high-performance code, letting his rigorous logic 
                            and flawless execution speak louder than words.
                        </p>
                    </div>
                    <div class="flex-1 h-full overflow-hidden">
                        <img src=<%: ResolveUrl("~/Content/Images/zhengyu.png") %> 
                             alt="Kuek Zhneg Yu" 
                             class="w-full h-full object-cover" 
                             style="object-position: center top;"> 
                    </div>
                 </div>
            </div>
        </div>
    </section>

    <!-- CTA -->
    <section class="text-center py-20">
        <a href=<%: ResolveUrl("~/Pages/Auth/Login.aspx") %>
           class="inline-block text-white px-10 py-4 rounded-full text-lg font-bold shadow-lg transition-all no-underline hover:-translate-y-1"
           style="background: linear-gradient(to right, #FF8C66, #FF6B4A); box-shadow: 0 10px 25px rgba(255,140,102,0.3);">
            Join WokFlow Today
        </a>
    </section>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%: ResolveUrl("~/Scripts/particles.js") %>'></script>
    <script src='<%: ResolveUrl("~/Scripts/scroll-stack.js") %>'></script>
    <script>
        lucide.createIcons();

        // Scroll arrow bounce animation
        var arrow = document.getElementById('scrollArrow');
        if (arrow) {
            var dir = 1, pos = 0;
            setInterval(function () {
                pos += dir * 1;
                if (pos >= 8 || pos <= 0) dir *= -1;
                arrow.style.transform = 'translateY(' + pos + 'px)';
            }, 30);
        }

        // Particles on hero
        if (typeof initParticles === 'function') {
            initParticles('aboutParticles', {
                particleCount: 40,
                particleColors: ['#FF8C66', '#FFB399', '#FF6B4A'],
                speed: 0.3,
                particleBaseSize: 3,
                alphaParticles: true
            });
        }

        // Register ScrollTrigger and init scroll stack
        if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
            gsap.registerPlugin(ScrollTrigger);
        }
        if (typeof initScrollStack === 'function') {
            initScrollStack('#scrollStackContainer', {
                itemDistance: 60,
                itemScale: 0.95,
                baseScale: 1,
                scaleDuration: 0.4
            });
        }
    </script>
</asp:Content>
