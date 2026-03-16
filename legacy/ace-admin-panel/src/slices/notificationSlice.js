/** @format */

import { createSlice } from '@reduxjs/toolkit';
import {
	clearALLNotification,
	clearALLNotificationWithoutType,
	clearNotification,
	getNotifications,
} from '../service/operations/notificationApi';

const initialState = {
	loading: false,
	muteNotification:
		localStorage.getItem('muteNotification') === 'true' ? true : false,
	allNotifications: [],
	systemNotifications: [],
	driverNotifications: [],
	notification: null,
	unreadCount: 0,
};

const notificationSlice = createSlice({
	name: 'notification',
	initialState,
	reducers: {
		setLoading(state, action) {
			state.loading = action.payload;
		},
		setALLNotifications(state, action) {
			state.allNotifications = action.payload;
			state.unreadCount = action.payload.filter((n) => n.status === 0).length;
		},
		setSystemNotifications(state, action) {
			state.systemNotifications = action.payload;
		},
		setDriverNotifications(state, action) {
			state.driverNotifications = action.payload;
		},
		setNotification(state, action) {
			state.notification = action.payload;
		},
		clearUnreadCount(state) {
			state.unreadCount = 0;
		},
		setMuteNotification(state, action) {
			state.muteNotification = action.payload;
			localStorage.setItem('muteNotification', action.payload);
		},
	},
});

export function refreshNotifications() {
	return async (dispatch) => {
		try {
			const response = await getNotifications();

			if (response.status === 'success') {
				const resultArray = Object.keys(response)
					.filter((key) => key !== 'status')
					.map((key) => response[key]);

				const systemNotificationsArray = resultArray.filter(
					(data) => data?.event === 1,
				);
				const driverNotificationsArray = resultArray.filter(
					(data) => data?.event === 2,
				);
				dispatch(setALLNotifications(resultArray));
				dispatch(setSystemNotifications(systemNotificationsArray));
				dispatch(setDriverNotifications(driverNotificationsArray));
			}
		} catch (error) {
			console.error('Failed to refresh users:', error);
		}
	};
}

export function markAsReadNotification(id) {
	return async (dispatch) => {
		try {
			const response = await clearNotification(id);
			if (response) {
				dispatch(refreshNotifications());
			}
		} catch (error) {
			console.log(error);
		}
	};
}

export function markAsAllReadNotifications(type) {
	return async (dispatch) => {
		try {
			let response;
			if (type === 0) {
				response = await clearALLNotificationWithoutType();
			} else {
				response = await clearALLNotification(type);
			}
			if (response) {
				dispatch(refreshNotifications());
			}
		} catch (error) {
			console.log(error);
		}
	};
}

export const {
	setLoading,
	setALLNotifications,
	setNotification,
	setSystemNotifications,
	setDriverNotifications,
	clearUnreadCount,
	setMuteNotification,
} = notificationSlice.actions;

export default notificationSlice.reducer;
