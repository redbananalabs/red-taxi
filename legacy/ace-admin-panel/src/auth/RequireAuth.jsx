/** @format */

import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { ScreenLoader } from '@/components/loaders';
import { useSelector } from 'react-redux';
const RequireAuth = () => {
	const { token, isAuth, loading } = useSelector((state) => state.auth);
	const location = useLocation();
	if (loading) {
		return <ScreenLoader />;
	}
	return token && isAuth ? (
		<Outlet />
	) : (
		<Navigate
			to='/auth/login'
			state={{
				from: location,
			}}
			replace
		/>
	);
};
export { RequireAuth };
