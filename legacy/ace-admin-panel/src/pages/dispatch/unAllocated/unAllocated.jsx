/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
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
// import { Container } from '@/components/container';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import {
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
	// DataGridRowSelectAll,
	// DataGridRowSelect,
} from '@/components';
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshBookingsByStatus,
	setBooking,
	setBookingsByStatus,
} from '../../../slices/bookingSlice';
import RestoreOutlinedIcon from '@mui/icons-material/RestoreOutlined';
import { AllocateBookingModal } from './allocateBookingModal';
import { restoreCancelledBooking } from '../../../service/operations/bookingApi';
import toast from 'react-hot-toast';
function UnAllocated() {
	const dispatch = useDispatch();
	const { bookingsByStatus } = useSelector((state) => state.booking);
	const [searchInput, setSearchInput] = useState('');
	const [date, setDate] = useState(new Date());
	const [open, setOpen] = useState(false);
	const [scope, setScope] = useState(3);
	const [status, setStatus] = useState();
	const [allocatedModal, setAllocatedModal] = useState(false);
	console.log(bookingsByStatus);

	// const handleClick = () => {
	// 	dispatch(
	// 		refreshBookingsByStatus(
	// 			format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
	// 			scope,
	// 			status || ''
	// 		)
	// 	);
	// };
	const handleDateSelect = (date) => {
		setDate(date);
		setOpen(false);
	};

	const handleClose = () => {
		setAllocatedModal(false);
	};

	useEffect(() => {
		// Agar status, scope ya date change hota hai to API call karega
		if (status === null) {
			dispatch(
				refreshBookingsByStatus(
					format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
					scope
				)
			);
		} else {
			dispatch(
				refreshBookingsByStatus(
					format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
					scope,
					status
				)
			);
		}
	}, [date, scope, status, dispatch]);

	const ColumnInputFilter = ({ column }) => {
		return (
			<Input
				placeholder='Filter...'
				value={column.getFilterValue() ?? ''}
				onChange={(event) => column.setFilterValue(event.target.value)}
				className='h-9 w-full max-w-40'
			/>
		);
	};

	const columns = useMemo(() => {
		let baseColumns = [
			{
				accessorKey: 'id',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'># id</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row.original.id}</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'pickupDateTime',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Date</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.pickupDateTime
							? new Date(row.original.pickupDateTime).toLocaleDateString(
									'en-GB'
								) +
								' ' +
								row.original.pickupDateTime
									.split('T')[1]
									?.split('.')[0]
									?.slice(0, 5)
							: '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'pickupAddress',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Pickup</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.pickupAddress}, {row.original.pickupPostCode}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'destinationAddress',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Destination</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.destinationAddress},{' '}
						{row.original.destinationPostCode}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'passengerName',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Passenger</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row.original.passengerName}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'passengers',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Pax</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>{row.original.passengers}</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
		];

		if (status === 0) {
			// **Unallocated Jobs** ➝ Show "Allocate" Column
			baseColumns.push({
				accessorKey: 'allocate',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Allocate</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<button
						className='rounded-full px-2 py-2  w-8 h-8 flex justify-center items-center hover:bg-red-100 group'
						onClick={() => {
							dispatch(setBooking(row.original));
							setAllocatedModal(true);
						}}
					>
						<KeenIcon
							icon='plus'
							className='group-hover:text-red-600'
						/>
					</button>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			});
		} else if (status === 1 || status === 3) {
			baseColumns.push({
				accessorKey: 'userId',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Driver #</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.userId ? row.original.userId : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[150px]' },
			});
			// **Allocated & Completed Jobs** ➝ Show "Last Updated" Column
			baseColumns.push({
				accessorKey: 'dateUpdated',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Last Updated</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.dateUpdated
							? new Date(row.original.dateUpdated).toLocaleDateString('en-GB') +
								' ' +
								new Date(row.original.dateUpdated).toLocaleTimeString('en-GB')
							: '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[150px]' },
			});
		} else if (status === 2) {
			baseColumns.push({
				accessorKey: 'cancelledByName',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Cancelled By</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.cancelledByName ? row.original.cancelledByName : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[150px]' },
			});
			baseColumns.push({
				accessorKey: 'dateUpdated',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Last Updated</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.dateUpdated
							? new Date(row.original.dateUpdated).toLocaleDateString('en-GB') +
								' ' +
								new Date(row.original.dateUpdated).toLocaleTimeString('en-GB')
							: '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[150px]' },
			});
			// **Cancelled Jobs** ➝ Show "Restore" Column
			baseColumns.push({
				accessorKey: 'restore',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Restore</span>
						column={column}
					/>
				),
				enableSorting: false,
				cell: ({ row }) => (
					<button
						className='rounded-full px-2 py-2  w-8 h-8 flex justify-center items-center hover:bg-red-100 group'
						onClick={() => handleRestoreBooking(row?.original?.id)}
					>
						{/* <KeenIcon
							icon='plus'
							className='group-hover:text-red-600'
						/> */}
						<RestoreOutlinedIcon
							className='group-hover:text-red-600'
							sx={{ fontSize: '14px' }}
						/>
					</button>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			});
		}

		return baseColumns;
	}, [status]);

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
		}
	};

	const handleRestoreBooking = async (id) => {
		console.log('Restore Booking ID:', id);
		try {
			const response = await restoreCancelledBooking(id);
			if (response.status === 'success') {
				toast.success('Booking restored successfully');
				if (status === null) {
					dispatch(
						refreshBookingsByStatus(
							format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
							scope
						)
					);
				} else {
					dispatch(
						refreshBookingsByStatus(
							format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
							scope,
							status
						)
					);
				}
			}
		} catch (error) {
			console.error('Error restoring booking:', error);
		}
	};

	const filteredBookings = useMemo(() => {
		return bookingsByStatus.filter((booking) => {
			const search = searchInput.toLowerCase();
			return (
				booking.id?.toString().includes(search) || // Search by Booking ID
				booking.passengerName?.toLowerCase().includes(search) || // Search by Passenger Name
				booking.pickupAddress?.toLowerCase().includes(search) || // Search by Pickup Address
				booking.destinationAddress?.toLowerCase().includes(search) // Search by Destination
			);
		});
	}, [bookingsByStatus, searchInput]);

	useEffect(() => {
		return () => {
			dispatch(setBookingsByStatus([])); // Clear table data
		};
	}, [dispatch]);

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {bookingsByStatus?.length}{' '}
							{status === 0
								? 'Unallocated'
								: status === 1
									? 'Allocated'
									: status === 2
										? 'Cancelled'
										: status === 3
											? 'Completed'
											: ''}{' '}
							Jobs{' '}
						</ToolbarDescription>
					</ToolbarHeading>
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
											style={{ height: '40px', marginTop: '1rem' }}
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
												<button
													id='date'
													className={cn(
														'input data-[state=open]:border-primary',
														!date && 'text-muted-foreground'
													)}
													style={{ width: '13rem', marginTop: '1rem' }}
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
												value={scope}
												onValueChange={(value) => setScope(value)}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value={3}>All</SelectItem>
													<SelectItem value={0}>Cash</SelectItem>
													<SelectItem value={4}>Card</SelectItem>
													<SelectItem value={1}>Account</SelectItem>
													<SelectItem value={2}>Rank</SelectItem>
												</SelectContent>
											</Select>
										</div>

										<div className='flex flex-col'>
											<label className='form-label'>Status</label>
											<Select
												value={status}
												onValueChange={(value) => setStatus(value)}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value={0}>Unallocated</SelectItem>
													<SelectItem value={1}>Allocated</SelectItem>
													<SelectItem value={2}>Cancelled</SelectItem>
													<SelectItem value={3}>Completed</SelectItem>
												</SelectContent>
											</Select>
										</div>

										{/* <button
											className='btn btn-sm btn-outline btn-primary'
											style={{ height: '40px' }}
											onClick={handleClick}
											disabled={loading}
										>
											<KeenIcon icon='magnifier' />{' '}
											{loading ? 'Searching...' : 'Search'}
										</button> */}
									</div>
								</div>
							</div>
							<div className='card-body'>
								{filteredBookings.length ? (
									<DataGrid
										columns={columns}
										data={filteredBookings}
										rowSelection={true}
										onRowSelectionChange={handleRowSelection}
										pagination={{ size: 10 }}
										sorting={[{ id: 'id', desc: false }]}
										layout={{ card: true }}
									/>
								) : (
									<div className='text-center py-10 text-gray-500'>
										No data found
									</div>
								)}
							</div>

							{allocatedModal && (
								<AllocateBookingModal
									open={allocatedModal}
									onOpenChange={handleClose}
									date={date}
									scope={scope}
									status={status}
								/>
							)}
						</div>
					</div>
				</div>
			</div>
		</Fragment>
	);
}

export { UnAllocated };
