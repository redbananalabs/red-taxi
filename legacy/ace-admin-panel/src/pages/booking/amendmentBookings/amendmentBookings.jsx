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
	refreshAmendWebBookings,
	setAmendRequest,
} from '../../../slices/webBookingSlice';
import { Link, useNavigate } from 'react-router-dom';
import { CancelModal } from './cancelModal';
import RefreshIcon from '@mui/icons-material/Refresh';

function AmendmentBookings() {
	const navigate = useNavigate();
	const dispatch = useDispatch();
	const { amendRequests } = useSelector((state) => state.webBooking);
	const [searchInput, setSearchInput] = useState('');
	const [date, setDate] = useState();
	const [cancelModal, setCancelModal] = useState(false);
	const [open, setOpen] = useState(false);

	const handleDateSelect = (date) => {
		setDate(date); // Update the date range
		// Close the popover if both from and to dates are selected
		setOpen(false);
	};

	useEffect(() => {
		dispatch(refreshAmendWebBookings());
	}, [dispatch]);

	const filteredBookings = useMemo(() => {
		// if No filtration is applied
		if (!searchInput && !date) {
			return amendRequests;
		}

		return amendRequests?.filter((booking) => {
			const searchValue = searchInput?.toLowerCase();

			const bookingDate = booking.dateTime
				? format(new Date(booking?.dateTime), 'yyyy-MM-dd')
				: '';

			const isMatch =
				booking?.pickupAddress?.toLowerCase().includes(searchValue) ||
				booking?.pickupPostCode?.toLowerCase().includes(searchValue) ||
				booking?.destinationAddress?.toLowerCase().includes(searchValue) ||
				booking?.destinationPostCode?.toLowerCase().includes(searchValue) ||
				booking?.passengerName?.toLowerCase().includes(searchValue);

			const isDateMatch = date
				? bookingDate === format(date, 'yyyy-MM-dd')
				: true;

			return isMatch && isDateMatch;
		});
	}, [amendRequests, searchInput, date]);

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

	const columns = useMemo(
		() => [
			{
				accessorKey: 'bookingId',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'># id</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`p-2 rounded-md`}>{row?.original?.bookingId}</span>
				),
				meta: { headerClassName: 'w-20' },
			},
			{
				accessorKey: 'dateTime',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Date/Time</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{new Date(row.original.dateTime?.split('T')[0])?.toLocaleDateString(
							'en-GB'
						)}{' '}
						{row.original.dateTime?.split('T')[1].split('.')[0]?.slice(0, 5)}
					</span>
				),
				meta: { headerClassName: 'min-w-[160px]' },
			},

			{
				accessorKey: 'pickupAddress',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Pickup Address</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row?.original?.pickupAddress}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'destinationAddress',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Destination Address</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.destinationAddress}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'passengerName',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Passenger Name</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row?.original?.passengerName}
					</span>
				),
				meta: { headerClassName: 'w-18' },
			},
			{
				accessorKey: 'amendments',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Amendments</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row?.original?.amendments}
					</span>
				),
				meta: { headerClassName: 'w-18' },
			},
			{
				accessorKey: 'applyToBlock',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Block</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row?.original?.applyToBlock ? "True" : "False"}
					</span>
				),
				meta: { headerClassName: 'w-18' },
			},
			{
				accessorKey: 'action',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Actions</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<div className='w-full flex justify-start items-center gap-2'>
						{!row?.accepted && (
							<button
								className='btn btn-sm btn-success px-4 py-4'
								onClick={() => {
									navigate('/bookings/booking-dispatch');
								}}
							>
								Amend
							</button>
						)}
						{!row?.accepted && (
							<button
								className='btn btn-sm btn-danger px-4 py-4'
								onClick={() => {
									setCancelModal(true);
									dispatch(setAmendRequest(row.original));
								}}
								disabled={!row.original.cancelBooking}
							>
								Cancel
							</button>
						)}
					</div>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
		],
		[]
	);

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
		}
	};

	const handleClose = () => {
		setCancelModal(false);
	};

	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Total {`${amendRequests.length}`} Amend Web Request(s){' '}
						</ToolbarDescription>
					</ToolbarHeading>
					<ToolbarActions>
						<Link to='/bookings/web-booking'>
							<button className='btn btn-sm btn-primary px-4 py-4'>
								<KeenIcon icon='arrow-left' /> Back
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
											style={{ height: '40px' }}
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
														style={{ width: '13rem' }}
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

										<button
											className='btn btn-sm btn-outline btn-primary'
											style={{ height: '40px' }}
											onClick={() => dispatch(refreshAmendWebBookings())}
										>
											<RefreshIcon sx={{ fontSize: '12px' }} /> Refresh
										</button>
									</div>
								</div>
							</div>
							<div className='card-body'>
								<DataGrid
									columns={columns}
									data={filteredBookings}
									rowSelection={true}
									onRowSelectionChange={handleRowSelection}
									pagination={{ size: 10 }}
									sorting={[{ id: 'bookingId', desc: false }]}
									layout={{ card: true }}
								/>
							</div>
						</div>
					</div>
				</div>
				{cancelModal && (
					<CancelModal
						open={cancelModal}
						onOpenChange={handleClose}
					/>
				)}
			</div>
		</Fragment>
	);
}

export { AmendmentBookings };
