/** @format */
import PrivateRoute from './components/Common/PrivateRoute';
import { Route, Routes } from 'react-router-dom';
import CreateBookingForm from './components/booking/CreateBookingForm';
import Confirmation from './components/booking/Confirmation';
import Login from './components/Authentication/Login';
import AddPassenger from './components/booking/AddPassenger';
import BookingDashboard from './components/booking/BookingDashboard';
import PassengerList from './components/booking/PassengerList';
import ExistingPassenger from './components/booking/ExistingPassenger';
import HistoryBooking from './components/booking/HistoryBooking';
import ActiveBooking from './components/booking/ActiveBooking';

function App() {
	return (
		<div className='h-screen w-screen overflow-hidden bg-[#F3F4F6]'>
			<Routes>
				{/* Public Routes */}
				<Route
					path='/login'
					element={<Login />}
				/>

				{/* Protected Routes */}
				<Route element={<PrivateRoute />}>
					<Route
						path='/'
						element={<BookingDashboard />}
					/>
					<Route
						path='/createbookingform'
						element={<CreateBookingForm />}
					/>
					<Route
						path='/bookinghistory'
						element={<HistoryBooking />}
					/>
					<Route
						path='/activebookings'
						element={<ActiveBooking />}
					/>
					<Route
						path='/confirmation'
						element={<Confirmation />}
					/>
					<Route
						path='/AddPassenger'
						element={<AddPassenger />}
					/>
					<Route
						path='/existingpassengers'
						element={<ExistingPassenger />}
					/>
					<Route
						path='/passengerlist'
						element={<PassengerList />}
					/>
				</Route>
			</Routes>
		</div>
	);
}

export default App;
