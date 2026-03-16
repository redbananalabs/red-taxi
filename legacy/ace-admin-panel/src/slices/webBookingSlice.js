/** @format */

import { createSlice } from '@reduxjs/toolkit';
import {
	getAcceptedWebBookings,
	getAmendRequests,
	getRejectedWebBookings,
	getWebBookings,
} from '../service/operations/webBookingsApi';

const initialState = {
	loading: false,
	webBookings: [],
	rejectedWebBookings: [],
	acceptedWebBookings: [],
	amendRequests: [],
	amendRequest: null,
	webBooking: null,
	rejectBooking: null,
};

const webBookingSlice = createSlice({
	name: 'webBooking',
	initialState: initialState,
	reducers: {
		setLoading: (state, action) => {
			state.loading = action.payload;
		},
		setWebBookings: (state, action) => {
			state.webBookings = action.payload;
		},
		setRejectedWebBookings: (state, action) => {
			state.rejectedWebBookings = action.payload;
		},
		setAcceptedWebBookings: (state, action) => {
			state.acceptedWebBookings = action.payload;
		},
		setWebBooking: (state, action) => {
			state.webBooking = action.payload;
		},
		setAmendRequests: (state, action) => {
			state.amendRequests = action.payload;
		},
		setAmendRequest: (state, action) => {
			state.amendRequest = action.payload;
		},
		setRejectBooking: (state, action) => {
			state.rejectBooking = action.payload;
		},
	},
});

export function refreshWebBookings() {
	return async (dispatch) => {
		try {
			const response = await getWebBookings();
			console.log(response.data);

			if (response.status === 'success') {
				const bookingsArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				const notAcceptedBookings = bookingsArray.filter(
					(booking) => !booking.processed && booking.status !== 1
				); // Convert objects to an array

				dispatch(setWebBookings(notAcceptedBookings));
			}
		} catch (error) {
			console.error('Failed to refresh web bookings:', error);
		}
	};
}

export function refreshRejectedWebBookings() {
	return async (dispatch) => {
		try {
			const response = await getRejectedWebBookings();

			if (response.status === 'success') {
				const bookingsArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]); // Convert objects to an array

				dispatch(setRejectedWebBookings(bookingsArray));
			}
		} catch (error) {
			console.error('Failed to refresh rejected web bookings:', error);
		}
	};
}

export function refreshAcceptedWebBookings() {
	return async (dispatch) => {
		try {
			const response = await getAcceptedWebBookings();

			if (response.status === 'success') {
				const bookingsArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]); // Convert objects to an array

				dispatch(setAcceptedWebBookings(bookingsArray));
			}
		} catch (error) {
			console.error('Failed to refresh rejected web bookings:', error);
		}
	};
}

export function refreshAmendWebBookings() {
	return async (dispatch) => {
		try {
			const response = await getAmendRequests();
			console.log(response.data);

			if (response.status === 'success') {
				const amendArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);
				dispatch(setAmendRequests(amendArray));
			}
		} catch (error) {
			console.error('Failed to refresh web bookings:', error);
		}
	};
}

export const {
	setLoading,
	setWebBooking,
	setWebBookings,
	setRejectedWebBookings,
	setAcceptedWebBookings,
	setAmendRequests,
	setAmendRequest,
	setRejectBooking,
} = webBookingSlice.actions;
export default webBookingSlice.reducer;
