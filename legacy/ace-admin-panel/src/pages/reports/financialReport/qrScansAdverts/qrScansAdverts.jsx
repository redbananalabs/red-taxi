/** @format */

import { Fragment, useEffect, useMemo } from 'react';
import {
	Toolbar,
	ToolbarDescription,
	ToolbarHeading,
	ToolbarPageTitle,
} from '@/partials/toolbar';
// import { KeenIcon } from '@/components';
// import {
// 	Select,
// 	SelectContent,
// 	SelectItem,
// 	SelectTrigger,
// 	SelectValue,
// } from '@/components/ui/select';
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
import { Input } from '@/components/ui/input';
import { useDispatch, useSelector } from 'react-redux';
import {
	refreshQrScansAdverts,
    setQrScansAdverts,
} from '../../../../slices/reportSlice';

function QrScansAdverts() {
	const dispatch = useDispatch();
	const { qrScansAdverts } = useSelector((state) => state.reports);
	// const [searchInput, setSearchInput] = useState('');
	// const [openDate, setOpenDate] = useState(false);
	// const [date, setDate] = useState({
	// 	from: new Date(),
	// 	to: addDays(new Date(), 20),
	// });
	// const [tempRange, setTempRange] = useState(date);
	// const [scope, setScope] = useState(3);
	// const [period, setPeriod] = useState(0);
	console.log(qrScansAdverts);
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
			refreshQrScansAdverts()
		);
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

	const columns = useMemo(() => {
		let baseColumns = [
			
			{
				accessorKey: 'location',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Location</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.location ? row.original.location : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			{
				accessorKey: 'scanCount',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Scan Count</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.scanCount ? row.original.scanCount : '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
            {
				accessorKey: 'firstScan',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>First Scan</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.firstScan
							? new Date(row.original.firstScan).toLocaleDateString('en-GB')
							: '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
            {
				accessorKey: 'lastScan',
				header: ({ column }) => (
					<DataGridColumnHeader
						title=<span className='font-bold'>Last Scan</span>
						filter={<ColumnInputFilter column={column} />}
						column={column}
					/>
				),
				enableSorting: true,
				cell: ({ row }) => (
					<span className={`font-medium ${row.original.color}`}>
						{row.original.lastScan
							? new Date(row.original.lastScan).toLocaleDateString('en-GB')
							: '-'}
					</span>
				),
				meta: { headerClassName: 'min-w-[120px]' },
			},
			
		];

		return baseColumns;
	}, []);

	// const totalProfitOnInvoice = useMemo(() => {
	// 	return qrScansAdverts.reduce(
	// 		(totals, item) => {
	// 			totals.cost += item.cost || 0;
	// 			totals.profit += item.profit || 0;
	// 			totals.netTotal += item.netTotal || 0;
	// 			return totals;
	// 		},
	// 		{
	// 			cost: 0,
	// 			profit: 0,
	// 			netTotal: 0,
	// 		}
	// 	);
	// }, [qrScansAdverts]);

	const handleRowSelection = (state) => {
		const selectedRowIds = Object.keys(state);
		if (selectedRowIds.length > 0) {
			alert(`Selected Drivers: ${selectedRowIds.join(', ')}`);
		}
	};

	useEffect(() => {
		return () => {
			dispatch(setQrScansAdverts([])); // Clear table data
		};
	}, [dispatch]);
	return (
		<Fragment>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<Toolbar>
					<ToolbarHeading>
						<ToolbarPageTitle />
						<ToolbarDescription>
							Showing {qrScansAdverts?.length} Report(s){' '}
						</ToolbarDescription>
					</ToolbarHeading>
				</Toolbar>
			</div>
			<div className='pe-[1.875rem] ps-[1.875rem] ms-auto me-auto max-w-[1850px] w-full'>
				<div className='flex flex-col items-stretch gap-5 lg:gap-7.5'>
					<div className='flex flex-wrap items-center gap-5 justify-between'>
						<div className='card card-grid min-w-full'>
							{/* <div className='card-header flex-wrap gap-2'>
								<div className='flex flex-wrap gap-2 lg:gap-5'> */}
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
									{/* <div className='flex flex-wrap items-center gap-2.5'> */}
										{/* <div className='flex flex-col'>
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
										</div> */}

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
									{/* </div>
								</div>
							</div> */}
							<div className='card-body'>
								{qrScansAdverts.length > 0 ? (
									<>
										<DataGrid
											columns={columns}
											data={qrScansAdverts}
											rowSelection={true}
											onRowSelectionChange={handleRowSelection}
											pagination={{ size: 10 }}
											sorting={[{ id: 'date', desc: true }]}
											layout={{ card: true }}
										/>
										{/* <div className='flex justify-end gap-6 dark:bg-[#14151A] font-semibold p-3 mt-2'>
											<span className=''>
												Total Cost: £{totalProfitOnInvoice.cost.toFixed(2)}
											</span>
											<span className=''>
												Total Margin:{' '}
												{(
													(totalProfitOnInvoice.profit /
														totalProfitOnInvoice.netTotal) *
													100
												).toFixed(2)}{' '}
												%
											</span>
											<span className=''>
												Total Profit: £{totalProfitOnInvoice.profit?.toFixed(2)}
											</span>
											<span className=''>
												Total: £{totalProfitOnInvoice.netTotal?.toFixed(2)}
											</span>
										</div> */}
									</>
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

export { QrScansAdverts };
