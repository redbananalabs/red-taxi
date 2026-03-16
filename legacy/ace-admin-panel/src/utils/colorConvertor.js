/** @format */

export const convertHexToRgba = (hex) => {
	if (!hex || typeof hex !== 'string') return 'rgba(0,0,0,1)';

	if (hex.startsWith('#')) hex = hex.slice(1);

	if (hex.length === 6) {
		// No alpha
		const r = parseInt(hex.slice(0, 2), 16);
		const g = parseInt(hex.slice(2, 4), 16);
		const b = parseInt(hex.slice(4, 6), 16);
		return `rgba(${r}, ${g}, ${b}, 1)`;
	}

	if (hex.length === 8) {
		const r = parseInt(hex.slice(0, 2), 16);
		const g = parseInt(hex.slice(2, 4), 16);
		const b = parseInt(hex.slice(4, 6), 16);
		const a = parseInt(hex.slice(6, 8), 16) / 255;
		return `rgba(${r}, ${g}, ${b}, ${a.toFixed(2)})`;
	}

	// Fallback
	return 'rgba(0,0,0,1)';
};
