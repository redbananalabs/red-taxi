/** @format */

// import { sendLogs } from '../../utils/getLogs';
import { handleGetReq, handlePostReq } from '../apiRequestHandler';
import { bookingsEndpoints } from '../apis';

const {
	CANCEL_BOOKING_DATE_RANGE,
	CANCEL_REPORT_DATE_RANGE,
	GET_CARD_BOOKINGS,
	SEND_REMINDER_CARD_PAYMENT,
	ALLOCATE_BOOKING,
	BOOKING_AUDIT,
	BOOKING_STATUS,
	AIRPORT_RUNS,
	TURNDOWN_BOOKINGS,
	RESTORE_CANCELLED,
} = bookingsEndpoints;
export async function cancelBookingByDateRange(data) {
	// Fetch current user details using token
	const response = await handlePostReq(CANCEL_BOOKING_DATE_RANGE, data);

	console.log('CANCEL BOOKING API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_ALL_GPS,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
}

export async function cancelReportByDateRange(data) {
	// Fetch current user details using token
	const response = await handlePostReq(CANCEL_REPORT_DATE_RANGE, data);

	console.log('CANCEL REPORT API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_ALL_GPS,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
}

export async function getAllCardBookings() {
	const response = await handleGetReq(GET_CARD_BOOKINGS);
	console.log('get all card bookings response ---', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_LOCAL_POI2,
		// 		reqBody: searchTerm,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return null;
}

export async function getBookingAudit(id) {
	const response = await handleGetReq(BOOKING_AUDIT(id));
	console.log('get booking audit response ---', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_LOCAL_POI2,
		// 		reqBody: searchTerm,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function sendReminderCardPayment(data) {
	// Fetch current user details using token
	const response = await handlePostReq(SEND_REMINDER_CARD_PAYMENT, data);

	console.log('SEND REMINDER BOOKING API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_ALL_GPS,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function getBookingByStatus(date, scope, status) {
	const response = await handlePostReq(BOOKING_STATUS(date, scope, status), {});
	console.log('get booking by status response ---', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_LOCAL_POI2,
		// 		reqBody: searchTerm,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function allocateBooking(data) {
	// Fetch current user details using token
	const response = await handlePostReq(ALLOCATE_BOOKING, data);

	console.log('ALLOCATE BOOKING API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_ALL_GPS,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function getAirportRuns(month) {
	const response = await handleGetReq(AIRPORT_RUNS(month));
	console.log('get airport runs response ---', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_LOCAL_POI2,
		// 		reqBody: searchTerm,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function getTurndownBookings(from, to) {
	const response = await handlePostReq(TURNDOWN_BOOKINGS(from, to), null);
	console.log('get all turndown bookings response ---', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_LOCAL_POI2,
		// 		reqBody: searchTerm,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function restoreCancelledBooking(bookingId) {
	// Fetch current user details using token
	const response = await handlePostReq(RESTORE_CANCELLED(bookingId), null);

	console.log('RESTORE_CANCELLED API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_ALL_GPS,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}
