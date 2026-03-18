// Red Taxi Dispatch Console — JS Interop
window.dispatchInterop = {
    _dotNetRef: null,
    _map: null,
    _driverMarkers: {},
    _bookingMarkers: {},

    // Initialize keyboard shortcuts (DC23)
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

            // Ctrl+S — Save/Confirm booking
            if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                e.preventDefault();
                if (dotNetRef) {
                    dotNetRef.invokeMethodAsync('OnSaveBooking');
                }
            }

            // Ctrl+Enter — Confirm booking
            if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
                e.preventDefault();
                if (dotNetRef) {
                    dotNetRef.invokeMethodAsync('OnConfirmBooking');
                }
            }
        });
    },

    // Initialize Google Maps (stub — requires API key)
    initMap: function (elementId) {
        var mapEl = document.getElementById(elementId);
        if (!mapEl) return false;

        if (typeof google === 'undefined' || !google.maps) return false;

        this._map = new google.maps.Map(mapEl, {
            center: { lat: 51.0478, lng: -2.2769 },
            zoom: 13,
            mapId: 'DISPATCH_MAP',
            disableDefaultUI: true,
            zoomControl: true,
            mapTypeControl: false,
            streetViewControl: false,
            fullscreenControl: false,
            colorScheme: 'DARK'
        });

        var placeholder = mapEl.parentElement ? mapEl.parentElement.querySelector('.map-placeholder') : null;
        if (placeholder) placeholder.style.display = 'none';

        return true;
    },

    // DC02: Update driver marker on map with status colours
    updateDriverMarker: function (userId, lat, lng, heading, color) {
        if (!this._map) return;

        if (this._driverMarkers[userId]) {
            // Update existing marker position
            this._driverMarkers[userId].setPosition({ lat: lat, lng: lng });
            this._driverMarkers[userId].setIcon(this._createDriverIcon(color, heading));
        } else {
            // Create new marker
            var marker = new google.maps.Marker({
                position: { lat: lat, lng: lng },
                map: this._map,
                icon: this._createDriverIcon(color, heading),
                title: 'Driver ' + userId,
                zIndex: 10
            });
            this._driverMarkers[userId] = marker;
        }
    },

    // DC02: Create driver pin icon SVG
    _createDriverIcon: function (color, heading) {
        var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">' +
            '<circle cx="12" cy="12" r="10" fill="' + color + '" stroke="#0B0D11" stroke-width="2"/>' +
            '<polygon points="12,4 16,14 12,12 8,14" fill="#0B0D11" transform="rotate(' + (heading || 0) + ', 12, 12)"/>' +
            '</svg>';
        return {
            url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg),
            scaledSize: typeof google !== 'undefined' ? new google.maps.Size(24, 24) : null,
            anchor: typeof google !== 'undefined' ? new google.maps.Point(12, 12) : null
        };
    },

    // DC03: Add unallocated booking marker (pulsing pin)
    addUnallocatedBookingMarker: function (bookingId, address, label) {
        if (!this._map) return;
        // Use geocoder to place marker at address
        if (typeof google !== 'undefined' && google.maps && google.maps.Geocoder) {
            var geocoder = new google.maps.Geocoder();
            var self = this;
            geocoder.geocode({ address: address }, function (results, status) {
                if (status === 'OK' && results[0]) {
                    var pos = results[0].geometry.location;

                    // Remove old marker if exists
                    if (self._bookingMarkers[bookingId]) {
                        self._bookingMarkers[bookingId].setMap(null);
                    }

                    var marker = new google.maps.Marker({
                        position: pos,
                        map: self._map,
                        icon: self._createPulsingBookingIcon(),
                        title: label + ' (#' + bookingId + ')',
                        zIndex: 5,
                        animation: google.maps.Animation.BOUNCE
                    });

                    // Stop bouncing after 2 seconds, rely on CSS pulse
                    setTimeout(function () {
                        if (marker.getMap()) marker.setAnimation(null);
                    }, 2000);

                    self._bookingMarkers[bookingId] = marker;
                }
            });
        }
    },

    _createPulsingBookingIcon: function () {
        var svg = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20">' +
            '<circle cx="10" cy="10" r="8" fill="#F59E0B" stroke="#0B0D11" stroke-width="2" opacity="0.9">' +
            '<animate attributeName="r" values="6;9;6" dur="1.5s" repeatCount="indefinite"/>' +
            '<animate attributeName="opacity" values="0.9;0.5;0.9" dur="1.5s" repeatCount="indefinite"/>' +
            '</circle>' +
            '</svg>';
        return {
            url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg),
            scaledSize: typeof google !== 'undefined' ? new google.maps.Size(20, 20) : null,
            anchor: typeof google !== 'undefined' ? new google.maps.Point(10, 10) : null
        };
    },

    // Remove booking marker (when allocated)
    removeBookingMarker: function (bookingId) {
        if (this._bookingMarkers[bookingId]) {
            this._bookingMarkers[bookingId].setMap(null);
            delete this._bookingMarkers[bookingId];
        }
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

    // DC33: Play notification sound
    playSound: function (soundFile) {
        try {
            var audio = new Audio('/audio/' + soundFile);
            audio.volume = 0.5;
            audio.play().catch(function () {
                // Autoplay blocked by browser — user must interact first
            });
        } catch (e) {
            // Sound file not found or audio not supported
        }
    },

    // DC34: Context menu helper
    showContextMenu: function (x, y) {
        // Position is handled by Blazor; this just helps with viewport clipping
        var menu = document.querySelector('.context-menu');
        if (menu) {
            menu.style.left = Math.min(x, window.innerWidth - 200) + 'px';
            menu.style.top = Math.min(y, window.innerHeight - 250) + 'px';
        }
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
