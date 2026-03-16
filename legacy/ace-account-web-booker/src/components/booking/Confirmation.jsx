/** @format */

import { useNavigate } from 'react-router-dom';
import Header from '../Common/header';
import { RiLogoutBoxLine } from 'react-icons/ri';
import { useDispatch } from 'react-redux';
import { logout } from '../../service/operations/authApi';
import { MdDashboard } from 'react-icons/md'; // Dashboard Icon
import { motion } from 'framer-motion'; // ✅ Import Framer Motion

function Confirmation() {
	const navigate = useNavigate();
	const dispatch = useDispatch();

	const handleNewBooking = () => {
		navigate('/createbookingform'); // Navigate to Create Booking Form
	};

	const handleDashboard = () => {
		navigate('/'); // Navigate to Dashboard
	};

	return (
		<div className='bg-white min-h-screen'>
			{/* ✅ Header remains unchanged */}
			<Header />

			{/* ✅ Main Content with Entry Animation */}
			<motion.div
				className='flex flex-col items-center justify-center min-h-[80vh] px-6'
				initial={{ opacity: 0, y: 30 }}
				animate={{ opacity: 1, y: 0 }}
				transition={{ duration: 0.8, ease: 'easeOut' }}
			>
				{/* ✅ Success Message with Bounce Animation */}
				<motion.div
					className='w-full max-w-2xl bg-green-500 text-white text-2xl font-bold text-center py-5 rounded-lg shadow-md'
					initial={{ scale: 0.5, opacity: 0 }}
					animate={{ scale: 1, opacity: 1 }}
					transition={{
						type: 'spring',
						stiffness: 150,
						damping: 10,
						delay: 0.2,
					}}
				>
					🎉 Booking Request Created
				</motion.div>

				{/* ✅ Confirmation Text with Fade-in */}
				<motion.div
					className='w-full max-w-2xl mt-8 bg-white rounded-lg p-8 text-center'
					initial={{ opacity: 0 }}
					animate={{ opacity: 1 }}
					transition={{ duration: 0.6, delay: 0.4 }}
				>
					<p className='text-gray-700 text-lg leading-relaxed'>
						Your booking request has been successfully created. An operator will
						review your booking shortly, and you will receive an email
						confirmation.
					</p>
					<p className='mt-4 text-red-600 font-semibold'>
						Please note: This booking is not confirmed until you receive a
						booking confirmation email.
					</p>
				</motion.div>

				{/* ✅ Action Buttons with Staggered Animation */}
				<motion.div
					className='flex flex-wrap justify-center gap-6 mt-10 w-full max-w-2xl'
					initial='hidden'
					animate='visible'
					variants={{
						hidden: { opacity: 0, y: 20 },
						visible: {
							opacity: 1,
							y: 0,
							transition: { staggerChildren: 0.2, delayChildren: 0.6 },
						},
					}}
				>
					{/* 🏠 Dashboard Button */}
					<motion.button
						onClick={handleDashboard}
						className='px-8 py-3 bg-gray-800 text-white font-medium text-lg rounded-lg hover:bg-gray-900 transition duration-300 shadow-md flex items-center justify-center gap-2'
						variants={{
							hidden: { opacity: 0, y: 20 },
							visible: { opacity: 1, y: 0 },
						}}
					>
						<MdDashboard className='text-2xl' />
						Go to Dashboard
					</motion.button>

					{/* ➕ New Booking Button */}
					<motion.button
						onClick={handleNewBooking}
						className='px-8 py-3 bg-blue-600 text-white font-medium text-lg rounded-lg hover:bg-blue-700 transition duration-300 shadow-md'
						variants={{
							hidden: { opacity: 0, y: 20 },
							visible: { opacity: 1, y: 0 },
						}}
					>
						New Booking Request +
					</motion.button>

					{/* 🔴 Log Out Button */}
					<motion.button
						onClick={() => dispatch(logout(navigate))}
						className='px-8 py-3 bg-red-600 text-white font-medium text-lg rounded-lg hover:bg-red-700 transition duration-300 shadow-md flex items-center justify-center gap-2'
						variants={{
							hidden: { opacity: 0, y: 20 },
							visible: { opacity: 1, y: 0 },
						}}
					>
						<RiLogoutBoxLine className='text-2xl' />
						Log Out
					</motion.button>
				</motion.div>
			</motion.div>
		</div>
	);
}

export default Confirmation;
