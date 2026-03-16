import { webbookingfromEndpoints } from "../api";
import { apiConnector } from "../apiConnector";
import toast from "react-hot-toast";

// Destructure API endpoints for cleaner usage
const { CREATEWEBBOOKING_CREATE_FORM } = webbookingfromEndpoints;

/**
 * Creates a new web booking action plan
 * @param {string} token - Authentication token
 * @param {object} webBookingData - Data for creating the web booking
 * @returns {Promise<object>} - Response data on success
 */
export const createActionPlan = async (token, webBookingData) => {
  try {
    if (!token) {
      throw new Error("Authentication token is required");
    }

    const response = await apiConnector(
      "POST",
      CREATEWEBBOOKING_CREATE_FORM,
      webBookingData,
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      }
    );

    // Handle success based on status code
    if (response.status === 201 || response.status === 200) {
      toast.success("Booking Added Successfully");
      return response.data;
    } else {
      throw new Error(
        response?.data?.message || "Unexpected response from server"
      );
    }
  } catch (error) {
    handleError(error, "Failed to create action plan");
    throw error; // Re-throw to allow caller to handle if needed
  }
};

/**
 * Handles API errors and displays appropriate toast messages
 * @param {Error} error - The error object from the API call
 * @param {string} defaultMessage - Fallback error message
 */
const handleError = (error, defaultMessage) => {
  console.error("API Error:", error);
  const errorMessage =
    error.response?.data?.error || error.message || defaultMessage;
  toast.error(errorMessage);
};