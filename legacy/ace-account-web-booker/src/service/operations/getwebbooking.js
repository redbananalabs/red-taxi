

import axios from "axios";
import { createAsyncThunk } from "@reduxjs/toolkit";
import { getwebbookingEndpoints } from "../api";

// ✅ Async Thunk to fetch Web Bookings
export const fetchWebBookings = createAsyncThunk(
  "webbookings/fetchWebBookings",
  async (_, { rejectWithValue, getState }) => {
      try {
          // Get token from Redux state (adjust path according to your store structure)
          const state = getState();
          const token = state.auth?.token; // Assuming token is stored in auth slice
          const accNo = state.auth?.username; // Assuming account number is stored in auth slice

          console.log("accNo:", accNo);

          // Configure axios request with token in headers
          const config = {
              headers: {
                  Authorization: `Bearer ${token}`,
                  "Content-Type": "application/json",
              },
          };

          const { data } = await axios.post(
              getwebbookingEndpoints.GETWEBBOOKING,
              {  
                  accNo: accNo,
                  processed: false,
                  accepted: false,
                  rejected: false,
              },
              config // Pass the config with token
          );

          // 🔹 Validate response format in a single check
          if (!Array.isArray(data)) {
              return rejectWithValue("Invalid data format received from server");
          }

          return data;
      } catch (error) {
          console.error("Fetch Web Bookings Error:", error);
          return rejectWithValue(error.response?.data || "Error fetching web bookings");
      }
  }
);
