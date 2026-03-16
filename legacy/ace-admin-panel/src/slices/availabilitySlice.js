/** @format */

import { createSlice } from '@reduxjs/toolkit';
import {
	availabilityReport,
	getAvailability,
	getAvailabilityLog,
} from '../service/operations/availabilityApi';

const initialState = {
	loading: false,
	allAvailability: [],
	availability: [],
	availabilityLog: [],
	availabilityReportData: {},
	availableHoursByDay: [],
	weekDay: [],
	weekEnd: [],
	week: [],
	month: [],
	unavailable: [],
};

const availabilitySlice = createSlice({
	name: 'availability',
	initialState: initialState,
	reducers: {
		setLoading: (state, action) => {
			state.loading = action.payload;
		},
		setALLAvailability: (state, action) => {
			state.allAvailability = action.payload;
		},
		setAvailability: (state, action) => {
			state.availability = action.payload;
		},
		setAvailabilityLog: (state, action) => {
			state.availabilityLog = action.payload;
		},
		setAvailabilityReportData: (state, action) => {
			state.availabilityReportData = action.payload;
		},
		setAvailableHoursByDay: (state, action) => {
			state.availableHoursByDay = action.payload;
		},
		setWeekDay: (state, action) => {
			state.weekDay = action.payload;
		},
		setWeekEnd: (state, action) => {
			state.weekEnd = action.payload;
		},
		setWeek: (state, action) => {
			state.week = action.payload;
		},
		setMonth: (state, action) => {
			state.month = action.payload;
		},
		setUnavailable: (state, action) => {
			state.unavailable = action.payload;
		},
	},
});

export function refreshAvailability(userId, date) {
	return async (dispatch) => {
		try {
			const response = await getAvailability(userId, date);
			console.log(response.data);

			if (response.status === 'success') {
				const availabilityArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				if (userId === 0) {
					dispatch(setALLAvailability(availabilityArray));
				} else {
					dispatch(setAvailability(availabilityArray));
				}
			}
		} catch (error) {
			console.error('Failed to refresh availability:', error);
		}
	};
}

export function refreshAllAvailability(date) {
	return async (dispatch) => {
		try {
			const response = await getAvailability(0, date);
			console.log(response.data);

			if (response.status === 'success') {
				const availabilityArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				dispatch(setALLAvailability(availabilityArray));
			}
		} catch (error) {
			console.error('Failed to refresh availability:', error);
		}
	};
}

export function refreshAvailabilityLog(userId, date) {
	return async (dispatch) => {
		try {
			dispatch(setLoading(true));
			const response = await getAvailabilityLog(userId, date);
			console.log(response.data);

			if (response.status === 'success') {
				const availabilityArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				dispatch(setAvailabilityLog(availabilityArray));
			}
		} catch (error) {
			console.error('Failed to refresh availability:', error);
		} finally {
			dispatch(setLoading(false));
		}
	};
}

export function refreshAvailabilityReport(payload) {
	return async (dispatch) => {
		try {
			dispatch(setLoading(true));
			const response = await availabilityReport(payload);

			if (response.status === 'success') {
				dispatch(setAvailabilityReportData(response));
				dispatch(setAvailableHoursByDay(response?.availableHoursByDay));
				dispatch(setWeekDay(response?.weekDay));
				dispatch(setWeekEnd(response?.weekEnd));
				dispatch(setWeek(response?.week));
				dispatch(setMonth(response?.month));
				dispatch(setUnavailable(response?.unavailable));
			}
		} catch (error) {
			console.error('Failed to refresh availability report data:', error);
		} finally {
			dispatch(setLoading(false));
		}
	};
}

export const {
	setAvailability,
	setALLAvailability,
	setLoading,
	setAvailabilityLog,
	setAvailabilityReportData,
	setAvailableHoursByDay,
	setWeekDay,
	setWeekEnd,
	setWeek,
	setMonth,
	setUnavailable,
} = availabilitySlice.actions;

export default availabilitySlice.reducer;
