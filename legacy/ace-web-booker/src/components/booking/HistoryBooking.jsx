/** @format */

import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import Header from '../Common/header'; // ✅ Keeping the same Header
import { TiArrowBack } from 'react-icons/ti';
import { fetchWebBookings } from '../../service/operations/getwebbooking'; // ✅ Import Redux action
import moment from 'moment';
import { useMemo } from 'react';

// ✅ MUI Imports
import {
	Box,
	Collapse,
	IconButton,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Typography,
	Paper,
	Button,
	CircularProgress,
	TablePagination,
	TextField,
} from '@mui/material';

import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import KeyboardArrowUpIcon from '@mui/icons-material/KeyboardArrowUp';
import { FaArrowUp } from 'react-icons/fa6';
import { FaArrowDown } from 'react-icons/fa6';

// ✅ Collapsible Row Component
function Row({ row }) {
	const [open, setOpen] = useState(false);

	const navigate = useNavigate(); // ✅ Get navigation function

	const handleReBooking = () => {
		navigate('/createbookingform', { state: row }); // ✅ Pass row data to the new page
	};

	const getStatusBadge = (status) => {
		switch (status) {
			case 0:
				return {
					text: 'Pending',
					bgColor: '#facc15', // Yellow
					textColor: '#000000',
				};
			case 1:
				return {
					text: 'Accepted',
					bgColor: '#22c55e', // Green
					textColor: '#ffffff',
				};
			case 2:
				return {
					text: 'Rejected',
					bgColor: '#ef4444', // Red
					textColor: '#ffffff',
				};
			default:
				return {
					text: 'Unknown',
					bgColor: '#6b7280', // Gray
					textColor: '#ffffff',
				};
		}
	};

	return (
		<>
			<TableRow sx={{ '& > *': { borderBottom: '1px solid #ddd' } }}>
				<TableCell sx={{ padding: '12px' }}>
					{row.status === 2 && (
						<IconButton
							size='small'
							onClick={() => setOpen(!open)}
						>
							{open ? <KeyboardArrowUpIcon /> : <KeyboardArrowDownIcon />}
						</IconButton>
					)}
				</TableCell>
				<TableCell sx={{ fontWeight: 'bold', padding: '12px' }}>
					{row.passengerName}
				</TableCell>
				<TableCell sx={{ padding: '12px' }}>
					{moment(row.pickupDateTime).format('DD-MM-YYYY HH:mm')}
				</TableCell>
				<TableCell sx={{ padding: '12px' }}>{row.pickupAddress}</TableCell>
				<TableCell sx={{ padding: '12px' }}>{row.destinationAddress}</TableCell>
				<TableCell sx={{ padding: '12px' }}>
					{row.phoneNumber ? row.phoneNumber : ''}
				</TableCell>
				<TableCell sx={{ padding: '12px' }}>
					<span
						style={{
							backgroundColor: getStatusBadge(row.status).bgColor,
							color: getStatusBadge(row.status).textColor,
							padding: '4px 12px',
							borderRadius: '8px',
							fontWeight: 'bold',
							display: 'inline-block',
							minWidth: '80px',
							textAlign: 'center',
						}}
					>
						{getStatusBadge(row.status).text}
					</span>
				</TableCell>
				{/* ✅ Moved "Duplicate" Button to the Last Column */}
				<TableCell sx={{ padding: '8px', textAlign: 'center' }}>
					<Button
						variant='contained'
						size='small' // ✅ Makes the button smaller
						sx={{
							'backgroundColor': '#000000',
							'color': 'white',
							'padding': '4px 12px', // ✅ Reducing padding
							'fontSize': '12px', // ✅ Slightly smaller font
							'fontWeight': 'bold',
							'borderRadius': '6px', // ✅ Rounded corners
							'&:hover': { backgroundColor: '#333333' }, // ✅ Hover effect
							'minWidth': '80px', // ✅ Minimum width for uniformity
						}}
						onClick={handleReBooking}
					>
						Duplicate
					</Button>
				</TableCell>
			</TableRow>

			{row.status === 2 && (
				<TableRow>
					<TableCell
						colSpan={7}
						sx={{ paddingBottom: 0, paddingTop: 0 }}
					>
						<Collapse
							in={open}
							timeout='auto'
							unmountOnExit
						>
							<Box sx={{ margin: 2, padding: 2, borderRadius: '5px' }}>
								<Typography
									variant='h6'
									gutterBottom
									sx={{ color: '#dc2626', fontWeight: 'bold' }}
								>
									Rejected Reason
								</Typography>
								<Typography variant='body1'>{row.rejectedReason}</Typography>
								<Box
									mt={2}
									display='flex'
									gap={2}
								>
									<Button
										variant='contained'
										sx={{
											'backgroundColor': '#b91c1c',
											'color': 'white',
											'&:hover': { backgroundColor: '#b91c1c' },
										}}
										onClick={handleReBooking} // ✅ Trigger navigation with row data
									>
										Re-Booking
									</Button>
									<Button
										variant='contained'
										sx={{
											backgroundColor: 'black',
											color: 'white',
										}}
									>
										Cancel
									</Button>
								</Box>
							</Box>
						</Collapse>
					</TableCell>
				</TableRow>
			)}
		</>
	);
}

