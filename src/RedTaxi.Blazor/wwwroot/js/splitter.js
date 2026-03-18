// Splitter interop for dispatch console split layout
window.splitterInterop = {
    init: function () {
        const handle = document.getElementById('split-handle');
        const container = document.getElementById('dispatch-split');
        const left = document.getElementById('split-left');
        const right = document.getElementById('split-right');

        if (!handle || !container || !left || !right) return;

        let isDragging = false;

        handle.addEventListener('mousedown', function (e) {
            isDragging = true;
            document.body.style.cursor = 'col-resize';
            document.body.style.userSelect = 'none';
            // Prevent iframe/map from eating events
            container.classList.add('split-dragging');
            e.preventDefault();
        });

        document.addEventListener('mousemove', function (e) {
            if (!isDragging) return;
            const rect = container.getBoundingClientRect();
            let pct = ((e.clientX - rect.left) / rect.width) * 100;
            // Clamp between 20% and 50%
            pct = Math.max(20, Math.min(50, pct));
            left.style.width = pct + '%';
            right.style.width = (100 - pct) + '%';
        });

        document.addEventListener('mouseup', function () {
            if (!isDragging) return;
            isDragging = false;
            document.body.style.cursor = '';
            document.body.style.userSelect = '';
            container.classList.remove('split-dragging');
        });
    }
};
