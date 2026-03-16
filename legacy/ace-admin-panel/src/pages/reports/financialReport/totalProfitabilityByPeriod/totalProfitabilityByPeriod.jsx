/** @format */

import { Fragment, useEffect, useMemo, useState } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarPageTitle,
} from '@/partials/toolbar';
import { KeenIcon } from '@/components';
// import {
// 	Select,
// 	SelectContent,
// 	SelectItem,
// 	SelectTrigger,
// 	SelectValue,
// } from '@/components/ui/select';
// import { Container } from '@/components/container';
import {
	Popover,
	PopoverContent,
	PopoverTrigger,
} from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { addDays, format } from 'date-fns';
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
	refreshTotalProfitabilityByPeriod,
	setTotalProfitabilityByPeriod,
} from '../../../../slices/reportSlice';

function TotalProfitabilityByPeriod() {
	const dispatch = useDispatch();
	const { totalProfitabilityByPeriod } = useSelector((state) => state.reports);
	// const [searchInput, setSearchInput] = useState('');
	const [openDate, setOpenDate] = useState(false);
	const [date, setDate] = useState({
		from: new Date(),
		to: addDays(new Date(), 20),
	});
	const [tempRange, setTempRange] = useState(date);
	// const [scope, setScope] = useState(3);
	// const [period, setPeriod] = useState(0);
	console.log(totalProfitabilityByPeriod);
	useEffect(() => {
		if (openDate) {
			setTempRange({ from: null, to: null });
		}
	}, [openDate]);

	const handleDateSelect = (range) => {
		setTempRange(range);
		if (range?.from && range?.to) {
			setDate(range);
			setOpenDate(false);
		}
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
			refreshTotalProfitabilityByPeriod(
				format(new Date(date.from), "yyyy-MM-dd'T'00:00:00'Z'"),
				format(new Date(date.to), "yyyy-MM-dd'T'00:00:00'Z'")
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
				accessorKey: 'period',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Period</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.period ? row.original.period : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'commissionNet',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Comms. Net</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.commissionNet?.toFixed(2) || '0.00'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'salesTotal',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Sales Total</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.salesTotal?.toFixed(2) || '0.00'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'driverPayoutsTotal',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Driver Payouts Total</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.driverPayoutsTotal?.toFixed(2) || '0.00'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'staffPayoutsTotal',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Staff Payouts Total</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.staffPayoutsTotal?.toFixed(2) || '0.00'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'totalPayouts',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Total Payouts</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.totalPayouts?.toFixed(2) || '0.00'}
					</span>
				),
				meta: { headerClassName: 'min-w-[200px]' },
			},
			{
				accessorKey: 'margin',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Margin</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.margin?.toFixed(2) || '0.00'} %
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'totalProfit',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Total Profit</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						£{row.original.totalProfit?.toFixed(2) || '0.00'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
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

	useEffect(() => {
		return () => {
			dispatch(setTotalProfitabilityByPeriod([])); // Clear table data
		};
	}, [dispatch]);
	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {totalProfitabilityByPeriod?.length} Report(s){' '}
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
                                placeholder='Search Jobs'
                                value={searchInput}
                                onChange={(e) => setSearchInput(e.target.value)}
                            />
                        </label>
                    </div> */}
									<div className='flex flex-wrap items-center gap-2.5'>
										<div className='flex flex-col'>
											<label className='form-label'>Date Range</label>
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
										</div>

										{/* <div className='flex flex-col'>
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
                                </div> */}

										{/* <div className='flex flex-col'>
                                    <label className='form-label'>Period</label>
                                    <Select
                                        value={period}
                                        onValueChange={(value) => setPeriod(value)}
                                    >
                                        <SelectTrigger
                                            className='w-28'
                                            size='sm'
                                            style={{ height: '40px' }}
                                        >
                                            <SelectValue placeholder='Select' />
                                        </SelectTrigger>
                                        <SelectContent className='w-32'>
                                            <SelectItem value={0}>Hourly</SelectItem>
                                            <SelectItem value={1}>Daily</SelectItem>
                                            <SelectItem value={2}>Weekly</SelectItem>
                                            <SelectItem value={3}>Monthly</SelectItem>
                                            <SelectItem value={4}>Quaterly</SelectItem>
                                            <SelectItem value={5}>Yearly</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div> */}

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
								{totalProfitabilityByPeriod.length ? (
									<DataGrid
										columns={columns}
										data={totalProfitabilityByPeriod}
										rowSelection={true}
										onRowSelectionChange={handleRowSelection}
										pagination={{ size: 10 }}
										sorting={[{ id: 'period', desc: true }]}
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

export { TotalProfitabilityByPeriod };
