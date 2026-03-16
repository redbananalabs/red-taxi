/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
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
	refreshDuplicateBookings,
	setDuplicateBookings,
} from '../../../../slices/reportSlice';
function DuplicateBookings() {
	const dispatch = useDispatch();
	const { duplicateBookings } = useSelector((state) => state.reports);
	const [searchInput, setSearchInput] = useState('');
	const [date, setDate] = useState(new Date());
	const [open, setOpen] = useState(false);
	console.log(duplicateBookings);

	const handleDateSelect = (date) => {
		setDate(date);
		setOpen(false);
	};
	// const handleClick = () => {
	// 	dispatch(
	// 		refreshBookingsByStatus(
	// 			format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'"),
	// 			scope,
	// 			status || ''
	// 		)
	// 	);
	// };

	useEffect(() => {
		// Agar status, scope ya date change hota hai to API call karega
		dispatch(
			refreshDuplicateBookings(
				format(new Date(date), "yyyy-MM-dd'T'00:00:00'Z'")
			)
		);
	}, [date, dispatch]);

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
						{row.original.pickupAddress}
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
						{row.original.destinationAddress}
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
				accessorKey: 'duplicateCount',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Count</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row.original.duplicateCount}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
		];

		return baseColumns;
	}, []);

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
		}
	};

	const filteredBookings = useMemo(() => {
		return duplicateBookings.filter((booking) => {
			const search = searchInput.toLowerCase();
			return (
				booking.passengerName?.toLowerCase().includes(search) || // Search by Passenger Name
				booking.pickupAddress?.toLowerCase().includes(search) || // Search by Pickup Address
				booking.destinationAddress?.toLowerCase().includes(search) // Search by Destination
			);
		});
	}, [duplicateBookings, searchInput]);

	useEffect(() => {
		return () => {
			dispatch(setDuplicateBookings([])); // Clear table data
		};
	}, [dispatch]);
	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {duplicateBookings?.length} Report(s){' '}
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
												placeholder='Search'
												value={searchInput}
												onChange={(e) => setSearchInput(e.target.value)}
											/>
										</label>
									</div>
									<div className='flex flex-wrap items-center '>
										<div className='flex flex-col'>
											<label className='form-label'>Date</label>
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
										sorting={[{ id: 'pickupDateTime', desc: false }]}
										layout={{ card: true }}
									/>
								) : (
									<div className='text-center py-10 text-gray-500'>
										No data found
									</div>
								)}
							</div>
						</div>
					</div>
				</div>
			</div>
		</Fragment>
	);
}

export { DuplicateBookings };
