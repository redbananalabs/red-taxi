/** @format */

import { createSlice } from "@reduxjs/toolkit";
import {
  duplicateBookings,
  getAverageDuration,
  getBookingScopeBreakdown,
  getGrowthByPeriod,
  getPayoutsByMonth,
  getPickupPostcodes,
  getProfitabilityByDateRange,
  getProfitabilityOnInvoice,
  getQrScans,
  getRevenueByMonth,
  getTopCustomer,
  getTotalProfitabilityByPeriod,
  getVehicleTypeCounts,
} from "../service/operations/reportsApi";

const initialState = {
  loading: false,
  duplicateBookings: [],
  bookingScopeBreakdown: [],
  topCustomers: [],
  pickupPostcodes: [],
  vehicleTypesCounts: [],
  averageDuration: [],
  growthByPeriod: [],
  revenueByMonth: [],
  payoutsByMonth: [],
  profitabilityOnInvoice: [],
  totalProfitabilityByPeriod: [],
  profitabilityByDateRange: [],
  qrScansAdverts: [],
};

const reportSlice = createSlice({
  name: "reports",
  initialState,
  reducers: {
    setLoading(state, action) {
      state.loading = action.payload;
    },
    setDuplicateBookings(state, action) {
      state.duplicateBookings = action.payload;
    },
    setBookingScopeBreakdown(state, action) {
      state.bookingScopeBreakdown = action.payload;
    },
    setTopCustomers(state, action) {
      state.topCustomers = action.payload;
    },
    setPickupPostcodes(state, action) {
      state.pickupPostcodes = action.payload;
    },
    setVehicleTypeCounts(state, action) {
      state.vehicleTypesCounts = action.payload;
    },
    setAverageDuration(state, action) {
      state.averageDuration = action.payload;
    },
    setGrowthByPeriod(state, action) {
      state.growthByPeriod = action.payload;
    },
    setRevenueByMonth(state, action) {
      state.revenueByMonth = action.payload;
    },
    setPayoutsByMonth(state, action) {
      state.payoutsByMonth = action.payload;
    },
    setProfitabilityOnInvoice(state, action) {
      state.profitabilityOnInvoice = action.payload;
    },
    setTotalProfitabilityByPeriod(state, action) {
      state.totalProfitabilityByPeriod = action.payload;
    },
    setProfitabilityByDateRange(state, action) {
      state.profitabilityByDateRange = action.payload;
    },
    setQrScansAdverts(state, action) {
      state.qrScansAdverts = action.payload;
    },
  },
});

export function refreshDuplicateBookings(startDate) {
  return async (dispatch) => {
    try {
      const response = await duplicateBookings(startDate);
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setDuplicateBookings(array));
      }
    } catch (error) {
      console.error("Failed to refresh duplicate Bookings:", error);
    }
  };
}

export function refreshBookingScopeBreakdown(from, to, period, compare) {
  return async (dispatch) => {
    try {
      const response = await getBookingScopeBreakdown(
        from,
        to,
        period,
        compare
      );
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setBookingScopeBreakdown(array));
      }
    } catch (error) {
      console.error("Failed to refresh Booking scope breakdown:", error);
    }
  };
}

export function refreshTopCustomer(from, to, scope, depth) {
  return async (dispatch) => {
    try {
      const response = await getTopCustomer(from, to, scope, depth);
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setTopCustomers(array));
      }
    } catch (error) {
      console.error("Failed to refresh Top Customers:", error);
    }
  };
}

export function refreshPickupPostcodes(from, to, scope) {
  return async (dispatch) => {
    try {
      const response = await getPickupPostcodes(from, to, scope);
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setPickupPostcodes(array));
      }
    } catch (error) {
      console.error("Failed to refresh Pickup postcodes:", error);
    }
  };
}

