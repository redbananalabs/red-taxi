/** @format */

import { combineReducers } from '@reduxjs/toolkit';

import authReducer from '../slices/authSlice';
import accountReducer from '../slices/accountSlice';
import localPoiReducer from '../slices/localPOISlice';
import bookingReducer from '../slices/bookingSlice';
import availabilityReducer from '../slices/availabilitySlice';
import dashboardReducer from '../slices/dashboardSlice';
import webBookingReducer from '../slices/webBookingSlice';
import notificationReducer from '../slices/notificationSlice';
import driverReducer from '../slices/driverSlice';
import billingReducer from '../slices/billingSlice';
import reportReducer from '../slices/reportSlice';
import tariffReducer from '../slices/tariffsSlice';

const rootReducer = combineReducers({
	auth: authReducer,
	dashboard: dashboardReducer,
	account: accountReducer,
	availability: availabilityReducer,
	booking: bookingReducer,
	webBooking: webBookingReducer,
	localPoi: localPoiReducer,
	notification: notificationReducer,
	driver: driverReducer,
	billing: billingReducer,
	reports: reportReducer,
	tariff: tariffReducer,
});

export default rootReducer;
