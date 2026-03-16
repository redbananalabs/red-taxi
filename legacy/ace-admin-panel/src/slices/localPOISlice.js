/** @format */

import { createSlice } from '@reduxjs/toolkit';
import { getAllPois } from '../service/operations/localPOIApi';

const initialState = {
	loading: false,
	localPOIs: [],
	localPOI: null,
};

const localPoiSlice = createSlice({
	name: 'localPoi',
	initialState,
	reducers: {
		setLoading(state, action) {
			state.loading = action.payload;
		},
		setLocalPOIs(state, action) {
			state.localPOIs = action.payload;
		},
		setLocalPOI(state, action) {
			state.localPOI = action.payload;
		},
	},
});

export function refreshAllLocalPOIS() {
	return async (dispatch) => {
		try {
			const response = await getAllPois();
			console.log(response.data);

			if (response.status === 'success') {
				const poisArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				dispatch(setLocalPOIs(poisArray));
			}
		} catch (error) {
			console.error('Failed to refresh local Pois:', error);
		}
	};
}

export const { setLoading, setLocalPOIs, setLocalPOI } = localPoiSlice.actions;

export default localPoiSlice.reducer;
