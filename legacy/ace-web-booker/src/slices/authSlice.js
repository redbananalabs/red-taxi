import { createSlice } from "@reduxjs/toolkit";

const initialState = {
    loading: false,
    token: localStorage.getItem("token") 
        ? JSON.parse(localStorage.getItem("token")) 
        : null,
    isAuth: localStorage.getItem("token") ? true : false,
    username: localStorage.getItem("username") 
        ? JSON.parse(localStorage?.getItem("username")) 
        : null, // Store username in localStorage
    userId: localStorage.getItem("userId") 
        ? JSON.parse(localStorage.getItem("userId")) 
        : null, // Store userId in localStorage
};

const authSlice = createSlice({
    name: "auth",
    initialState: initialState,
    reducers: {
        setLoading(state, action) {
            state.loading = action.payload;
        },
        setToken(state, action) {
            state.token = action.payload;
            localStorage.setItem("token", JSON.stringify(action.payload));
        },
        setUser(state, action) {
            state.username = action.payload.username; 
            state.userId = action.payload.userId; // Store userId
            localStorage.setItem("username", JSON.stringify(action.payload.username)); 
            localStorage.setItem("userId", JSON.stringify(action.payload.userId)); 
        },
        setIsAuth(state, action) {
            state.isAuth = action.payload;
        },
    },
});

export const { setToken, setLoading, setUser, setIsAuth } = authSlice.actions;
export default authSlice.reducer;
