// ScrollStack.js - Vanilla JS port of React ScrollStack.tsx
// Lenis + GSAP scroll-based stacking animation

function initScrollStack(containerSelector, options) {
    if (typeof gsap === 'undefined' || typeof Lenis === 'undefined') return;

    var container = document.querySelector(containerSelector);
    if (!container) return;

    var opts = Object.assign({
        itemDistance: 50,
        itemScale: 0.95,
        baseScale: 1,
        scaleDuration: 0.3
    }, options || {});

    var cards = container.querySelectorAll('.scroll-stack-card');
    if (!cards.length) return;

    var lenis = new Lenis({
        duration: 1.2,
        easing: function (t) { return Math.min(1, 1.001 - Math.pow(2, -10 * t)); }
    });

    function raf(time) {
        lenis.raf(time);
        requestAnimationFrame(raf);
    }
    requestAnimationFrame(raf);

    cards.forEach(function (card, i) {
        gsap.fromTo(card, {
            y: i * opts.itemDistance,
            scale: opts.baseScale - (i * (1 - opts.itemScale) / cards.length)
        }, {
            scrollTrigger: {
                trigger: card,
                start: 'top 80%',
                end: 'bottom 20%',
                scrub: true
            },
            y: 0,
            scale: opts.baseScale,
            duration: opts.scaleDuration
        });
    });
}