export function refreshVehicleTypeCounts(from, to, scope) {
  return async (dispatch) => {
    try {
      const response = await getVehicleTypeCounts(from, to, scope);
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setVehicleTypeCounts(array));
      }
    } catch (error) {
      console.error("Failed to refresh Vehicle Type Counts:", error);
    }
  };
}

export function refreshAverageDuration(from, to, period, scope) {
  return async (dispatch) => {
    try {
      const response = await getAverageDuration(from, to, period, scope);
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setAverageDuration(array));
      }
    } catch (error) {
      console.error("Failed to refresh Average Duration:", error);
    }
  };
}

export function refreshGrowthByPeriod(
  startMonth,
  startYear,
  endMonth,
  endYear,
  viewBy
) {
  return async (dispatch) => {
    try {
      const response = await getGrowthByPeriod(
        startMonth,
        startYear,
        endMonth,
        endYear,
        viewBy
      );
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setGrowthByPeriod(array));
      }
    } catch (error) {
      console.error("Failed to refresh Growth By Period:", error);
    }
  };
}

export function refreshRevenueByMonth(from, to) {
  return async (dispatch) => {
    try {
      const response = await getRevenueByMonth(from, to);
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setRevenueByMonth(array));
      }
    } catch (error) {
      console.error("Failed to refresh Revenue By Month:", error);
    }
  };
}

export function refreshPayoutsByMonth(from, to) {
  return async (dispatch) => {
    try {
      const response = await getPayoutsByMonth(from, to);
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setPayoutsByMonth(array));
      }
    } catch (error) {
      console.error("Failed to refresh Revenue By Month:", error);
    }
  };
}

export function refreshProfitabilityOnInvoice(from, to) {
  return async (dispatch) => {
    try {
      const response = await getProfitabilityOnInvoice(from, to);
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setProfitabilityOnInvoice(array));
      }
    } catch (error) {
      console.error("Failed to refresh Profitability On Invoice:", error);
    }
  };
}

export function refreshTotalProfitabilityByPeriod(from, to) {
  return async (dispatch) => {
    try {
      const response = await getTotalProfitabilityByPeriod(from, to);
      console.log(response);

      if (response.status === "success") {
        // const array = Object.keys(response)
        //   .filter((key) => key !== "status") // Exclude 'status' field
        //   .map((key) => response[key]);

        dispatch(setTotalProfitabilityByPeriod([{ ...response }]));
      }
    } catch (error) {
      console.error("Failed to refresh Total Profitability By Period:", error);
    }
  };
}

export function refreshProfitabilityByDateRange(from, to) {
  return async (dispatch) => {
    try {
      const response = await getProfitabilityByDateRange(from, to);
      console.log(response);

      if (response.status === "success") {
        // const array = Object.keys(response)
        //   .filter((key) => key !== "status") // Exclude 'status' field
        //   .map((key) => response[key]);

        dispatch(setProfitabilityByDateRange([{ ...response }]));
      }
    } catch (error) {
      console.error("Failed to refresh Profitability By DateRange:", error);
    }
  };
}

export function refreshQrScansAdverts() {
  return async (dispatch) => {
    try {
      const response = await getQrScans();
      console.log(response);

      if (response.status === "success") {
        const array = Object.keys(response)
          .filter((key) => key !== "status") // Exclude 'status' field
          .map((key) => response[key]);

        dispatch(setQrScansAdverts(array));
      }
    } catch (error) {
      console.error("Failed to refresh Total Profitability By Period:", error);
    }
  };
}

export const {
  setLoading,
  setDuplicateBookings,
  setBookingScopeBreakdown,
  setAverageDuration,
  setGrowthByPeriod,
  setPayoutsByMonth,
  setPickupPostcodes,
  setRevenueByMonth,
  setTopCustomers,
  setVehicleTypeCounts,
  setProfitabilityOnInvoice,
  setTotalProfitabilityByPeriod,
  setProfitabilityByDateRange,
  setQrScansAdverts
} = reportSlice.actions;

export default reportSlice.reducer;
