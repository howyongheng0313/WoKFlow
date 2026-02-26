<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WokFlow.Pages.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="min-h-screen flex flex-col selection:bg-orange-200 selection:text-black">
        <div class="flex-1">
            <!-- Hero Section -->
            <section class="relative min-h-[90vh] flex items-center overflow-hidden pt-20">
                <!-- Particles Canvas -->
                <canvas id="particlesCanvas" class="absolute inset-0 w-full h-full pointer-events-none" style="z-index: 1;"></canvas>

                <div class="relative z-10 w-full max-w-7xl mx-auto px-6 flex flex-col lg:flex-row items-center lg:items-center gap-12 lg:gap-16">
                    <!-- Left Column: Text Content -->
                    <div class="flex-1 text-center lg:text-left">
                        <!-- Title -->
                        <h1 class="text-5xl md:text-6xl lg:text-7xl font-extrabold text-[#1A1A1A] mb-6 leading-tight" id="heroHeading">
                            Find Your<br /><span class="text-[#FF8C66]">Culinary Flow</span>
                        </h1>

                        <!-- Subtitle -->
                        <p class="text-lg md:text-xl text-gray-500 mb-10 max-w-xl mx-auto lg:mx-0" id="heroSubtext">
                            Master world-class recipes through interactive tutorials, expert quizzes, and step-by-step guidance.
                        </p>
                        
                        <!-- Start Cooking Button -->
                        <div id="heroCta">
                            <a href="<%: ResolveUrl("~/Pages/Auth/Login.aspx") %>"
                                class="inline-flex items-center gap-2 bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white px-10 py-4 rounded-full text-lg font-bold shadow-lg shadow-orange-500/20 hover:shadow-orange-500/30 transition-all transform hover:-translate-y-1 no-underline">
                                <i data-lucide="chef-hat" class="w-5 h-5"></i>
                                Start Cooking
                            </a>
                        </div>
                    </div>

                    <!-- Right Column: Overlapping Squares -->
                    <div class="flex-1 flex items-center justify-center relative z-20">
                        <div class="relative w-[320px] h-[320px] md:w-[400px] md:h-[400px] lg:w-[450px] lg:h-[450px]">
                            <!-- Back Diamond (decorative, rotates in) -->
                            <div id="heroDiamond"
                                 class="absolute inset-0 w-full h-full opacity-0 will-change-transform">
                                <div class="w-full h-full rounded-3xl bg-gradient-to-br from-white/90 to-white/70 border border-white/80 shadow-[0_10px_50px_rgba(255,140,102,0.2),0_4px_12px_rgba(0,0,0,0.08),inset_0_1px_0_rgba(255,255,255,0.9)]"></div>
                            </div>

                            <!-- Front Image Square (fades in with blur) -->
                            <div id="heroImageSquare"
                                class="absolute top-6 left-6 md:top-8 md:left-8 w-[calc(100%-24px)] h-[calc(100%-24px)] md:w-[calc(100%-32px)] md:h-[calc(100%-32px)] rounded-2xl overflow-hidden shadow-2xl opacity-0 will-change-transform">
                                <img src="<%: ResolveUrl("~/Content/Images/landing-page.png") %>"
                                     alt="Wok cooking"
                                     class="w-full h-full object-cover" />
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="<%: ResolveUrl("~/Scripts/particles.js") %>"></script>
    <script src="<%: ResolveUrl("~/Scripts/split-text.js") %>"></script>
    <script>
        // Ensure lucide icons render
        if (typeof lucide !== 'undefined') lucide.createIcons();

        // Initialize particles
        if (typeof initParticles === 'function') {
            initParticles('particlesCanvas', {
                particleCount: 40,
                particleColors: ['#FF8C66', '#FFB399', '#FF6B4A'],
                speed: 0.3,
                particleBaseSize: 3
            });
        }

        // GSAP Hero animation timeline
        if (typeof gsap !== 'undefined') {
            var tl = gsap.timeline({ defaults: { ease: 'power3.out', force3D: true } });

            // 1. Left text animates in (staggered)
            tl.from('#heroHeading', { opacity: 0, y: 50, duration: 1 })
                .from('#heroSubtext', { opacity: 0, y: 30, duration: 0.8 }, '-=0.5')
                .from('#heroCta', { opacity: 0, y: 20, duration: 0.6 }, '-=0.4')

                // 2. Back diamond rotates in from 0 to 45 degrees
                .to('#heroDiamond', {
                    opacity: 1,
                    rotation: 45,
                    duration: 1.2,
                    ease: 'power2.out'
                }, '-=0.6')

                // 3. Front image square fades in with scale (GPU-friendly, no filter blur)
                .fromTo('#heroImageSquare',
                    { opacity: 0, scale: 0.92 },
                    { opacity: 1, scale: 1, duration: 1, ease: 'power2.out' }
                );
        }
    </script>
</asp:Content>