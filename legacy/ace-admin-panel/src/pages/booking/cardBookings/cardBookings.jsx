/** @format */
import { useState, Fragment, useEffect } from 'react';
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
	Paper,
	Typography,
	TableSortLabel,
	TablePagination,
} from '@mui/material';
import {
	KeyboardArrowDown,
	KeyboardArrowUp,
	EmailOutlined,
} from '@mui/icons-material';
import { format } from 'date-fns';
import { Calendar } from '@/components/ui/calendar';
import {
	Popover,
	PopoverTrigger,
	PopoverContent,
} from '@/components/ui/popover';
import { KeenIcon } from '@/components';
import { useDispatch, useSelector } from 'react-redux';
import { refreshAllCardBookings } from '../../../slices/bookingSlice';
import { sendReminderCardPayment } from '../../../service/operations/bookingApi';
import toast from 'react-hot-toast';
import { cn } from '@/lib/utils';

function Row({ row }) {
	const [open, setOpen] = useState(false);

	const handleSendReminder = async () => {
		try {
			// console.log(row);
			const response = await sendReminderCardPayment({
				bookingId: row?.id || 0,
				phone: row?.phoneNumber || '',
			});
			if (response?.status === 'success') {
				toast.success('Reminder send Successfully');
			} else {
				console.log('error response', response);
				toast.error(response.data);
			}
		} catch (error) {
			console.log('send reminder error', error);
		}
	};

	return (
		<>
			<TableRow className='bg-white dark:bg-[#14151A] hover:bg-gray-100'>
				<TableCell>
					<IconButton
						size='small'
						onClick={() => setOpen(!open)}
					>
						{open ? (
							<KeyboardArrowUp className='text-[#14151A] dark:text-gray-700' />
						) : (
							<KeyboardArrowDown className='text-[#14151A] dark:text-gray-700' />
						)}
					</IconButton>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<Typography className='dark:text-cyan-400 text-blue-400'>
						{row.id}
					</Typography>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					{row.date}
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					{row.driver}
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					{row.pickup}
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					{row.passenger}
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					£{row.price.toFixed(2)}
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					{row.status}
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<Typography variant='body2'>{row.payment}</Typography>
				</TableCell>
				<TableCell>
					<IconButton
						size='small'
						onClick={() => {
							if (row.phoneNumber) handleSendReminder();
							else toast.error('Phone number is Required');
						}}
					>
						<EmailOutlined className='text-blue-400 dark:text-cyan-400' />
					</IconButton>
				</TableCell>
			</TableRow>
			<TableRow>
				<TableCell
					colSpan={10}
					style={{ paddingBottom: 0, paddingTop: 0 }}
				>
					<Collapse
						in={open}
						timeout='auto'
						unmountOnExit
					>
						<Box
							margin={1}
							className='border border-gray-400 rounded p-4 bg-gray-100 dark:bg-[#14151A] text-[#14151A] dark:text-gray-500'
						>
							<Typography
								variant='h6'
								gutterBottom
								className='text-blue-400 dark:text-cyan-400'
							>
								Booking #: {row.id}
							</Typography>
							<Box
								display='flex'
								justifyContent='space-between'
							>
								<Box>
									<Typography variant='body2'>
										<strong>Vias:</strong> {row.details?.vias}
									</Typography>
									<Typography variant='body2'>
										<strong>Booked By:</strong> {row.details.bookedBy}
									</Typography>
									<Typography variant='body2'>
										<strong>Details:</strong> {row.details.details}
									</Typography>
									<Typography variant='body2'>
										<strong>Last Updated By:</strong>{' '}
										{row.details.lastUpdatedBy}
									</Typography>
									<Typography variant='body2'>
										<strong>Last Updated On:</strong>{' '}
										{row.details.lastUpdatedOn}
									</Typography>
								</Box>
								<Box>
									<Typography variant='body2'>
										<strong>Scope:</strong> {row.details.scope}
									</Typography>
									<Typography variant='body2'>
										<strong>Mileage:</strong> {row.details.mileage}
									</Typography>
									<Typography variant='body2'>
										<strong>Duration:</strong> {row.details.duration}
									</Typography>
									<Typography variant='body2'>
										<strong>Charge From Base:</strong>{' '}
										{row.details.chargeFromBase ? 'True' : 'False'}
									</Typography>
								</Box>
							</Box>
						</Box>
					</Collapse>
				</TableCell>
			</TableRow>
		</>
	);
}

