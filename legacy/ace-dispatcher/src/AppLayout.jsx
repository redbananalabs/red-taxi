/** @format */

import { Outlet } from 'react-router-dom';
import Header from './ui/Header';
import { AuthProvider } from './context/AuthContext';
import { BookingProvider } from './context/BookingContext';
import CallerIdPopUp from './components/CallerIdPopUp';
import { Provider } from 'react-redux';
import store from './store';
import Footer from './ui/Footer';
import { useAuth } from './hooks/useAuth';
import { useEffect } from 'react';
import tracker from './utils/tracker';
// import { checkPreviousLogs } from './utils/getLogs';

const ALLOWED_USERS = [9, 25];

function InnerLayout() {
	const { currentUser } = useAuth(); // Assuming this exists

	console.log('Current User:', currentUser);

	useEffect(() => {
		if (currentUser && ALLOWED_USERS.includes(currentUser?.userId)) {
			tracker.setUserID(currentUser?.userId);
			tracker.setMetadata('fullName', currentUser?.fullName);
			tracker.start();
		}
	}, [currentUser]);

	return (
		<>
			<CallerIdPopUp />
			<Header />
			<Outlet />
			<Footer />
		</>
	);
}

function AppLayout() {
	// checkPreviousLogs();
	return (
		<AuthProvider>
			<BookingProvider>
				<Provider store={store}>
					<InnerLayout />
					{/* <Header />
					<Outlet />
					<Footer /> */}
				</Provider>
			</BookingProvider>
		</AuthProvider>
	);
}

export default AppLayout;
