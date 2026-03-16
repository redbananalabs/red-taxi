/** @format */

// import { sendLogs } from '../../utils/getLogs';
import { handleGetReq, handlePostReq } from '../apiRequestHandler';
import { availabilityEndpoints } from '../apis';

const {
	GET_AVAILABILITY,
	GET_AVAILABILITY_LOG,
	DELETE_AVAILABILITY,
	SET_AVAILABILITY,
	AVAILABILITY_REPORT,
} = availabilityEndpoints;

export async function getAvailability(userId, date) {
	// Fetch current user details using token
	const response = await handleGetReq(GET_AVAILABILITY(userId, date));

	console.log('Get Availability API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_AVAILABILITY,
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

export async function getAvailabilityLog(userId, date) {
	const response = await handleGetReq(GET_AVAILABILITY_LOG(userId, date));

	console.log('Get Availability Log API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_AVAILABILITY_LOG(userId, date),
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

export async function updateAvailability(data) {
	const response = await handlePostReq(SET_AVAILABILITY, data);

	console.log('SET AVAILABILITY API response.', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_AVAILABILITY_LOG(userId, date),
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

export async function availabilityReport(data) {
	const response = await handlePostReq(AVAILABILITY_REPORT, data);

	console.log('AVAILABILITY REPORT API response.', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_AVAILABILITY_LOG(userId, date),
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

export async function deleteAvailability(id) {
	const response = await handleGetReq(DELETE_AVAILABILITY(id));

	console.log('DELETE AVAILABILITY API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		//     {
		//         url: DELETE_AVAILABILITY(id),
		//         reqBody: null,
		//         headers: setHeaders(),
		//         response: response,
		//     },
		//     'info'
		// );
		return response;
	}
	return response;
}
