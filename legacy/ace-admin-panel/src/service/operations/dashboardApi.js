/** @format */

// import { sendLogs } from '../../utils/getLogs';
import { handleGetReq, handlePostReq } from '../apiRequestHandler';
import { dashBoardEndpoints, driverEarningEndpoints } from '../apis';

const {
	GET_DASHBOARD,
	GET_SMS_HEART_BEAT,
	SEND_DIRECT_MSG_TO_DRIVER,
	SEND_GLOBAL_MSG_TO_DRIVER,
} = dashBoardEndpoints;
const { GET_DRIVER_EARNINGS_REPORT } = driverEarningEndpoints;

export async function dashboard() {
	const response = await handleGetReq(GET_DASHBOARD);

	console.log('GET DASHBOARD API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_DASHBOARD,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
}

export async function getSmaHeartBeat() {
	const response = await handleGetReq(GET_SMS_HEART_BEAT);

	// console.log('GET GET_SMS_HEART_BEAT API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_DASHBOARD,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
}

export async function sendDirectMsgToDriver(driver, msg) {
	const response = await handlePostReq(
		SEND_DIRECT_MSG_TO_DRIVER(driver, msg),
		null
	);

	console.log('SEND DIRECT MSG API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: SEND_DIRECT_MSG_TO_DRIVER(driver, msg),
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return true;
	}
}

export async function sendGlobalMsgToDriver(msg) {
	const response = await handlePostReq(SEND_GLOBAL_MSG_TO_DRIVER(msg), null);

	console.log('SEND GLOBAL MSG API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: SEND_DIRECT_MSG_TO_DRIVER(msg),
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return true;
	}
}

export async function driverEarningsReport(data) {
	const response = await handlePostReq(GET_DRIVER_EARNINGS_REPORT, data);

	console.log('GET DRIVER EARNINGS REPORT API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_DRIVER_EARNINGS_REPORT,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
}
