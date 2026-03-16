/** @format */
import { useLocation, useNavigate } from 'react-router-dom'; // Import useLocation
import { FaAngleDown } from 'react-icons/fa';
import { useState } from 'react';
import { useDispatch } from 'react-redux';
import { logout } from '../../service/operations/authApi';
import { RiLogoutBoxLine } from 'react-icons/ri';
import { useEffect } from 'react';
import customImage from '../../assets/acelogo2.png';

const Header = () => {
	const location = useLocation();
	const dispatch = useDispatch();
	const navigate = useNavigate();
	const [dropdownOpen, setDropdownOpen] = useState(false); // Dropdown state
	const [fullName, setFullName] = useState(''); // State for fullName

	// Retrieve fullName from localStorage on component mount
	useEffect(() => {
		const storedName = localStorage.getItem('username');
		setFullName(storedName || 'Guest'); // Default to "Guest" if no fullName found
	}, []);

	// Access loading and error state from Redux
	// const { fullName } = useSelector((state) => state.auth);
	// console.log(fullName);

	// Handle logout
	// const handleLogout = () => {
	// 	navigate('/'); // Navigate to the logout route
	// };

	// Define headings for different routes
	const routeHeadings = {
		'/': 'ACCOUNT BOOKING REQUEST FORM',
		'/AddPassenger': ' ADD PASSENGER',
		'/passengerlist': ' PASSENGER LIST',
		'/existingPassengers': ' EXISTING PASSENGERS',
		'/createbookingform': ' CREATE BOOKING FORM',
		'/bookinghistory': '  BOOKING REQUEST HISTORY',
		'/activebookings': ' ACTIVE BOOKINGS',
		'/confirmation': ' CONFIRMATION',
	};

	// Determine heading based on current route
	const currentHeading = routeHeadings[location.pathname];

	return (
		<div className='bg-white'>
		<header className='px-4 bg-white sm:flex-row justify-between  flex px-2 sm:px-16'>
			{/* Custom Image Section */}
			<div className='flex flex-1 justify-center items-center sm:ml-[12rem] flex-col sm:flex-row'>
				<div>
					<div className='relative flex justify-center items-center'>
						{/* Image: Smaller for mobile, larger for desktop */}
						<img
							src={customImage}
							alt='Custom Banner'
							className='w-[180px] h-[50px] sm:w-[450px] sm:h-[120px] object-contain'
						/>
					</div>
				</div>
			</div>

			{/* Right Section: Account Info */}
			<div className='flex items-center text-center sm:text-right text-xs sm:text-base text-gray-700'>
				<div
					className='space-x-1 cursor-pointer'
					onClick={() => setDropdownOpen(!dropdownOpen)} // Toggle dropdown
				>
					<p className='text-gray-700 flex items-center'>
					<span className="hidden sm:inline text-lg md:text-lg">Logged in as:</span> {/* Hide on mobile, show on larger screens */}
					<span className='text-red-700 font-semibold ml-1 text-sm md:text-lg'>{fullName}</span>
						<FaAngleDown
							className={`text-red-700 ml-1 transform transition-transform duration-200 ${
								dropdownOpen ? 'rotate-0' : 'rotate-180'
							}`}
						/>
					</p>
				</div>

				{/* Dropdown Menu */}
				{dropdownOpen && (
					<div
						className='absolute right-0 mt-2 sm:mr-16 w-48 bg-white border border-gray-300 shadow-md rounded-md z-10'
						style={{ marginTop: '5rem' }}
					>
						<button
							onClick={() => dispatch(logout(navigate))}
							className='flex items-center justify-start w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100'
						>
							<RiLogoutBoxLine className='text-xl mr-2' />
							<span>Log Out</span>
						</button>
					</div>
				)}
			</div>
			
		</header>
		<div className='bg-white flex justify-center items-center px-4 sm:pl-12 rounded mt-2 sm:mt-0'>
		{/* Heading: Smaller for mobile */}
		<h2 className='text-sm sm:text-2xl font-bold text-center'>
			{currentHeading}
		</h2>
	</div>
	</div>
	);
};

export default Header;
