<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WokFlow.Pages.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="min-h-screen flex flex-col selection:bg-orange-200 selection:text-black">
        <div class="flex-1">
            <!-- Hero Section -->
            <section class="relative min-h-[90vh] flex items-center justify-center overflow-hidden pt-20">
                
                <!-- Particles Canvas -->
                <canvas id="particlesCanvas" class="absolute inset-0 w-full h-full" style="z-index: 0;"></canvas>

                <div class="relative z-10 text-center max-w-4xl mx-auto px-6">
                    <!-- Animated Heading -->
                    <h1 class="text-5xl md:text-7xl font-extrabold text-[#1A1A1A] mb-6 leading-tight" id="heroHeading">
                        Find Your<br />Culinary Flow
                    </h1>

                    <p class="text-lg md:text-xl text-gray-500 mb-10 max-w-2xl mx-auto" id="heroSubtext">
                        Connect with professional chefs and master culinary arts from around the world.
                    </p>

                    <!-- CTA Button -->
                    <a href=<%: ResolveUrl("~/Pages/Auth/Login.aspx") %>
                        class="inline-block bg-gradient-to-r from-[#FF8C66] to-[#FF6B4A] text-white px-10 py-4 rounded-full text-lg font-bold shadow-lg shadow-orange-500/20 hover:shadow-orange-500/30 transition-all transform hover:-translate-y-1 no-underline">
                        Start Cooking
                    </a>
                </div>

                <!-- Decorative Diamond -->
                <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] opacity-10 pointer-events-none" id="heroDiamond">
                    <div class="w-full h-full glass-panel rounded-3xl rotate-45 bg-gradient-to-br from-[#FF8C66]/20 to-[#FFB399]/10"></div>
                </div>
            </section>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src=<%: ResolveUrl("~/Scripts/particles.js") %>></script>
    <script src=<%: ResolveUrl("~/Scripts/split-text.js") %>></script>
    <script>
        // Initialize particles
        if (typeof initParticles === 'function') {
            initParticles('particlesCanvas', {
                particleCount: 40,
                particleColors: ['#FF8C66', '#FFB399', '#FF6B4A'],
                speed: 0.3,
                particleBaseSize: 3
            });
        }

        // GSAP Hero animation
        if (typeof gsap !== 'undefined') {
            gsap.from('#heroHeading', { opacity: 0, y: 50, duration: 1, ease: 'power3.out' });
            gsap.from('#heroSubtext', { opacity: 0, y: 30, duration: 1, delay: 0.3, ease: 'power3.out' });
            gsap.from('#heroDiamond', { opacity: 0, rotation: 90, scale: 0.5, duration: 1.5, delay: 0.5, ease: 'power3.out' });
        }
    </script>
</asp:Content>
