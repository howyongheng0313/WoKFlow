// ClickSpark.js - Vanilla JS port of React ClickSpark.tsx (Framer Motion -> CSS animations)
// Click-triggered particle explosion effect

(function () {
    var sparkColor = '#FF8C66';
    var sparkSize = 10;
    var sparkRadius = 30;
    var sparkCount = 8;
    var duration = 500; // ms

    document.addEventListener('click', function (e) {
        for (var i = 0; i < sparkCount; i++) {
            createSpark(e.clientX, e.clientY, i);
        }
    });

    function createSpark(x, y, index) {
        var angle = (index * (360 / sparkCount)) * (Math.PI / 180);
        var endX = Math.cos(angle) * sparkRadius;
        var endY = Math.sin(angle) * sparkRadius;

        var spark = document.createElement('div');
        spark.className = 'spark-particle';
        spark.style.width = sparkSize + 'px';
        spark.style.height = sparkSize + 'px';
        spark.style.backgroundColor = sparkColor;
        spark.style.left = x + 'px';
        spark.style.top = y + 'px';
        spark.style.opacity = '1';
        spark.style.transform = 'translate(-50%, -50%) scale(1)';
        spark.style.transition = 'all ' + duration + 'ms ease-out';

        document.body.appendChild(spark);

        // Trigger animation
        requestAnimationFrame(function () {
            spark.style.transform = 'translate(calc(-50% + ' + endX + 'px), calc(-50% + ' + endY + 'px)) scale(0)';
            spark.style.opacity = '0';
        });

        setTimeout(function () {
            if (spark.parentNode) {
                spark.parentNode.removeChild(spark);
            }
        }, duration);
    }
})();
