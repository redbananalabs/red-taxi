/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarPageTitle,
} from '@/partials/toolbar';
// import { KeenIcon } from '@/components';

// import { Container } from '@/components/container';
// import {
// 	Popover,
// 	PopoverContent,
// 	PopoverTrigger,
// } from '@/components/ui/popover';
// import { Calendar } from '@/components/ui/calendar';
// import { addDays, format } from 'date-fns';
// import { cn } from '@/lib/utils';
import {
	DataGrid,
	DataGridColumnHeader,
	// useDataGrid,
	// DataGridRowSelectAll,
	// DataGridRowSelect,
} from '@/components';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue,
} from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshGrowthByPeriod,
	setGrowthByPeriod,
} from '../../../../slices/reportSlice';
function GrowthByPeriod() {
	const dispatch = useDispatch();
	const { growthByPeriod } = useSelector((state) => state.reports);
	// const [searchInput, setSearchInput] = useState('');
	// const [openDate, setOpenDate] = useState(false);
	// const [date, setDate] = useState({
	// 	from: new Date(),
	// 	to: addDays(new Date(), 20),
	// });
	// const [tempRange, setTempRange] = useState(date);
	const currentYear = new Date().getFullYear();
	const [viewBy, setViewBy] = useState(0);
	const [startMonth, setStartMonth] = useState(1);
	const [endMonth, setEndMonth] = useState(1);
	const [startYear, setStartYear] = useState(currentYear);
	const [endYear, setEndYear] = useState(currentYear);

	// const [period, setPeriod] = useState(0);
	// useEffect(() => {
	// 	if (openDate) {
	// 		setTempRange({ from: null, to: null });
	// 	}
	// }, [openDate]);

	// const handleDateSelect = (range) => {
	// 	setTempRange(range);
	// 	if (range?.from && range?.to) {
	// 		setDate(range);
	// 		setOpenDate(false);
	// 	}
	// };
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
			refreshGrowthByPeriod(startMonth, startYear, endMonth, endYear, viewBy)
		);
	}, [viewBy, dispatch, startMonth, startYear, endMonth, endYear]);

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

	const scopes = {
		0: 'Cash',
		1: 'Account',
		2: 'Rank',
		3: 'All',
		4: 'Card',
	};

	const columns = useMemo(() => {
		let baseColumns = [
			{
				accessorKey: 'periodLabel',
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
						{row.original.periodLabel ? row.original.periodLabel : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'scope',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Scope</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{scopes[row.original.scope]}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'currentYearCount',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Current Year Count</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.currentYearCount}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'previousYearCount',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Previous Year Count</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row.original.previousYearCount}
					</span>
				),
				meta: { headerClassName: 'min-w-[80px]' },
			},
			{
				accessorKey: 'percentageGrowth',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Percentage Growth</span>
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={row.original.color}>
						{row.original.percentageGrowth}
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

	// const filteredBookings = useMemo(() => {
	// 	return growthByPeriod.filter((booking) => {
	// 		const search = searchInput.toLowerCase();
	// 		return (
	// 			booking.passengerName?.toLowerCase().includes(search) || // Search by Passenger Name
	// 			booking.pickupAddress?.toLowerCase().includes(search) || // Search by Pickup Address
	// 			booking.destinationAddress?.toLowerCase().includes(search) // Search by Destination
	// 		);
	// 	});
	// }, [growthByPeriod, searchInput]);

	const months = [
		'January',
		'February',
		'March',
		'April',
		'May',
		'June',
		'July',
		'August',
		'September',
		'October',
		'November',
		'December',
	];

	const years = Array.from({ length: 11 }, (_, i) => currentYear - 10 + i);

	useEffect(() => {
		return () => {
			dispatch(setGrowthByPeriod([])); // Clear table data
		};
	}, [dispatch]);
	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {growthByPeriod?.length} Report(s){' '}
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
									{/* <div className='flex'>
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
									</div> */}
									<div className='flex flex-wrap items-center gap-2 lg:gap-5'>
										{/* <div className='flex flex-col'>
											<label className='form-label'>Date</label>
											<Popover
												open={openDate}
												onOpenChange={setOpenDate}
											>
												<PopoverTrigger asChild>
													<button
														id='date'
														className={cn(
															'btn btn-sm btn-light data-[state=open]:bg-light-active',
															!date && 'text-gray-400'
														)}
														style={{ height: '40px' }}
													>
														<KeenIcon
															icon='calendar'
															className='me-0.5'
														/>
														{date?.from ? (
															date.to ? (
																<>
																	{format(date.from, 'LLL dd, y')} -{' '}
																	{format(date.to, 'LLL dd, y')}
																</>
															) : (
																format(date.from, 'LLL dd, y')
															)
														) : (
															<span>Pick a date range</span>
														)}
													</button>
												</PopoverTrigger>
												<PopoverContent
													className='w-auto p-0'
													align='end'
												>
													<Calendar
														initialFocus
														mode='range'
														defaultMonth={date?.from}
														selected={tempRange}
														onSelect={handleDateSelect}
														numberOfMonths={2}
													/>
												</PopoverContent>
											</Popover>
										</div> */}
										<div className='flex flex-col'>
											<label className='form-label'>Start Month</label>
											<Select
												value={startMonth}
												onValueChange={(value) => setStartMonth(value)}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value={0}>Select</SelectItem>
													{months.map((month, index) => (
														<>
															<SelectItem value={index + 1}>{month}</SelectItem>
														</>
													))}
												</SelectContent>
											</Select>
										</div>
										<div className='flex flex-col'>
											<label className='form-label'>End Month</label>
											<Select
												value={endMonth}
												onValueChange={(value) => setEndMonth(value)}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value={0}>Select</SelectItem>
													{months.map((month, index) => (
														<>
															<SelectItem value={index + 1}>{month}</SelectItem>
														</>
													))}
												</SelectContent>
											</Select>
										</div>
										<div className='flex flex-col'>
											<label className='form-label'>Start Year</label>
											<Select
												value={startYear}
												onValueChange={(value) => setStartYear(value)}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value={0}>Select</SelectItem>
													{years.map((year) => (
														<SelectItem
															key={year}
															value={year}
														>
															{year}
														</SelectItem>
													))}
												</SelectContent>
											</Select>
										</div>
										<div className='flex flex-col'>
											<label className='form-label'>End Year</label>
											<Select
												value={endYear}
												onValueChange={(value) => setEndYear(value)}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value={0}>Select</SelectItem>
													{years.map((year) => (
														<SelectItem
															key={year}
															value={year}
														>
															{year}
														</SelectItem>
													))}
												</SelectContent>
											</Select>
										</div>

										<div className='flex flex-col'>
											<label className='form-label'>View By</label>
											<Select
												value={viewBy}
												onValueChange={(value) => setViewBy(value)}
											>
												<SelectTrigger
													className='w-28'
													size='sm'
													style={{ height: '40px' }}
												>
													<SelectValue placeholder='Select' />
												</SelectTrigger>
												<SelectContent className='w-32'>
													<SelectItem value={0}>Month</SelectItem>
													<SelectItem value={1}>Year</SelectItem>
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
								{growthByPeriod.length ? (
									<DataGrid
										columns={columns}
										data={growthByPeriod}
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

export { GrowthByPeriod };
