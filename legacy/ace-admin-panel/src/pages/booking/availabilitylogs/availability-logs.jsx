/** @format */
import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarPageTitle,
} from '@/partials/toolbar';
import { DataGrid, DataGridColumnHeader } from '@/components';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import {
	Select,
	SelectTrigger,
	SelectContent,
	SelectItem,
	SelectValue,
} from '@/components/ui/select';
import { Calendar } from '@/components/ui/calendar';
import { Input } from '@/components/ui/input';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import { KeenIcon } from '@/components';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshAvailabilityLog,
	setAvailabilityLog,
} from '../../../slices/availabilitySlice';
import toast from 'react-hot-toast';
import { refreshAllDrivers } from '../../../slices/driverSlice';

const AvailabilityLogs = () => {
	const dispatch = useDispatch();
	const { availabilityLog, loading } = useSelector(
		(state) => state.availability
	);
	const { drivers } = useSelector((state) => state.driver);
	const [driverNumber, setDriverNumber] = useState();
	const [date, setDate] = useState(new Date());
	const [open, setOpen] = useState(false);
	const handleSearch = async () => {
		if (!String(driverNumber)?.trim()) {
			toast.error('Please enter a driver ID');
			dispatch(setAvailabilityLog([])); // Reset table if input is empty
			return;
		}
		dispatch(
			refreshAvailabilityLog(driverNumber, format(new Date(date), 'yyyy-MM-dd'))
		);
	};

	useEffect(() => {
		return () => {
			dispatch(setAvailabilityLog([])); // Clear table data
		};
	}, [dispatch]);

	useEffect(() => {
		dispatch(refreshAllDrivers());
	}, [dispatch]);

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
				accessorKey: 'forDate',
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
						{row.original.forDate
							? new Date(row.original.forDate).toLocaleDateString('en-GB')
							: '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'theChange',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>The Change</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.theChange ? row.original.theChange : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'changedOn',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Changed On</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.changedOn
							? new Date(row.original.changedOn).toLocaleDateString('en-GB') +
								' ' +
								row.original.changedOn.split('T')[1]?.split('.')[0]?.slice(0, 5)
							: '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'changeBy',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Changed by User</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.changeBy ? row.original.changeBy : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},

			{
				accessorKey: 'userId',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Driver #</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row.original.userId ? row.original.userId : '-'}
					</span>
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
							{availabilityLog.length > 0
								? `Showing ${availabilityLog.length} Availability Logs for Driver #: ${driverNumber}`
								: 'Search for Availability Log'}
						</ToolbarDescription>
					</ToolbarHeading>
				</Toolbar>
			</div>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
					<div className='flex flex-wrap items-center gap-5 justify-between'>
						<div className='card card-grid min-w-full'>
							<div className='card-header flex flex-wrap gap-2'>
								<div className='flex flex-wrap gap-2 lg:gap-5'>
									<div className='flex flex-wrap gap-2'>
										{/* <label
											className='input input-sm'
											style={{ height: '40px' }}
										>
											<KeenIcon icon='magnifier' />
											<input
												type='number'
												placeholder='Search Driver Id'
												value={driverNumber}
												onChange={(e) => setDriverNumber(e.target.value)}
											/>
										</label> */}
										<div className='flex flex-col'>
											<label className='form-label'>Driver</label>
											<Select
												value={driverNumber}
												onValueChange={(value) => setDriverNumber(value)}
											>
												<SelectTrigger
													className='w-40 hover:shadow-lg'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-36'>
													{drivers?.length > 0 &&
														drivers?.map((driver) => (
															<>
																<SelectItem value={driver?.id}>
																	{driver?.id} - {driver?.fullName}
																</SelectItem>
															</>
														))}
												</SelectContent>
											</Select>
										</div>

										<div className='flex flex-col'>
											<label className='form-label'>Date</label>
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
																	setDate(undefined); // Clear date
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
										</div>

										<button
											className='btn btn-sm btn-outline btn-primary mt-4'
											style={{ height: '40px' }}
											onClick={handleSearch}
											disabled={loading}
										>
											<KeenIcon icon='magnifier' />{' '}
											{loading ? 'Searching...' : 'Search'}
										</button>
									</div>
								</div>
							</div>
							<div className='card-body'>
								{availabilityLog.length > 0 ? (
									<DataGrid
										columns={columns}
										data={availabilityLog}
										rowSelection={true}
										onRowSelectionChange={handleRowSelection}
										pagination={{ size: 10 }}
										sorting={[{ id: 'forDate', desc: false }]}
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
};

export { AvailabilityLogs };
