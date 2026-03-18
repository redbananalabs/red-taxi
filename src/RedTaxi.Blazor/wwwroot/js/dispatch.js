// Red Taxi Dispatch Console — JS Interop
window.dispatchInterop = {
    _dotNetRef: null,
    _map: null,

    // Initialize keyboard shortcuts
    initKeyboard: function (dotNetRef) {
        this._dotNetRef = dotNetRef;

        document.addEventListener('keydown', function (e) {
            // Ctrl+K or Cmd+K — Command Palette
            if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
                e.preventDefault();
                if (dotNetRef) {
                    dotNetRef.invokeMethodAsync('OnCommandPaletteToggle');
                }
            }

            // Ctrl+N or Cmd+N — New Booking
            if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
                e.preventDefault();
                if (dotNetRef) {
                    dotNetRef.invokeMethodAsync('OnNewBooking');
                }
            }

            // Escape — Close panels
            if (e.key === 'Escape') {
                if (dotNetRef) {
                    dotNetRef.invokeMethodAsync('OnEscapePressed');
                }
            }
        });
    },

    // Initialize Google Maps (stub — requires API key)
    initMap: function (elementId) {
        var mapEl = document.getElementById(elementId);
        if (!mapEl) return;

        // Check if Google Maps API is loaded
        if (typeof google !== 'undefined' && google.maps) {
            this._map = new google.maps.Map(mapEl, {
                center: { lat: 51.5074, lng: -0.1278 }, // London default
                zoom: 12,
                disableDefaultUI: true,
                zoomControl: true,
                styles: this._darkMapStyles
            });

            // Hide placeholder when map loads
            var placeholder = mapEl.parentElement.querySelector('.map-placeholder');
            if (placeholder) {
                placeholder.style.display = 'none';
            }
        }
    },

    // Update driver marker on map
    updateDriverMarker: function (userId, lat, lng, heading, color) {
        if (!this._map) return;
        // Stub for driver marker updates
    },

    // Add booking pickup/destination markers
    addBookingMarkers: function (bookingId, pickupLat, pickupLng, destLat, destLng) {
        if (!this._map) return;
        // Stub for booking markers
    },

    // Fit map to show specific bounds
    fitBounds: function (north, south, east, west) {
        if (!this._map) return;
        var bounds = new google.maps.LatLngBounds(
            { lat: south, lng: west },
            { lat: north, lng: east }
        );
        this._map.fitBounds(bounds);
    },

    // Dark map styling
    _darkMapStyles: [
        { elementType: 'geometry', stylers: [{ color: '#1A1E27' }] },
        { elementType: 'labels.text.stroke', stylers: [{ color: '#0B0D11' }] },
        { elementType: 'labels.text.fill', stylers: [{ color: '#6B7280' }] },
        { featureType: 'administrative', elementType: 'geometry', stylers: [{ color: '#2E3440' }] },
        { featureType: 'poi', elementType: 'labels', stylers: [{ visibility: 'off' }] },
        { featureType: 'road', elementType: 'geometry', stylers: [{ color: '#242934' }] },
        { featureType: 'road', elementType: 'geometry.stroke', stylers: [{ color: '#2E3440' }] },
        { featureType: 'road.highway', elementType: 'geometry', stylers: [{ color: '#2E3440' }] },
        { featureType: 'water', elementType: 'geometry', stylers: [{ color: '#12151B' }] },
        { featureType: 'water', elementType: 'labels.text.fill', stylers: [{ color: '#6B7280' }] },
        { featureType: 'transit', stylers: [{ visibility: 'off' }] }
    ]
};
