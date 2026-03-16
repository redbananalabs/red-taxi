/** @format */

import { createSlice } from '@reduxjs/toolkit';
import { getAccounts } from '../service/operations/accountApi';

const initialState = {
	loading: false,
	accounts: [],
	account: null,
};

const accountSlice = createSlice({
	name: 'account',
	initialState: initialState,
	reducers: {
		setLoading(state, action) {
			state.loading = action.payload;
		},
		setAccounts(state, action) {
			state.accounts = action.payload;
		},
		setAccount(state, action) {
			state.account = action.payload;
		},
	},
});

export function refreshAllAccounts() {
	return async (dispatch) => {
		try {
			const response = await getAccounts();

			if (response.status === 'success') {
				const accountsArray = Object.keys(response)
					.filter((key) => key !== 'status') // Exclude 'status' field
					.map((key) => response[key]);

				dispatch(setAccounts(accountsArray));
			}
		} catch (error) {
			console.error('Failed to refresh Accounts:', error);
		}
	};
}

export const { setLoading, setAccounts, setAccount } = accountSlice.actions;

export default accountSlice.reducer;
