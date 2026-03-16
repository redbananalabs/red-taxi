/** @format */

import { useEffect } from 'react';

const BookingDispatch = () => {
	const url = import.meta.env.VITE_IFRAME_URL;
	const token = localStorage.getItem('authToken');
	const username = localStorage.getItem('username');
	const userData = localStorage.getItem('userData');

	useEffect(() => {
		const iframe = document.getElementById('bookingDispatch');

		// Check if iframe exists and send token once iframe loads
		if (iframe) {
			iframe.onload = () => {
				iframe.contentWindow.postMessage({ token, username, userData }, url); // Send token to iframe
			};
		}
	}, [url, token, username, userData]);

	return (
		<iframe
			id='bookingDispatch'
			src={url}
			key={username}
			title='Booking Dispatch Iframe'
			className='w-full h-[865px] bg-white'
		></iframe>
	);
};

export { BookingDispatch };
