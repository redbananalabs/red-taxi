/** @format */

import { toast } from "react-hot-toast";
import { authEndpoints } from "../apis";
import {
  setIsAuth,
  setLoading,
  setToken,
  setUser,
  setGetUser,
} from "../../slices/authSlice";
import { handleGetReq, handlePostReq, setHeaders } from "../apiRequestHandler";
import { sendLogs } from "../../utils/getLogs";

const { LOGIN, REGISTER, GET_USER, RESET_PASSWORD } = authEndpoints;

export function register(data, navigate) {
  return async (dispatch) => {
    dispatch(setLoading(true));
    const response = await handlePostReq(REGISTER, data);
    console.log("SIGNUP API RESPONSE.........", response);

    if (response.status === "success") {
      toast.success("User Register Successfully");
      navigate("/");
      // sendLogs(
      // 	{
      // 		url: REGISTER,
      // 		reqBody: data,
      // 		headers: setHeaders(),
      // 		response: response,
      // 	},
      // 	'info'
      // );
    } else {
      toast.error("Failed to Register New User");
      navigate("/auth/signup");
    }

    dispatch(setLoading(false));
  };
}

export function login(data, navigate) {
  return async (dispatch) => {
    dispatch(setLoading(true));

    const response = await handlePostReq(LOGIN, data);

    console.log("LOGIN API RESPONSE.........", response);
    if (response.status === "success") {
      toast.success("Login Successfully");
      const user = {
        userId: response?.userId,
        fullName: response?.fullName,
        username: data?.username,
        isAdmin: response?.isAdmin,
        regNo: response?.regNo,
        roleId: response?.roleId,
        type: response?.type,
        value: response?.value,
      };

      dispatch(setToken(response.token));
      dispatch(setUser(user));
      dispatch(setIsAuth(true));
      localStorage.setItem("authToken", response.token);
      localStorage.setItem("username", JSON.stringify(user.username));
      localStorage.setItem("userData", JSON.stringify(response));
      navigate("/");

      // sendLogs(
      // 	{
      // 		url: LOGIN,
      // 		reqBody: data,
      // 		headers: setHeaders(),
      // 		response: response,
      // 	},
      // 	'info'
      // );
    } else {
      toast.error("Failed to Login User");
      navigate("/auth/login");
    }

    dispatch(setLoading(false));
  };
}

export function getUser(navigate) {
  return async (dispatch, getState) => {
    // Check for token in Redux state or localStorage
    const storedToken =
      getState().auth.token || localStorage.getItem("authToken");

    const username = getState().auth.username;

    if (!storedToken) {
      console.log("No token provided, redirecting to sign-in.");
      toast.error("No token found. Please log in.");
      dispatch(setToken(null));
      dispatch(setIsAuth(false));
      dispatch(setUser(null));
      dispatch(setGetUser(null));
      navigate("/auth/login"); // Redirect to login again
      return;
    }
    dispatch(setLoading(true));

    // Fetch current user details using token
    const response = await handleGetReq(GET_USER(username));

    console.log("GET ME API RESPONSE.........", response);

    if (response.status === "success") {
      dispatch(setGetUser(response.data));
      dispatch(setIsAuth(true));
      sendLogs(
        {
          url: LOGIN,
          reqBody: username,
          headers: setHeaders(),
          response: response,
        },
        "info"
      );
    } else {
      dispatch(setToken(null));
      dispatch(setIsAuth(false));
      localStorage.removeItem("authToken");
      localStorage.removeItem("username");
      localStorage.removeItem("userData");

      // Redirect to login page
      navigate("/auth/login");
    }

    navigate("/");

    dispatch(setLoading(false));
  };
}

export function verify(navigate) {
  return async (dispatch, getState) => {
    const auth = getState().auth.isAuth;

    if (auth) {
      try {
        dispatch(setLoading(true));

        // Fetch user details from the API
        const response = await handleGetReq(GET_USER());

        if (response.status === "success") {
          dispatch(setUser(response.data)); // Update user in the state
          dispatch(setIsAuth(true));
          toast.success("User verified successfully");

          sendLogs(
            {
              url: GET_USER(),
              headers: setHeaders(),
              response: response,
            },
            "info"
          );
        } else {
          // Clear state and token on failure
          dispatch(setToken(null));
          dispatch(setUser(null));
          dispatch(setIsAuth(false));
          localStorage.removeItem("authToken");
          localStorage.removeItem("username");
          localStorage.removeItem("userData");

          toast.error("User verification failed. Please log in again.");
          navigate("/auth/login");
        }
      } catch (error) {
        // Handle any unexpected errors
        console.error("Verification Error:", error);
        dispatch(setToken(null));
        dispatch(setUser(null));
        dispatch(setIsAuth(false));
        localStorage.removeItem("authToken");
        localStorage.removeItem("username");
        localStorage.removeItem("userData");

        toast.error("An error occurred during verification.");
        navigate("/auth/login");
      } finally {
        dispatch(setLoading(false));
      }
    } else {
      // If not authenticated, redirect to login
      toast.error("You are not authenticated. Please log in.");
      navigate("/auth/login");
    }
  };
}

export async function resetUserPassword(userId) {
  // Fetch reset password link using the user ID
  const response = await handleGetReq(RESET_PASSWORD(userId));

  console.log("RESET PASSWORD API RESPONSE.........", response);

  if (response.status === "success") {
    toast.success("Reset password request sent successfully");
    sendLogs(
      {
        url: RESET_PASSWORD(userId),
        reqBody: userId,
        headers: setHeaders(),
        response: response,
      },
      "info"
    );
    const mergedString = Object.keys(response)
      .filter((key) => !isNaN(key)) // Keep only numeric keys
      .sort((a, b) => a - b) // Sort keys in order
      .map((key) => response[key]) // Extract values
      .join("");
    return {
      ...response,
      password: mergedString,
    };
  } else {
    toast.error("Failed to send reset password request");
  }
}

export function logout(navigate) {
  return (dispatch) => {
    dispatch(setToken(null));
    dispatch(setUser(null));
    dispatch(setGetUser(null));
    dispatch(setIsAuth(false));
    localStorage.removeItem("authToken");
    localStorage.removeItem("username");
    localStorage.removeItem("userData");
    localStorage.removeItem("isNotification");
    localStorage.removeItem("lastSystemId");
    localStorage.removeItem("lastDriverId");
    localStorage.removeItem("muteNotification");

    // ✅ Send logout message to headless iframe
    const iframe = document.getElementById("bookingDispatch");
    if (iframe) {
      iframe.contentWindow.postMessage(
        { action: "logout" },
        import.meta.env.VITE_IFRAME_URL
      );
    }

    toast.success("Logged Out");
    navigate("/auth/login");
  };
}
