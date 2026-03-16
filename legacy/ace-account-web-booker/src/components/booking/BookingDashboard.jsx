/** @format */
import { useNavigate } from 'react-router-dom';
import Header from '../Common/header';
import addpassenger from '../../assets/addpassenger.svg';
import existingpassenger from '../../assets/existingpassenger.svg';
import newbooking from '../../assets/newbooking.svg';
import payment from '../../assets/history.png';
// import customImage from '../../assets/acelogo2.png'; // Import your uploaded image
import activeImage from '../../assets/task-list.png';

const BookingDashboard = () => {
	const navigate = useNavigate();

	const handleCreateBooking = () => {
		navigate('/createbookingform');
	};

	const handleBookingHistory = () => {
		navigate('/bookinghistory');
	};

	const handleActiveBookings = () => {
		navigate('/activebookings');
	};

	const handleAddPassenger = () => {
		navigate('/AddPassenger');
	};

	const handleExistingPassengers = () => {
		navigate('/existingPassengers');
	};

	return (
		<div className='flex flex-col min-h-full max-h-full overflow-y-auto bg-white'>
			{/* Header Section */}
			<Header />

			{/* Main Section */}
			<div className='flex-1 flex justify-center items-center p-4'>
				{/* Buttons Section */}
				<div className='grid grid-cols-1 sm:grid-cols-5 gap-6 w-full max-w-7xl'>
					{/* Create New Booking Button */}
					<button
						onClick={handleCreateBooking}
						className='group bg-[#b91c1c] text-white rounded-lg shadow-lg py-6 sm:py-8 px-3 sm:px-6 text-center hover:bg-red-700 transition duration-300 flex flex-col items-center'
					>
						<img
							src={newbooking}
							alt='New Booking'
							className='w-12 h-12 sm:w-20 sm:h-20 mb-3 sm:mb-4 group-hover:scale-110 group-hover:filter transition-transform duration-300'
						/>
						<span className='font-semibold text-xs sm:text-lg text-center'>
							CREATE NEW BOOKING
						</span>
					</button>

					{/* History Page */}
					<button
						onClick={handleBookingHistory}
						className='group bg-[#b91c1c] text-white rounded-lg shadow-lg py-6 sm:py-8 px-3 sm:px-6 text-center hover:bg-red-700 transition duration-300 flex flex-col items-center'
					>
						<img
							src={payment}
							alt='Booking History'
							className='w-12 h-12 sm:w-20 sm:h-20 mb-3 sm:mb-4 group-hover:scale-110 group-hover:filter transition-transform duration-300'
						/>
						<span className='font-semibold text-xs sm:text-lg text-center'>
							BOOKING REQUEST HISTORY
						</span>
					</button>

					{/* Active bookings Page */}
					<button
						onClick={handleActiveBookings}
						className='group bg-[#b91c1c] text-white rounded-lg shadow-lg py-6 sm:py-8 px-3 sm:px-6 text-center hover:bg-red-700 transition duration-300 flex flex-col items-center'
					>
						<img
							src={activeImage}
							alt='Booking History'
							className='w-12 h-12 sm:w-20 sm:h-20 mb-3 sm:mb-4 group-hover:scale-110 group-hover:filter transition-transform duration-300'
						/>
						<span className='font-semibold text-xs sm:text-lg text-center'>
							ACTIVE BOOKINGS
						</span>
					</button>

					{/* Add New Passenger Button */}
					<button
						onClick={handleAddPassenger}
						className='group bg-[#b91c1c] text-white rounded-lg shadow-lg py-6 sm:py-8 px-3 sm:px-6 text-center hover:bg-red-700 transition duration-300 flex flex-col items-center'
					>
						<img
							src={addpassenger}
							alt='Add Passenger'
							className='w-12 h-12 sm:w-20 sm:h-20 mb-3 sm:mb-4 group-hover:scale-110 group-hover:filter transition-transform duration-300'
						/>
						<span className='font-semibold text-xs sm:text-lg text-center'>
							ADD NEW PASSENGER
						</span>
					</button>

					{/* Existing Passengers Button */}
					<button
						onClick={handleExistingPassengers}
						className='group bg-[#b91c1c] text-white rounded-lg shadow-lg py-6 sm:py-8 px-3 sm:px-6 text-center hover:bg-red-700 transition duration-300 flex flex-col items-center'
					>
						<img
							src={existingpassenger}
							alt='Existing Passengers'
							className='w-12 h-12 sm:w-20 sm:h-20 mb-3 sm:mb-4 group-hover:scale-110 group-hover:filter transition-transform duration-300'
						/>
						<span className='font-semibold text-xs sm:text-lg text-center'>
							EXISTING PASSENGERS
						</span>
					</button>
				</div>
			</div>
		</div>
	);
};

export default BookingDashboard;
