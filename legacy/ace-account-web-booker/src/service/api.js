/** @format */

import axios from 'axios';

const BASE_URL = import.meta.env.VITE_BASE_URL;

export const endpoints = {
	LOGIN_API: `${BASE_URL}/Auth/Authenticate`,
};

export const newpassengerformEndpoints = {
	GET_ALL_PASSENGERS: (accountNo) =>
		`${BASE_URL}/WeBooking/GetPassengers?accountNo=${accountNo}`, // Fetch all forms
	ADDNEWPASSENGER_CREATE_FORM: `${BASE_URL}/WeBooking/AddNewPassenger`, // Add New passenger form
	DELETE_PASSENGERS: (id) =>
		`${BASE_URL}/WeBooking/DeletePassenger?passengerId=${id}`, // Delete form by ID
};

export const webbookingfromEndpoints = {
	CREATEWEBBOOKING_CREATE_FORM: `${BASE_URL}/WeBooking/CreateWebBooking`, // CREATEWEB BOOKING From
};

export const getwebbookingEndpoints = {
	GETWEBBOOKING: `${BASE_URL}/WeBooking/GetWebBookings`, // Get web booking
};

export const getactivebookingEndpoints = {
	GETACTIVEBOOKING: (accountNo) =>
		`${BASE_URL}/WeBooking/GetAccountActiveBookings?accno=${accountNo}`, // Get active booking
	REQUESTAMENDMENT: (bookingId, message, block = false) =>
		`${BASE_URL}/WeBooking/RequestAmendment?bookingId=${bookingId}&message=${encodeURIComponent(
			message,
		)}&block=${block}`,

	REQUESTCANCELLATION: (bookingId, block = false) =>
		`${BASE_URL}/WeBooking/RequestCancellation?bookingId=${bookingId}&block=${block}`,
};

function setHeaders() {
	const accessToken = localStorage.getItem('authToken');
	if (!accessToken) return {};
	return {
		'Accept': '*/*',
		'Authorization': `Bearer ${accessToken}`,
		'Content-Type': 'application/json',
		'Cache-Control': 'no-cache, no-store, must-revalidate',
		'Pragma': 'no-cache',
		'Expires': '0',
	};
}

// event handlers
// Event handlers
async function handleGetReq(URL) {
	try {
		// console.log(URL);
		const response = await axios.get(URL, { headers: setHeaders() });
		if (response.status >= 200 && response.status < 300) {
			return { ...response.data, status: 'success' };
		} else {
			console.log('Unexpected response status:', response);
			return null;
		}
	} catch (err) {
		// sendLogs({ url: URL, error: err.response }, 'error');
		console.error('Error in GET request:', err);
		return {
			...err.response,
			status: err.response.status > 499 ? 'error' : 'fail',
			message: `${
				err.response.status > 499 ? 'server error' : 'Failed'
			} while fetching the data`,
		};
	}
}

async function getAddress(query, token) {
	const URL = `${BASE_URL}/address/dispatchsearch?q=${query}&sessionToken=${token}`;
	return await handleGetReq(URL);
}

async function resolveAddress(id, token) {
	const URL = `${BASE_URL}/address/resolve?id=${id}&sessionToken=${token}`;
	return await handleGetReq(URL);
}

async function getAddressByPostCode(postcode) {
	const URL = `${BASE_URL}/Address/PostcodeLookup?postcode=${postcode}`;
	return await handleGetReq(URL);
}

export { getAddress, resolveAddress, getAddressByPostCode };
