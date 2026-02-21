// Particles.js - Vanilla JS port of React Particles.tsx
// Canvas-based particle animation

function initParticles(canvasId, options) {
    var canvas = document.getElementById(canvasId);
    if (!canvas) return;

    var ctx = canvas.getContext('2d');
    var opts = Object.assign({
        particleCount: 40,
        particleColors: ['#FF8C66', '#FFB399', '#FF6B4A'],
        speed: 0.3,
        particleBaseSize: 3,
        alphaParticles: true
    }, options || {});

    var particles = [];
    var animId;

    function resize() {
        canvas.width = canvas.parentElement.offsetWidth;
        canvas.height = canvas.parentElement.offsetHeight;
    }

    function createParticle() {
        return {
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            vx: (Math.random() - 0.5) * opts.speed,
            vy: (Math.random() - 0.5) * opts.speed,
            size: Math.random() * opts.particleBaseSize + 1,
            color: opts.particleColors[Math.floor(Math.random() * opts.particleColors.length)],
            alpha: opts.alphaParticles ? Math.random() * 0.5 + 0.3 : 1
        };
    }

    function init() {
        resize();
        particles = [];
        for (var i = 0; i < opts.particleCount; i++) {
            particles.push(createParticle());
        }
    }

    function draw() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        for (var i = 0; i < particles.length; i++) {
            var p = particles[i];

            p.x += p.vx;
            p.y += p.vy;

            if (p.x < 0 || p.x > canvas.width) p.vx *= -1;
            if (p.y < 0 || p.y > canvas.height) p.vy *= -1;

            ctx.globalAlpha = p.alpha;
            ctx.fillStyle = p.color;
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            ctx.fill();
        }

        ctx.globalAlpha = 1;
        animId = requestAnimationFrame(draw);
    }

    window.addEventListener('resize', resize);
    init();
    draw();
}
