/** @format */

import toast from 'react-hot-toast';
import { sendLogs } from '../../utils/getLogs';
import { handleGetReq, handlePostReq, setHeaders } from '../apiRequestHandler';
import { accountEndpoints } from '../apis';

const {
	GET_ACCOUNTS,
	UPDATE_ACCOUNTS,
	CREATE_ACCOUNTS,
	DELETE_ACCOUNTS,
	REGISTER_ACCOUNT_WEB_BOOKER,
	GET_CLEAR_INVOICE,
} = accountEndpoints;

export async function createAccounts(data) {
	const response = await handlePostReq(CREATE_ACCOUNTS, data);
	console.log('create accounts response ---', response);

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
		toast.success('Account Created Successfully');
		return response;
	}
	return null;
}

export async function getAccounts() {
	// Fetch current user details using token
	const response = await handleGetReq(GET_ACCOUNTS);

	console.log('Get List Account API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: GET_ACCOUNTS,
		// 		reqBody: null,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return null;
}

export async function updateAccounts(data) {
	// Upload accounts data using token
	const response = await handlePostReq(UPDATE_ACCOUNTS, data);
	console.log('Upload Account API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: UPDATE_ACCOUNTS,
		// 		reqBody: data,
		// 		headers: setHeaders(),
		// 		response: response,
		// 	},
		// 	'info'
		// );
		return response;
	}
	return null;
}

export async function registerAccountOnWebBooker(data) {
	// Upload accounts data using token
	const response = await handlePostReq(REGISTER_ACCOUNT_WEB_BOOKER, data);
	console.log('Register Account API RESPONSE.........', response);

	if (response.status === 'success') {
		// sendLogs(
		// 	{
		// 		url: UPDATE_ACCOUNTS,
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

export async function deleteAccounts(accno) {
	const response = await handleGetReq(DELETE_ACCOUNTS(accno));
	console.log('delete accounts response ---', response);
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
		toast.success('Account Deleted Successfully');
		return response;
	}
	return false;
}

export async function getClearInvoice(invoiceNo) {
	const response = await handleGetReq(GET_CLEAR_INVOICE(invoiceNo));

	console.log('clear invoice api response ---', response);

	if (response.status === 'success') {
		sendLogs(
			{
				url: GET_CLEAR_INVOICE(invoiceNo),
				reqBody: null,
				headers: setHeaders(),
				response: response,
			},
			'info'
		);
		return response;
	}
	return null;
}
