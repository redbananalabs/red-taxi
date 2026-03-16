/** @format */

// import { sendLogs } from '../../utils/getLogs';
import axios from "axios";
import { handleGetReq, handlePostReq } from "../apiRequestHandler";
import { reportsEndpoints } from "../apis";

const {
  DUPLICATE_BOOKINGS,
  GET_BOOKING_SCOPE_BREAKDOWN,
  GET_TOP_CUSTOMER,
  GET_PICKUP_POSTCODES,
  GET_VEHICLE_TYPE_COUNTS,
  GET_AVERAGE_DURATION,
  GET_GROWTH_BY_PERIOD,
  GET_REVENUE_BY_MONTH,
  GET_PAYOUTS_BY_MONTH,
  GET_PROFITABILITY_ON_INVOICE,
  GET_TOTAL_PROFITABILITY_BY_PERIOD,
  GET_PROFITABILITY_BY_DATE_RANGE,
  GET_QR_SCANS,
  SUBMIT_TICKET,
} = reportsEndpoints;

export async function duplicateBookings(startDate) {
  const response = await handlePostReq(DUPLICATE_BOOKINGS(startDate));

  console.log("DUPLICATE_BOOKINGS API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getBookingScopeBreakdown(from, to, period, compare) {
  const response = await handlePostReq(
    GET_BOOKING_SCOPE_BREAKDOWN(from, to, period, compare)
  );

  console.log("GET_BOOKING_SCOPE_BREAKDOWN API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getTopCustomer(from, to, scope, depth) {
  const response = await handlePostReq(
    GET_TOP_CUSTOMER(from, to, scope, depth)
  );

  console.log("GET_TOP_CUSTOMER API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getPickupPostcodes(from, to, scope) {
  const response = await handlePostReq(GET_PICKUP_POSTCODES(from, to, scope));

  console.log("GET_PICKUP_POSTCODES API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getVehicleTypeCounts(from, to, scope) {
  const response = await handlePostReq(
    GET_VEHICLE_TYPE_COUNTS(from, to, scope)
  );

  console.log("GET_VEHICLE_TYPE_COUNTS API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getAverageDuration(from, to, period, scope) {
  const response = await handlePostReq(
    GET_AVERAGE_DURATION(from, to, period, scope)
  );

  console.log("GET_AVERAGE_DURATION API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getGrowthByPeriod(
  startMonth,
  startYear,
  endMonth,
  endYear,
  viewBy
) {
  const response = await handlePostReq(
    GET_GROWTH_BY_PERIOD(startMonth, startYear, endMonth, endYear, viewBy)
  );

  console.log("GET_GROWTH_BY_PERIOD API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getRevenueByMonth(from, to) {
  const response = await handlePostReq(GET_REVENUE_BY_MONTH(from, to));

  console.log("GET_REVENUE_BY_MONTH API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getPayoutsByMonth(from, to) {
  const response = await handlePostReq(GET_PAYOUTS_BY_MONTH(from, to));

  console.log("GET_PAYOUTS_BY_MONTH API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getProfitabilityOnInvoice(from, to) {
  const response = await handlePostReq(GET_PROFITABILITY_ON_INVOICE(from, to));

  console.log("GET_PROFITABILITY_ON_INVOICE API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getTotalProfitabilityByPeriod(from, to) {
  const response = await handlePostReq(
    GET_TOTAL_PROFITABILITY_BY_PERIOD(from, to)
  );

  console.log(
    "GET_TOTAL_PROFITABILITY_BY_PERIOD API RESPONSE.........",
    response
  );

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getProfitabilityByDateRange(from, to) {
  const response = await handlePostReq(
    GET_PROFITABILITY_BY_DATE_RANGE(from, to)
  );

  console.log(
    "GET_PROFITABILITY_BY_DATE_RANGE API RESPONSE.........",
    response
  );

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function getQrScans() {
  const response = await handleGetReq(GET_QR_SCANS);

  console.log("GET_QR_SCANS API RESPONSE.........", response);

  if (response.status === "success") {
    // sendLogs(
    // 	{
    // 		url: UPDATE_MSG_CONFIG,
    // 		reqBody: data,
    // 		headers: setHeaders(),
    // 		response: response,
    // 	},
    // 	'info'
    // );
    return response;
  }
}

export async function submitTicket(formData) {
  const accessToken = localStorage.getItem("authToken");
  if (!accessToken) return {};

  try {
    const response = await axios.post(SUBMIT_TICKET, formData, {
      headers: {
        Accept: "*/*",
        Authorization: `Bearer ${accessToken}`,
      },
    });
    if (response.status >= 200 && response.status < 300) {
      return {
        ...response.data,
        status: "success",
      };
    }
    // fallback (rare case)
    return {
      status: "fail",
      message: "Unexpected response status",
    };
  } catch (err) {
    console.error("SubmitTicket Error:", err);

    return {
      ...err.response,
      status: err.response?.status > 499 ? "error" : "fail",
      message: `${
        err.response?.status > 499 ? "server error" : "Failed"
      } while submitting ticket`,
    };
  }
}
