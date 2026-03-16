/** @format */

import { useJsApiLoader } from '@react-google-maps/api';

const GOOGLE_LIBRARIES = ['visualization', 'maps'];

export default function useGoogleMapsLoader() {
	const apiKey = import.meta.env.VITE_GOOGLE_API_KEY;
	return useJsApiLoader({
		googleMapsApiKey: apiKey,
		libraries: GOOGLE_LIBRARIES,
	});
}
