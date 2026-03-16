/** @format */
import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import { createActionPlan } from "../service/operations/webbookingApi"; // Import the API function


/**
 * Async Thunk: Create a new action plan
 */
export const createActionPlanThunk = createAsyncThunk(
  "actionPlan/create",
  async ({ formData }, { rejectWithValue }) => {
    try {
      const response = await createActionPlan("token", formData); // Ensure the correct token is used
      return response;
    } catch (error) {
      return rejectWithValue(
        error.response?.data?.error || error.message || "Failed to create action plan"
      );
    }
  }
);


const actionPlanSlice = createSlice({
  name: "actionPlan",
  initialState: {
    loading: false,
    success: null,
    error: null,
  },
  reducers: {
    resetStatus: (state) => {
      state.success = null;
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Pending State
      .addCase(createActionPlanThunk.pending, (state) => {
        state.loading = true;
        state.success = null;
        state.error = null;
      })
      // Fulfilled State
      .addCase(createActionPlanThunk.fulfilled, (state) => {
        state.loading = false;
        state.success = "Action plan created successfully!";
        state.error = null;
      })
      // Rejected State
      .addCase(createActionPlanThunk.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
        state.success = null;
      });
  },
});

// Export actions and reducer
export const { resetStatus } = actionPlanSlice.actions;
export default actionPlanSlice.reducer;
