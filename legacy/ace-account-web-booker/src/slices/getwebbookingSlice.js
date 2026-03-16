import { createSlice } from "@reduxjs/toolkit";
import { fetchWebBookings } from "../service/operations/getwebbooking"; // ✅ Import the async thunk    

const initialState = {
  webBookings: [], // ✅ Ensure default is an array
  loading: false,
  error: null,
};

const webBookingSlice = createSlice({
  name: "webbookings",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchWebBookings.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchWebBookings.fulfilled, (state, action) => {
        state.loading = false;
        state.webBookings = Array.isArray(action.payload) ? action.payload : []; // ✅ Ensure it’s always an array
      })
      .addCase(fetchWebBookings.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
        state.webBookings = []; // ✅ Keep it as an empty array on error
      });
  },
});

export default webBookingSlice.reducer;
