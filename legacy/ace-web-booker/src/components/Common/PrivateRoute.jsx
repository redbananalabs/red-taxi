
import { Outlet, Navigate } from 'react-router-dom';
import { useSelector } from 'react-redux';

const PrivateRoute = () => {
    const isAuth = useSelector((state) => state.auth.isAuth);
    const token = localStorage.getItem('token');

    console.log('isAuth:', isAuth, 'token:', token); // Debug log

    return isAuth && token ? <Outlet /> : <Navigate to="/login" />; // the token and auth is taking the redux and here we just check and navigate the login section 
};

export default PrivateRoute;
