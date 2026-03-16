import { toast } from "react-hot-toast";
import { endpoints } from "../api";
import { apiConnector } from "../apiConnector";
import { setIsAuth, setLoading, setToken, setUser } from "../../slices/authSlice";

const { LOGIN_API } = endpoints;

export function login(userName, password, navigate) {
    return async (dispatch) => {
        dispatch(setLoading(true));
        try {
            // Call API for login
            const response = await apiConnector("POST", LOGIN_API, {
                userName,
                password,
            });

            if (response.status !== 200) {
                throw new Error(response.data?.message || "Login failed");
            }

            toast.success("Login successful!");

            // Extract token, userId, and username from API response
            const { token, userId, username } = response.data; 

            // Update Redux Store
            dispatch(setToken(token));
            dispatch(setUser({ username, userId })); // Store username & userId
            dispatch(setIsAuth(true)); 

            // Save token, username, and userId to localStorage
            localStorage.setItem("token", JSON.stringify(token));
            localStorage.setItem("username", JSON.stringify(username)); 
            localStorage.setItem("userId", JSON.stringify(userId)); // Store userId

            // Navigate to dashboard
            navigate("/");
        } catch (error) {
            dispatch(setIsAuth(false));
            toast.error("Invalid credentials");
        } finally {
            dispatch(setLoading(false));
        }
    };
}


// Ensure refreshToken is declared and exported
export const refreshToken = async () => {
	const response = await fetch('/api/auth/refresh', {
		method: 'POST',
		credentials: 'include', // Include cookies if required
	});
	if (!response.ok) {
		throw new Error('Failed to refresh token');
	}
	return await response.json();
};


export function logout(navigate) {
    return (dispatch) => {
        console.log("LOGOUT");
        dispatch(setToken(null));
        dispatch(setUser({ username: null, userId: null }));
        dispatch(setIsAuth(false));

        // Remove token, username, and userId from localStorage
        localStorage.removeItem("token");
        localStorage.removeItem("username"); 
        localStorage.removeItem("userId"); // Remove userId
        localStorage.removeItem("hasModalShown");

        toast.success("Logged Out");
        navigate("/login");
    };
}




