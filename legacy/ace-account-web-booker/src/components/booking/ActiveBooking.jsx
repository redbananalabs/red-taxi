/** @format */
import React from 'react';
import { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import { TiArrowBack } from 'react-icons/ti';
import moment from 'moment';
import {
	Box,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
	Button,
	TextField,
	CircularProgress,
	IconButton,
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
} from '@mui/material';
import { FaArrowUp } from 'react-icons/fa6';
import { FaArrowDown } from 'react-icons/fa6';
import { FaMinus, FaPlus } from 'react-icons/fa';

import {
	fetchActiveBookings,
	amendBooking,
	cancelBooking,
} from '../../slices/activeSlice';
import Header from '../Common/header';
import { toast } from 'react-hot-toast';
import { debounce } from 'lodash';

// Row Component for Each Booking
function Row({ row, isParent, isOpen, toggleGroup, lowestBookingId }) {
	const dispatch = useDispatch();
	const [openAmendModal, setOpenAmendModal] = useState(false);
	const [openCancelModal, setOpenCancelModal] = useState(false);
	const [cancelType, setCancelType] = useState('');
	const [message, setMessage] = useState('');
	const [loading, setLoading] = useState(false);
	const recurrenceId = row?.recurranceId ?? 0;
	const changesPending = row?.changesPending || false;
	const applyToBlock = row?.applyToBlock || false;

	const handleAmendSubmit = async (isAmendAll = false) => {
		if (!message.trim()) {
			toast.error('Amendment message cannot be empty!');
			return;
		}

		setLoading(true);
		try {
			await dispatch(
				amendBooking({
					bookingId: row.bookingId,
					message: message,
					block: isAmendAll ? true : false,
					recurrenceId: recurrenceId,
				})
			).unwrap();
			toast.success(
				isAmendAll ? 'All Amendments Submitted' : 'Amendment Request Submitted'
			);
			setOpenAmendModal(false);
			setMessage('');
		} catch (error) {
			toast.error('Failed to amend booking.');
		}
		setLoading(false);
	};

	const handleCancelSubmit = async (
		isCancelAll = false,
		isCancelFuture = false
	) => {
		setLoading(true);
		try {
			// Use the lowestBookingId for "Cancel All" operations, or row.bookingId for individual cancels or "Cancel This & Future"
			const bookingIdToUse =
				isCancelAll && recurrenceId !== 0 ? lowestBookingId : row.bookingId;

			await dispatch(
				cancelBooking({
					bookingId: bookingIdToUse,
					block: isCancelAll || isCancelFuture ? true : false, // block: true for "Cancel All" or "Cancel This & Future"
					recurrenceId: recurrenceId,
				})
			).unwrap();
			toast.success(
				isCancelAll
					? 'All Bookings Cancelled'
					: isCancelFuture
					? 'This and Future Bookings Cancelled'
					: 'Booking cancelled successfully!'
			);
			setOpenCancelModal(false);
		} catch (error) {
			toast.error('Failed to cancel booking.');
		}
		setLoading(false);
	};

	// Function to open the cancel modal and set the cancel type
	const openCancelModalWithType = (type) => {
		setCancelType(type);
		setOpenCancelModal(true);
	};

	return (
		<>
			<TableRow>
				<TableCell>
					{isParent && (
						<IconButton
							size='small'
							onClick={() => toggleGroup(row.recurranceId || 0)}
						>
							{isOpen ? <FaMinus /> : <FaPlus />}
						</IconButton>
					)}
				</TableCell>

				{isParent ? (
					<TableCell colSpan={6}>
						<Box
							display='flex'
							justifyContent='space-between'
							alignItems='center'
						>
							<span
								style={{
									fontWeight: '600',
									fontSize: '1rem',
									color: '#1f2937',
								}}
							>
								{row.passengerName}
							</span>
							{recurrenceId !== null &&
								recurrenceId !== 0 &&
								!applyToBlock &&
								!changesPending && ( // Added !changesPending condition here
									<Box
										display='flex'
										gap={1}
									>
										<Button
											variant='contained'
											size='small'
											sx={{
												backgroundColor: 'gray',
												color: 'white',
												padding: '6px 16px',
												fontWeight: 'bold',
												borderRadius: '6px',
												textTransform: 'capitalize',
											}}
											onClick={() => setOpenAmendModal(true)}
										>
											Amend All
										</Button>
										<Button
											variant='contained'
											size='small'
											sx={{
												'backgroundColor': '#dc2626',
												'color': 'white',
												'padding': '6px 16px',
												'fontWeight': 'bold',
												'borderRadius': '6px',
												'textTransform': 'capitalize',
												'&:hover': { backgroundColor: '#b91c1c' },
											}}
											onClick={() => openCancelModalWithType('cancelAll')}
										>
											Cancel All
										</Button>
									</Box>
								)}
						</Box>
					</TableCell>
				) : (
					<>
						<TableCell>{row.bookingId}</TableCell>
						<TableCell>
							{moment(row.dateTime).format('DD-MM-YYYY HH:mm')}
						</TableCell>
						<TableCell>{row.passengerName}</TableCell>
						<TableCell>{row.pickupAddress}</TableCell>
						<TableCell>{row.destinationAddress}</TableCell>
						<TableCell sx={{ padding: '8px', textAlign: 'center' }}>
							<Box
								display='flex'
								justifyContent='center'
								gap={1}
							>
								{!changesPending && (
									<Button
										variant='contained'
										size='small'
										sx={{
											backgroundColor: 'gray',
											color: 'white',
											padding: '6px 16px',
											fontWeight: 'bold',
											borderRadius: '6px',
											textTransform: 'capitalize',
										}}
										onClick={() => setOpenAmendModal(true)}
									>
										Amend
									</Button>
								)}
								{!changesPending && (
									<Button
										variant='contained'
										size='small'
										sx={{
											'backgroundColor': '#dc2626',
											'color': 'white',
											'padding': '4px 8px',
											'fontWeight': 'bold',
											'borderRadius': '6px',
											'textTransform': 'capitalize',
											'&:hover': { backgroundColor: '#b91c1c' },
										}}
										onClick={() => openCancelModalWithType('cancelThisOnly')}
									>
										Cancel This Only
									</Button>
								)}
								{/* Show "Cancel This & Future" only if recurrenceId is not 0 */}
								{!changesPending && recurrenceId !== 0 && (
									<Button
										variant='contained'
										size='small'
										sx={{
											'backgroundColor': '#dc2626',
											'color': 'white',
											'padding': '4px 8px',
											'fontWeight': 'bold',
											'borderRadius': '6px',
											'textTransform': 'capitalize',
											'&:hover': { backgroundColor: '#b91c1c' },
										}}
										onClick={() =>
											openCancelModalWithType('cancelThisAndFuture')
										}
									>
										Cancel This & Future
									</Button>
								)}
							</Box>
						</TableCell>
					</>
				)}
			</TableRow>

			{/* Amend Booking Modal */}
			<Dialog
				open={openAmendModal}
				onClose={() => setOpenAmendModal(false)}
				maxWidth='sm'
				fullWidth
				sx={{
					'& .MuiDialog-paper': {
						borderRadius: '16px',
						boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
						backgroundColor: '#ffffff',
						padding: '8px',
						fontFamily: 'Arial, sans-serif',
					},
				}}
			>
				<DialogTitle
					sx={{
						backgroundColor: '#ffffff',
						color: '#4a5568',
						textAlign: 'center',
						fontWeight: 'bold',
						padding: '16px 24px',
						fontSize: '1.25rem',
						borderBottom: '1px solid #e2e8f0',
						display: 'flex',
						justifyContent: 'space-between',
						alignItems: 'center',
					}}
				>
					Amend Booking
					<IconButton
						onClick={() => setOpenAmendModal(false)}
						sx={{
							color: '#a0aec0',
							p: 0.5,
						}}
					>
						<span style={{ fontSize: '24px', lineHeight: '1' }}>×</span>
					</IconButton>
				</DialogTitle>
				<DialogContent
					sx={{
						textAlign: 'center',
						padding: '24px',
						backgroundColor: '#ffffff',
						fontSize: '0.875rem',
						color: '#4a5568',
					}}
				>
					<TextField
						label='Enter amendment message'
						variant='outlined'
						fullWidth
						value={message}
						onChange={(e) => setMessage(e.target.value)}
						sx={{
							'marginTop': 2,
							'& .MuiOutlinedInput-root': {
								'borderRadius': '8px',
								'& .MuiOutlinedInput-input': {
									fontSize: '0.875rem',
									color: '#4a5568',
								},
								'& .MuiInputLabel-root': {
									fontSize: '0.875rem',
									color: '#4a5568',
								},
								'& .MuiOutlinedInput-notchedOutline': {
									borderColor: '#e2e8f0',
								},
							},
						}}
					/>
				</DialogContent>
				<DialogActions
					sx={{
						justifyContent: 'center',
						padding: '16px 24px',
						backgroundColor: '#ffffff',
						gap: '12px',
					}}
				>
					<Button
						onClick={() => setOpenAmendModal(false)}
						sx={{
							'backgroundColor': '#ffffff',
							'color': '#4a5568',
							'padding': '8px 24px',
							'fontWeight': 'bold',
							'borderRadius': '8px',
							'border': '1px solid #e2e8f0',
							'textTransform': 'none',
							'fontSize': '0.875rem',
							'&:hover': { backgroundColor: '#edf2f7', borderColor: '#cbd5e0' },
						}}
						disabled={loading}
					>
						Cancel
					</Button>
					{isParent ? (
						<Button
							onClick={() => handleAmendSubmit(true)}
							sx={{
								'backgroundColor': '#0ea5e9',
								'color': 'white',
								'padding': '8px 24px',
								'fontWeight': 'bold',
								'borderRadius': '8px',
								'textTransform': 'none',
								'fontSize': '0.875rem',
								'&:hover': { backgroundColor: '#0284c7' },
							}}
							disabled={loading}
						>
							Submit All Future Bookings
						</Button>
					) : (
						<Button
							onClick={() => handleAmendSubmit(false)}
							sx={{
								'backgroundColor': '#e53e3e',
								'color': 'white',
								'padding': '8px 24px',
								'fontWeight': 'bold',
								'borderRadius': '8px',
								'textTransform': 'none',
								'fontSize': '0.875rem',
								'&:hover': { backgroundColor: '#c53030' },
							}}
							disabled={loading}
						>
							Submit
						</Button>
					)}
				</DialogActions>
			</Dialog>

			{/* Cancel Booking Modal */}
			<Dialog
				open={openCancelModal}
				onClose={() => setOpenCancelModal(false)}
				maxWidth='sm'
				fullWidth
				sx={{
					'& .MuiDialog-paper': {
						borderRadius: '16px',
						boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
						backgroundColor: '#ffffff',
						padding: '8px',
						fontFamily: 'Arial, sans-serif',
					},
				}}
			>
				<DialogTitle
					sx={{
						backgroundColor: '#ffffff',
						color: '#4a5568',
						fontWeight: 'bold',
						padding: '16px 24px',
						fontSize: '1.25rem',
						display: 'flex',
						alignItems: 'center',
						justifyContent: 'space-between',
					}}
				>
					<Box sx={{ display: 'flex', alignItems: 'center', color: '#e53e3e' }}>
						<span style={{ fontSize: '20px', marginRight: '8px' }}>⚠</span>
						Cancel Booking
					</Box>
					<IconButton
						onClick={() => setOpenCancelModal(false)}
						sx={{ color: '#a0aec0', p: 0.5 }}
					>
						<span style={{ fontSize: '24px', lineHeight: '1' }}>×</span>
					</IconButton>
				</DialogTitle>
				<DialogContent
					sx={{
						textAlign: 'center',
						padding: '24px',
						backgroundColor: '#ffffff',
						fontSize: '1rem',
						color: '#4a5568',
					}}
				>
					<p>
						Are you sure you want to submit a cancellation request for: <br />
						<strong style={{ color: '#4a5568', fontWeight: 'bold' }}>
							{row.passengerName || 'Unknown Passenger'}
						</strong>
					</p>
				</DialogContent>
				<DialogActions
					sx={{
						justifyContent: 'center',
						padding: '16px 24px',
						backgroundColor: '#ffffff',
						gap: '12px',
					}}
				>
					<Button
						onClick={() => setOpenCancelModal(false)}
						sx={{
							'backgroundColor': '#ffffff',
							'color': '#4a5568',
							'padding': '8px 24px',
							'fontWeight': 'bold',
							'borderRadius': '8px',
							'border': '1px solid #e2e8f0',
							'textTransform': 'none',
							'fontSize': '0.875rem',
							'&:hover': { backgroundColor: '#edf2f7', borderColor: '#cbd5e0' },
						}}
					>
						Cancel
					</Button>
					{cancelType === 'cancelAll' && (
						<Button
							onClick={() => handleCancelSubmit(true)}
							sx={{
								'backgroundColor': '#e53e3e',
								'color': 'white',
								'padding': '8px 24px',
								'fontWeight': 'bold',
								'borderRadius': '8px',
								'textTransform': 'none',
								'fontSize': '0.875rem',
								'&:hover': { backgroundColor: '#c53030' },
							}}
							disabled={loading}
						>
							Cancel All Bookings
						</Button>
					)}
					{cancelType === 'cancelThisOnly' && (
						<Button
							onClick={() => handleCancelSubmit(false)}
							sx={{
								'backgroundColor': '#e53e3e',
								'color': 'white',
								'padding': '8px 16px',
								'fontWeight': 'bold',
								'borderRadius': '8px',
								'textTransform': 'none',
								'fontSize': '0.85rem',
								'&:hover': { backgroundColor: '#c53030' },
							}}
							disabled={loading}
						>
							Cancel This Booking Only
						</Button>
					)}
					{cancelType === 'cancelThisAndFuture' && (
						<Button
							onClick={() => handleCancelSubmit(false, true)}
							sx={{
								'backgroundColor': '#e53e3e',
								'color': 'white',
								'padding': '8px 16px',
								'fontWeight': 'bold',
								'borderRadius': '8px',
								'textTransform': 'none',
								'fontSize': '0.85rem',
								'&:hover': { backgroundColor: '#c53030' },
							}}
							disabled={loading}
						>
							Cancel This & Future Bookings
						</Button>
					)}
				</DialogActions>
			</Dialog>
		</>
	);
}

Row.propTypes = {
	row: PropTypes.object.isRequired,
	isParent: PropTypes.bool,
	isOpen: PropTypes.bool,
	toggleGroup: PropTypes.func,
	lowestBookingId: PropTypes.number,
};

Row.defaultProps = {
	isParent: false,
	isOpen: false,
	toggleGroup: () => {},
	lowestBookingId: null,
};

const ActiveBooking = () => {
	const navigate = useNavigate();
	const dispatch = useDispatch();
	const { activeBookings, loading } = useSelector(
		(state) => state.activebookings
	);
	const [page, setPage] = useState(0);
	const [rowsPerPage, setRowsPerPage] = useState(20);
	const [searchInput, setSearchInput] = useState('');
	const [searchTerm, setSearchTerm] = useState('');
	const [sortConfig, setSortConfig] = useState({
		key: 'bookingId',
		direction: 'asc',
	});
	const [openGroups, setOpenGroups] = useState({});

	const handleSort = (key) => {
		let direction = 'desc';
		if (sortConfig.key === key && sortConfig.direction === 'desc') {
			direction = 'asc';
		}
		setSortConfig({ key, direction });
	};

	const filteredBookings = useMemo(() => {
		return activeBookings.filter((booking) => {
			const searchableFields = [
				'passengerName',
				'pickupAddress',
				'destinationAddress',
				'bookingId',
			];
			return searchableFields.some((field) =>
				String(booking[field] || '')
					.toLowerCase()
					.includes(searchTerm.toLowerCase())
			);
		});
	}, [activeBookings, searchTerm]);

	const sortedBookings = useMemo(() => {
		if (!sortConfig.key) return filteredBookings;

		return [...filteredBookings].sort((a, b) => {
			const valA = a[sortConfig.key];
			const valB = b[sortConfig.key];

			// Handle dateTime specifically by converting to timestamps
			if (sortConfig.key === 'dateTime') {
				const dateA = moment(valA).toDate().getTime(); // Convert to timestamp
				const dateB = moment(valB).toDate().getTime(); // Convert to timestamp
				return sortConfig.direction === 'asc' ? dateA - dateB : dateB - dateA;
			}

			// Handle other fields (strings or numbers)
			if (valA < valB) return sortConfig.direction === 'asc' ? -1 : 1;
			if (valA > valB) return sortConfig.direction === 'asc' ? 1 : -1;
			return 0;
		});
	}, [filteredBookings, sortConfig]);

	console.log('Sorted Bookings:', sortedBookings);

	const handleSearchChange = debounce((value) => {
		setSearchTerm(value);
	}, 300);

	useEffect(() => {
		dispatch(fetchActiveBookings());
	}, [dispatch]);

	// Group bookings by recurrenceId and find the highest bookingId in each group
	const groupedBookings = useMemo(() => {
		const groups = {};
		sortedBookings.forEach((booking) => {
			const key = booking.recurranceId || 0; // Agar recurrenceId null hai to 0
			// Agar key 0 hai (yaani recurrenceId null ya 0 hai), to is booking ko alag row ke roop mein treat karo
			if (key === 0) {
				// Har booking ko apna unique group do, taaki wo independent row ban jaye
				groups[`booking_${booking.bookingId}`] = {
					parent: booking,
					bookings: [booking], // Sirf ek booking hogi is group mein
					lowestBookingId: booking.bookingId,
				};
			} else {
				// Agar recurrenceId non-zero hai, to grouping karo
				if (!groups[key]) {
					groups[key] = {
						parent: booking,
						bookings: [booking],
						lowestBookingId: booking.bookingId,
					};
				} else {
					groups[key].bookings.push(booking);
					groups[key].lowestBookingId = Math.min(
						groups[key].lowestBookingId,
						booking.bookingId
					);
				}
			}
		});
		return groups;
	}, [sortedBookings]);

	const totalFilteredBookings = Object.keys(groupedBookings).length || 0;
	const startIndex = page * rowsPerPage;
	const endIndex = Math.min(startIndex + rowsPerPage, totalFilteredBookings);
	const paginatedParentBookings = Object.values(groupedBookings)
		.map((group) => group.parent)
		.slice(startIndex, endIndex);

	const paginatedBookings = useMemo(() => {
		if (totalFilteredBookings === 0) return {};
		const finalGroups = {};
		console.log('paginatedParentBookings:', paginatedParentBookings);
		console.log('groupedBookings:', groupedBookings);
		paginatedParentBookings.forEach((parentBooking) => {
			const recurrenceId = parentBooking.recurranceId || 0;
			const key =
				recurrenceId === 0
					? `booking_${parentBooking.bookingId}`
					: recurrenceId;
			const group = groupedBookings[key];
			console.log(`Key: ${key}, Group:`, group);
			if (group) {
				finalGroups[key] = group.bookings;
			}
		});
		console.log('Final paginatedBookings:', finalGroups);
		return finalGroups;
	}, [paginatedParentBookings, groupedBookings, totalFilteredBookings]);

	const toggleGroup = (groupId) => {
		setOpenGroups((prev) => ({ ...prev, [groupId]: !prev[groupId] }));
	};

	useEffect(() => {
		setPage(0);
	}, [searchTerm]);

	useEffect(() => {
		console.log('Sorted Bookings:', sortedBookings);
		console.log('Paginated Bookings:', paginatedBookings);
	}, [sortedBookings, paginatedBookings]);

	return (
		<div className='bg-white max-h-full overflow-auto'>
			<Header />
			<div className='bg-white pt-10 sm:mx-16 p-4 flex flex-col items-center min-h-[500px] sm:min-h-screen'>
				<div className='flex flex-col sm:flex-row sm:justify-center w-full mb-4 gap-3'>
					<button
						onClick={() => navigate('/')}
						className='px-3 py-2 bg-gray-200 text-gray-700 text-sm rounded-lg hover:bg-gray-300 transition flex items-center justify-center'
					>
						<TiArrowBack className='mr-2' />
						<span className='font-medium'>Back</span>
					</button>

					<TextField
						label='Search...'
						variant='outlined'
						value={searchInput}
						onChange={(e) => {
							setSearchInput(e.target.value);
							handleSearchChange(e.target.value);
						}}
						size='small'
						sx={{ width: '100%', maxWidth: '350px' }}
					/>
				</div>

				{loading ? (
					<CircularProgress />
				) : (
					<TableContainer component={Paper}>
						<Table>
							<TableHead>
								<TableRow sx={{ backgroundColor: '#545454' }}>
									<TableCell />
									<TableCell
										sx={{
											color: 'white',
											fontWeight: 'bold',
											cursor: 'pointer',
											borderBottom: 'none',
										}}
										onClick={() => handleSort('bookingId')}
									>
										<span
											style={{ display: 'inline-flex', alignItems: 'center' }}
										>
											Booking ID
											{sortConfig.key === 'bookingId' && (
												<span style={{ marginLeft: '8px' }}>
													{sortConfig.direction === 'desc' ? (
														<FaArrowDown />
													) : (
														<FaArrowUp />
													)}
												</span>
											)}
										</span>
									</TableCell>
									<TableCell
										sx={{
											color: 'white',
											fontWeight: 'bold',
											cursor: 'pointer',
											borderBottom: 'none',
										}}
										onClick={() => handleSort('dateTime')}
									>
										<span
											style={{ display: 'inline-flex', alignItems: 'center' }}
										>
											Date & Time{' '}
											{sortConfig.key === 'dateTime' &&
												(sortConfig.direction === 'asc' ? (
													<FaArrowUp />
												) : (
													<FaArrowDown />
												))}
										</span>
									</TableCell>
									<TableCell
										sx={{
											color: 'white',
											fontWeight: 'bold',
											cursor: 'pointer',
											borderBottom: 'none',
										}}
										onClick={() => handleSort('passengerName')}
									>
										<span
											style={{ display: 'inline-flex', alignItems: 'center' }}
										>
											Passenger{' '}
											{sortConfig.key === 'passengerName' &&
												(sortConfig.direction === 'asc' ? (
													<FaArrowUp />
												) : (
													<FaArrowDown />
												))}
										</span>
									</TableCell>
									<TableCell
										sx={{
											color: 'white',
											fontWeight: 'bold',
											cursor: 'pointer',
											borderBottom: 'none',
										}}
										onClick={() => handleSort('pickupAddress')}
									>
										<span
											style={{ display: 'inline-flex', alignItems: 'center' }}
										>
											Pickup Address{' '}
											{sortConfig.key === 'pickupAddress' &&
												(sortConfig.direction === 'asc' ? (
													<FaArrowUp />
												) : (
													<FaArrowDown />
												))}
										</span>
									</TableCell>
									<TableCell
										sx={{
											color: 'white',
											fontWeight: 'bold',
											cursor: 'pointer',
											borderBottom: 'none',
										}}
										onClick={() => handleSort('destinationAddress')}
									>
										<span
											style={{ display: 'inline-flex', alignItems: 'center' }}
										>
											Destination{' '}
											{sortConfig.key === 'destinationAddress' &&
												(sortConfig.direction === 'asc' ? (
													<FaArrowUp />
												) : (
													<FaArrowDown />
												))}
										</span>
									</TableCell>
									<TableCell sx={{ color: 'white', fontWeight: 'bold' }}>
										Actions
									</TableCell>
								</TableRow>
							</TableHead>
							<TableBody>
								{Object.keys(paginatedBookings).length > 0 ? (
									Object.keys(paginatedBookings).map((groupId) => {
										const bookings = paginatedBookings[groupId];
										if (!bookings) return null; // Agar bookings undefined hai, to skip karo
										const firstBooking = bookings[0];
										const { lowestBookingId } = groupedBookings[groupId] || {};

										return (
											<React.Fragment key={groupId}>
												<Row
													row={firstBooking}
													isParent={
														bookings.length > 1 &&
														firstBooking.recurranceId !== 0 &&
														firstBooking.recurranceId !== null
													}
													isOpen={!!openGroups[groupId]}
													toggleGroup={toggleGroup}
													lowestBookingId={lowestBookingId}
												/>
												{openGroups[groupId] &&
													bookings.slice(0).map((booking) => (
														<Row
															key={booking.bookingId}
															row={booking}
															lowestBookingId={lowestBookingId}
														/>
													))}
											</React.Fragment>
										);
									})
								) : (
									<TableRow>
										<TableCell
											colSpan={7}
											sx={{ textAlign: 'center' }}
										>
											No bookings found
										</TableCell>
									</TableRow>
								)}
							</TableBody>
						</Table>
					</TableContainer>
				)}

				<div className='flex flex-col md:flex-row justify-between items-center mt-4 gap-2 w-full'>
					<div className='flex items-center gap-2'>
						<label
							htmlFor='rowsPerPage'
							className='text-sm md:text-base text-black font-medium'
						>
							Rows:
						</label>
						<select
							id='rowsPerPage'
							value={rowsPerPage}
							onChange={(e) => setRowsPerPage(Number(e.target.value))}
							className='px-2 py-1 text-sm border border-gray-300 bg-white text-black rounded-md focus:outline-none hover:bg-red-50'
						>
							<option value={20}>20</option>
							<option value={40}>40</option>
							<option value={80}>80</option>
							<option value={100}>100</option>
							<option value={200}>200</option>
						</select>
					</div>
					<div className='flex items-center gap-2'>
						<button
							disabled={page === 0}
							onClick={() => setPage((prev) => Math.max(prev - 1, 0))}
							className={`px-3 py-1 text-sm md:text-base text-white bg-[#b91c1c] rounded-md hover:bg-red-700 transition ${
								page === 0 ? 'opacity-50 cursor-not-allowed' : ''
							}`}
						>
							Prev
						</button>
						<p className='text-sm md:text-base'>
							{startIndex + 1} - {endIndex} of {totalFilteredBookings || 1}
						</p>
						<button
							disabled={endIndex >= totalFilteredBookings}
							onClick={() => setPage((prev) => prev + 1)}
							className={`px-3 py-1 text-sm md:text-base text-white bg-[#b91c1c] rounded-md hover:bg-red-700 transition ${
								endIndex >= totalFilteredBookings
									? 'opacity-50 cursor-not-allowed'
									: ''
							}`}
						>
							Next
						</button>
					</div>
				</div>
			</div>
		</div>
	);
};

export default ActiveBooking;