// Main Component
function CardBookings() {
	const dispatch = useDispatch();
	const { cardBookings } = useSelector((state) => state.booking);
	const [search, setSearch] = useState('');
	const [date, setDate] = useState(new Date());
	const [openDate, setOpenDate] = useState(false);
	const [order, setOrder] = useState('asc'); // Sort order
	const [orderBy, setOrderBy] = useState(''); // Default sorted column
	const [page, setPage] = useState(0);
	const [rowPerPage, setRowPerPage] = useState(10);
	const handleDateSelect = (date) => {
		setDate(date);
		setOpenDate(false);
	};

	const handleChangePage = (e, newPage) => {
		setPage(newPage);
	};

	const handleChangeRowsPerPage = (e) => {
		setRowPerPage(parseInt(e.target.value, 10));
		setPage(0);
	};

	const formattedBookings = (cardBookings || []).map((booking) => ({
		id: booking?.id,
		date: booking?.pickupDateTime
			? new Date(booking?.pickupDateTime).toLocaleDateString('en-GB') +
				' ' +
				booking?.pickupDateTime?.split('T')[1]?.split('.')[0]?.slice(0, 5)
			: '-', // Ensure correct date format
		driver: booking?.userId || '-',
		pickup: `${booking?.pickupAddress}, ${booking?.pickupPostCode}`,
		passenger: booking?.passengerName || 'Unknown',
		phoneNumber: booking?.phoneNumber || '',
		price: booking?.price || 0,
		status:
			booking?.paymentStatus === 0
				? 'Unpaid'
				: booking?.paymentStatus === 1
					? 'Paid'
					: 'Waiting',
		payment: booking?.paymentOrderId || '-',
		details: {
			bookedBy: booking?.bookedByName || '',
			details: booking?.details || '',
			vias: booking?.vias?.length
				? booking.vias
						.map((via) => `${via.address}, ${via.postCode}`)
						.join(' → ')
				: '',
			lastUpdatedBy: booking?.updatedByName,
			lastUpdatedOn: booking?.dateUpdated
				? new Date(booking.dateUpdated).toLocaleDateString('en-GB') +
					' ' +
					booking.dateUpdated.split('T')[1]?.split('.')[0]?.slice(0, 5)
				: '',
			scope: booking?.scope === 4 ? 'Card' : 'Cash',
			mileage: booking.mileageText || '',
			duration: booking.durationMinutes || '',
			chargeFromBase: booking.chargeFromBase || false,
		},
	}));

	const filteredBookings = formattedBookings?.filter((booking) => {
		if (!search?.trim() && !date) return true;

		const isMatch =
			booking?.pickup?.toLowerCase().includes(search?.toLowerCase()) ||
			booking?.passenger?.toLowerCase().includes(search?.toLowerCase()) ||
			booking?.price?.toString().includes(search?.toLowerCase());
		const bookingDateParts = booking.date.split(' ')[0].split('/'); // ['DD', 'MM', 'YYYY']
		const formattedBookingDate = `${bookingDateParts[2]}-${bookingDateParts[1]}-${bookingDateParts[0]}`; // YYYY-MM-DD

		const isDateMatch = date
			? formattedBookingDate === format(date, 'yyyy-MM-dd') // Compare in correct format
			: true;

		return isMatch && isDateMatch;
	});

	const handleSort = (property) => {
		const isAscending = orderBy === property && order === 'asc';
		setOrder(isAscending ? 'desc' : 'asc');
		setOrderBy(property);
	};

	const sortedBookings = [...filteredBookings].sort((a, b) => {
		if (order === 'asc') {
			return a[orderBy] > b[orderBy] ? 1 : -1;
		} else {
			return a[orderBy] < b[orderBy] ? 1 : -1;
		}
	});

	useEffect(() => {
		dispatch(refreshAllCardBookings());
	}, [dispatch]);

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Typography
					variant='h5'
					fontWeight='medium'
					mb={2}
					className='text-xl leading-none text-gray-900 '
				>
					Card Bookings
				</Typography>

				{/* Filters */}
				<Box
					display='flex'
					flexWrap='wrap'
					gap={2}
					alignItems='center'
					mb={2}
				>
					<div className='input input-sm max-w-48 h-10'>
						<KeenIcon icon='magnifier' />
						<input
							type='text'
							placeholder='Search Booking'
							value={search}
							onChange={(e) => setSearch(e.target.value)}
						/>
					</div>

					<Popover
						open={openDate}
						onOpenChange={setOpenDate}
					>
						<PopoverTrigger asChild>
							<div className='relative'>
								<button
									id='date'
									className={cn(
										'input data-[state=open]:border-primary',
										!date && 'text-muted-foreground'
									)}
									style={{ width: '13rem' }}
								>
									<KeenIcon
										icon='calendar'
										className='-ms-0.5'
									/>
									{date ? format(date, 'LLL dd, y') : <span>Pick a date</span>}
								</button>
								{date && (
									<button
										onClick={(e) => {
											e.stopPropagation(); // Prevent closing popover
											setDate(null); // Clear date
										}}
										className='absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700'
									>
										<KeenIcon
											icon='cross-circle'
											className=''
										/>
									</button>
								)}
							</div>
						</PopoverTrigger>
						<PopoverContent
							className='w-auto p-0'
							align='start'
						>
							<Calendar
								initialFocus
								mode='single' // Single date selection
								defaultMonth={date}
								selected={date}
								onSelect={handleDateSelect}
								numberOfMonths={1}
							/>
						</PopoverContent>
					</Popover>
				</Box>

				{/* Table */}
				<TableContainer
					component={Paper}
					className='shadow-none bg-white dark:bg-[#14151A]'
				>
					<Table className='text-[#14151A] dark:text-gray-100'>
						<TableHead
							className='bg-gray-100 dark:bg-[#14151A]'
							sx={{
								'& .MuiTableCell-root': {
									// borderBottom: '1px solid #464852',
								},
							}}
						>
							<TableRow>
								<TableCell />
								<TableCell className='text-[#14151A] dark:text-gray-700 border-e'>
									<TableSortLabel
										active={orderBy === 'id'}
										direction={order}
										onClick={() => handleSort('id')}
										sx={{
											'&:hover': { color: '#9A9CAE' }, // Change color on hover
											'&.Mui-active': { color: '#9A9CAE' },
											'&.Mui-active .MuiTableSortLabel-icon': {
												color: '#9A9CAE',
											}, // Change to blue when active
											'fontWeight': 'bold',
										}}
									>
										#
									</TableSortLabel>
								</TableCell>
								<TableCell className='text-[#14151A] dark:text-gray-700 border-e'>
									<TableSortLabel
										active={orderBy === 'date'}
										direction={order}
										onClick={() => handleSort('date')}
										sx={{
											'&:hover': { color: '#9A9CAE' }, // Change color on hover
											'&.Mui-active': { color: '#9A9CAE' },
											'&.Mui-active .MuiTableSortLabel-icon': {
												color: '#9A9CAE',
											}, // Change to blue when active
											'fontWeight': 'bold',
										}}
									>
										Date
									</TableSortLabel>
								</TableCell>
								<TableCell className='text-[#14151A] dark:text-gray-700 border-e'>
									<TableSortLabel
										active={orderBy === 'driver'}
										direction={order}
										onClick={() => handleSort('driver')}
										sx={{
											'&:hover': { color: '#9A9CAE' }, // Change color on hover
											'&.Mui-active': { color: '#9A9CAE' },
											'&.Mui-active .MuiTableSortLabel-icon': {
												color: '#9A9CAE',
											}, // Change to blue when active
											'fontWeight': 'bold',
										}}
									>
										Driver #
									</TableSortLabel>
								</TableCell>
								<TableCell
									className='text-[#14151A] dark:text-gray-700 border-e'
									sx={{ fontWeight: 'bold' }}
								>
									Pickup
								</TableCell>
								<TableCell
									className='text-[#14151A] dark:text-gray-700 border-e'
									sx={{ fontWeight: 'bold' }}
								>
									Passenger
								</TableCell>
								<TableCell
									className='text-[#14151A] dark:text-gray-700 border-e'
									sx={{ fontWeight: 'bold' }}
								>
									<TableSortLabel
										active={orderBy === 'price'}
										direction={order}
										onClick={() => handleSort('price')}
										sx={{
											'&:hover': { color: '#9A9CAE' }, // Change color on hover
											'&.Mui-active': { color: '#9A9CAE' },
											'&.Mui-active .MuiTableSortLabel-icon': {
												color: '#9A9CAE',
											}, // Change to blue when active
										}}
									>
										Price
									</TableSortLabel>
								</TableCell>
								<TableCell
									className='text-[#14151A] dark:text-gray-700 border-e'
									sx={{ fontWeight: 'bold' }}
								>
									<TableSortLabel
										active={orderBy === 'status'}
										direction={order}
										onClick={() => handleSort('status')}
										sx={{
											'&:hover': { color: '#9A9CAE' }, // Change color on hover
											'&.Mui-active': { color: '#9A9CAE' },
											'&.Mui-active .MuiTableSortLabel-icon': {
												color: '#9A9CAE',
											}, // Change to blue when active
										}}
									>
										Status
									</TableSortLabel>
								</TableCell>
								<TableCell
									className='text-[#14151A] dark:text-gray-700 border-e'
									sx={{ fontWeight: 'bold' }}
								>
									Payment #
								</TableCell>
								<TableCell
									className='text-[#14151A] dark:text-gray-700 border-e'
									sx={{ fontWeight: 'bold' }}
								>
									Reminder
								</TableCell>
							</TableRow>
						</TableHead>
						<TableBody
							sx={{
								'& .MuiTableCell-root': {
									// borderBottom: '1px solid #464852',
								},
							}}
						>
							{sortedBookings
								?.slice(page * rowPerPage, page * rowPerPage + rowPerPage)
								.map((row) => (
									<Row
										key={row.id}
										row={row}
									/>
								))}
						</TableBody>
					</Table>
					<TablePagination
						component='div'
						count={sortedBookings.length}
						page={page}
						onPageChange={handleChangePage}
						rowsPerPage={rowPerPage}
						onRowsPerPageChange={handleChangeRowsPerPage}
						rowsPerPageOptions={[5, 10, 25, 50]}
						className='text-sm text-gray-900 dark:text-gray-700 px-4'
						SelectProps={{
							MenuProps: {
								PaperProps: {
									sx: {
										'& .MuiMenuItem-root': {
											'fontSize': '0.875rem',
											'&:hover': {
												backgroundColor: 'transparent', // Tailwind's gray-100
												color: '#071437', // Tailwind's blue-800
											},
											'&.Mui-selected': {
												backgroundColor: '#F1F1F4', // selected bg
												color: '#071437', // selected text (blue-800)
											},
										},
										// Dark mode styles (optional)
										'@media (prefers-color-scheme: dark)': {
											'backgroundColor': 'transparent', // dark gray bg
											'color': '#9A9CAE',
											'& .MuiMenuItem-root': {
												'&:hover': {
													backgroundColor: '#374151', // hover dark gray
													color: '#9A9CAE',
												},
												'&.Mui-selected': {
													backgroundColor: '#0D0E12',
													color: '#9A9CAE',
												},
											},
										},
									},
								},
							},
						}}
					/>
				</TableContainer>
			</div>
		</Fragment>
	);
}

export { CardBookings };
