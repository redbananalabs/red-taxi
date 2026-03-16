/** @format */

import { createSlice } from '@reduxjs/toolkit';
import {
	driverExpenses,
	driverExpirys,
	driverLockout,
	driverResendLogin,
	driverShowAllJobs,
	driverShowHvsJobs,
	getAllDrivers,
} from '../service/operations/driverApi';
import toast from 'react-hot-toast';

const initialState = {
	loading: false,
	drivers: [],
	driversExpiryList: [],
	driversExpiry: null,
	driver: null,
	driverExpenses: {},
};

const driverSlice = createSlice({
	name: 'driver',
	initialState,
	reducers: {
		setLoading(state, action) {
			state.loading = action.payload;
		},
		setDrivers(state, action) {
			state.drivers = action.payload;
		},
		setDriver(state, action) {
			state.driver = action.payload;
		},
		setDriversExpiryList(state, action) {
			state.driversExpiryList = action.payload;
		},
		setDriversExpiry(state, action) {
			state.driversExpiry = action.payload;
		},
		setDriverExpenses(state, action) {
			state.driverExpenses = action.payload;
		},
	},
});

export function refreshAllDrivers() {
	return async (dispatch) => {
		try {
			const response = await getAllDrivers();
			console.log(response.data);

			if (response.status === 'success') {
				const driversArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				dispatch(setDrivers(driversArray));
			}
		} catch (error) {
			console.error('Failed to refresh drivers:', error);
		}
	};
}

export function handleLockJobs(id, lockout) {
	return async (dispatch) => {
		try {
			const response = await driverLockout(id, lockout);

			if (response.status === 'success') {
				toast.success('Driver Locked Successfully');
				dispatch(refreshAllDrivers());
			}
		} catch (error) {
			console.error('Failed to refresh drivers:', error);
		}
	};
}

export function handleShowAllJobs(id, turnOn) {
	return async (dispatch) => {
		try {
			const response = await driverShowAllJobs(id, turnOn);

			if (response.status === 'success') {
				toast.success('Driver Show Jobs Successfully');
				dispatch(refreshAllDrivers());
			}
		} catch (error) {
			console.error('Failed to refresh drivers:', error);
		}
	};
}

export function handleShowHvsJobs(id, turnOn) {
	return async (dispatch) => {
		try {
			const response = await driverShowHvsJobs(id, turnOn);

			if (response.status === 'success') {
				toast.success('Driver Show HVS Successfully');
				dispatch(refreshAllDrivers());
			}
		} catch (error) {
			console.error('Failed to refresh drivers:', error);
		}
	};
}

export function handleSendJobs(id) {
	return async (dispatch) => {
		try {
			const response = await driverResendLogin(id);

			if (response.status === 'success') {
				toast.success('Driver send Successfully');
				dispatch(refreshAllDrivers());
			}
		} catch (error) {
			console.error('Failed to refresh drivers:', error);
		}
	};
}

export function refreshAllDriversExpiry() {
	return async (dispatch) => {
		try {
			const response = await driverExpirys();

			if (response.status === 'success') {
				const driversExpiryArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				dispatch(setDriversExpiryList(driversExpiryArray));
			}
		} catch (error) {
			console.error('Failed to refresh drivers:', error);
		}
	};
}

export function refreshDriversExpenses(data) {
	return async (dispatch) => {
		try {
			dispatch(setLoading(true));
			const response = await driverExpenses(data);
			console.log(response);

			if (response.status === 'success') {
				dispatch(
					setDriverExpenses({
						data: response.data || [],
						total: response.total || 0,
					})
				);
			}
		} catch (error) {
			console.error('Failed to refresh drivers Expense:', error);
		} finally {
			dispatch(setLoading(false));
		}
	};
}

export const {
	setLoading,
	setDrivers,
	setDriver,
	setDriverExpenses,
	setDriversExpiryList,
	setDriversExpiry,
} = driverSlice.actions;

export default driverSlice.reducer;
