/** @format */

// import { sendLogs } from '../../utils/getLogs';
import toast from 'react-hot-toast';
import { handleGetReq, handlePostReq } from '../apiRequestHandler';
import { LocalPoiEndpoints } from '../apis';

const { CREATE_LOCAL_POI, UPDATE_LOCAL_POI, DELETE_LOCAL_POI, GET_ALL_POIS } =
	LocalPoiEndpoints;

export async function getAllPois() {
	const response = await handleGetReq(GET_ALL_POIS);
	console.log('get all pois response ---', response);

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

export async function createPoi(data) {
	const response = await handlePostReq(CREATE_LOCAL_POI, data);
	console.log('create local poi response ---', response);

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
		toast.success('Local POI Created Successfully');
		return response;
	}
	return null;
}

export async function updatePoi(data) {
	const response = await handlePostReq(UPDATE_LOCAL_POI, data);
	console.log('update local poi response ---', response);

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
		toast.success('Local POI Updated Successfully');
		return response;
	}
	return null;
}

export async function deletePoi(id) {
	const response = await handleGetReq(DELETE_LOCAL_POI(id));
	console.log('delete local poi response ---', response);
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
		toast.success('Local POI Deleted Successfully');
		return response;
	}
	return false;
}
