/** @format */

// import { sendLogs } from '../../utils/getLogs';
import { handleGetReq, handlePostReq } from '../apiRequestHandler';
import { driverEndpoints } from '../apis';

const {
	DRIVER_EXPENSES,
	GET_DRIVER_LIST,
	ADD_DRIVER,
	UPDATE_DRIVER,
	DELETE_DRIVER,
	GET_DRIVER_RESEND_LOGIN,
	GET_DRIVER_SHOW_ALL_JOBS,
	GET_DRIVER_SHOW_HVS_JOBS,
	GET_DRIVER_LOCKOUT,
	GET_DRIVER_EXPIRYS,
	UPDATE_DRIVER_EXPIRYS,
} = driverEndpoints;

export async function getAllDrivers() {
	const response = await handleGetReq(GET_DRIVER_LIST);
	console.log('get all drivers response ---', response);

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

export async function createDriver(data) {
	const response = await handlePostReq(ADD_DRIVER, data);
	console.log('create driver response ---', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: CREATE_LOCAL_POI,
		// 		reqBody: data,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function updateDriver(data) {
	const response = await handlePostReq(UPDATE_DRIVER, data);
	console.log('update Driver response ---', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: UPDATE_LOCAL_POI,
		// 		reqBody: data,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function deleteDriver(id) {
	const response = await handlePostReq(DELETE_DRIVER(id), {});
	console.log('delete driver response ---', response);
	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: DELETE_LOCAL_POI,
		// 		reqBody: { id },
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );

		return response;
	}
	return false;
}

export async function driverExpenses(data) {
	const response = await handlePostReq(DRIVER_EXPENSES, data);
	console.log('driver expenses response ---', response);
	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: DELETE_LOCAL_POI,
		// 		reqBody: { id },
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function driverResendLogin(id) {
	const response = await handleGetReq(GET_DRIVER_RESEND_LOGIN(id));
	console.log('driver resend login response ---', response);
	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: DELETE_LOCAL_POI,
		// 		reqBody: { id },
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function driverShowAllJobs(id, turnOn) {
	const response = await handleGetReq(GET_DRIVER_SHOW_ALL_JOBS(id, turnOn));
	console.log('driver show all jobs response ---', response);
	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: DELETE_LOCAL_POI,
		// 		reqBody: { id },
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function driverShowHvsJobs(id, turnOn) {
	const response = await handleGetReq(GET_DRIVER_SHOW_HVS_JOBS(id, turnOn));
	console.log('driver show hvs jobs response ---', response);
	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: DELETE_LOCAL_POI,
		// 		reqBody: { id },
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function driverLockout(id, lockout) {
	const response = await handleGetReq(GET_DRIVER_LOCKOUT(id, lockout));
	console.log('driver lockout response ---', response);
	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: DELETE_LOCAL_POI,
		// 		reqBody: { id },
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function driverExpirys() {
	const response = await handleGetReq(GET_DRIVER_EXPIRYS);
	console.log('driver expirys response ---', response);
	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: DELETE_LOCAL_POI,
		// 		reqBody: { id },
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}

export async function updateDriverExpirys(data) {
	const response = await handlePostReq(UPDATE_DRIVER_EXPIRYS, data);
	console.log('update driver expirys response ---', response);
	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: DELETE_LOCAL_POI,
		// 		reqBody: { id },
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return response;
}