Row.propTypes = {
	row: PropTypes.shape({
		accNo: PropTypes.string.isRequired,
		passengerName: PropTypes.string.isRequired,
		pickupAddress: PropTypes.string.isRequired,
		destinationAddress: PropTypes.string.isRequired,
		phoneNumber: PropTypes.string.isRequired,
		pickupDateTime: PropTypes.string.isRequired,
		status: PropTypes.number.isRequired,
		rejectedReason: PropTypes.string,
	}).isRequired,
};

// ✅ Main Component
const HistoryBooking = () => {
	const navigate = useNavigate();
	const dispatch = useDispatch();

	// Fetch bookings from Redux
	const { webBookings, loading, error } = useSelector(
		(state) => state.webbookings
	);

	// Fetch data on component mount
	useEffect(() => {
		dispatch(fetchWebBookings());
	}, [dispatch]);

	const [searchTerm, setSearchTerm] = useState('');
	const [page, setPage] = useState(0);
	const [rowsPerPage, setRowsPerPage] = useState(20);

	const [sortConfig, setSortConfig] = useState({
		key: 'pickupDateTime',
		direction: 'desc',
	});

	const handleSort = (key) => {
		let direction = 'desc';
		if (sortConfig.key === key && sortConfig.direction === 'desc') {
			direction = 'asc';
		}
		setSortConfig({ key, direction });
	};

	// ✅ Filter bookings based on search term
	const filteredBookings = webBookings.filter((booking) => {
		return (
			(booking.passengerName || '')
				.toLowerCase()
				.includes(searchTerm.toLowerCase()) ||
			(booking.pickupAddress || '')
				.toLowerCase()
				.includes(searchTerm.toLowerCase()) ||
			(booking.destinationAddress || '')
				.toLowerCase()
				.includes(searchTerm.toLowerCase()) ||
			(booking.phoneNumber || '')
				.toLowerCase()
				.includes(searchTerm.toLowerCase())
		);
	});

	useEffect(() => {
		setPage(0); // ✅ Reset to first page when search term changes
	}, [searchTerm]);

	const sortedBookings = useMemo(() => {
		if (!sortConfig.key) {
			// 🔹 If no column sorting is applied, just sort by status (0 → 1 → 2)
			return [...filteredBookings].sort((a, b) => a.status - b.status);
		}

		return [...filteredBookings]
			.sort((a, b) => {
				const valA = String(a[sortConfig.key] || '').toLowerCase();
				const valB = String(b[sortConfig.key] || '').toLowerCase();

				if (valA < valB) return sortConfig.direction === 'asc' ? -1 : 1;
				if (valA > valB) return sortConfig.direction === 'asc' ? 1 : -1;
				return 0;
			})
			.sort((a, b) => a.status - b.status); // 🔹 Always ensure status sorting is first
	}, [filteredBookings, sortConfig]);
	// ✅ Sort bookings: Pending (0), Accepted (1), Rejected (2)
	// const sortedBookings = [...filteredBookings].sort(
	// 	(a, b) => a.status - b.status
	// );

	// const handleChangePage = (event, newPage) => {
	// 	setPage(newPage);
	// };

	// const handleChangeRowsPerPage = (event) => {
	// 	setRowsPerPage(parseInt(event.target.value, 10));
	// 	setPage(0);
	// };

	return (
		<div className='bg-white max-h-full overflow-auto'>
			<Header />
			<div className='bg-white pt-10 sm:mx-16 p-4 flex flex-col items-center min-h-[500px] sm:min-h-screen'>
				{/* ✅ Back Button */}
				<div className='flex flex-col sm:flex-row sm:justify-center w-full mb-4 gap-3'>
					{/* ✅ Back Button */}
					<button
						onClick={() => navigate('/')}
						className='px-3 py-2 bg-gray-200 text-gray-700 text-sm rounded-lg hover:bg-gray-300 transition flex items-center justify-center'
					>
						<TiArrowBack className='mr-2' />
						<span className='font-medium'>Back</span>
					</button>

					{/* ✅ Search Field */}
					<TextField
						label='Search Bookings....'
						variant='outlined'
						value={searchTerm}
						onChange={(e) => setSearchTerm(e.target.value)}
						size='small'
						sx={{ width: '100%', maxWidth: '350px' }}
					/>
				</div>

				{/* ✅ Loading & Error Handling */}
				{loading && <CircularProgress />}
				{error && <p style={{ color: 'red' }}>Error: {error}</p>}

				{/* ✅ Table Content */}
				{sortedBookings.length > 0 ? (
					<TableContainer
						component={Paper}
						sx={{
							backgroundColor: 'white',
						}}
					>
						<Table aria-label='collapsible table'>
							<TableHead>
								<TableRow sx={{ backgroundColor: '#545454' }}>
									<TableCell
										sx={{
											color: 'white',
											fontWeight: 'bold',
											borderBottom: 'none',
										}}
									/>

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
										onClick={() => handleSort('pickupDateTime')}
									>
										<span
											style={{ display: 'inline-flex', alignItems: 'center' }}
										>
											Time & Date{' '}
											{sortConfig.key === 'pickupDateTime' &&
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

									<TableCell
										sx={{
											color: 'white',
											fontWeight: 'bold',
											cursor: 'pointer',
											borderBottom: 'none',
										}}
										onClick={() => handleSort('phoneNumber')}
									>
										<span
											style={{ display: 'inline-flex', alignItems: 'center' }}
										>
											Phone{' '}
											{sortConfig.key === 'phoneNumber' &&
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
											borderBottom: 'none',
										}}
									>
										Status
									</TableCell>

									<TableCell
										sx={{
											color: 'white',
											fontWeight: 'bold',
											borderBottom: 'none',
										}}
									>
										Duplicate
									</TableCell>
								</TableRow>
							</TableHead>

							<TableBody>
								{sortedBookings
									.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
									.map((booking) => (
										<Row
											key={booking.id}
											row={booking}
										/>
									))}
							</TableBody>
						</Table>
					</TableContainer>
				) : (
					!loading && (
						<Typography>No data available in booking history.</Typography>
					)
				)}

				{/* ✅ Pagination */}
				{/* Pagination Controls */}
				<div className='flex flex-col md:flex-row justify-between items-center mt-4 gap-2 w-full'>
					{/* Rows Per Page Selector */}
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

					{/* Pagination Navigation */}
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
							{page * rowsPerPage + 1} -
							{Math.min((page + 1) * rowsPerPage, filteredBookings.length)} of{' '}
							{filteredBookings.length}
						</p>

						<button
							disabled={(page + 1) * rowsPerPage >= filteredBookings.length}
							onClick={() => setPage((prev) => prev + 1)}
							className={`px-3 py-1 text-sm md:text-base text-white bg-[#b91c1c] rounded-md hover:bg-red-700 transition ${
								(page + 1) * rowsPerPage >= filteredBookings.length
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

export default HistoryBooking;
