/** @format */

import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux'; // Redux hooks
import {
	addPassenger,
	fetchPassengers,
	setPassengers,
} from '../../slices/formSlice'; // Redux thunk for adding a passenger
import Header from '../Common/header';
import toast from 'react-hot-toast'; // Notification library
import { TiArrowBack } from 'react-icons/ti';
import {
	getAddressSuggestions,
	getAddressDetails,
} from '../../utils/addressAPI'; // Utility functions for address handling
import { getAllPassengers } from '../../service/operations/formApi';

const AddPassenger = () => {
	const navigate = useNavigate();
	const dispatch = useDispatch();

	// Redux states
	const { loading } = useSelector((state) => state.forms); // Sezlect loading state from Redux
	const { token = '', username, userId } = useSelector((state) => state.auth);
	// const token = 'static-token';

	// Local state for form inputs
	const [formData, setFormData] = useState({
		passengerName: '',
		description: '',
		address: '',
		postcode: '',
		phone: '',
		email: '',
	});

	// Local state for address suggestions
	const [addressSuggestions, setAddressSuggestions] = useState([]);
	const [highlightIndex, setHighlightIndex] = useState(-1); // ✅ Tracks selected dropdown item

	// Handle input changes
	const handleChange = (e) => {
		const { id, value } = e.target;
		setFormData({ ...formData, [id]: value });

		// Fetch address suggestions if typing in the address field
		if (id === 'address' && value.length > 2) {
			fetchSuggestions(value);
		}
	};

	// Fetch address suggestions
	const fetchSuggestions = async (query) => {
		try {
			const suggestions = await getAddressSuggestions(query);
			setAddressSuggestions(suggestions);
		} catch (error) {
			console.error('Error fetching address suggestions:', error);
		}
	};

	const handleKeyDown = (e) => {
		if (addressSuggestions.length === 0) return;

		if (e.key === 'ArrowDown') {
			setHighlightIndex((prev) => {
				const nextIndex =
					prev < addressSuggestions.length - 1 ? prev + 1 : prev;
				scrollToHighlightedItem(nextIndex); // ✅ Auto-scroll function call
				return nextIndex;
			});
		} else if (e.key === 'ArrowUp') {
			setHighlightIndex((prev) => {
				const prevIndex = prev > 0 ? prev - 1 : 0;
				scrollToHighlightedItem(prevIndex); // ✅ Auto-scroll function call
				return prevIndex;
			});
		} else if (e.key === 'Enter' && highlightIndex !== -1) {
			handleSelectSuggestion(addressSuggestions[highlightIndex].id);
			setHighlightIndex(-1);
		} else if (e.key === 'Escape') {
			setHighlightIndex(-1);
		}
	};

	// ✅ Function to scroll dropdown with keyboard navigation
	const scrollToHighlightedItem = (index) => {
		const dropdown = document.getElementById('address-dropdown');
		const highlightedItem = document.getElementById(`suggestion-${index}`);

		if (dropdown && highlightedItem) {
			dropdown.scrollTop = highlightedItem.offsetTop - dropdown.offsetTop;
		}
	};

	const handleSelectSuggestion = async (id) => {
		try {
			const details = await getAddressDetails(id);
			setFormData({
				...formData,
				address: details.address,
				postcode: details.postcode,
			});
			setAddressSuggestions([]); // ✅ Hide dropdown after selection
			setHighlightIndex(-1);
		} catch (error) {
			console.error('Error fetching address details:', error);
		}
	};

	const handleSubmit = async (e) => {
		e.preventDefault();

		// Validate required fields
		if (
			!formData.passengerName ||
			!formData.description ||
			!formData.address ||
			!formData.postcode
		) {
			toast.error('Please fill in all required fields');
			return;
		}

		// Ensure token and username are available
		if (!token) {
			toast.error('Authentication failed. Please login again.');
			return;
		}
		if (!username) {
			toast.error('Username is missing. Please login again.');
			return;
		}

		// Prepare request payload
		const requestBody = {
			id: 0, // Static value for new passengers
			accNo: username, // Use username instead of accNo object
			description: formData.description,
			passenger: formData.passengerName, // Map passengerName to passenger
			address: formData.address,
			postcode: formData.postcode,
			phone: formData.phone || '', // Optional field
			email: formData.email || '', // Optional field
		};

		console.log('Submitting Passenger Data:', requestBody);

		try {
			// Dispatch Redux action with token & data
			await dispatch(
				addPassenger({
					token, // Use token from Redux
					data: requestBody,
				})
			).unwrap(); // Wait for thunk to complete

			toast.success('Passenger created successfully!');

			// Fetch updated passenger list
			const response = await getAllPassengers(token, username);
			if (response.length > 0) dispatch(setPassengers(response));

			// Redirect after successful creation
			navigate('/passengerlist');
		} catch (error) {
			console.error('Error creating passenger:', error);
			toast.error(error.message || 'An error occurred');
		}
	};

	return (
		<div className='bg-white min-h-screen'>
			<Header />
			<div className=' bg-white pt-10 p-4 min-h-[500px] max-h-[80vh] overflow-y-auto sm:min-h-screen sm:max-h-full'>
				{/* Button Section */}
				<div className='flex justify-center gap-2 sm:gap-4 mb-6 sm:mb-8'>
					<button
						onClick={() => navigate('/')}
						className='px-3 py-2 sm:px-5 sm:py-2 bg-gray-300 text-gray-700 text-xs sm:text-sm rounded-lg hover:bg-gray-400 transition flex items-center'
					>
						<TiArrowBack className='mr-1 sm:mr-2' />
						<span>Back</span>
					</button>

					<button
						onClick={() => navigate('/add-passenger')}
						className='px-3 py-2 sm:px-5 sm:py-2 bg-[#b91c1c] text-white text-xs sm:text-sm rounded-lg hover:bg-red-700 transition'
					>
						Add Passenger
					</button>
					<button
						onClick={() => navigate('/passengerlist')}
						className='px-3 py-2 sm:px-5 sm:py-2 bg-gray-300 text-gray-700 text-xs sm:text-sm rounded-lg hover:bg-gray-400 transition'
					>
						Passenger List
					</button>
				</div>

				{/* Add Passenger Form */}
				<div className='flex justify-center'>
					<div className='w-full max-w-md sm:max-w-2xl bg-white p-4 sm:p-8 rounded-lg shadow-lg overflow-auto'>
						<form
							onSubmit={handleSubmit}
							className='space-y-4 sm:space-y-6'
						>
							{/* Passenger Name */}
							<div>
								<label
									htmlFor='passengerName'
									className='block text-xs sm:text-sm text-gray-700 font-medium mb-1'
								>
									Passenger Name:
									<span className='text-red-500 ml-1'>*</span>
								</label>
								<input
									type='text'
									id='passengerName'
									placeholder='Enter passenger name'
									value={formData.passengerName}
									onChange={handleChange}
									className='w-full px-3 py-2 sm:px-4 sm:py-3 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring text-xs sm:text-sm'
									required
								/>
							</div>

							{/* Description */}
							<div>
								<label
									htmlFor='description'
									className='block text-xs sm:text-sm text-gray-700 font-medium mb-1'
								>
									Description:
									<span className='text-red-500 ml-1'>*</span>
								</label>
								<input
									type='text'
									id='description'
									placeholder='Enter description'
									value={formData.description}
									onChange={handleChange}
									className='w-full px-3 py-2 sm:px-4 sm:py-3 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring text-xs sm:text-sm'
									required
								/>
							</div>

							{/* Address and Postcode */}
							<div className='grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4'>
								<div>
									<label
										htmlFor='address'
										className='block text-xs sm:text-sm text-gray-700 font-medium mb-1'
									>
										Address:
										<span className='text-red-500 ml-1'>*</span>
									</label>
									<div className='relative'>
										<input
											type='text'
											id='address'
											placeholder='Enter address'
											value={formData.address}
											onChange={handleChange}
											onKeyDown={handleKeyDown} // ✅ Keyboard navigation added
											className='w-full px-3 py-2 sm:px-4 sm:py-3 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring text-xs sm:text-sm'
											required
										/>
										{/* Suggestions Dropdown */}
										{addressSuggestions.length > 0 && (
											<ul
												id='address-dropdown' // ✅ Add this ID for scrolling
												className='absolute z-10 bg-white border border-gray-300 rounded shadow-lg max-h-40 overflow-y-auto w-full mt-1'
											>
												{addressSuggestions.map((suggestion, index) => (
													<li
														id={`suggestion-${index}`} // ✅ Add unique ID for each item
														key={suggestion.id}
														onClick={() =>
															handleSelectSuggestion(suggestion.id)
														}
														className={`px-3 sm:px-4 py-2 hover:bg-gray-100 cursor-pointer text-xs sm:text-sm ${
															highlightIndex === index ? 'bg-gray-200' : ''
														}`}
													>
														{suggestion.label}
													</li>
												))}
											</ul>
										)}
									</div>
								</div>

								<div>
									<label
										htmlFor='postcode'
										className='block text-xs sm:text-sm text-gray-700 font-medium mb-1'
									>
										Postcode:
										<span className='text-red-500 ml-1'>*</span>
									</label>
									<input
										type='text'
										id='postcode'
										placeholder='Enter postcode'
										value={formData.postcode}
										onChange={handleChange}
										className='w-full px-3 py-2 sm:px-4 sm:py-3 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring text-xs sm:text-sm'
										required
									/>
								</div>
							</div>

							{/* Phone and Email */}
							<div className='grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4'>
								<div>
									<label
										htmlFor='phone'
										className='block text-xs sm:text-sm text-gray-700 font-medium mb-1'
									>
										Phone #:
									</label>
									<input
										type='tel'
										id='phone'
										placeholder='Enter phone number'
										value={formData.phone}
										onChange={handleChange}
										className='w-full px-3 py-2 sm:px-4 sm:py-3 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring text-xs sm:text-sm'
									/>
								</div>

								<div>
									<label
										htmlFor='email'
										className='block text-xs sm:text-sm text-gray-700 font-medium mb-1'
									>
										Email:
									</label>
									<input
										type='email'
										id='email'
										placeholder='Enter email address'
										value={formData.email}
										onChange={handleChange}
										className='w-full px-3 py-2 sm:px-4 sm:py-3 bg-white border border-gray-300 rounded-lg focus:outline-none focus:ring text-xs sm:text-sm'
									/>
								</div>
							</div>

							{/* Buttons */}
							<div className='flex flex-col sm:flex-row justify-end gap-2 sm:gap-4'>
								<button
									type='button'
									onClick={() => navigate('/passengerlist')}
									className='px-3 py-2 sm:px-5 sm:py-2 bg-gray-300 text-gray-700 text-xs sm:text-sm rounded-lg hover:bg-gray-400'
								>
									Cancel
								</button>
								<button
									type='submit'
									className='px-3 py-2 sm:px-5 sm:py-2 bg-black text-white text-xs sm:text-sm rounded-lg'
									disabled={loading} // Disable button while loading
								>
									{loading ? 'Submitting...' : 'Create Passenger'}
								</button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	);
};

export default AddPassenger;
