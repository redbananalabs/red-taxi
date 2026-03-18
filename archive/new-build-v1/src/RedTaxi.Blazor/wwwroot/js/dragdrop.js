// Red Taxi Dispatch Console — Drag & Drop for Timeline
window.timelineDragDrop = {
    _dotNetRef: null,
    _draggedBookingId: null,
    _draggedElement: null,

    // Initialize drag-and-drop on the timeline
    init: function (dotNetRef) {
        this._dotNetRef = dotNetRef;
    },

    // Called when drag starts on a booking block
    onDragStart: function (event, bookingId) {
        this._draggedBookingId = bookingId;
        this._draggedElement = event.target;

        event.dataTransfer.effectAllowed = 'move';
        event.dataTransfer.setData('text/plain', bookingId.toString());

        // Add dragging class after a tick so the ghost image shows properly
        requestAnimationFrame(function () {
            if (window.timelineDragDrop._draggedElement) {
                window.timelineDragDrop._draggedElement.classList.add('dragging');
            }
        });
    },

    // Called on dragover for driver rows (drop zones)
    onDragOver: function (event) {
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move';

        var row = event.currentTarget;
        if (row && !row.classList.contains('drop-target-valid')) {
            row.classList.add('drop-target-valid');
        }
    },

    // Called on dragover for booking blocks (merge zones)
    onDragOverBooking: function (event) {
        event.preventDefault();
        event.stopPropagation();
        event.dataTransfer.dropEffect = 'move';

        var block = event.currentTarget;
        if (block && !block.classList.contains('drop-target-valid')) {
            block.classList.add('drop-target-valid');
        }
    },

    // Called on dragleave for drop zones
    onDragLeave: function (event) {
        var row = event.currentTarget;
        if (row) {
            row.classList.remove('drop-target-valid');
            row.classList.remove('drop-target-invalid');
        }
    },

    // Called on drop for driver rows — reallocation
    onDrop: function (event, targetDriverUserId) {
        event.preventDefault();

        var row = event.currentTarget;
        if (row) {
            row.classList.remove('drop-target-valid');
            row.classList.remove('drop-target-invalid');
        }

        var bookingId = parseInt(event.dataTransfer.getData('text/plain'), 10);
        if (!bookingId || !this._dotNetRef) return;

        this._cleanupDrag();

        this._dotNetRef.invokeMethodAsync('OnBookingDroppedOnDriver', bookingId, targetDriverUserId);
    },

    // Called on drop for the unallocated area
    onDropUnallocated: function (event) {
        event.preventDefault();

        var area = event.currentTarget;
        if (area) {
            area.classList.remove('drop-target-valid');
        }

        var bookingId = parseInt(event.dataTransfer.getData('text/plain'), 10);
        if (!bookingId || !this._dotNetRef) return;

        this._cleanupDrag();

        this._dotNetRef.invokeMethodAsync('OnBookingDroppedOnUnallocated', bookingId);
    },

    // Called on drop for booking blocks — merge
    onDropOnBooking: function (event, targetBookingId) {
        event.preventDefault();
        event.stopPropagation();

        var block = event.currentTarget;
        if (block) {
            block.classList.remove('drop-target-valid');
        }

        var sourceBookingId = parseInt(event.dataTransfer.getData('text/plain'), 10);
        if (!sourceBookingId || !this._dotNetRef || sourceBookingId === targetBookingId) return;

        this._cleanupDrag();

        this._dotNetRef.invokeMethodAsync('OnBookingDroppedOnBooking', sourceBookingId, targetBookingId);
    },

    // Called when drag ends
    onDragEnd: function (event) {
        this._cleanupDrag();

        // Remove all drop-target highlights
        var highlighted = document.querySelectorAll('.drop-target-valid, .drop-target-invalid');
        highlighted.forEach(function (el) {
            el.classList.remove('drop-target-valid');
            el.classList.remove('drop-target-invalid');
        });
    },

    _cleanupDrag: function () {
        if (this._draggedElement) {
            this._draggedElement.classList.remove('dragging');
        }
        this._draggedBookingId = null;
        this._draggedElement = null;
    },

    dispose: function () {
        this._dotNetRef = null;
        this._draggedBookingId = null;
        this._draggedElement = null;
    }
};
