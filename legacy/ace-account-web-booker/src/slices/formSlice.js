/** @format */

// Import required functions from Redux Toolkit
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

// Import service functions for API calls
import {
	getAllPassengers,
	deletePassenger,
	addNewPassenger, // Import add passenger API function
} from '../service/operations/formApi';



const formSlice = createSlice({
	name: 'forms',
	initialState: {
		passengers: [], // List of passengers
		forms: [], // Forms array
		selectedPassenger: null, // Selected passenger for editing or viewing
		loading: false, // Loading state
		success: null, // Success message
		error: null, // Error message
	},

	reducers: {
		updateForm: (state, action) => {
			const index = state.forms.findIndex(
				(form) => form.id === action.payload.id
			);
			if (index !== -1) {
				state.forms[index] = { ...state.forms[index], ...action.payload };
			}
		},
		setPassengers: (state, action) => {
			state.passengers = action.payload;
		},
		setSelectedPassenger: (state, action) => {
			state.selectedPassenger = action.payload;
		},
		resetStatus: (state) => {
			state.success = null;
			state.error = null;
		},
	},

	extraReducers: (builder) => {
		builder
			// Fetch Passengers
			.addCase(fetchPassengers.pending, (state) => {
				state.loading = true;
				state.error = null;
			})
			.addCase(fetchPassengers.fulfilled, (state, action) => {
				state.loading = false;
				state.passengers = action.payload;
			})
			.addCase(fetchPassengers.rejected, (state, action) => {
				state.loading = false;
				state.error = action.payload;
			})

			// Remove Passenger
			.addCase(removePassenger.pending, (state) => {
				state.loading = true;
				state.error = null;
				state.success = null;
			})
			.addCase(removePassenger.fulfilled, (state, action) => {
				state.loading = false;
				state.success = 'Passenger deleted successfully!';
				state.passengers = state.passengers.filter(
					(passenger) => passenger.id !== action.payload
				);
			})
			.addCase(removePassenger.rejected, (state, action) => {
				state.loading = false;
				state.error = action.payload;
			})

			// Add Passenger
			.addCase(addPassenger.pending, (state) => {
				state.loading = true;
				state.error = null;
				state.success = null;
			})
			.addCase(addPassenger.fulfilled, (state, action) => {
				state.loading = false;
				state.success = 'Passenger added successfully!';
				state.passengers.push(action.payload); // Add new passenger to the list
			})
			.addCase(addPassenger.rejected, (state, action) => {
				state.loading = false;
				state.error = action.payload;
			});
	},
});

export const fetchPassengers = createAsyncThunk(
	'forms/fetchPassengers',
	async (_, { getState, rejectWithValue }) => {
		const { forms } = getState();
		if (forms.passengers.length > 0) {
			// Return cached passengers if already fetched
			console.log('Using cached passengers');
			return forms.passengers;
		}

		try {
			const token = getState().auth.token; // Replace with your actual token
			const accountNo = getState().auth.username; // Static account number
			const response = await getAllPassengers(token, accountNo); // API call
			return response; // Return passenger list
		} catch (error) {
			console.error('Fetch Passengers Error:', error);
			return rejectWithValue(
				error.response?.data?.error || 'Failed to fetch passengers'
			);
		}
	}
);

export const removePassenger = createAsyncThunk(
	'forms/removePassenger',
	async ({ token, id }, { rejectWithValue }) => {
		try {
			// API call
			await deletePassenger(token, id);

			// Return the deleted passenger ID
			return id;
		} catch (error) {
			console.error('Delete Passenger Error:', error.message);
			return rejectWithValue(
				error.response?.data?.error || 'Failed to delete passenger'
			);
		}
	}
);

export const addPassenger = createAsyncThunk(
	'forms/addPassenger',
	async ({ token, data }, { rejectWithValue }) => {
		try {
			const response = await addNewPassenger(token, data); // API call
			return response; // Return added passenger data
		} catch (error) {
			console.error('Add Passenger Error:', error.message);
			return rejectWithValue(
				error.response?.data?.error || 'Failed to add passenger'
			);
		}
	}
);

// Export reducers and actions
export const { updateForm, setPassengers, setSelectedPassenger, resetStatus } =
	formSlice.actions;
export default formSlice.reducer;
