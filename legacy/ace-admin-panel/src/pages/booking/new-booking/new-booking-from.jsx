/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarActions,
	ToolbarPageTitle,
} from '@/partials/toolbar';
import { KeenIcon } from '@/components';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';
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
// import { Container } from '@/components/container';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
// import {
// 	DataGrid,
// 	DataGridColumnHeader,
// 	// useDataGrid,
// 	// DataGridRowSelectAll,
// 	// DataGridRowSelect,
// } from '@/components';
// import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshWebBookings,
	setWebBooking,
} from '../../../slices/webBookingSlice';
import { AcceptWebBooking } from './acceptWebBooking';
import { RejectWebBooking } from './rejectWebBooking';
import { Link } from 'react-router-dom';
import RefreshIcon from '@mui/icons-material/Refresh';

import {
	KeyboardArrowDown,
	KeyboardArrowUp,
	// EmailOutlined,
} from '@mui/icons-material';

function Row({ row, setAcceptModal, setRejectModal, dispatch }) {
	const [open, setOpen] = useState(false);

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
						<span className={`font-medium ${row.color}`}>
							<label className='switch'>
								<input
									type='checkbox'
									name='arriveBy'
									checked={row.arriveBy}
									readOnly
								/>
							</label>
						</span>
					</Typography>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<span className={`font-medium ${row.color}`}>
						{new Date(row.pickupDateTime?.split('T')[0])?.toLocaleDateString(
							'en-GB'
						)}{' '}
						{row.pickupDateTime?.split('T')[1].split('.')[0]?.slice(0, 5)}
					</span>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<span className={`font-medium ${row.color}`}>
						{row?.pickupAddress}, {row?.pickupPostCode}
					</span>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<span className={`font-medium ${row.color}`}>
						{row.destinationAddress}, {row.destinationPostCode}
					</span>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<span className={row.color}>{row?.passengerName}</span>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<span className={row.color}>{row?.passengers}</span>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<span className={row.color}>
						{row.phoneNumber ? row.phoneNumber : '-'}
					</span>
				</TableCell>
				<TableCell className='text-[#14151A] dark:text-gray-700'>
					<span className={row.color}>
						{row.repeatText ? row.repeatText : '-'}
					</span>
				</TableCell>
				<TableCell>
					<div className='w-full flex justify-start items-center gap-2'>
						{!row?.accepted && (
							<button
								className='btn btn-sm btn-success px-4 py-4'
								onClick={() => {
									setAcceptModal(true);
									dispatch(setWebBooking(row));
								}}
							>
								Accept
							</button>
						)}
						{!row?.accepted && (
							<button
								className='btn btn-sm btn-danger px-4 py-4'
								onClick={() => {
									setRejectModal(true);
									dispatch(setWebBooking(row));
								}}
							>
								Reject
							</button>
						)}
					</div>
				</TableCell>
			</TableRow>
			<TableRow>
				<TableCell
					colSpan={18}
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
								justifyContent='space-start'
								gap='12rem'
							>
								<Box>
									<Typography variant='body2'>
										<strong>Account No:</strong> {row.accNo}
									</Typography>
									<Typography variant='body2'>
										<strong>Details:</strong> {row.details}
									</Typography>
								</Box>
								<Box>
									<Typography variant='body2'>
										<strong>Passengers:</strong> {row.passengers}
									</Typography>
									<Typography variant='body2'>
										<strong>Passenger Name:</strong> {row.passengerName}
									</Typography>
								</Box>
								<Box>
									<Typography variant='body2'>
										<strong>Phone Number:</strong> {row.phoneNumber}
									</Typography>
									<Typography variant='body2'>
										<strong>Email:</strong>
										<a
											href={`mailto:${row.email}`}
											className='hover:underline'
										>
											{row.email}
										</a>
									</Typography>
								</Box>
								<Box>
									<Typography variant='body2'>
										<strong>Luggage:</strong> {row.luggage}
									</Typography>
									<Typography variant='body2'>
										<strong>Price:</strong> £ {row.price?.toFixed(2)}
									</Typography>
									<Typography variant='body2'>
										<strong>Created On:</strong>{' '}
										{new Date(row.createdOn?.split('T')[0])?.toLocaleDateString(
											'en-GB'
										)}{' '}
										{row.createdOn?.split('T')[1].split('.')[0]?.slice(0, 5)}
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
function NewBooking() {
	const dispatch = useDispatch();
	const [acceptModal, setAcceptModal] = useState(false);
	const [rejectModal, setRejectModal] = useState(false);
	const [searchInput, setSearchInput] = useState('');
	const [selectedScope, setSelectedScope] = useState('3');
	const [date, setDate] = useState(null);
	const [open, setOpen] = useState(false);
	const { webBookings } = useSelector((state) => state.webBooking);
	const [order, setOrder] = useState('asc'); // Sort order
	const [orderBy, setOrderBy] = useState('pickUpDateTime'); // Default sorted column
	const [page, setPage] = useState(0);
	const [rowPerPage, setRowPerPage] = useState(10);

	const handleChangePage = (e, newPage) => {
		setPage(newPage);
	};

	const handleChangeRowsPerPage = (e) => {
		setRowPerPage(parseInt(e.target.value, 10));
		setPage(0);
	};

	const handleSort = (property) => {
		const isAscending = orderBy === property && order === 'asc';
		setOrder(isAscending ? 'desc' : 'asc');
		setOrderBy(property);
	};

	useEffect(() => {
		dispatch(refreshWebBookings());
	}, [dispatch]);

	const filteredBookings = useMemo(() => {
		// if No filtration is applied
		if (!searchInput && selectedScope === '3' && !date) {
			return webBookings;
		}

		return webBookings?.filter((booking) => {
			const searchValue = searchInput?.toLowerCase();

			const bookingDate = booking.pickupDateTime
				? format(new Date(booking?.pickupDateTime), 'yyyy-MM-dd')
				: '';

			const isMatch =
				booking?.pickupAddress.toLowerCase().includes(searchValue) ||
				booking?.pickupPostCode.toLowerCase().includes(searchValue) ||
				booking?.destinationAddress.toLowerCase().includes(searchValue) ||
				booking?.destinationPostCode.toLowerCase().includes(searchValue) ||
				booking?.passengerName.toLowerCase().includes(searchValue);

			const isDateMatch = date
				? bookingDate === format(date, 'yyyy-MM-dd')
				: true;

			const isScopeMatch =
				selectedScope === '3' || String(booking?.scope) === selectedScope;

			return isMatch && isDateMatch && isScopeMatch;
		});
	}, [webBookings, searchInput, date, selectedScope]);

	const sortedBookings = [...filteredBookings].sort((a, b) => {
		if (order === 'asc') {
			return a[orderBy] > b[orderBy] ? 1 : -1;
		} else {
			return a[orderBy] < b[orderBy] ? 1 : -1;
		}
	});

	// const ColumnInputFilter = ({ column }) => {
	// 	return (
	// 		<Input
	// 			placeholder='Filter...'
	// 			value={column.getFilterValue() ?? ''}
	// 			onChange={(event) => column.setFilterValue(event.target.value)}
	// 			className='h-9 w-full max-w-40'
	// 		/>
	// 	);
	// };

	// const columns = useMemo(
	// 	() => [
	// 		// {
	// 		// 	accessorKey: 'id',
	// 		// 	header: ({ column }) => (
	// 		// 		<DataGridColumnHeader
	// 		// 			title=<span className='font-bold'># id</span>
	// 		// 			filter={<ColumnInputFilter column={column} />}
	// 		// 			column={column}
	// 		// 		/>
	// 		// 	),
	// 		// 	enableSorting: true,
	// 		// 	cell: ({ row }) => (
	// 		// 		<span className={`p-2 rounded-md`}>{row?.original?.id}</span>
	// 		// 	),
	// 		// 	meta: { headerClassName: 'w-10' },
	// 		// },
	// 		{
	// 			accessorKey: 'arriveBy',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Arrive By</span>
	// 					filter={<ColumnInputFilter column={column} />}
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<span className={`font-medium ${row.original.color}`}>
	// 					<label className='switch'>
	// 						<input
	// 							type='checkbox'
	// 							name='arriveBy'
	// 							checked={row.original.arriveBy}
	// 							readOnly
	// 						/>
	// 					</label>
	// 				</span>
	// 			),
	// 			meta: { headerClassName: 'w-10' },
	// 		},
	// 		{
	// 			accessorKey: 'pickUpDateTime',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Date/Time</span>
	// 					filter={<ColumnInputFilter column={column} />}
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<span className={`font-medium ${row.original.color}`}>
	// 					{new Date(
	// 						row.original.pickupDateTime?.split('T')[0]
	// 					)?.toLocaleDateString('en-GB')}{' '}
	// 					{row.original.pickupDateTime
	// 						?.split('T')[1]
	// 						.split('.')[0]
	// 						?.slice(0, 5)}
	// 				</span>
	// 			),
	// 			meta: { headerClassName: 'min-w-[160px]' },
	// 		},

	// 		{
	// 			accessorKey: 'pickupAddress',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Pickup Address</span>
	// 					filter={<ColumnInputFilter column={column} />}
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<span className={`font-medium ${row.original.color}`}>
	// 					{row?.original?.pickupAddress}, {row?.original?.pickupPostCode}
	// 				</span>
	// 			),
	// 			meta: { headerClassName: 'min-w-[200px]' },
	// 		},
	// 		{
	// 			accessorKey: 'destinationAddress',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Destination Address</span>
	// 					filter={<ColumnInputFilter column={column} />}
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<span className={`font-medium ${row.original.color}`}>
	// 					{row.original.destinationAddress},{' '}
	// 					{row.original.destinationPostCode}
	// 				</span>
	// 			),
	// 			meta: { headerClassName: 'min-w-[200px]' },
	// 		},
	// 		{
	// 			accessorKey: 'passengerName',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Passenger Name</span>
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<span className={row.original.color}>
	// 					{row?.original?.passengerName}
	// 				</span>
	// 			),
	// 			meta: { headerClassName: 'w-18' },
	// 		},
	// 		{
	// 			accessorKey: 'passengers',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Passenger</span>
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<span className={row.original.color}>
	// 					{row?.original?.passengers}
	// 				</span>
	// 			),
	// 			meta: { headerClassName: 'w-18' },
	// 		},
	// 		{
	// 			accessorKey: 'phoneNumber',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Phone Number</span>
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<span className={row.original.color}>
	// 					{row.original.phoneNumber ? row.original.phoneNumber : '-'}
	// 				</span>
	// 			),
	// 			meta: { headerClassName: 'min-w-[80px]' },
	// 		},
	// 		{
	// 			accessorKey: 'repeatText',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Days & Ends on Date</span>
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<span className={row.original.color}>
	// 					{row.original.repeatText ? row.original.repeatText : '-'}
	// 				</span>
	// 			),
	// 			meta: { headerClassName: 'min-w-[80px]' },
	// 		},

	// 		{
	// 			accessorKey: 'action',
	// 			header: ({ column }) => (
	// 				<DataGridColumnHeader
	// 					title=<span className='font-bold'>Actions</span>
	// 					column={column}
	// 				/>
	// 			),
	// 			enableSorting: true,
	// 			cell: ({ row }) => (
	// 				<div className='w-full flex justify-start items-center gap-2'>
	// 					{!row?.accepted && (
	// 						<button
	// 							className='btn btn-sm btn-success px-4 py-4'
	// 							onClick={() => {
	// 								setAcceptModal(true);
	// 								dispatch(setWebBooking(row.original));
	// 							}}
	// 						>
	// 							Accept
	// 						</button>
	// 					)}
	// 					{!row?.accepted && (
	// 						<button
	// 							className='btn btn-sm btn-danger px-4 py-4'
	// 							onClick={() => {
	// 								setRejectModal(true);
	// 								dispatch(setWebBooking(row.original));
	// 							}}
	// 						>
	// 							Reject
	// 						</button>
	// 					)}
	// 				</div>
	// 			),
	// 			meta: { headerClassName: 'min-w-[80px]' },
	// 		},
	// 	],
	// 	[dispatch]
	// );

	const handleCloseAcceptModal = () => {
		setAcceptModal(false);
	};

	const handleCloseRejectModal = () => {
		setRejectModal(false);
	};

	// const handleRowSelection = (state) => {
	// 	const selectedRowIds = Object.keys(state);
	// 	if (selectedRowIds.length > 0) {
	// 		alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
	// 	}
	// };

	const handleDateSelect = (date) => {
		setDate(date); // Update the date range
		// Close the popover if both from and to dates are selected
		setOpen(false);
	};

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Total {`${webBookings?.length}`} Web Job(s){' '}
						</ToolbarDescription>
					</ToolbarHeading>
					<ToolbarActions>
						<Link to='/bookings/reject-booking'>
							<button className='btn btn-sm btn-danger px-4 py-4'>
								Rejected Bookings
							</button>
						</Link>
					</ToolbarActions>
				</Toolbar>
			</div>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
					<div className='flex flex-wrap items-center gap-5 justify-between'>
						<div className='card card-grid min-w-full'>
							<div className='card-header flex-wrap gap-2'>
								<div className='flex flex-wrap gap-2 lg:gap-5'>
									<div className='flex'>
										<label
											className='input input-sm'
											style={{ height: '40px', marginTop: '16px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='text'
												placeholder='Search Jobs'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
									</div>
									<div className='flex flex-wrap items-center gap-2.5'>
										<Popover
											open={open}
											onOpenChange={setOpen}
										>
											<PopoverTrigger asChild>
												<div className='relative'>
													<button
														id='date'
														className={cn(
															'input data-[state=open]:border-primary',
															!date && 'text-muted-foreground'
														)}
														style={{ width: '13rem', marginTop: '16px' }}
													>
														<KeenIcon
															icon='calendar'
															className='-ms-0.5'
														/>
														{date ? (
															format(date, 'LLL dd, y')
														) : (
															<span>Pick a date</span>
														)}
													</button>
													{date && (
														<button
															onClick={(e) => {
																e.stopPropagation(); // Prevent closing popover
																setDate(null); // Clear date
															}}
															className='absolute right-2 top-2/3 transform -translate-y-1/2 text-gray-500 hover:text-gray-700'
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

										<div className='flex flex-col'>
											<label className='form-label'>Scope</label>
											<Select
												value={selectedScope}
												onValueChange={setSelectedScope}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value='3'>All</SelectItem>
													<SelectItem value='0'>Cash</SelectItem>
													<SelectItem value='4'>Card</SelectItem>
													<SelectItem value='1'>Account</SelectItem>
													<SelectItem value='2'>Rank</SelectItem>
												</SelectContent>
											</Select>
										</div>

										<button
											className='btn btn-sm btn-outline btn-primary mt-4'
											style={{ height: '40px' }}
											onClick={() => dispatch(refreshWebBookings())}
										>
											<RefreshIcon sx={{ fontSize: '12px' }} /> Refresh
										</button>
									</div>
								</div>
							</div>
							<div className='card-body'>
								{/* <DataGrid
									columns={columns}
									data={filteredBookings}
									rowSelection={true}
									onRowSelectionChange={handleRowSelection}
									pagination={{ size: 10 }}
									sorting={[{ id: 'pickUpDateTime', desc: false }]}
									layout={{ card: true }}
								/> */}
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
												{/* <TableCell className='text-[#14151A] dark:text-gray-700 border-e'>
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
												</TableCell> */}
												<TableCell className='text-[#14151A] dark:text-gray-700 border-e'>
													<TableSortLabel
														active={orderBy === 'arriveBy'}
														direction={order}
														onClick={() => handleSort('arriveBy')}
														sx={{
															'&:hover': { color: '#9A9CAE' }, // Change color on hover
															'&.Mui-active': { color: '#9A9CAE' },
															'&.Mui-active .MuiTableSortLabel-icon': {
																color: '#9A9CAE',
															}, // Change to blue when active
															'fontWeight': 'bold',
														}}
													>
														Arrive By
													</TableSortLabel>
												</TableCell>
												<TableCell className='text-[#14151A] dark:text-gray-700 border-e'>
													<TableSortLabel
														active={orderBy === 'pickUpDateTime'}
														direction={order}
														onClick={() => handleSort('pickUpDateTime')}
														sx={{
															'&:hover': { color: '#9A9CAE' }, // Change color on hover
															'&.Mui-active': { color: '#9A9CAE' },
															'&.Mui-active .MuiTableSortLabel-icon': {
																color: '#9A9CAE',
															}, // Change to blue when active
															'fontWeight': 'bold',
														}}
													>
														Date/Time
													</TableSortLabel>
												</TableCell>
												<TableCell
													className='text-[#14151A] dark:text-gray-700 border-e'
													sx={{ fontWeight: 'bold' }}
												>
													<TableSortLabel
														active={orderBy === 'pickupAddress'}
														direction={order}
														onClick={() => handleSort('pickupAddress')}
														sx={{
															'&:hover': { color: '#9A9CAE' }, // Change color on hover
															'&.Mui-active': { color: '#9A9CAE' },
															'&.Mui-active .MuiTableSortLabel-icon': {
																color: '#9A9CAE',
															}, // Change to blue when active
															'fontWeight': 'bold',
														}}
													>
														Pickup Address
													</TableSortLabel>
												</TableCell>
												<TableCell
													className='text-[#14151A] dark:text-gray-700 border-e'
													sx={{ fontWeight: 'bold' }}
												>
													<TableSortLabel
														active={orderBy === 'destinationAddress'}
														direction={order}
														onClick={() => handleSort('destinationAddress')}
														sx={{
															'&:hover': { color: '#9A9CAE' }, // Change color on hover
															'&.Mui-active': { color: '#9A9CAE' },
															'&.Mui-active .MuiTableSortLabel-icon': {
																color: '#9A9CAE',
															}, // Change to blue when active
															'fontWeight': 'bold',
														}}
													>
														Destination Address
													</TableSortLabel>
												</TableCell>
												<TableCell
													className='text-[#14151A] dark:text-gray-700 border-e'
													sx={{ fontWeight: 'bold' }}
												>
													<TableSortLabel
														active={orderBy === 'passengerName'}
														direction={order}
														onClick={() => handleSort('passengerName')}
														sx={{
															'&:hover': { color: '#9A9CAE' }, // Change color on hover
															'&.Mui-active': { color: '#9A9CAE' },
															'&.Mui-active .MuiTableSortLabel-icon': {
																color: '#9A9CAE',
															}, // Change to blue when active
															'fontWeight': 'bold',
														}}
													>
														Passenger Name
													</TableSortLabel>
												</TableCell>
												<TableCell
													className='text-[#14151A] dark:text-gray-700 border-e'
													sx={{ fontWeight: 'bold' }}
												>
													<TableSortLabel
														active={orderBy === 'passengers'}
														direction={order}
														onClick={() => handleSort('passengers')}
														sx={{
															'&:hover': { color: '#9A9CAE' }, // Change color on hover
															'&.Mui-active': { color: '#9A9CAE' },
															'&.Mui-active .MuiTableSortLabel-icon': {
																color: '#9A9CAE',
															}, // Change to blue when active
															'fontWeight': 'bold',
														}}
													>
														Passengers
													</TableSortLabel>
												</TableCell>
												<TableCell className='text-[#14151A] dark:text-gray-700 border-e'>
													<TableSortLabel
														active={orderBy === 'phoneNumber'}
														direction={order}
														onClick={() => handleSort('phoneNumber')}
														sx={{
															'&:hover': { color: '#9A9CAE' }, // Change color on hover
															'&.Mui-active': { color: '#9A9CAE' },
															'&.Mui-active .MuiTableSortLabel-icon': {
																color: '#9A9CAE',
															}, // Change to blue when active
															'fontWeight': 'bold',
														}}
													>
														Phone Number
													</TableSortLabel>
												</TableCell>

												<TableCell
													className='text-[#14151A] dark:text-gray-700 border-e'
													sx={{ fontWeight: 'bold' }}
												>
													<TableSortLabel
														active={orderBy === 'repeatText'}
														direction={order}
														onClick={() => handleSort('repeatText')}
														sx={{
															'&:hover': { color: '#9A9CAE' }, // Change color on hover
															'&.Mui-active': { color: '#9A9CAE' },
															'&.Mui-active .MuiTableSortLabel-icon': {
																color: '#9A9CAE',
															}, // Change to blue when active
														}}
													>
														Days & Ends on Date
													</TableSortLabel>
												</TableCell>
												<TableCell
													className='text-[#14151A] dark:text-gray-700 border-e'
													sx={{ fontWeight: 'bold' }}
												>
													Actions
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
												?.slice(
													page * rowPerPage,
													page * rowPerPage + rowPerPage
												)
												.map((row) => (
													<Row
														key={row.id}
														row={row}
														setAcceptModal={setAcceptModal}
														setRejectModal={setRejectModal}
														dispatch={dispatch}
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
						</div>
					</div>
				</div>
			</div>
			{acceptModal && (
				<AcceptWebBooking
					open={acceptModal}
					onOpenChange={handleCloseAcceptModal}
				/>
			)}
			{rejectModal && (
				<RejectWebBooking
					open={rejectModal}
					onOpenChange={handleCloseRejectModal}
				/>
			)}
		</Fragment>
	);
}

export { NewBooking };
