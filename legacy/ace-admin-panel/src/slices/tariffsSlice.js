/** @format */

import { createSlice } from '@reduxjs/toolkit';
import { getAccountTariffs } from '../service/operations/settingsApi';

const initialState = {
	loading: false,
	accountTariffs: [],
	accountTariff: null,
};

const accountTariffSlice = createSlice({
	name: 'tariff',
	initialState,
	reducers: {
		setLoading(state, action) {
			state.loading = action.payload;
		},
		setAccountTariffs(state, action) {
			state.accountTariffs = action.payload;
		},
		setAccountTariff(state, action) {
			state.accountTariff = action.payload;
		},
	},
});

export function refreshAllAccountTariffs() {
	return async (dispatch) => {
		try {
			const response = await getAccountTariffs();
			console.log(response.data);

			if (response.status === 'success') {
				const resArr = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				dispatch(setAccountTariffs(resArr));
			}
		} catch (error) {
			console.error('Failed to refresh account tariffs:', error);
		}
	};
}

export const { setLoading, setAccountTariffs, setAccountTariff } =
	accountTariffSlice.actions;

export default accountTariffSlice.reducer;
