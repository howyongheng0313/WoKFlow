// SplitText.js - Vanilla JS port of React SplitText.tsx
// GSAP-powered text animation that splits text into characters or words

function splitTextAnimate(selector, options) {
    if (typeof gsap === 'undefined') return;

    var el = document.querySelector(selector);
    if (!el) return;

    var opts = Object.assign({
        splitType: 'chars', // 'chars' or 'words'
        delay: 0,
        duration: 0.6,
        stagger: 0.03,
        ease: 'power3.out',
        from: { opacity: 0, y: 40 },
        to: { opacity: 1, y: 0 }
    }, options || {});

    var text = el.textContent;
    el.innerHTML = '';

    var items = opts.splitType === 'chars' ? text.split('') : text.split(' ');

    items.forEach(function (item, i) {
        var span = document.createElement('span');
        span.style.display = 'inline-block';
        span.style.opacity = '0';
        span.textContent = item === ' ' ? '\u00A0' : item;
        if (opts.splitType === 'words' && i < items.length - 1) {
            span.style.marginRight = '0.25em';
        }
        el.appendChild(span);
    });

    var spans = el.querySelectorAll('span');

    gsap.fromTo(spans, opts.from, Object.assign({}, opts.to, {
        duration: opts.duration,
        stagger: opts.stagger,
        delay: opts.delay,
        ease: opts.ease
    }));
}